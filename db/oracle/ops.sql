-- Operational helpers (Oracle) for ICONSTRUCTION
-- Run after schema.sql and proposals.sql

-- Procedure: registrar prestamo (cabecera + detalle) y movimiento de inventario
CREATE OR REPLACE PACKAGE pkg_prestamos AS
  TYPE t_prestamo_detalle IS RECORD (
    herramienta_id NUMBER,
    cantidad       NUMBER
  );
  TYPE t_detalle_tab IS TABLE OF t_prestamo_detalle INDEX BY PLS_INTEGER;

  PROCEDURE crear_prestamo(
    p_obrero_id        IN NUMBER,
    p_bodeguero_id     IN NUMBER,
    p_bodega_id        IN NUMBER,
    p_fecha_compromiso IN DATE,
    p_detalle          IN t_detalle_tab,
    p_prestamo_id      OUT NUMBER
  );
END pkg_prestamos;
/

CREATE OR REPLACE PACKAGE BODY pkg_prestamos AS
  PROCEDURE crear_prestamo(
    p_obrero_id        IN NUMBER,
    p_bodeguero_id     IN NUMBER,
    p_bodega_id        IN NUMBER,
    p_fecha_compromiso IN DATE,
    p_detalle          IN t_detalle_tab,
    p_prestamo_id      OUT NUMBER
  ) AS
    v_id NUMBER;
  BEGIN
    -- cabecera
    INSERT INTO prestamo_cabecera (id, obrero_id, bodeguero_id, bodega_id, fecha_prestamo, fecha_compromiso, estado_id)
    VALUES (prestamo_cabecera_seq.NEXTVAL, p_obrero_id, p_bodeguero_id, p_bodega_id, SYSDATE, p_fecha_compromiso, 1)
    RETURNING id INTO v_id;

    -- detalle + movimientos (egreso)
    IF p_detalle.COUNT > 0 THEN
      FOR i IN 1 .. p_detalle.COUNT LOOP
        INSERT INTO prestamo_detalle (id, prestamo_id, herramienta_id, cantidad)
        VALUES (prestamo_detalle_seq.NEXTVAL, v_id, p_detalle(i).herramienta_id, p_detalle(i).cantidad);

        INSERT INTO movimiento_inventario (id, fecha, tipo, bodega_id, herramienta_id, cantidad, referencia)
        VALUES (movimiento_inventario_seq.NEXTVAL, SYSDATE, 'PRESTAMO', p_bodega_id, p_detalle(i).herramienta_id, p_detalle(i).cantidad, 'PRESTAMO:' || v_id);
      END LOOP;
    END IF;

    p_prestamo_id := v_id;
  END crear_prestamo;
END pkg_prestamos;
/
