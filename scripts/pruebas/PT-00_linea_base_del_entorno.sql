-- PT-00: Línea base del entorno
-- Qué demuestra: Registra la versión y las opciones de seguridad disponibles antes de empezar.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-00  Línea base del entorno
-- Conexión: SYS AS SYSDBA, servicio FREEPDB1
SET LINESIZE 200
SET PAGESIZE 100
SPOOL evidencias/PT-00.txt
PROMPT === PT-00: Línea base del entorno ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha
FROM   dual;

SELECT banner_full FROM v$version;
SELECT parameter, value
FROM   v$option
WHERE  parameter IN ('Advanced Security','Unified Auditing',
                     'Fine-grained Auditing','Oracle Database Vault');
SPOOL OFF

-- En el anfitrión:
--   docker ps --filter name=oracle-eliasulate
--   docker port oracle-eliasulate
