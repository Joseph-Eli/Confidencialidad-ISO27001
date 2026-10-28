-- =====================================================================
-- DIAGNÓSTICO DE CONFIDENCIALIDAD - LÍNEA BASE (SOLO LECTURA)
-- EIF402 · Controles ISO/IEC 27001:2022 · Joseph Elías Ulate Aguilar
-- Entorno: Oracle AI Database 26ai Free, contenedor oracle-eliasulate
-- Ejecutar como SYS AS SYSDBA (arranca en CDB$ROOT y pasa a FREEPDB1).
-- Este script NO crea, modifica ni borra nada: solo consulta.
-- =====================================================================
SET DEFINE OFF
SET LINESIZE 230
SET PAGESIZE 200
SET TRIMOUT ON
SET TRIMSPOOL ON
SET TAB OFF
SET FEEDBACK ON
WHENEVER SQLERROR CONTINUE

ALTER SESSION SET NLS_DATE_FORMAT         = 'YYYY-MM-DD HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT    = 'YYYY-MM-DD HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'YYYY-MM-DD HH24:MI:SS TZH:TZM';

COLUMN banner_full     FORMAT A90
COLUMN contenedor      FORMAT A15
COLUMN ejecutado_por   FORMAT A15
COLUMN fecha           FORMAT A28
COLUMN name            FORMAT A36
COLUMN value           FORMAT A70
COLUMN parameter       FORMAT A32
COLUMN username        FORMAT A28
COLUMN grantee         FORMAT A28
COLUMN privilege       FORMAT A32
COLUMN granted_role    FORMAT A30
COLUMN account_status  FORMAT A22
COLUMN profile         FORMAT A20
COLUMN resource_name   FORMAT A28
COLUMN limit           FORMAT A22
COLUMN owner           FORMAT A20
COLUMN object_owner    FORMAT A20
COLUMN table_name      FORMAT A30
COLUMN object_name     FORMAT A30
COLUMN column_name     FORMAT A30
COLUMN data_type       FORMAT A14
COLUMN comments        FORMAT A40
COLUMN policy_name     FORMAT A30
COLUMN expression      FORMAT A55
COLUMN function        FORMAT A30
COLUMN wrl_parameter   FORMAT A45
COLUMN handle          FORMAT A70
COLUMN tablespace_name FORMAT A20
COLUMN entity_name     FORMAT A20
COLUMN action_name     FORMAT A25
COLUMN dbusername      FORMAT A25
COLUMN description     FORMAT A50
COLUMN original_name   FORMAT A30
COLUMN parameter_name  FORMAT A32
COLUMN parameter_value FORMAT A20
COLUMN audit_trail     FORMAT A28

PROMPT
PROMPT ##########################  PARTE A: CDB$ROOT  ##########################

PROMPT
PROMPT ===== D00 Contexto de la ejecución =====
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS fecha
FROM   dual;
SELECT banner_full FROM v$version;
SELECT name, log_mode, open_mode FROM v$database;
SELECT con_id, name, open_mode, restricted FROM v$pdbs ORDER BY con_id;

PROMPT
PROMPT ===== D01 Cuentas con privilegios administrativos (archivo de contraseñas) =====
SELECT username, sysdba, sysoper, sysbackup, sysdg, syskm, con_id
FROM   v$pwfile_users
ORDER  BY username;

PROMPT
PROMPT ===== D02 Cifrado TDE: estado del keystore =====
SELECT con_id, wrl_type, wrl_parameter, status, wallet_type, keystore_mode
FROM   v$encryption_wallet
ORDER  BY con_id;

PROMPT
PROMPT ===== D03 Respaldos RMAN: configuración y últimas piezas =====
SELECT name, value FROM v$rman_configuration ORDER BY name;
SELECT handle, encrypted, completion_time
FROM   v$backup_piece
ORDER  BY completion_time DESC
FETCH FIRST 10 ROWS ONLY;

ALTER SESSION SET CONTAINER = FREEPDB1;

PROMPT
PROMPT ##########################  PARTE B: FREEPDB1  ##########################

PROMPT
PROMPT ===== D04 Contexto, opciones de seguridad y parámetros =====
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor FROM dual;
SELECT parameter, value
FROM   v$option
WHERE  parameter IN ('Advanced Security','Unified Auditing','Fine-grained Auditing',
                     'Oracle Database Vault','Oracle Label Security','Real Application Security')
ORDER  BY parameter;
SELECT name, value
FROM   v$parameter
WHERE  name IN ('audit_sys_operations','audit_trail','encrypt_new_tablespaces',
                'os_authent_prefix','recyclebin','remote_login_passwordfile',
                'remote_os_authent','resource_limit','sec_case_sensitive_logon',
                'sec_max_failed_login_attempts','sec_protocol_error_further_action',
                'sec_return_server_release_banner','sql92_security',
                'tde_configuration','undo_retention','wallet_root')
ORDER  BY name;

PROMPT
PROMPT ===== D05 Inventario de cuentas no mantenidas por Oracle  [A5.16] =====
SELECT username, account_status, profile, authentication_type,
       password_versions, created, last_login
FROM   dba_users
WHERE  oracle_maintained = 'N'
ORDER  BY username;

PROMPT
PROMPT ===== D06 Cuentas con contraseña por defecto  [A5.17] =====
SELECT d.username, u.account_status, u.oracle_maintained
FROM   dba_users_with_defpwd d
JOIN   dba_users u ON u.username = d.username
ORDER  BY u.account_status, d.username;

