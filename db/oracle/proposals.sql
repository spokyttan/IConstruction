-- Optional improvements for ICONSTRUCTION schema (Oracle)
-- Apply only if they match your business rules. Run after schema.sql

-- 1) Enforce boolean semantics for 'activo'
ALTER TABLE usuario_estado      ADD CONSTRAINT usuario_estado_activo_chk      CHECK (activo IN ('S','N'));
ALTER TABLE usuario_rol         ADD CONSTRAINT usuario_rol_activo_chk         CHECK (activo IN ('S','N'));
ALTER TABLE bodeguero_cargo     ADD CONSTRAINT bodeguero_cargo_activo_chk     CHECK (activo IN ('S','N'));
ALTER TABLE bodeguero_turno     ADD CONSTRAINT bodeguero_turno_activo_chk     CHECK (activo IN ('S','N'));
ALTER TABLE prestamo_estado     ADD CONSTRAINT prestamo_estado_activo_chk     CHECK (activo IN ('S','N'));
ALTER TABLE proyecto_tipo       ADD CONSTRAINT proyecto_tipo_activo_chk       CHECK (activo IN ('S','N'));
ALTER TABLE herramienta_categoria ADD CONSTRAINT herramienta_categoria_activo_chk CHECK (activo IN ('S','N'));
ALTER TABLE herramienta_marca   ADD CONSTRAINT herramienta_marca_activo_chk   CHECK (activo IN ('S','N'));
ALTER TABLE herramienta_tipo    ADD CONSTRAINT herramienta_tipo_activo_chk    CHECK (activo IN ('S','N'));
ALTER TABLE herramienta_ubicacion ADD CONSTRAINT herramienta_ubicacion_activo_chk CHECK (activo IN ('S','N'));
ALTER TABLE material_marca      ADD CONSTRAINT material_marca_activo_chk      CHECK (activo IN ('S','N'));
ALTER TABLE material_tipo       ADD CONSTRAINT material_tipo_activo_chk       CHECK (activo IN ('S','N'));
ALTER TABLE material_categoria  ADD CONSTRAINT material_categoria_activo_chk  CHECK (activo IN ('S','N'));
ALTER TABLE bodega_tipo         ADD CONSTRAINT bodega_tipo_activo_chk         CHECK (activo IN ('S','N'));
ALTER TABLE bodega_ubicacion    ADD CONSTRAINT bodega_ubicacion_activo_chk    CHECK (activo IN ('S','N'));
ALTER TABLE usuario             ADD CONSTRAINT usuario_activo_chk             CHECK (activo IN ('S','N'));
ALTER TABLE bodega              ADD CONSTRAINT bodega_activo_chk              CHECK (activo IN ('S','N'));
ALTER TABLE material            ADD CONSTRAINT material_activo_chk            CHECK (activo IN ('S','N'));
ALTER TABLE herramienta         ADD CONSTRAINT herramienta_activo_chk         CHECK (activo IN ('S','N'));
ALTER TABLE proyecto            ADD CONSTRAINT proyecto_activo_chk            CHECK (activo IN ('S','N'));
ALTER TABLE proyecto_actividad  ADD CONSTRAINT proyecto_actividad_activo_chk  CHECK (activo IN ('S','N'));
ALTER TABLE reporte             ADD CONSTRAINT reporte_activo_chk             CHECK (activo IN ('S','N'));
ALTER TABLE obrero              ADD CONSTRAINT obrero_activo_chk              CHECK (activo IN ('S','N'));
ALTER TABLE bodeguero           ADD CONSTRAINT bodeguero_activo_chk           CHECK (activo IN ('S','N'));

-- 2) Unique constraints to avoid duplicates
ALTER TABLE usuario ADD CONSTRAINT usuario_correo_uk UNIQUE (correo);
ALTER TABLE usuario ADD CONSTRAINT usuario_rut_uk    UNIQUE (rut);

-- 3) Inventory quantities
-- Materials: add stock quantity per bodega-material
ALTER TABLE bodega_material ADD (cantidad NUMBER(8) DEFAULT 0 NOT NULL);

