using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.OpenApi.Models;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Oracle.ManagedDataAccess.Client;
using Microsoft.AspNetCore.Identity;
using System.Security.Cryptography;
using System.Linq;

var builder = WebApplication.CreateBuilder(args);

// Oracle connection string from environment variables
// ORACLE__USER, ORACLE__PASSWORD, ORACLE__CONNECTSTRING (e.g., HOST:1521/SERVICE)
var cfg = builder.Configuration;
cfg.AddEnvironmentVariables();

// Register a factory for OracleConnection (transient per request)
builder.Services.AddTransient(_ =>
{
    var user = cfg["ORACLE:USER"] ?? Environment.GetEnvironmentVariable("ORACLE__USER");
    var pwd = cfg["ORACLE:PASSWORD"] ?? Environment.GetEnvironmentVariable("ORACLE__PASSWORD");
    var dsn = cfg["ORACLE:CONNECTSTRING"] ?? Environment.GetEnvironmentVariable("ORACLE__CONNECTSTRING");
    var cs = new OracleConnectionStringBuilder
    {
        UserID = user,
        Password = pwd,
        DataSource = dsn,
        PersistSecurityInfo = true
    }.ToString();
    return new OracleConnection(cs);
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "IConstruction API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Description = "JWT Authorization header using the Bearer scheme. Example: 'Authorization: Bearer {token}'",
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            new string[]{}
        }
    });
});

// CORS: permitir Front local (ajusta orígenes según frontend)
builder.Services.AddCors(options =>
{
    options.AddPolicy("frontend", p =>
        p.WithOrigins("http://localhost:5173", "http://localhost:4200", "http://localhost:3000")
         .AllowAnyHeader()
         .AllowAnyMethod());
});

// JWT config (clave simple por entorno)
var jwtKey = cfg["JWT:KEY"] ?? Environment.GetEnvironmentVariable("JWT__KEY") ?? "dev-key-change-me";
var jwtIssuer = cfg["JWT:ISSUER"] ?? Environment.GetEnvironmentVariable("JWT__ISSUER") ?? "IConstruction";
var jwtAudience = cfg["JWT:AUDIENCE"] ?? Environment.GetEnvironmentVariable("JWT__AUDIENCE") ?? "IConstructionClients";
var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = signingKey,
            ClockSkew = TimeSpan.FromMinutes(2)
        };
    });
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireAssertion(ctx =>
            ctx.User.IsInRole("Administrador") ||
            ctx.User.Claims.Any(c => c.Type == ClaimTypes.Role && c.Value == "1") ||
            ctx.User.Claims.Any(c => c.Type == "role_id" && c.Value == "1")
        )
    );
});

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "IConstruction API v1");
});

// Serve static files from wwwroot (frontend pages)
app.UseStaticFiles();
app.UseCors("frontend");

// Global error handling
app.Use(async (context, next) =>
{
    try
    {
        await next();
    }
    catch (Exception ex)
    {
        int status = 500;
        string title = "Error interno del servidor";
        string detail = ex.Message;

        if (ex is OracleException oex)
        {
            // ORA-01017: invalid username/password
            if (oex.Number == 1017)
            {
                status = 401;
                title = "Credenciales de base de datos inválidas";
            }
            // Unique constraint / FK / check constraint
            else if (oex.Number is 1 or 2291 or 2292 or 1400)
            {
                status = 409;
                title = "Conflicto de datos en base de datos";
            }
        }

        context.Response.StatusCode = status;
        await context.Response.WriteAsJsonAsync(new
        {
            title,
            detail,
            status,
            traceId = context.TraceIdentifier
        });
    }
});

app.UseAuthentication();
app.UseAuthorization();

app.MapGet("/health", () => Results.Ok(new { ok = true }));

// DB health: muestra usuario y contenedor actuales
app.MapGet("/health/db", async (OracleConnection conn) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        using var cmd = new OracleCommand("SELECT sys_context('userenv','session_user') AS usuario, sys_context('userenv','con_name') AS contenedor FROM dual", conn);
        using var rdr = await cmd.ExecuteReaderAsync();
        await rdr.ReadAsync();
        return Results.Ok(new { usuario = rdr.GetString(0), contenedor = rdr.GetString(1) });
    }
}).AllowAnonymous();

