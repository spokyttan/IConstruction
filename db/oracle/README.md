# IConstruction Oracle schema

This folder contains an Oracle SQL script (`schema.sql`) generated from your `modelo_v1` (Oracle SQL Developer Data Modeler) engineered model.

## What’s inside
- Lookup tables: `usuario_estado`, `usuario_rol`, `bodeguero_cargo`, `bodeguero_turno`, `prestamo_estado`, `proyecto_tipo`, `herramienta_*`, `material_*`, `bodega_*`.
- Core tables: `usuario`, `bodega`, `material`, `herramienta`.
- Associations/ops: `bodega_material`, `bodegas_herramientas`, `supervisor_obra`, `obrero`, `bodeguero`, `proyecto`, `proyecto_actividad`, `reporte`, `prestamo`.

IDs are `NUMBER(8)` without identity/sequence; adjust to your key strategy if needed.

## How to run (SQL Developer / SQLcl)
1. Open SQL Developer, connect to your Oracle schema (with privileges to create tables).
2. Run the scripts in this recommended order:

```sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/schema.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/proposals.sql  -- optional but recommended
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/sequences.sql  -- sequences + triggers for IDs
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/indexes.sql    -- performance indexes
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/triggers.sql   -- stock maintenance
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/views.sql      -- reporting views
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/ops.sql        -- create loan
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/ops_devolucion.sql -- return loan
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/ops_api.sql    -- JSON API wrappers
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/auth_seed.sql  -- seed usuarios para login
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/sample_data.sql -- sample data
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/dev_setup.sql  -- dev helpers for demo préstamo
```

If you prefer SQLcl:
```sql
sql system@//host:1521/service
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/schema.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/proposals.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/sequences.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/indexes.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/triggers.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/views.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/ops.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/ops_devolucion.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/ops_api.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/auth_seed.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/sample_data.sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/dev_setup.sql
```

## Optional improvements
There’s an additional script `proposals.sql` with recommended constraints and structures for production use:
- Check constraints for boolean `activo`.
- Unique constraints for `usuario` (`correo`, `rut`).
- Stock quantities and a normalized préstamo (cabecera/detalle).
- Longer password hashes and richer `reporte` fields.
- Inventory movement log (kardex).

Run it after `schema.sql` if it fits your business rules:
```sql
@c:/Users/natta/OneDrive - INACAP/Documentos/IConstruction/db/oracle/proposals.sql
```

## Notes
- Foreign keys mirror the engineered model; ON DELETE behavior is default (NO ACTION). Update if your business rules require CASCADE/SET NULL.
- Unique indexes from model: `supervisor_obra__IDX` (usuario_id), `obrero__IDX`, `bodeguero__IDX`/`__IDXv1`. Drop/adjust if your business rules differ.
- Sample data is minimal for dev; expand as needed.
