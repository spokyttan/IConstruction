-- API Wrappers (JSON) for ICONSTRUCTION
-- These procedures accept JSON arrays and delegate to existing packages.
-- Run after ops.sql and ops_devolucion.sql

CREATE OR REPLACE PACKAGE pkg_prestamos_api AS
  PROCEDURE crear_prestamo_json(
    p_obrero_id        IN NUMBER,
    p_bodeguero_id     IN NUMBER,
    p_bodega_id        IN NUMBER,
    p_fecha_compromiso IN DATE,
    p_detalle_json     IN CLOB, -- [{"herramienta_id":1,"cantidad":2}, ...]
    p_prestamo_id      OUT NUMBER
  );
END pkg_prestamos_api;
/

CREATE OR REPLACE PACKAGE BODY pkg_prestamos_api AS
  PROCEDURE crear_prestamo_json(
    p_obrero_id        IN NUMBER,
    p_bodeguero_id     IN NUMBER,
    p_bodega_id        IN NUMBER,
    p_fecha_compromiso IN DATE,
    p_detalle_json     IN CLOB,
    p_prestamo_id      OUT NUMBER
  ) AS
    l_detalle pkg_prestamos.t_detalle_tab;
    i PLS_INTEGER := 0;
  BEGIN
    -- Parse JSON array into the PL/SQL table type
    FOR rec IN (
      SELECT herramienta_id, cantidad
      FROM JSON_TABLE(
             p_detalle_json,
             '$[*]'
             COLUMNS (
               herramienta_id NUMBER PATH '$.herramienta_id',
               cantidad       NUMBER PATH '$.cantidad'
             )
           )
    ) LOOP
      i := i + 1;
      l_detalle(i).herramienta_id := rec.herramienta_id;
      l_detalle(i).cantidad       := rec.cantidad;
    END LOOP;

    pkg_prestamos.crear_prestamo(
      p_obrero_id        => p_obrero_id,
      p_bodeguero_id     => p_bodeguero_id,
      p_bodega_id        => p_bodega_id,
      p_fecha_compromiso => p_fecha_compromiso,
      p_detalle          => l_detalle,
      p_prestamo_id      => p_prestamo_id
    );
  END crear_prestamo_json;
END pkg_prestamos_api;
/

CREATE OR REPLACE PACKAGE pkg_devoluciones_api AS
  PROCEDURE devolver_json(
    p_prestamo_id  IN NUMBER,
    p_bodega_id    IN NUMBER,
    p_detalle_json IN CLOB -- [{"herramienta_id":1,"cantidad":2}, ...]
  );
END pkg_devoluciones_api;
/

CREATE OR REPLACE PACKAGE BODY pkg_devoluciones_api AS
  PROCEDURE devolver_json(
    p_prestamo_id  IN NUMBER,
    p_bodega_id    IN NUMBER,
    p_detalle_json IN CLOB
  ) AS
    l_detalle pkg_prestamos.t_detalle_tab;
    i PLS_INTEGER := 0;
  BEGIN
    FOR rec IN (
      SELECT herramienta_id, cantidad
      FROM JSON_TABLE(
             p_detalle_json,
             '$[*]'
             COLUMNS (
               herramienta_id NUMBER PATH '$.herramienta_id',
               cantidad       NUMBER PATH '$.cantidad'
             )
           )
    ) LOOP
      i := i + 1;
      l_detalle(i).herramienta_id := rec.herramienta_id;
      l_detalle(i).cantidad       := rec.cantidad;
    END LOOP;

    pkg_devoluciones.devolver_herramientas(
      p_prestamo_id => p_prestamo_id,
      p_bodega_id   => p_bodega_id,
      p_detalle_h   => l_detalle
    );
  END devolver_json;
END pkg_devoluciones_api;
/
