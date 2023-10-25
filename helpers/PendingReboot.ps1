function EnsureNoPendingReboot {
    $rebootPending = (Test-PendingReboot -SkipPendingFileRenameOperationsCheck -SkipConfigurationManagerClientCheck).IsRebootPending
    if ($rebootPending) {
        Write-Host "Reboot is pending, cannot continue"
        throw "Reboot is pending, cannot continue"
    }
}
