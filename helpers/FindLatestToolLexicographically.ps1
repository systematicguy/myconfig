function FindLatestToolLexicographically {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Vendor,

        [Parameter(Mandatory=$true)]
        [string]$Tool,

        [string]$ExistingChildPath = $null
    )

    $programFilesVendor = "$Env:ProgramFiles\$Vendor"
    # if not there, switch to x86
    if (-not (Test-Path $programFilesVendor)) {
        $programFilesVendor = "$Env:ProgramFiles (x86)\$Vendor"
    }

    # Look for all directories containing the given tool
    $toolDirs = Get-ChildItem $programFilesVendor -Filter "$Tool*" | Where-Object {
        if ($null -ne $ExistingChildPath) {
            Test-Path (Join-Path $_.FullName -ChildPath $ExistingChildPath)
        } else {
            $true
        }
    }

    # Sort the directories based on name and return the first one
    $latestToolDir = $toolDirs | Sort-Object -Property Name -Descending | Select-Object -First 1

    return $latestToolDir.FullName
}
