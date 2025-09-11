-- Useful reporting views for ICONSTRUCTION
-- Run after schema.sql and proposals.sql

CREATE OR REPLACE VIEW vw_stock_material_por_bodega AS
SELECT b.id AS bodega_id,
       b.nombre AS bodega,
       m.id AS material_id,
       m.nombre AS material,
       NVL(bm.cantidad, 0) AS cantidad
FROM bodega b
LEFT JOIN bodega_material bm ON bm.bodega_id = b.id
LEFT JOIN material m ON m.id = bm.material_id;

CREATE OR REPLACE VIEW vw_stock_herramienta_por_bodega AS
SELECT b.id AS bodega_id,
       b.nombre AS bodega,
       h.id AS herramienta_id,
       h.nombre AS herramienta,
       NVL(bh.cantidad, 0) AS cantidad
FROM bodega b
LEFT JOIN bodegas_herramientas bh ON bh.bodega_id = b.id
LEFT JOIN herramienta h ON h.id = bh.herramienta_id;

CREATE OR REPLACE VIEW vw_reportes_por_proyecto AS
SELECT r.id, r.fecha, r.activo, r.proyecto_id, p.nombre AS proyecto,
       r.supervisor_obra_id, so.nombre AS supervisor,
       r.titulo, r.tipo
FROM reporte r
JOIN proyecto p ON p.id = r.proyecto_id
LEFT JOIN supervisor_obra so ON so.id = r.supervisor_obra_id;

CREATE OR REPLACE VIEW vw_prestamos_detalle AS
SELECT pc.id AS prestamo_id,
       pc.fecha_prestamo,
       pc.fecha_compromiso,
       pe.nombre AS estado,
       o.id AS obrero_id,
       uo.nombre AS obrero_nombre,
       bg.id AS bodeguero_id,
       ub.nombre AS bodeguero_nombre,
       b.id AS bodega_id,
       b.nombre AS bodega,
       pd.herramienta_id,
       h.nombre AS herramienta,
       pd.cantidad,
       pd.fecha_devolucion
FROM prestamo_cabecera pc
JOIN prestamo_estado pe ON pe.id = pc.estado_id
JOIN obrero o ON o.id = pc.obrero_id
JOIN usuario uo ON uo.id = o.usuario_id
JOIN bodeguero bg ON bg.id = pc.bodeguero_id
JOIN usuario ub ON ub.id = bg.usuario_id
LEFT JOIN bodega b ON b.id = pc.bodega_id
JOIN prestamo_detalle pd ON pd.prestamo_id = pc.id
JOIN herramienta h ON h.id = pd.herramienta_id;
