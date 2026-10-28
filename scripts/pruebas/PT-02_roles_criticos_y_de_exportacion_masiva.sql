-- PT-02: Roles críticos y de exportación masiva
-- Qué demuestra: Revisa quién puede administrar o exportar toda la base.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-02  Roles críticos y de exportación masiva
-- Conexión: SYS AS SYSDBA, servicio FREEPDB1
SET LINESIZE 200
SET PAGESIZE 100
SPOOL evidencias/PT-02.txt
PROMPT === PT-02: Roles críticos y de exportación masiva ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha
FROM   dual;

SELECT grantee, granted_role, admin_option
FROM   dba_role_privs
WHERE  granted_role IN ('DBA','DATAPUMP_EXP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE',
                        'EXP_FULL_DATABASE','IMP_FULL_DATABASE','AUDIT_ADMIN')
AND    grantee NOT IN (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
ORDER  BY granted_role, grantee;

SELECT owner, table_name, privilege
FROM   dba_tab_privs
WHERE  grantee = 'PUBLIC'
AND    owner   = 'APP_OWNER';
SPOOL OFF
