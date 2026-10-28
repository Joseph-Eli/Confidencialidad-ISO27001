-- PT-10: Protección del rastro de auditoría y logs
-- Qué demuestra: Comprueba que solo personas designadas pueden leer la auditoría y los registros.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-10  Protección del rastro de auditoría y logs
-- Conexión: SYS AS SYSDBA, servicio FREEPDB1
SET LINESIZE 200
SET PAGESIZE 100
SPOOL evidencias/PT-10.txt
PROMPT === PT-10: Protección del rastro de auditoría y logs ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha
FROM   dual;

SELECT grantee, granted_role
FROM   dba_role_privs
WHERE  granted_role IN ('AUDIT_ADMIN','AUDIT_VIEWER')
ORDER  BY granted_role, grantee;

SELECT parameter_name, parameter_value, audit_trail
FROM   dba_audit_mgmt_config_params;

SELECT name, value FROM v$diag_info
WHERE  name IN ('ADR Home','Diag Trace','Diag Alert');
SPOOL OFF

-- Como USR_CONSULTA:
SELECT COUNT(*) FROM unified_audit_trail;   -- esperado ORA-00942

-- Anfitrión (usar la ruta Diag Trace obtenida arriba):
--   docker exec oracle-eliasulate ls -ld <ruta_diag_trace>
