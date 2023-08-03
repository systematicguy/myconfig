function ExecuteWithTimeout {
    param(
        [Parameter(Mandatory=$true)]
        [ScriptBlock]$CommandScriptBlock,

        [Parameter(Mandatory=$false)]
        [int]$TimeoutSeconds = 10,

        [Parameter(Mandatory=$false)]
        [ScriptBlock]$OnTimeoutScriptBlock = {
            throw "Command timed out after $using:TimeoutSeconds seconds."
        }
    )

    $job = Start-Job -ScriptBlock $CommandScriptBlock

    for ($i = 0; $i -lt $TimeoutSeconds; $i++) {
        if ($job.State -ne "Running") {
            break
        }
        Start-Sleep -Seconds 1
    }

    if ($job.State -eq "Running") {
        Stop-Job $job
        . $OnTimeoutScriptBlock
    }

    $result = Receive-Job -Job $job
    Write-Output $result
}