// Config health (no DB): muestra variables ORACLE leídas por la API
app.MapGet("/health/config", () =>
{
    return Results.Ok(new
    {
        oracle_user = cfg["ORACLE:USER"],
        oracle_connect = cfg["ORACLE:CONNECTSTRING"],
        jwt_issuer = cfg["JWT:ISSUER"],
        jwt_audience = cfg["JWT:AUDIENCE"]
    });
}).AllowAnonymous();

// TEMP: Lista tablas del usuario actual (para diagnosticar ORA-00942)
app.MapGet("/health/user-tables", async (OracleConnection conn) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        using var cmd = new OracleCommand("SELECT table_name FROM user_tables ORDER BY table_name", conn);
        using var rdr = await cmd.ExecuteReaderAsync();
        var list = new List<string>();
        while (await rdr.ReadAsync())
        {
            list.Add(rdr.GetString(0));
        }
        return Results.Ok(list);
    }
}).AllowAnonymous();

// TEMP: Lista tablas accesibles relevantes (USUARIO, USUARIO_ROL)
app.MapGet("/health/all-tables", async (OracleConnection conn) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        using var cmd = new OracleCommand(@"SELECT owner, table_name
                                           FROM all_tables
                                           WHERE table_name IN ('USUARIO','USUARIO_ROL')
                                           ORDER BY owner, table_name", conn);
        using var rdr = await cmd.ExecuteReaderAsync();
        var list = new List<object>();
        while (await rdr.ReadAsync())
        {
            list.Add(new { owner = rdr.GetString(0), table = rdr.GetString(1) });
        }
        return Results.Ok(list);
    }
}).AllowAnonymous();

// Información del usuario actual desde el token
app.MapGet("/auth/me", (ClaimsPrincipal user) =>
{
    var id = user.FindFirstValue(JwtRegisteredClaimNames.Sub);
    var name = user.FindFirstValue(ClaimTypes.Name);
    var role = user.FindFirstValue(ClaimTypes.Role);
    var roleId = user.Claims.FirstOrDefault(c => c.Type == "role_id")?.Value;
    return Results.Ok(new { id, nombre = name, rol = role, rol_id = roleId });
}).RequireAuthorization("AdminOnly");

// Optional: establecer/actualizar contraseña (admin use). Provide userId + new password.
app.MapPost("/auth/set-password", async (OracleConnection conn, SetPasswordRequest req) =>
{
    var hasher = new PasswordHasher<string>();
    var hash = hasher.HashPassword(null!, req.nueva_password);
    await using (conn)
    {
        await conn.OpenAsync();
        using var cmd = new OracleCommand("UPDATE usuario SET password = :p_hash WHERE id = :p_id", conn) { BindByName = true };
        cmd.Parameters.Add(new OracleParameter("p_hash", hash));
        cmd.Parameters.Add(new OracleParameter("p_id", req.usuario_id));
        var rows = await cmd.ExecuteNonQueryAsync();
        return rows == 1 ? Results.NoContent() : Results.NotFound();
    }
}).RequireAuthorization();

