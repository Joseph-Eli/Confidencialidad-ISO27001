-- PT-09: Auditoría unificada de accesos
-- Qué demuestra: Hace una consulta y comprueba que queda registrada en la auditoría.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-09  Auditoría unificada de accesos
-- Conexión: SYS AS SYSDBA, servicio FREEPDB1
SET LINESIZE 200
SET PAGESIZE 100
SPOOL evidencias/PT-09.txt
PROMPT === PT-09: Auditoría unificada de accesos ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha
FROM   dual;

CREATE AUDIT POLICY pol_conf_clientes
  ACTIONS SELECT ON app_owner.clientes,
          UPDATE ON app_owner.clientes,
          DELETE ON app_owner.clientes;
AUDIT POLICY pol_conf_clientes;

CREATE AUDIT POLICY pol_conf_cuentas
  ACTIONS CREATE USER, ALTER USER, DROP USER, GRANT, REVOKE;
AUDIT POLICY pol_conf_cuentas;

SELECT policy_name, enabled_option, entity_name, success, failure
FROM   audit_unified_enabled_policies;

-- Generar actividad (SELECT como USR_CONSULTA; CREATE/DROP USER de prueba como SYS) y luego:
SELECT event_timestamp, dbusername, action_name, object_schema, object_name, return_code
FROM   unified_audit_trail
WHERE  object_name = 'CLIENTES' OR action_name IN ('CREATE USER','DROP USER')
ORDER  BY event_timestamp DESC
FETCH FIRST 20 ROWS ONLY;
SPOOL OFF
