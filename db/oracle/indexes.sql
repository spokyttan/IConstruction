-- Foreign key and lookup indexes for performance
-- Run after schema.sql and proposals.sql

-- usuario
CREATE INDEX usuario_estado_idx ON usuario(usuario_estado_id);
CREATE INDEX usuario_rol_idx    ON usuario(usuario_rol_id);

-- bodega
CREATE INDEX bodega_ubicacion_idx ON bodega(bodega_ubicacion_id);
CREATE INDEX bodega_tipo_idx      ON bodega(bodega_tipo_id);

-- material
CREATE INDEX material_categoria_idx ON material(material_categoria_id);
CREATE INDEX material_marca_idx     ON material(material_marca_id);
CREATE INDEX material_tipo_idx      ON material(material_tipo_id);

-- herramienta
CREATE INDEX herramienta_categoria_idx ON herramienta(herramienta_categoria_id);
CREATE INDEX herramienta_ubicacion_idx ON herramienta(herramienta_ubicacion_id);
CREATE INDEX herramienta_marca_idx     ON herramienta(herramienta_marca_id);
CREATE INDEX herramienta_tipo_idx      ON herramienta(herramienta_tipo_id);

-- obrero
CREATE INDEX obrero_cargo_idx          ON obrero(bodeguero_cargo_id);
CREATE INDEX obrero_prestamo_estado_idx ON obrero(prestamo_estado_id);
CREATE INDEX obrero_usuario_idx        ON obrero(usuario_id);

-- bodeguero
CREATE INDEX bodeguero_turno_idx  ON bodeguero(bodeguero_turno_id);
CREATE INDEX bodeguero_usuario_idx ON bodeguero(usuario_id);
CREATE INDEX bodeguero_bodega_idx  ON bodeguero(bodega_id);

-- proyecto / actividad / reporte
CREATE INDEX proyecto_tipo_idx       ON proyecto(proyecto_tipo_id);
CREATE INDEX proyecto_actividad_proj_idx ON proyecto_actividad(proyecto_id);
CREATE INDEX reporte_supervisor_idx  ON reporte(supervisor_obra_id);
CREATE INDEX reporte_proyecto_idx    ON reporte(proyecto_id);

-- prestamo (PK already covers both columns)

-- proposals tables
CREATE INDEX prestamo_cabecera_obrero_idx    ON prestamo_cabecera(obrero_id);
CREATE INDEX prestamo_cabecera_bodeguero_idx ON prestamo_cabecera(bodeguero_id);
CREATE INDEX prestamo_cabecera_bodega_idx    ON prestamo_cabecera(bodega_id);
CREATE INDEX prestamo_cabecera_estado_idx    ON prestamo_cabecera(estado_id);

CREATE INDEX prestamo_detalle_prestamo_idx   ON prestamo_detalle(prestamo_id);
CREATE INDEX prestamo_detalle_herramienta_idx ON prestamo_detalle(herramienta_id);

CREATE INDEX movinv_bodega_idx      ON movimiento_inventario(bodega_id);
CREATE INDEX movinv_material_idx    ON movimiento_inventario(material_id);
CREATE INDEX movinv_herramienta_idx ON movimiento_inventario(herramienta_id);
CREATE INDEX movinv_usuario_idx     ON movimiento_inventario(usuario_id);
