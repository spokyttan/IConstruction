-- Sequences and triggers for auto-generating IDs (Oracle)
-- Run after schema.sql (and proposals.sql if used)

-- Helper to create sequence + trigger for a table with ID column
-- Pattern used below for each table with single-column PK "id".

-- usuario_estado
CREATE SEQUENCE usuario_estado_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER usuario_estado_bi
BEFORE INSERT ON usuario_estado
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := usuario_estado_seq.NEXTVAL;
END;
/

-- usuario_rol
CREATE SEQUENCE usuario_rol_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER usuario_rol_bi
BEFORE INSERT ON usuario_rol
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := usuario_rol_seq.NEXTVAL;
END;
/

-- bodeguero_cargo
CREATE SEQUENCE bodeguero_cargo_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER bodeguero_cargo_bi
BEFORE INSERT ON bodeguero_cargo
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := bodeguero_cargo_seq.NEXTVAL;
END;
/

-- bodeguero_turno
CREATE SEQUENCE bodeguero_turno_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER bodeguero_turno_bi
BEFORE INSERT ON bodeguero_turno
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := bodeguero_turno_seq.NEXTVAL;
END;
/

-- prestamo_estado
CREATE SEQUENCE prestamo_estado_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER prestamo_estado_bi
BEFORE INSERT ON prestamo_estado
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := prestamo_estado_seq.NEXTVAL;
END;
/

-- proyecto_tipo
CREATE SEQUENCE proyecto_tipo_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER proyecto_tipo_bi
BEFORE INSERT ON proyecto_tipo
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := proyecto_tipo_seq.NEXTVAL;
END;
/

-- herramienta_categoria
CREATE SEQUENCE herramienta_categoria_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER herramienta_categoria_bi
BEFORE INSERT ON herramienta_categoria
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := herramienta_categoria_seq.NEXTVAL;
END;
/

-- herramienta_marca
CREATE SEQUENCE herramienta_marca_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER herramienta_marca_bi
BEFORE INSERT ON herramienta_marca
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := herramienta_marca_seq.NEXTVAL;
END;
/

-- herramienta_tipo
CREATE SEQUENCE herramienta_tipo_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER herramienta_tipo_bi
BEFORE INSERT ON herramienta_tipo
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := herramienta_tipo_seq.NEXTVAL;
END;
/

-- herramienta_ubicacion
CREATE SEQUENCE herramienta_ubicacion_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER herramienta_ubicacion_bi
BEFORE INSERT ON herramienta_ubicacion
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := herramienta_ubicacion_seq.NEXTVAL;
END;
/

-- material_marca
CREATE SEQUENCE material_marca_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER material_marca_bi
BEFORE INSERT ON material_marca
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := material_marca_seq.NEXTVAL;
END;
/

-- material_tipo
CREATE SEQUENCE material_tipo_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER material_tipo_bi
BEFORE INSERT ON material_tipo
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := material_tipo_seq.NEXTVAL;
END;
/

-- material_categoria
CREATE SEQUENCE material_categoria_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER material_categoria_bi
BEFORE INSERT ON material_categoria
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := material_categoria_seq.NEXTVAL;
END;
/

-- bodega_tipo
CREATE SEQUENCE bodega_tipo_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER bodega_tipo_bi
BEFORE INSERT ON bodega_tipo
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := bodega_tipo_seq.NEXTVAL;
END;
/

-- bodega_ubicacion
CREATE SEQUENCE bodega_ubicacion_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER bodega_ubicacion_bi
BEFORE INSERT ON bodega_ubicacion
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := bodega_ubicacion_seq.NEXTVAL;
END;
/

-- usuario
CREATE SEQUENCE usuario_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER usuario_bi
BEFORE INSERT ON usuario
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := usuario_seq.NEXTVAL;
END;
/

-- bodega
CREATE SEQUENCE bodega_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER bodega_bi
BEFORE INSERT ON bodega
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := bodega_seq.NEXTVAL;
END;
/

-- material
CREATE SEQUENCE material_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER material_bi
BEFORE INSERT ON material
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := material_seq.NEXTVAL;
END;
/

-- herramienta
CREATE SEQUENCE herramienta_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER herramienta_bi
BEFORE INSERT ON herramienta
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := herramienta_seq.NEXTVAL;
END;
/

-- supervisor_obra
CREATE SEQUENCE supervisor_obra_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER supervisor_obra_bi
BEFORE INSERT ON supervisor_obra
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := supervisor_obra_seq.NEXTVAL;
END;
/

-- obrero
CREATE SEQUENCE obrero_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER obrero_bi
BEFORE INSERT ON obrero
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := obrero_seq.NEXTVAL;
END;
/

-- bodeguero
CREATE SEQUENCE bodeguero_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER bodeguero_bi
BEFORE INSERT ON bodeguero
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := bodeguero_seq.NEXTVAL;
END;
/

-- proyecto
CREATE SEQUENCE proyecto_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER proyecto_bi
BEFORE INSERT ON proyecto
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := proyecto_seq.NEXTVAL;
END;
/

-- proyecto_actividad
CREATE SEQUENCE proyecto_actividad_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER proyecto_actividad_bi
BEFORE INSERT ON proyecto_actividad
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := proyecto_actividad_seq.NEXTVAL;
END;
/

-- reporte
CREATE SEQUENCE reporte_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER reporte_bi
BEFORE INSERT ON reporte
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := reporte_seq.NEXTVAL;
END;
/

-- prestamo_cabecera (from proposals.sql)
CREATE SEQUENCE prestamo_cabecera_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER prestamo_cabecera_bi
BEFORE INSERT ON prestamo_cabecera
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := prestamo_cabecera_seq.NEXTVAL;
END;
/

-- prestamo_detalle (from proposals.sql)
CREATE SEQUENCE prestamo_detalle_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER prestamo_detalle_bi
BEFORE INSERT ON prestamo_detalle
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := prestamo_detalle_seq.NEXTVAL;
END;
/

-- movimiento_inventario (from proposals.sql)
CREATE SEQUENCE movimiento_inventario_seq START WITH 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER movimiento_inventario_bi
BEFORE INSERT ON movimiento_inventario
FOR EACH ROW
WHEN (NEW.id IS NULL)
BEGIN
  :NEW.id := movimiento_inventario_seq.NEXTVAL;
END;
/