// Login simple (demo): busca usuario por correo y password plano
app.MapPost("/auth/login", async (OracleConnection conn, LoginRequest req) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        // 1) Traer usuario por correo (y activo)
    using var cmd = new OracleCommand(@"SELECT u.id, u.nombre, u.usuario_rol_id, u.password, COALESCE(r.nombre,'') AS rol_nombre
                       FROM usuario u LEFT JOIN usuario_rol r ON r.id = u.usuario_rol_id
                       WHERE u.correo = :p_correo AND u.activo = 'S'", conn);
        cmd.Parameters.Add(new OracleParameter("p_correo", req.correo));
        using var rdr = await cmd.ExecuteReaderAsync();
        if (!await rdr.ReadAsync()) return Results.Unauthorized();

        var userId = Convert.ToInt32(rdr.GetValue(0));
        var name = rdr.GetString(1);
        var roleId = Convert.ToInt32(rdr.GetValue(2));
    var storedPassword = rdr.IsDBNull(3) ? string.Empty : rdr.GetString(3);
    var roleName = rdr.IsDBNull(4) ? string.Empty : rdr.GetString(4);

        // 2) Verificar contraseña con hasher de Identity (PBKDF2) o aceptar legacy plano y migrar
        var hasher = new PasswordHasher<string>();
        bool authenticated = false;
        bool needsUpgrade = false;

        // Intentar verificar como hash de Identity primero
        if (!string.IsNullOrEmpty(storedPassword) && storedPassword.StartsWith("AQAAAA", StringComparison.Ordinal))
        {
            var result = hasher.VerifyHashedPassword(null!, storedPassword, req.password);
            authenticated = result == PasswordVerificationResult.Success || result == PasswordVerificationResult.SuccessRehashNeeded;
            needsUpgrade = result == PasswordVerificationResult.SuccessRehashNeeded;
        }
        else
        {
            // Legacy options:
            // a) Texto plano
            // b) SHA-256 en HEX (RAWTOHEX(STANDARD_HASH(...,'SHA256')))
            var sha256Hex = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(req.password))); // UPPER HEX
            authenticated = string.Equals(storedPassword, req.password, StringComparison.Ordinal)
                            || string.Equals(storedPassword, sha256Hex, StringComparison.OrdinalIgnoreCase);
            needsUpgrade = authenticated; // migraremos a Identity hash si autenticó
        }

        if (!authenticated) return Results.Unauthorized();

        // 3) Si requiere upgrade, re-hashear y guardar
        if (needsUpgrade)
        {
            var newHash = hasher.HashPassword(null!, req.password);
            using var up = new OracleCommand("UPDATE usuario SET password = :p_hash WHERE id = :p_id", conn) { BindByName = true };
            up.Parameters.Add(new OracleParameter("p_hash", newHash));
            up.Parameters.Add(new OracleParameter("p_id", userId));
            await up.ExecuteNonQueryAsync();
        }

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, userId.ToString()),
            new Claim(ClaimTypes.Name, name),
            new Claim(ClaimTypes.Role, string.IsNullOrWhiteSpace(roleName) ? roleId.ToString() : roleName),
            new Claim("role_id", roleId.ToString())
        };
        var creds = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            issuer: jwtIssuer,
            audience: jwtAudience,
            claims: claims,
            expires: DateTime.UtcNow.AddHours(8),
            signingCredentials: creds);
        var tokenStr = new JwtSecurityTokenHandler().WriteToken(token);

    return Results.Ok(new { token = tokenStr, user = new { id = userId, nombre = name, rol = string.IsNullOrWhiteSpace(roleName) ? roleId.ToString() : roleName, rol_id = roleId } });
    }
}).AllowAnonymous();

// Stock vistas
app.MapGet("/stock/herramientas", async (OracleConnection conn, int? bodega_id) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        var sql = "SELECT bodega_id, bodega, herramienta_id, herramienta, cantidad FROM vw_stock_herramienta_por_bodega" + (bodega_id.HasValue ? " WHERE bodega_id = :p_bodega_id" : string.Empty);
        using var cmd = new OracleCommand(sql, conn);
        if (bodega_id.HasValue)
            cmd.Parameters.Add(new OracleParameter("p_bodega_id", bodega_id.Value));
        using var rdr = await cmd.ExecuteReaderAsync();
        var list = new List<object>();
        while (await rdr.ReadAsync())
        {
            list.Add(new
            {
                bodega_id = Convert.ToInt32(rdr.GetValue(0)),
                bodega = rdr.GetString(1),
                herramienta_id = Convert.ToInt32(rdr.GetValue(2)),
                herramienta = rdr.GetString(3),
                cantidad = rdr.IsDBNull(4) ? 0 : Convert.ToInt32(rdr.GetValue(4))
            });
        }
        return Results.Ok(list);
    }
}).RequireAuthorization();

app.MapGet("/stock/materiales", async (OracleConnection conn, int? bodega_id) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        var sql = "SELECT bodega_id, bodega, material_id, material, cantidad FROM vw_stock_material_por_bodega" + (bodega_id.HasValue ? " WHERE bodega_id = :p_bodega_id" : string.Empty);
        using var cmd = new OracleCommand(sql, conn);
        if (bodega_id.HasValue)
            cmd.Parameters.Add(new OracleParameter("p_bodega_id", bodega_id.Value));
        using var rdr = await cmd.ExecuteReaderAsync();
        var list = new List<object>();
        while (await rdr.ReadAsync())
        {
            list.Add(new
            {
                bodega_id = Convert.ToInt32(rdr.GetValue(0)),
                bodega = rdr.GetString(1),
                material_id = Convert.ToInt32(rdr.GetValue(2)),
                material = rdr.GetString(3),
                cantidad = rdr.IsDBNull(4) ? 0 : Convert.ToInt32(rdr.GetValue(4))
            });
        }
        return Results.Ok(list);
    }
}).RequireAuthorization();