PROMPT
PROMPT ===== D07 Reglas de contraseña de los perfiles en uso  [A5.17 / A8.5] =====
SELECT profile, resource_name, limit
FROM   dba_profiles
WHERE  resource_type = 'PASSWORD'
AND    (profile = 'DEFAULT'
        OR profile IN (SELECT profile FROM dba_users WHERE oracle_maintained = 'N'))
ORDER  BY profile, resource_name;

PROMPT
PROMPT ===== D08 Privilegios de sistema críticos fuera de Oracle  [A8.2] =====
SELECT grantee, privilege, admin_option
FROM   dba_sys_privs
WHERE  (privilege LIKE '%ANY%'
        OR privilege IN ('ALTER SYSTEM','BECOME USER','GRANT ANY PRIVILEGE',
                         'EXEMPT ACCESS POLICY','EXEMPT REDACTION POLICY'))
AND    grantee NOT IN (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
AND    grantee NOT IN (SELECT role     FROM dba_roles WHERE oracle_maintained = 'Y')
ORDER  BY grantee, privilege;

PROMPT
PROMPT ===== D09 Roles críticos y de exportación masiva  [A5.18 / A8.12] =====
SELECT grantee, granted_role, admin_option
FROM   dba_role_privs
WHERE  granted_role IN ('DBA','DATAPUMP_EXP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE',
                        'EXP_FULL_DATABASE','IMP_FULL_DATABASE','AUDIT_ADMIN',
                        'PDB_DBA','SELECT_CATALOG_ROLE')
AND    grantee NOT IN (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
ORDER  BY granted_role, grantee;

PROMPT
PROMPT ===== D10 Privilegios sobre objetos de esquemas de aplicación  [A5.15 / A8.3] =====
SELECT owner, table_name, grantee, privilege
FROM   dba_tab_privs
WHERE  owner IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N')
AND    grantee <> owner
ORDER  BY owner, table_name, grantee, privilege;

PROMPT
PROMPT ===== D11 Columnas con posibles datos personales o sensibles  [A5.12] =====
SELECT c.owner, c.table_name, c.column_name, c.data_type, t.num_rows, cc.comments
FROM   dba_tab_columns c
JOIN   dba_tables t
       ON t.owner = c.owner AND t.table_name = c.table_name
LEFT JOIN dba_col_comments cc
       ON cc.owner = c.owner AND cc.table_name = c.table_name AND cc.column_name = c.column_name
WHERE  c.owner IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N')
AND    c.table_name NOT LIKE 'BIN$%'
AND    REGEXP_LIKE(c.column_name,
         'CEDULA|IDENTIF|DNI|PASAPORTE|CORREO|EMAIL|MAIL|TELEF|CELULAR|PHONE|SALARIO|SUELDO|'
       ||'TARJETA|CARD|CUENTA|IBAN|PASS|CLAVE|CONTRASE|DIRECC|NACIM|NOMBRE|APELLIDO', 'i')
ORDER  BY c.owner, c.table_name, c.column_name;

PROMPT
PROMPT ===== D12 Tablespaces, cifrado y ubicación de los datos de aplicación  [A8.12] =====
SELECT tablespace_name, encrypted, status, contents FROM dba_tablespaces ORDER BY tablespace_name;
SELECT * FROM v$encrypted_tablespaces;
SELECT owner, tablespace_name, COUNT(*) AS segmentos,
       ROUND(SUM(bytes)/1024/1024, 1) AS mb
FROM   dba_segments
WHERE  owner IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N')
GROUP  BY owner, tablespace_name
ORDER  BY owner, tablespace_name;

PROMPT
PROMPT ===== D13 Políticas de redacción y VPD  [A8.11 / A8.3] =====
SELECT object_owner, object_name, policy_name, expression, enable FROM redaction_policies;
SELECT object_owner, object_name, policy_name, function, enable
FROM   dba_policies
WHERE  object_owner IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N');

PROMPT
PROMPT ===== D14 Auditoría unificada  [A8.15 / A5.33] =====
SELECT policy_name, enabled_option, entity_name, success, failure
FROM   audit_unified_enabled_policies
ORDER  BY policy_name;
SELECT COUNT(*) AS eventos_7_dias,
       MIN(event_timestamp) AS primero,
       MAX(event_timestamp) AS ultimo
FROM   unified_audit_trail
WHERE  event_timestamp > SYSTIMESTAMP - INTERVAL '7' DAY;
SELECT dbusername, action_name, COUNT(*) AS eventos
FROM   unified_audit_trail
WHERE  event_timestamp > SYSTIMESTAMP - INTERVAL '7' DAY
GROUP  BY dbusername, action_name
ORDER  BY eventos DESC
FETCH FIRST 15 ROWS ONLY;
SELECT grantee, granted_role
FROM   dba_role_privs
WHERE  granted_role IN ('AUDIT_ADMIN','AUDIT_VIEWER')
ORDER  BY granted_role, grantee;
SELECT parameter_name, parameter_value, audit_trail
FROM   dba_audit_mgmt_config_params
ORDER  BY parameter_name;

PROMPT
PROMPT ===== D15 Datos borrados en la papelera  [A8.10] =====
SELECT owner, original_name, type, droptime
FROM   dba_recyclebin
WHERE  owner IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N')
ORDER  BY droptime DESC;

PROMPT
PROMPT ===== D16 Parches aplicados  [A8.8] =====
SELECT patch_id, action, status, action_time, description
FROM   dba_registry_sqlpatch
ORDER  BY action_time;

PROMPT
PROMPT ===== D17 Ubicación de logs y trazas  [A8.15 / A5.33] =====
SELECT name, value FROM v$diag_info WHERE name IN ('ADR Home','Diag Trace','Diag Alert');

PROMPT
PROMPT ===== FIN DEL DIAGNÓSTICO =====
EXIT
