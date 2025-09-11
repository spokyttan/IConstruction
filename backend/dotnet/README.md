# IConstruction .NET Backend

Minimal ASP.NET Core 8 Web API wired to Oracle. Includes health and stock endpoints. Loan/Return endpoints are scaffolded (501) until a small PL/SQL wrapper is added to accept JSON arrays.

## Configuración

Variables de entorno leídas por la API:
- ORACLE:USER
- ORACLE:PASSWORD
- ORACLE:CONNECTSTRING (ej: `localhost:1521/XEPDB1`)

En desarrollo, `launchSettings.json` ya define valores de ejemplo.

## Endpoints

- GET /health
- GET /stock/herramientas
- GET /stock/materiales
- POST /prestamos (501 por ahora)
- POST /prestamos/{prestamoId}/devoluciones (501 por ahora)

## Próximos pasos

- Agregar un wrapper PL/SQL que parsee JSON a tipos/tabla y llamar desde .NET con un solo parámetro CLOB.
- Exponer endpoints de reportes usando las vistas creadas.
- Autenticación básica (JWT) y roles.
