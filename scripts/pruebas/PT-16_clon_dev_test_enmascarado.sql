-- PT-16: Clon DEV/TEST enmascarado
-- Qué demuestra: Crea una copia de prueba de la base y comprueba que los datos personales quedan ocultos.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-16  Clon DEV/TEST enmascarado (SYS AS SYSDBA)
SPOOL evidencias/PT-16.txt
ALTER SESSION SET CONTAINER = CDB$ROOT;
CREATE PLUGGABLE DATABASE pdb_test FROM freepdb1
  FILE_NAME_CONVERT = ('/FREEPDB1/','/PDB_TEST/');
ALTER PLUGGABLE DATABASE pdb_test OPEN;
ALTER SESSION SET CONTAINER = pdb_test;

-- Enmascaramiento: solo en el clon, nunca en FREEPDB1
UPDATE app_owner.clientes
SET    cedula   = LPAD(TRUNC(DBMS_RANDOM.VALUE(100000000, 999999999)), 9, '0'),
       correo   = 'cliente' || id_cliente || '@ejemplo.test',
       telefono = '0000-0000',
       nombre   = 'Cliente ' || id_cliente;
COMMIT;

SELECT COUNT(*) AS correos_sin_enmascarar
FROM   app_owner.clientes
WHERE  correo NOT LIKE '%@ejemplo.test';            -- esperado 0

SELECT COUNT(*) AS cedulas_originales
FROM   app_owner.clientes
WHERE  cedula IN ('100000001','100000002','100000003','100000999');   -- esperado 0
SPOOL OFF
