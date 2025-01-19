# WIP
# ensure administrator:
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (! $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # elevate
    Start-Process powershell.exe -Verb runAs -ArgumentList "-NoExit", "-Command &{ &'$PSCommandPath' }"
}