-- 4) Loan/return model: introduce header/detail and move status to the loan
-- Keep existing 'prestamo' as legacy; new normalized structure below
CREATE TABLE prestamo_cabecera (
  id               NUMBER(8) PRIMARY KEY,
  obrero_id        NUMBER(8) NOT NULL,
  bodeguero_id     NUMBER(8) NOT NULL,
  bodega_id        NUMBER(8),
  fecha_prestamo   DATE      DEFAULT SYSDATE,
  fecha_compromiso DATE,
  estado_id        NUMBER(8) NOT NULL,
  observacion      VARCHAR2(255),
  CONSTRAINT prestamo_cabecera_obrero_fk    FOREIGN KEY (obrero_id)    REFERENCES obrero(id),
  CONSTRAINT prestamo_cabecera_bodeguero_fk FOREIGN KEY (bodeguero_id) REFERENCES bodeguero(id),
  CONSTRAINT prestamo_cabecera_bodega_fk    FOREIGN KEY (bodega_id)    REFERENCES bodega(id),
  CONSTRAINT prestamo_cabecera_estado_fk    FOREIGN KEY (estado_id)    REFERENCES prestamo_estado(id)
);

CREATE TABLE prestamo_detalle (
  id               NUMBER(8) PRIMARY KEY,
  prestamo_id      NUMBER(8) NOT NULL,
  herramienta_id   NUMBER(8) NOT NULL,
  cantidad         NUMBER(8) NOT NULL,
  fecha_devolucion DATE,
  observacion      VARCHAR2(255),
  CONSTRAINT prestamo_detalle_prestamo_fk    FOREIGN KEY (prestamo_id)    REFERENCES prestamo_cabecera(id),
  CONSTRAINT prestamo_detalle_herramienta_fk FOREIGN KEY (herramienta_id) REFERENCES herramienta(id)
);

-- Optional: remove the incorrect link from obrero to prestamo_estado
-- (each loan has its own status; not the worker)
-- ALTER TABLE obrero DROP CONSTRAINT obrero_prestamo_estado_FK;
-- ALTER TABLE obrero DROP COLUMN prestamo_estado_id;

-- 5) Reporting: enrich report content and authorship
ALTER TABLE reporte ADD (
  titulo      VARCHAR2(100),
  tipo        VARCHAR2(30),
  contenido   CLOB,
  creado_por  NUMBER(8)
);
ALTER TABLE reporte ADD CONSTRAINT reporte_creado_por_fk FOREIGN KEY (creado_por) REFERENCES usuario(id);

-- 6) Security: allow longer password hashes
ALTER TABLE usuario MODIFY password VARCHAR2(255);

-- 7) Optional: relax one-bodeguero-per-bodega restriction
-- If you need multiple storekeepers per warehouse, drop the unique index below
-- DROP INDEX bodeguero__IDXv1;

-- 8) Movement log (kardex) to audit stock changes for both materials and tools
CREATE TABLE movimiento_inventario (
  id             NUMBER(8) PRIMARY KEY,
  fecha          DATE DEFAULT SYSDATE,
  tipo           VARCHAR2(20) NOT NULL, -- INGRESO, EGRESO, PRESTAMO, DEVOLUCION, AJUSTE
  bodega_id      NUMBER(8) NOT NULL,
  material_id    NUMBER(8),
  herramienta_id NUMBER(8),
  cantidad       NUMBER(8) NOT NULL,
  referencia     VARCHAR2(100),
  usuario_id     NUMBER(8),
  CONSTRAINT movinv_bodega_fk      FOREIGN KEY (bodega_id)      REFERENCES bodega(id),
  CONSTRAINT movinv_material_fk    FOREIGN KEY (material_id)    REFERENCES material(id),
  CONSTRAINT movinv_herramienta_fk FOREIGN KEY (herramienta_id) REFERENCES herramienta(id),
  CONSTRAINT movinv_usuario_fk     FOREIGN KEY (usuario_id)     REFERENCES usuario(id),
  CONSTRAINT movinv_item_chk CHECK (
    (material_id IS NOT NULL AND herramienta_id IS NULL)
    OR (material_id IS NULL AND herramienta_id IS NOT NULL)
  )
);
