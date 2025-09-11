-- Devolución de herramientas: registra devolución y movimiento
-- Run after proposals.sql, sequences.sql, triggers.sql

CREATE OR REPLACE PACKAGE pkg_devoluciones AS
  PROCEDURE devolver_herramientas(
    p_prestamo_id IN NUMBER,
    p_bodega_id   IN NUMBER,
    p_detalle_h   IN pkg_prestamos.t_detalle_tab
  );

  PROCEDURE cerrar_prestamo(
    p_prestamo_id IN NUMBER,
    p_estado_id   IN NUMBER DEFAULT 2 -- Devuelto
  );
END pkg_devoluciones;
/

CREATE OR REPLACE PACKAGE BODY pkg_devoluciones AS
  PROCEDURE devolver_herramientas(
    p_prestamo_id IN NUMBER,
    p_bodega_id   IN NUMBER,
    p_detalle_h   IN pkg_prestamos.t_detalle_tab
  ) AS
  BEGIN
    IF p_detalle_h.COUNT > 0 THEN
      FOR i IN 1 .. p_detalle_h.COUNT LOOP
        UPDATE prestamo_detalle
           SET fecha_devolucion = NVL(fecha_devolucion, SYSDATE)
         WHERE prestamo_id = p_prestamo_id
           AND herramienta_id = p_detalle_h(i).herramienta_id;

        INSERT INTO movimiento_inventario (id, fecha, tipo, bodega_id, herramienta_id, cantidad, referencia)
        VALUES (movimiento_inventario_seq.NEXTVAL, SYSDATE, 'DEVOLUCION', p_bodega_id, p_detalle_h(i).herramienta_id, p_detalle_h(i).cantidad, 'DEVOLUCION:' || p_prestamo_id);
      END LOOP;
    END IF;
  END devolver_herramientas;

  PROCEDURE cerrar_prestamo(
    p_prestamo_id IN NUMBER,
    p_estado_id   IN NUMBER
  ) AS
  BEGIN
    UPDATE prestamo_cabecera
       SET estado_id = p_estado_id
     WHERE id = p_prestamo_id;
  END cerrar_prestamo;
END pkg_devoluciones;
/
