-- PT-06: TDE: keystore y tablespace cifrado
-- Qué demuestra: Cifra un espacio de la base y comprueba que su archivo no se puede leer directamente.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-06  TDE: keystore y tablespace cifrado
-- 1) Estado actual (ejecutable ya, en CDB$ROOT)
SELECT con_id, wrl_type, wrl_parameter, status, wallet_type, keystore_mode
FROM   v$encryption_wallet;
SELECT name, value FROM v$parameter WHERE name IN ('wallet_root','tde_configuration');

-- 2) Configuración en CDB$ROOT (docker exec -it oracle-eliasulate sqlplus / as sysdba)
--    Anfitrión: docker exec oracle-eliasulate mkdir -p /opt/oracle/oradata/wallet
--    Nota para el informe: el keystore junto a los datafiles es comodidad de laboratorio;
--    en producción se guarda en otro medio.
ALTER SYSTEM SET wallet_root = '/opt/oracle/oradata/wallet' SCOPE = SPFILE;
SHUTDOWN IMMEDIATE
STARTUP
ALTER PLUGGABLE DATABASE ALL OPEN;
ALTER SYSTEM SET tde_configuration = 'KEYSTORE_CONFIGURATION=FILE' SCOPE = BOTH;
ADMINISTER KEY MANAGEMENT CREATE KEYSTORE IDENTIFIED BY &clave_keystore;
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY &clave_keystore CONTAINER = ALL;
ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY &clave_keystore WITH BACKUP CONTAINER = ALL;
-- Si el contenedor se detiene al apagar la base: docker start oracle-eliasulate

-- 3) Tablespace nuevo cifrado en FREEPDB1
ALTER SESSION SET CONTAINER = FREEPDB1;
CREATE TABLESPACE ts_conf
  DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/ts_conf01.dbf' SIZE 50M
  ENCRYPTION USING 'AES256' ENCRYPT;
ALTER USER app_owner QUOTA 10M ON ts_conf;
SELECT tablespace_name, encrypted FROM dba_tablespaces ORDER BY 1;

-- 4) Prueba de efectividad
CREATE TABLE app_owner.prueba_tde_cifrada (txt VARCHAR2(50)) TABLESPACE ts_conf;
CREATE TABLE app_owner.prueba_tde_plana   (txt VARCHAR2(50)) TABLESPACE users;
INSERT INTO app_owner.prueba_tde_cifrada VALUES ('MARCA-PRUEBA-TDE');
INSERT INTO app_owner.prueba_tde_plana   VALUES ('MARCA-PRUEBA-TDE');
COMMIT;
ALTER SYSTEM CHECKPOINT;
SELECT file_name FROM dba_data_files;   -- confirma las rutas

-- Anfitrión (guardar ambas salidas):
--   docker exec oracle-eliasulate grep -c -a MARCA-PRUEBA-TDE /opt/oracle/oradata/FREE/FREEPDB1/ts_conf01.dbf
--   docker exec oracle-eliasulate grep -c -a MARCA-PRUEBA-TDE /opt/oracle/oradata/FREE/FREEPDB1/users01.dbf
