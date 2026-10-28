-- PT-15: Clasificación de columnas
-- Qué demuestra: Marca cada columna según qué tan sensible es y verifica que ninguna quede sin marcar.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-15  Clasificación de columnas
-- Conexión: APP_OWNER, servicio FREEPDB1
SET LINESIZE 200
SET PAGESIZE 100
SPOOL evidencias/PT-15.txt
PROMPT === PT-15: Clasificación de columnas ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha
FROM   dual;

COMMENT ON COLUMN app_owner.clientes.id_cliente       IS '[INTERNO] identificador técnico';
COMMENT ON COLUMN app_owner.clientes.nombre           IS '[CONFIDENCIAL] dato personal';
COMMENT ON COLUMN app_owner.clientes.cedula           IS '[RESTRINGIDO] identificador personal';
COMMENT ON COLUMN app_owner.clientes.correo           IS '[CONFIDENCIAL] contacto personal';
COMMENT ON COLUMN app_owner.clientes.telefono         IS '[CONFIDENCIAL] contacto personal';
COMMENT ON COLUMN app_owner.clientes.salario          IS '[RESTRINGIDO] dato económico';
COMMENT ON COLUMN app_owner.clientes.usuario_asignado IS '[INTERNO] control de acceso VPD';

SELECT table_name, column_name, comments
FROM   all_col_comments
WHERE  owner = 'APP_OWNER'
ORDER  BY table_name, column_name;

SELECT table_name, column_name
FROM   all_col_comments
WHERE  owner = 'APP_OWNER' AND comments IS NULL;   -- esperado 0 filas
SPOOL OFF
