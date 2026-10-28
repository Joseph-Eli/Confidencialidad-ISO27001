# V-02: repite el diagnóstico sobre FREEPDB2 (solo lectura)
[Console]::OutputEncoding = [Text.Encoding]::UTF8
(Get-Content diagnostico_confidencialidad.sql) -replace 'CONTAINER = FREEPDB1','CONTAINER = FREEPDB2' | Set-Content diagnostico_freepdb2.sql
docker cp diagnostico_freepdb2.sql oracle-eliasulate:/tmp/diagnostico_freepdb2.sql
docker exec oracle-eliasulate sqlplus -s "/ as sysdba" "@/tmp/diagnostico_freepdb2.sql" | Out-File -Encoding utf8 evidencias\D-freepdb2.txt
