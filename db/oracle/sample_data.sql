-- Sample data to develop and test the web app
-- Run after sequences.sql

-- Usuarios base
INSERT INTO usuario_estado (nombre, activo) VALUES ('Activo', 'S');
INSERT INTO usuario_estado (nombre, activo) VALUES ('Inactivo', 'N');

INSERT INTO usuario_rol (nombre, activo) VALUES ('Administrador', 'S');
INSERT INTO usuario_rol (nombre, activo) VALUES ('Supervisor', 'S');
INSERT INTO usuario_rol (nombre, activo) VALUES ('Bodeguero', 'S');
INSERT INTO usuario_rol (nombre, activo) VALUES ('Obrero', 'S');

INSERT INTO usuario (rut, nombre, correo, password, fecha_creacion, activo, usuario_estado_id, usuario_rol_id)
VALUES ('11.111.111-1', 'Admin', 'admin@dyriconstruction.cl', 'hash', SYSDATE, 'S', 1, 1);

-- Bodegas
INSERT INTO bodega_ubicacion (nombre, activo) VALUES ('Casa Central', 'S');
INSERT INTO bodega_tipo (nombre, activo) VALUES ('Principal', 'S');
INSERT INTO bodega (nombre, activo, bodega_ubicacion_id, bodega_tipo_id)
VALUES ('Bodega Central', 'S', 1, 1);

-- Materiales
INSERT INTO material_categoria (nombre, activo) VALUES ('Cemento', 'S');
INSERT INTO material_marca (nombre, activo) VALUES ('DyR', 'S');
INSERT INTO material_tipo (nombre, activo) VALUES ('Consumo', 'S');
INSERT INTO material (nombre, fecha_vencimiento, activo, material_categoria_id, material_marca_id, material_tipo_id)
VALUES ('Saco Cemento 25kg', SYSDATE+90, 'S', 1, 1, 1);

-- Herramientas
INSERT INTO herramienta_categoria (nombre, activo) VALUES ('Manuales', 'S');
INSERT INTO herramienta_marca (nombre, activo) VALUES ('Stanley', 'S');
INSERT INTO herramienta_tipo (nombre, activo) VALUES ('Uso general', 'S');
INSERT INTO herramienta_ubicacion (nombre, activo) VALUES ('Rack A', 'S');
INSERT INTO herramienta (nombre, activo, herramienta_categoria_id, herramienta_ubicacion_id, herramienta_marca_id, herramienta_tipo_id)
VALUES ('Martillo', 'S', 1, 1, 1, 1);

-- Stock inicial
INSERT INTO bodega_material (bodega_id, material_id, cantidad) VALUES (1, 1, 100);
INSERT INTO bodegas_herramientas (herramienta_id, bodega_id, cantidad) VALUES (1, 1, 10);

COMMIT;
