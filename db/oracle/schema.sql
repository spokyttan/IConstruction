-- IConstruction - Oracle schema DDL
-- Generated from modelo_v1 engineered model (Oracle SQL Developer Data Modeler)
-- Note: IDs are NUMBER(8) without identity/sequence; manage key generation as needed.

-- =============================================================
-- Lookup / Catalog tables
-- =============================================================

CREATE TABLE usuario_estado (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE usuario_rol (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE bodeguero_cargo (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE bodeguero_turno (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE prestamo_estado (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE proyecto_tipo (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE herramienta_categoria (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE herramienta_marca (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE herramienta_tipo (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE herramienta_ubicacion (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE material_marca (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE material_tipo (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE material_categoria (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE bodega_tipo (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

CREATE TABLE bodega_ubicacion (
  id            NUMBER(8)      PRIMARY KEY,
  nombre        VARCHAR2(50),
  activo        CHAR(1)
);

-- =============================================================
-- Core tables
-- =============================================================

CREATE TABLE usuario (
  id                 NUMBER(8)      PRIMARY KEY,
  rut                VARCHAR2(13),
  nombre             VARCHAR2(50),
  correo             VARCHAR2(50),
  password           VARCHAR2(50),
  fecha_creacion     DATE,
  activo             CHAR(1),
  usuario_estado_id  NUMBER(8),
  usuario_rol_id     NUMBER(8),
  CONSTRAINT usuario_usuario_estado_FK FOREIGN KEY (usuario_estado_id) REFERENCES usuario_estado(id),
  CONSTRAINT usuario_usuario_rol_FK    FOREIGN KEY (usuario_rol_id)    REFERENCES usuario_rol(id)
);

CREATE TABLE bodega (
  id                  NUMBER(8)      PRIMARY KEY,
  nombre              VARCHAR2(50),
  activo              CHAR(1),
  bodega_ubicacion_id NUMBER(8),
  bodega_tipo_id      NUMBER(8),
  CONSTRAINT bodega_bodega_ubicacion_FK FOREIGN KEY (bodega_ubicacion_id) REFERENCES bodega_ubicacion(id),
  CONSTRAINT bodega_bodega_tipo_FK      FOREIGN KEY (bodega_tipo_id)      REFERENCES bodega_tipo(id)
);

CREATE TABLE material (
  id                   NUMBER(8)      PRIMARY KEY,
  nombre               VARCHAR2(50),
  fecha_vencimiento    DATE,
  activo               CHAR(1),
  material_categoria_id NUMBER(8),
  material_marca_id     NUMBER(8),
  material_tipo_id      NUMBER(8),
  CONSTRAINT material_material_categoria_FK FOREIGN KEY (material_categoria_id) REFERENCES material_categoria(id),
  CONSTRAINT material_material_marca_FK     FOREIGN KEY (material_marca_id)     REFERENCES material_marca(id),
  CONSTRAINT material_material_tipo_FK      FOREIGN KEY (material_tipo_id)      REFERENCES material_tipo(id)
);

CREATE TABLE herramienta (
  id                       NUMBER(8)      PRIMARY KEY,
  nombre                   VARCHAR2(50),
  activo                   CHAR(1),
  herramienta_categoria_id NUMBER(8),
  herramienta_ubicacion_id NUMBER(8),
  herramienta_marca_id     NUMBER(8),
  herramienta_tipo_id      NUMBER(8),
  CONSTRAINT herramienta_herramienta_categoria_FK FOREIGN KEY (herramienta_categoria_id) REFERENCES herramienta_categoria(id),
  CONSTRAINT herramienta_herramienta_ubicacion_FK FOREIGN KEY (herramienta_ubicacion_id) REFERENCES herramienta_ubicacion(id),
  CONSTRAINT herramienta_herramienta_marca_FK     FOREIGN KEY (herramienta_marca_id)     REFERENCES herramienta_marca(id),
  CONSTRAINT herramienta_herramienta_tipo_FK      FOREIGN KEY (herramienta_tipo_id)      REFERENCES herramienta_tipo(id)
);

-- =============================================================
-- Associations and operational tables
-- =============================================================

CREATE TABLE bodega_material (
  bodega_id   NUMBER(8) NOT NULL,
  material_id NUMBER(8) NOT NULL,
  CONSTRAINT bodega_material_PK PRIMARY KEY (bodega_id, material_id),
  CONSTRAINT bodega_material_bodega_FK   FOREIGN KEY (bodega_id)   REFERENCES bodega(id),
  CONSTRAINT bodega_material_material_FK FOREIGN KEY (material_id) REFERENCES material(id)
);

CREATE TABLE bodegas_herramientas (
  herramienta_id NUMBER(8) NOT NULL,
  bodega_id      NUMBER(8) NOT NULL,
  id             NUMBER(8),
  cantidad       NUMBER(8),
  CONSTRAINT bodegas_herramientas_PK PRIMARY KEY (herramienta_id, bodega_id),
  CONSTRAINT bodegas_herramientas_herramienta_FK FOREIGN KEY (herramienta_id) REFERENCES herramienta(id),
  CONSTRAINT bodegas_herramientas_bodega_FK      FOREIGN KEY (bodega_id)      REFERENCES bodega(id)
);

CREATE TABLE supervisor_obra (
  id         NUMBER(8)      PRIMARY KEY,
  nombre     VARCHAR2(50),
  activo     CHAR(1),
  usuario_id NUMBER(8),
  CONSTRAINT supervisor_obra_usuario_FK FOREIGN KEY (usuario_id) REFERENCES usuario(id)
);

CREATE UNIQUE INDEX supervisor_obra__IDX ON supervisor_obra(usuario_id);

CREATE TABLE obrero (
  id                  NUMBER(8)      PRIMARY KEY,
  activo              CHAR(1),
  bodeguero_cargo_id  NUMBER(8),
  prestamo_estado_id  NUMBER(8),
  usuario_id          NUMBER(8),
  CONSTRAINT obrero_bodeguero_cargo_FK FOREIGN KEY (bodeguero_cargo_id) REFERENCES bodeguero_cargo(id),
  CONSTRAINT obrero_prestamo_estado_FK FOREIGN KEY (prestamo_estado_id) REFERENCES prestamo_estado(id),
  CONSTRAINT obrero_usuario_FK         FOREIGN KEY (usuario_id)         REFERENCES usuario(id)
);

CREATE UNIQUE INDEX obrero__IDX ON obrero(usuario_id);

CREATE TABLE bodeguero (
  id                 NUMBER(8)      PRIMARY KEY,
  rut                VARCHAR2(13),
  nombre             VARCHAR2(50),
  activo             CHAR(1),
  bodeguero_turno_id NUMBER(8),
  usuario_id         NUMBER(8),
  bodega_id          NUMBER(8),
  CONSTRAINT bodeguero_bodeguero_turno_FK FOREIGN KEY (bodeguero_turno_id) REFERENCES bodeguero_turno(id),
  CONSTRAINT bodeguero_usuario_FK         FOREIGN KEY (usuario_id)         REFERENCES usuario(id),
  CONSTRAINT bodeguero_bodega_FK          FOREIGN KEY (bodega_id)          REFERENCES bodega(id)
);

CREATE UNIQUE INDEX bodeguero__IDX ON bodeguero(usuario_id);
CREATE UNIQUE INDEX bodeguero__IDXv1 ON bodeguero(bodega_id);

CREATE TABLE proyecto (
  id               NUMBER(8)      PRIMARY KEY,
  nombre           VARCHAR2(50),
  fecha_inicio     DATE,
  fecha_termino    DATE,
  activo           CHAR(1),
  proyecto_tipo_id NUMBER(8),
  CONSTRAINT proyecto_proyecto_tipo_FK FOREIGN KEY (proyecto_tipo_id) REFERENCES proyecto_tipo(id)
);

CREATE TABLE proyecto_actividad (
  id             NUMBER(8)      PRIMARY KEY,
  nombre         VARCHAR2(50),
  fecha_entrega  DATE,
  porcentaje     NUMBER(3,2),
  activo         CHAR(1),
  proyecto_id    NUMBER(8),
  CONSTRAINT proyecto_actividad_proyecto_FK FOREIGN KEY (proyecto_id) REFERENCES proyecto(id)
);

CREATE TABLE reporte (
  id                 NUMBER(8)      PRIMARY KEY,
  fecha              DATE,
  activo             CHAR(1),
  supervisor_obra_id NUMBER(8),
  proyecto_id        NUMBER(8),
  CONSTRAINT reporte_supervisor_obra_FK FOREIGN KEY (supervisor_obra_id) REFERENCES supervisor_obra(id),
  CONSTRAINT reporte_proyecto_FK       FOREIGN KEY (proyecto_id)        REFERENCES proyecto(id)
);

CREATE TABLE prestamo (
  obrero_id    NUMBER(8) NOT NULL,
  bodeguero_id NUMBER(8) NOT NULL,
  CONSTRAINT prestamo_PK PRIMARY KEY (obrero_id, bodeguero_id),
  CONSTRAINT prestamo_obrero_FK    FOREIGN KEY (obrero_id)    REFERENCES obrero(id),
  CONSTRAINT prestamo_bodeguero_FK FOREIGN KEY (bodeguero_id) REFERENCES bodeguero(id)
);

-- =============================================================
-- Minimal seeds (optional)
-- =============================================================

INSERT INTO usuario_estado (id, nombre, activo) VALUES (1, 'Activo', 'S');
INSERT INTO usuario_estado (id, nombre, activo) VALUES (2, 'Inactivo', 'N');

INSERT INTO usuario_rol (id, nombre, activo) VALUES (1, 'Administrador', 'S');
INSERT INTO usuario_rol (id, nombre, activo) VALUES (2, 'Operador', 'S');

INSERT INTO prestamo_estado (id, nombre, activo) VALUES (1, 'Pendiente', 'S');
INSERT INTO prestamo_estado (id, nombre, activo) VALUES (2, 'Devuelto', 'S');

INSERT INTO bodeguero_turno (id, nombre, activo) VALUES (1, 'Mañana', 'S');
INSERT INTO bodeguero_turno (id, nombre, activo) VALUES (2, 'Tarde', 'S');

COMMIT;
