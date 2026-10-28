-- PT-08: VPD: filtrado de filas por usuario
-- Qué demuestra: Demuestra que cada usuario ve solo sus propias filas.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-08  VPD: filtrado de filas por usuario
SPOOL evidencias/PT-08.txt
-- Como APP_OWNER:
CREATE OR REPLACE FUNCTION app_owner.fn_vpd_clientes (
  p_schema IN VARCHAR2,
  p_object IN VARCHAR2
) RETURN VARCHAR2
AS
BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') = 'APP_OWNER' THEN
    RETURN NULL;
  END IF;
  RETURN 'usuario_asignado = SYS_CONTEXT(''USERENV'',''SESSION_USER'')';
END;
/
BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema   => 'APP_OWNER',
    object_name     => 'CLIENTES',
    policy_name     => 'VPD_CLIENTES',
    function_schema => 'APP_OWNER',
    policy_function => 'FN_VPD_CLIENTES',
    statement_types => 'SELECT');
END;
/
GRANT SELECT ON app_owner.clientes TO usr_otro;

SELECT object_owner, object_name, policy_name, function, enable
FROM   dba_policies
WHERE  object_owner = 'APP_OWNER';

-- Como USR_CONSULTA, como USR_OTRO y como APP_OWNER:
SELECT COUNT(*) FROM app_owner.clientes;

-- Como SYS:
SELECT grantee FROM dba_sys_privs WHERE privilege = 'EXEMPT ACCESS POLICY';
SPOOL OFF