// Prestamo: llama a pkg_prestamos.crear_prestamo
app.MapPost("/prestamos", async (OracleConnection conn, PrestamoRequest req) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "BEGIN pkg_prestamos_api.crear_prestamo_json(:p_obrero_id, :p_bodeguero_id, :p_bodega_id, :p_fecha_compromiso, :p_detalle_json, :p_prestamo_id); END;";
        cmd.BindByName = true;

        cmd.Parameters.Add(new OracleParameter("p_obrero_id", req.obrero_id));
        cmd.Parameters.Add(new OracleParameter("p_bodeguero_id", req.bodeguero_id));
        cmd.Parameters.Add(new OracleParameter("p_bodega_id", req.bodega_id));
        cmd.Parameters.Add(new OracleParameter("p_fecha_compromiso", req.fecha_compromiso));

        var detalleJson = System.Text.Json.JsonSerializer.Serialize(req.detalle);
        cmd.Parameters.Add(new OracleParameter("p_detalle_json", OracleDbType.Clob) { Value = detalleJson });

        var outId = new OracleParameter("p_prestamo_id", OracleDbType.Decimal) { Direction = System.Data.ParameterDirection.Output };
        cmd.Parameters.Add(outId);

        await cmd.ExecuteNonQueryAsync();
        var newId = Convert.ToInt32(outId.Value?.ToString());
        return Results.Created($"/prestamos/{newId}", new { id = newId });
    }
}).RequireAuthorization();

// Reportes por proyecto
app.MapGet("/reportes/proyecto/{proyectoId:int}", async (int proyectoId, OracleConnection conn) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        using var cmd = new OracleCommand(@"SELECT id, fecha, activo, proyecto_id, proyecto, supervisor_obra_id, supervisor, titulo, tipo
                                           FROM vw_reportes_por_proyecto WHERE proyecto_id = :p_proyecto_id", conn);
        cmd.Parameters.Add(new OracleParameter("p_proyecto_id", proyectoId));
        using var rdr = await cmd.ExecuteReaderAsync();
        var list = new List<object>();
        while (await rdr.ReadAsync())
        {
            list.Add(new
            {
                id = Convert.ToInt32(rdr.GetValue(0)),
                fecha = rdr.GetDateTime(1),
                activo = rdr.GetString(2),
                proyecto_id = Convert.ToInt32(rdr.GetValue(3)),
                proyecto = rdr.GetString(4),
                supervisor_obra_id = rdr.IsDBNull(5) ? (int?)null : Convert.ToInt32(rdr.GetValue(5)),
                supervisor = rdr.IsDBNull(6) ? null : rdr.GetString(6),
                titulo = rdr.IsDBNull(7) ? null : rdr.GetString(7),
                tipo = rdr.IsDBNull(8) ? null : rdr.GetString(8)
            });
        }
        return Results.Ok(list);
    }
}).RequireAuthorization();

// Prestamos detalle (filtros opcionales)
app.MapGet("/prestamos/detalle", async (OracleConnection conn, int? prestamo_id, int? obrero_id, int? bodeguero_id) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        var sql = @"SELECT prestamo_id, fecha_prestamo, fecha_compromiso, estado, obrero_id, obrero_nombre, bodeguero_id, bodeguero_nombre, bodega_id, bodega, herramienta_id, herramienta, cantidad, fecha_devolucion
                    FROM vw_prestamos_detalle WHERE 1=1";
        if (prestamo_id.HasValue) sql += " AND prestamo_id = :p_prestamo_id";
        if (obrero_id.HasValue) sql += " AND obrero_id = :p_obrero_id";
        if (bodeguero_id.HasValue) sql += " AND bodeguero_id = :p_bodeguero_id";
        using var cmd = new OracleCommand(sql, conn) { BindByName = true };
        if (prestamo_id.HasValue) cmd.Parameters.Add(new OracleParameter("p_prestamo_id", prestamo_id.Value));
        if (obrero_id.HasValue) cmd.Parameters.Add(new OracleParameter("p_obrero_id", obrero_id.Value));
        if (bodeguero_id.HasValue) cmd.Parameters.Add(new OracleParameter("p_bodeguero_id", bodeguero_id.Value));
        using var rdr = await cmd.ExecuteReaderAsync();
        var list = new List<object>();
        while (await rdr.ReadAsync())
        {
            list.Add(new
            {
                prestamo_id = Convert.ToInt32(rdr.GetValue(0)),
                fecha_prestamo = rdr.GetDateTime(1),
                fecha_compromiso = rdr.GetDateTime(2),
                estado = rdr.GetString(3),
                obrero_id = Convert.ToInt32(rdr.GetValue(4)),
                obrero_nombre = rdr.GetString(5),
                bodeguero_id = Convert.ToInt32(rdr.GetValue(6)),
                bodeguero_nombre = rdr.GetString(7),
                bodega_id = rdr.IsDBNull(8) ? (int?)null : Convert.ToInt32(rdr.GetValue(8)),
                bodega = rdr.IsDBNull(9) ? null : rdr.GetString(9),
                herramienta_id = Convert.ToInt32(rdr.GetValue(10)),
                herramienta = rdr.GetString(11),
                cantidad = Convert.ToInt32(rdr.GetValue(12)),
                fecha_devolucion = rdr.IsDBNull(13) ? (DateTime?)null : rdr.GetDateTime(13)
            });
        }
        return Results.Ok(list);
    }
}).RequireAuthorization();

