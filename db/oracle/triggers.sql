-- Stock maintenance triggers using movimiento_inventario
-- Run after proposals.sql (needs movimiento_inventario) and base tables

-- Helper function: signed quantity by type
CREATE OR REPLACE FUNCTION f_signo_por_tipo(p_tipo VARCHAR2) RETURN NUMBER IS
BEGIN
  -- Define sign: INGRESO(+), EGRESO(-), PRESTAMO(-), DEVOLUCION(+), AJUSTE(+/- handled by cantidad sign)
  IF p_tipo IN ('INGRESO', 'DEVOLUCION') THEN
    RETURN 1;
  ELSIF p_tipo IN ('EGRESO', 'PRESTAMO') THEN
    RETURN -1;
  ELSE
    RETURN 1; -- AJUSTE as provided
  END IF;
END;
/

-- Upsert helper procedure
CREATE OR REPLACE PROCEDURE p_upsert_stock_material(p_bodega_id NUMBER, p_material_id NUMBER, p_delta NUMBER) AS
BEGIN
  MERGE INTO bodega_material bm
  USING (SELECT p_bodega_id AS bodega_id, p_material_id AS material_id FROM dual) src
  ON (bm.bodega_id = src.bodega_id AND bm.material_id = src.material_id)
  WHEN MATCHED THEN UPDATE SET bm.cantidad = NVL(bm.cantidad,0) + p_delta
  WHEN NOT MATCHED THEN INSERT (bodega_id, material_id, cantidad) VALUES (p_bodega_id, p_material_id, GREATEST(p_delta,0));
END;
/

CREATE OR REPLACE PROCEDURE p_upsert_stock_herramienta(p_bodega_id NUMBER, p_herramienta_id NUMBER, p_delta NUMBER) AS
BEGIN
  MERGE INTO bodegas_herramientas bh
  USING (SELECT p_bodega_id AS bodega_id, p_herramienta_id AS herramienta_id FROM dual) src
  ON (bh.bodega_id = src.bodega_id AND bh.herramienta_id = src.herramienta_id)
  WHEN MATCHED THEN UPDATE SET bh.cantidad = NVL(bh.cantidad,0) + p_delta
  WHEN NOT MATCHED THEN INSERT (herramienta_id, bodega_id, cantidad) VALUES (p_herramienta_id, p_bodega_id, GREATEST(p_delta,0));
END;
/

-- Trigger after insert on movimiento_inventario
CREATE OR REPLACE TRIGGER movimiento_inventario_ai
AFTER INSERT ON movimiento_inventario
FOR EACH ROW
DECLARE
  v_sign NUMBER := f_signo_por_tipo(:NEW.tipo);
BEGIN
  IF :NEW.material_id IS NOT NULL THEN
    p_upsert_stock_material(:NEW.bodega_id, :NEW.material_id, v_sign * :NEW.cantidad);
  ELSIF :NEW.herramienta_id IS NOT NULL THEN
    p_upsert_stock_herramienta(:NEW.bodega_id, :NEW.herramienta_id, v_sign * :NEW.cantidad);
  END IF;
END;
/
