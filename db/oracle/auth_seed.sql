-- Idempotent seed using MERGE (upsert) by correo
-- If user exists: updates nombre/rol/estado/activo (keeps existing password by default)
-- If not exists: inserts with next incremental id (simple MAX(id)+1, acceptable for seed)
-- NOTE: If you want to always reset password, uncomment the line indicated below

DECLARE
  FUNCTION next_usuario_id RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    SELECT NVL(MAX(id),0)+1 INTO v_id FROM usuario;
    RETURN v_id;
  END;

  PROCEDURE upsert_usuario(
    p_rut VARCHAR2,
    p_nombre VARCHAR2,
    p_correo VARCHAR2,
    p_password VARCHAR2,
    p_estado_id NUMBER,
    p_rol_id NUMBER
  ) IS
  BEGIN
    MERGE INTO usuario u
    USING (SELECT p_correo correo FROM dual) src
       ON (u.correo = src.correo)
    WHEN MATCHED THEN
      UPDATE SET u.nombre = p_nombre,
                 u.usuario_estado_id = p_estado_id,
                 u.usuario_rol_id = p_rol_id,
                 u.activo = 'S'
                 -- , u.password = p_password -- Uncomment to force password reset
    WHEN NOT MATCHED THEN
      INSERT (id, rut, nombre, correo, password, fecha_creacion, activo, usuario_estado_id, usuario_rol_id)
      VALUES (next_usuario_id(), p_rut, p_nombre, p_correo, p_password, SYSDATE, 'S', p_estado_id, p_rol_id);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      -- Edge case: RUT unique conflict with existing different correo
      RAISE_APPLICATION_ERROR(-20001, 'Conflicto de RUT para '||p_correo||' (rut='||p_rut||') ya existe con otro correo.');
  END;
BEGIN
  upsert_usuario('11.111.111-1','Admin','admin@iconstruction.cl','admin123',1,1);
  upsert_usuario('22.222.222-2','Operador','operador@iconstruction.cl','operador123',1,2);
  COMMIT;
END;
/