// Catálogos básicos
app.MapGet("/catalogos/bodegas", async (OracleConnection conn) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        using var cmd = new OracleCommand("SELECT id, nombre FROM bodega ORDER BY nombre", conn);
        using var rdr = await cmd.ExecuteReaderAsync();
        var list = new List<object>();
        while (await rdr.ReadAsync())
        {
            list.Add(new { id = Convert.ToInt32(rdr.GetValue(0)), nombre = rdr.GetString(1) });
        }
        return Results.Ok(list);
    }
}).RequireAuthorization();

app.MapGet("/catalogos/herramientas", async (OracleConnection conn) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        using var cmd = new OracleCommand("SELECT id, nombre FROM herramienta ORDER BY nombre", conn);
        using var rdr = await cmd.ExecuteReaderAsync();
        var list = new List<object>();
        while (await rdr.ReadAsync())
        {
            list.Add(new { id = Convert.ToInt32(rdr.GetValue(0)), nombre = rdr.GetString(1) });
        }
        return Results.Ok(list);
    }
}).RequireAuthorization();

app.MapGet("/catalogos/obreros", async (OracleConnection conn) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        using var cmd = new OracleCommand(@"SELECT o.id, u.nombre
                                           FROM obrero o JOIN usuario u ON u.id = o.usuario_id
                                           ORDER BY u.nombre", conn);
        using var rdr = await cmd.ExecuteReaderAsync();
        var list = new List<object>();
        while (await rdr.ReadAsync())
        {
            list.Add(new { id = Convert.ToInt32(rdr.GetValue(0)), nombre = rdr.GetString(1) });
        }
        return Results.Ok(list);
    }
}).RequireAuthorization();
// Root endpoint -> redirect to Swagger UI for convenience
app.MapGet("/", () => Results.Redirect("/swagger", permanent: false)).AllowAnonymous();
// Devolución
app.MapPost("/prestamos/{prestamoId:int}/devoluciones", async (int prestamoId, OracleConnection conn, DevolucionRequest req) =>
{
    await using (conn)
    {
        await conn.OpenAsync();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "BEGIN pkg_devoluciones_api.devolver_json(:p_prestamo_id, :p_bodega_id, :p_detalle_json); END;";
        cmd.BindByName = true;
        cmd.Parameters.Add(new OracleParameter("p_prestamo_id", prestamoId));
        cmd.Parameters.Add(new OracleParameter("p_bodega_id", req.bodega_id));
        var detalleJson = System.Text.Json.JsonSerializer.Serialize(req.detalle);
        cmd.Parameters.Add(new OracleParameter("p_detalle_json", OracleDbType.Clob) { Value = detalleJson });
        await cmd.ExecuteNonQueryAsync();
        return Results.NoContent();
    }
}).RequireAuthorization();

app.Run();

public record PrestamoDetalle(int herramienta_id, int cantidad);
public record PrestamoRequest(int obrero_id, int bodeguero_id, int bodega_id, DateTime fecha_compromiso, List<PrestamoDetalle> detalle);

public record DevolucionDetalle(int herramienta_id, int cantidad);
public record DevolucionRequest(int bodega_id, List<DevolucionDetalle> detalle);
public record LoginRequest(string correo, string password);
public record SetPasswordRequest(int usuario_id, string nueva_password);
