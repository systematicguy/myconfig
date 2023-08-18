Get-Process | Where-Object { $_.ProcessName -eq "Spotify" } | ForEach-Object { Stop-Process -Id $_.Id -Force }
