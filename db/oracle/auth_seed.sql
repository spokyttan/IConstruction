-- Seed simple users for API login tests
-- Assumes: usuario_estado(1='Activo'), usuario_rol(1='Administrador', 2='Operador') exist
-- Run after schema.sql, sequences.sql (triggers)

DECLARE
  v_exists NUMBER;
BEGIN
  -- Admin user
  SELECT COUNT(*) INTO v_exists FROM usuario WHERE correo = 'admin@iconstruction.cl';
  IF v_exists = 0 THEN
    INSERT INTO usuario (rut, nombre, correo, password, fecha_creacion, activo, usuario_estado_id, usuario_rol_id)
    VALUES ('11.111.111-1', 'Admin', 'admin@iconstruction.cl', 'admin123', SYSDATE, 'S', 1, 1);
  END IF;

  -- Operador user
  SELECT COUNT(*) INTO v_exists FROM usuario WHERE correo = 'operador@iconstruction.cl';
  IF v_exists = 0 THEN
    INSERT INTO usuario (rut, nombre, correo, password, fecha_creacion, activo, usuario_estado_id, usuario_rol_id)
    VALUES ('22.222.222-2', 'Operador', 'operador@iconstruction.cl', 'operador123', SYSDATE, 'S', 1, 2);
  END IF;

  COMMIT;
END;
/
