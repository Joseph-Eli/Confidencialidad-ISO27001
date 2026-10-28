-- PREP  Datos de prueba ficticios (SYS como SYSDBA en FREEPDB1)
ALTER SESSION SET CONTAINER = FREEPDB1;

CREATE USER app_owner IDENTIFIED BY &clave_app_owner QUOTA 50M ON users;
GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE TO app_owner;

CREATE TABLE app_owner.clientes (
  id_cliente       NUMBER PRIMARY KEY,
  nombre           VARCHAR2(100),
  cedula           VARCHAR2(12),
  correo           VARCHAR2(100),
  telefono         VARCHAR2(15),
  salario          NUMBER(12,2),
  usuario_asignado VARCHAR2(30)
);

INSERT INTO app_owner.clientes VALUES (1,  'Cliente Ficticio Uno',  '100000001', 'uno@correo.test',  '8000-0001', 850000, 'USR_CONSULTA');
INSERT INTO app_owner.clientes VALUES (2,  'Cliente Ficticio Dos',  '100000002', 'dos@correo.test',  '8000-0002', 920000, 'USR_CONSULTA');
INSERT INTO app_owner.clientes VALUES (3,  'Cliente Ficticio Tres', '100000003', 'tres@correo.test', '8000-0003', 640000, 'USR_OTRO');
INSERT INTO app_owner.clientes VALUES (999,'Titular Supresion',     '100000999', 'baja@correo.test', '8000-0999', 500000, 'USR_OTRO');
COMMIT;

CREATE USER usr_consulta IDENTIFIED BY &clave_usr_consulta;
CREATE USER usr_otro     IDENTIFIED BY &clave_usr_otro;
GRANT CREATE SESSION TO usr_consulta, usr_otro;
