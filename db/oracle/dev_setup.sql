-- Developer setup to create valid sample Obrero and Bodeguero and run a demo préstamo
-- Run after: schema.sql, proposals.sql, sequences.sql, indexes.sql, triggers.sql, views.sql, ops.sql, ops_devolucion.sql, sample_data.sql

SET SERVEROUTPUT ON
DECLARE
  v_obrero_user_id    NUMBER;
  v_bodeguero_user_id NUMBER;
  v_obrero_id         NUMBER;
  v_bodeguero_id      NUMBER;
  v_cargo_id          NUMBER;
  v_prestamo_id       NUMBER;
BEGIN
  -- Ensure a bodeguero_cargo exists (e.g., 'Maestro')
  SELECT NVL(MAX(id), 0) INTO v_cargo_id FROM bodeguero_cargo;
  IF v_cargo_id = 0 THEN
    INSERT INTO bodeguero_cargo (id, nombre, activo) VALUES (bodeguero_cargo_seq.NEXTVAL, 'Maestro', 'S') RETURNING id INTO v_cargo_id;
  END IF;

  -- Create user for Obrero
  INSERT INTO usuario (rut, nombre, correo, password, fecha_creacion, activo, usuario_estado_id, usuario_rol_id)
  VALUES ('22.222.222-2', 'Obrero Demo', 'obrero@dyriconstruction.cl', 'hash', SYSDATE, 'S', 1, 4)
  RETURNING id INTO v_obrero_user_id;

  -- Create user for Bodeguero
  INSERT INTO usuario (rut, nombre, correo, password, fecha_creacion, activo, usuario_estado_id, usuario_rol_id)
  VALUES ('33.333.333-3', 'Bodeguero Demo', 'bodeguero@dyriconstruction.cl', 'hash', SYSDATE, 'S', 1, 3)
  RETURNING id INTO v_bodeguero_user_id;

  -- Insert Obrero (prestamo_estado_id = 1 'Pendiente')
  INSERT INTO obrero (id, activo, bodeguero_cargo_id, prestamo_estado_id, usuario_id)
  VALUES (obrero_seq.NEXTVAL, 'S', v_cargo_id, 1, v_obrero_user_id)
  RETURNING id INTO v_obrero_id;

  -- Insert Bodeguero (turno id=1, bodega id=1)
  INSERT INTO bodeguero (id, rut, nombre, activo, bodeguero_turno_id, usuario_id, bodega_id)
  VALUES (bodeguero_seq.NEXTVAL, '33.333.333-3', 'Bodeguero Demo', 'S', 1, v_bodeguero_user_id, 1)
  RETURNING id INTO v_bodeguero_id;

  -- Demo préstamo: 2 unidades de herramienta id=1 desde bodega 1
  DECLARE
    v_det pkg_prestamos.t_detalle_tab;
  BEGIN
    v_det(1).herramienta_id := 1;
    v_det(1).cantidad := 2;
    pkg_prestamos.crear_prestamo(
      p_obrero_id        => v_obrero_id,
      p_bodeguero_id     => v_bodeguero_id,
      p_bodega_id        => 1,
      p_fecha_compromiso => SYSDATE + 7,
      p_detalle          => v_det,
      p_prestamo_id      => v_prestamo_id
    );
  END;

  DBMS_OUTPUT.PUT_LINE('OK. Prestamo creado con ID: ' || v_prestamo_id);
END;
/

-- Quick checks
SELECT * FROM movimiento_inventario ORDER BY fecha DESC;
SELECT * FROM vw_stock_herramienta_por_bodega WHERE herramienta_id = 1;
