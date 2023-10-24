# Get all explorer.exe processes
$explorerProcesses = Get-Process explorer

# Stop all explorer.exe processes
$explorerProcesses | Stop-Process

# Start explorer.exe again
Start-Process explorer.exe
