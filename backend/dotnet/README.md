# IConstruction .NET Backend

Minimal ASP.NET Core 8 Web API wired to Oracle. Includes health, config, and stock endpoints. Loan/Return endpoints are implemented via PL/SQL wrappers that accept JSON arrays (`pkg_prestamos_api`, `pkg_devoluciones_api`).

## Configuración

Variables de entorno leídas por la API:
- ORACLE:USER
- ORACLE:PASSWORD
- ORACLE:CONNECTSTRING (ej: `localhost:1521/XEPDB1`)

En desarrollo, `launchSettings.json` ya define valores de ejemplo.

## Endpoints

- GET `/` → redirige a `/swagger`
- GET `/health`
- GET `/health/config`
- GET `/health/db` (requiere Oracle)
- GET `/health/user-tables` (requiere Oracle)
- GET `/health/all-tables` (requiere Oracle)
- POST `/auth/login` (JWT)
- POST `/auth/set-password` (JWT requerido)
- GET `/auth/me` (JWT requerido, política `AdminOnly`)
- GET `/stock/herramientas` (JWT)
- GET `/stock/materiales` (JWT)
- GET `/reportes/proyecto/{proyectoId}` (JWT)
- GET `/prestamos/detalle` (JWT)
- POST `/prestamos` (JWT, requiere `ops_api.sql`)
- POST `/prestamos/{prestamoId}/devoluciones` (JWT, requiere `ops_devolucion.sql` + `ops_api.sql`)

## Próximos pasos

- Revisar y aplicar los scripts de `db/oracle` en el orden indicado en su README.
- Ajustar CORS (`Program.cs`) según el origen del frontend.
- Configurar variables JWT en producción y cambiar la clave por defecto.
