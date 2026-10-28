# V-03: muestra si Windows escucha 1521 y 5500 en todas las interfaces
netstat -ano | findstr ":1521 :5500" | Out-File -Encoding utf8 evidencias\D-red-windows.txt
Get-Content evidencias\D-red-windows.txt
