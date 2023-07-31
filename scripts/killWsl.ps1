# get pskill via choco install -y pstools
$lxssManagerPID = Get-WmiObject Win32_Service | Where-Object { $_.Name -eq 'LxssManager' } | ForEach-Object { $_.ProcessId }
pskill -t $lxssManagerPID
