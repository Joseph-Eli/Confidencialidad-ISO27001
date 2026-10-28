-- PT-07: Data Redaction sobre la cédula
-- Qué demuestra: Demuestra que la cédula aparece oculta para quien no debe verla.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-07  Data Redaction sobre la cédula
SPOOL evidencias/PT-07.txt
-- Como APP_OWNER:
BEGIN
  DBMS_REDACT.ADD_POLICY(
    object_schema => 'APP_OWNER',
    object_name   => 'CLIENTES',
    column_name   => 'CEDULA',
    policy_name   => 'RED_CLIENTES_CEDULA',
    function_type => DBMS_REDACT.FULL,
    expression    => q'[SYS_CONTEXT('USERENV','SESSION_USER') <> 'APP_OWNER']');
END;
/
SELECT object_owner, object_name, policy_name, expression, enable FROM redaction_policies;
SELECT object_name, column_name, function_type FROM redaction_columns;

-- Como USR_CONSULTA y luego como APP_OWNER:
SELECT id_cliente, cedula FROM app_owner.clientes FETCH FIRST 5 ROWS ONLY;

-- Como SYS:
SELECT grantee FROM dba_sys_privs WHERE privilege = 'EXEMPT REDACTION POLICY';
SPOOL OFF
