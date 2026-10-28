-- PT-03: Prueba negativa de mínimo privilegio
-- Qué demuestra: Demuestra que un usuario sin permiso no puede leer ni modificar una tabla.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-03  Prueba negativa de mínimo privilegio
SPOOL evidencias/PT-03.txt

-- 1) Conectado como USR_CONSULTA, sin grant:
SELECT * FROM app_owner.clientes;
-- Esperado: ORA-00942: table or view does not exist

-- 2) Conectado como APP_OWNER:
GRANT SELECT ON app_owner.clientes TO usr_consulta;

-- 3) De nuevo como USR_CONSULTA:
UPDATE app_owner.clientes SET salario = 0;
-- Esperado: ORA-01031: insufficient privileges
SPOOL OFF
