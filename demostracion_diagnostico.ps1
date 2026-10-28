# =====================================================================
# demostracion_diagnostico.ps1
# EIF402 - Controles ISO 27001:2022 - Joseph Elías Ulate Aguilar
# Ejecuta el diagnóstico de confidencialidad (SOLO LECTURA) sobre el
# contenedor Oracle y guarda la evidencia en una carpeta con fecha.
#
# Uso, desde la carpeta del proyecto:
#   powershell -ExecutionPolicy Bypass -File .\demostracion_diagnostico.ps1
# =====================================================================

$contenedor = "oracle-eliasulate"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
Set-Location $PSScriptRoot

Write-Host "1/6 Verificando que el contenedor esté encendido..." -ForegroundColor Cyan
$estado = docker inspect -f "{{.State.Running}}" $contenedor 2>$null
if ($estado -ne "true") {
    Write-Host "   El contenedor está apagado; encendiéndolo..." -ForegroundColor Yellow
    docker start $contenedor | Out-Null
}

Write-Host "2/6 Esperando a que FREEPDB1 esté abierta (puede tardar 1 a 3 minutos)..." -ForegroundColor Cyan
$abierta = $false
for ($i = 1; $i -le 36; $i++) {
    $r = docker exec $contenedor bash -c "echo 'SELECT name, open_mode FROM v`$pdbs;' | sqlplus -s / as sysdba" 2>$null
    if (($r -join "`n") -match 'FREEPDB1\s+READ WRITE') { $abierta = $true; break }
    Write-Host "   Todavía no abre (intento $i de 36); reintento en 5 segundos..."
    Start-Sleep -Seconds 5
}
if (-not $abierta) {
    Write-Host "FREEPDB1 no abrió en 3 minutos. Revise con: docker logs --tail 50 $contenedor" -ForegroundColor Red
    exit 1
}

$marca   = Get-Date -Format "yyyy-MM-dd_HHmm"
$destino = Join-Path "evidencias" $marca
New-Item -ItemType Directory -Force $destino | Out-Null

Write-Host "3/6 Copiando el script SQL al contenedor..." -ForegroundColor Cyan
docker cp diagnostico_confidencialidad.sql "${contenedor}:/tmp/diagnostico_confidencialidad.sql"

Write-Host "4/6 Ejecutando el diagnóstico D00-D17 (solo lectura)..." -ForegroundColor Cyan
docker exec $contenedor sqlplus -s "/ as sysdba" "@/tmp/diagnostico_confidencialidad.sql" |
    Out-File -Encoding utf8 "$destino\D-linea-base.txt"

if ((Get-Item "$destino\D-linea-base.txt").Length -lt 1000) {
    Write-Host "El diagnóstico salió vacío o incompleto. Revise $destino\D-linea-base.txt" -ForegroundColor Red
    exit 1
}

Write-Host "5/6 Revisando puertos publicados, listener y sqlnet.ora..." -ForegroundColor Cyan
docker port $contenedor | Out-File -Encoding utf8 "$destino\D-red.txt"
docker exec $contenedor lsnrctl status | Out-File -Encoding utf8 -Append "$destino\D-red.txt"
docker exec $contenedor bash -c 'cat $ORACLE_HOME/network/admin/sqlnet.ora' |
    Out-File -Encoding utf8 -Append "$destino\D-red.txt"

Write-Host "6/6 Listo. Evidencia guardada en $destino" -ForegroundColor Green
Get-ChildItem $destino | Format-Table Name, Length, LastWriteTime
