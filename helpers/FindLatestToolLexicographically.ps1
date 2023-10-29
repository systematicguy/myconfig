function FindLatestToolLexicographically {
    param (
        # param for vendor
        [Parameter(Mandatory=$true)]
        [string]$Vendor,

        [Parameter(Mandatory=$true)]
        [string]$Tool
    )

    $programFilesVendor = "$Env:ProgramFiles\$Vendor"
    # if not there, switch to x86
    if (-not (Test-Path $programFilesVendor)) {
        $programFilesVendor = "$Env:ProgramFiles (x86)\$Vendor"
    }
    # look for the latest version of given tool
    $toolDir = Get-ChildItem $programFilesVendor -Filter "$Tool*" | Sort-Object -Property Name -Descending | Select-Object -First 1
    return $toolDir.FullName
}