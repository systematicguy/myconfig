. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\ToIdentifier.ps1
. $RepoRoot\helpers\Chocolatey.ps1

EnsureChocoPackage -Name "jq"

function EnsureJsonConfig {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        # mutually exclusive parameters for the configuration:
        [Parameter(Mandatory=$true, ParameterSetName = "jsonConfigPath")]
        [string]$JsonConfigPath,
        [Parameter(Mandatory=$true, ParameterSetName = "jsonConfigObject")]
        [hashtable]$JsonConfigObject,

        [Parameter(Mandatory=$false)]
        [scriptblock]$ScriptBeforeApplying = {}
    )

    # work dir with datetime string and identifier
    
    $workDir = "$DscWorkDir\$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')_$(PathToIdentifier $Path)"
    New-Item -Path $workDir -ItemType Directory -Force

    $targetFileName = Split-Path $Path -Leaf
    
    if ($PSCmdlet.ParameterSetName -eq "jsonConfigPath") {
        $appliedConfigPath = $JsonConfigPath 
    } else {
        # produce intermediate json file based on config object:
        $appliedConfigPath = "$workDir\config_object_$targetFileName"
        $JsonConfigObject | ConvertTo-Json -Depth 100 | Set-Content $appliedConfigPath -Encoding ASCII
    } 

    # produce intermediate json file based on target json file keeping only keys that are affected by the config:
    $affectedConfigPath = "$DscWorkDir\only_affected_$targetFileName"
    jq.exe --argfile appliedConfig $appliedConfigPath 'with_entries(select(.key | in($appliedConfig)))' $Path `
        | Set-Content $affectedConfigPath -Encoding ASCII

    # calculate difference between affected and applied config
    $configAdjustments = jq.exe --argfile affected "$affectedConfigPath" 'with_entries(select(.value != ($affected[.key])))' "$appliedConfigPath"
    if ($($configAdjustments | jq.exe 'keys | length') -eq 0) {
        Write-Host "[$Path] is up to date"
        return
    } 
    Write-Host "The following settings are missing or different in [$Path]:"
    $configAdjustments | Write-Output

    # call script block before applying config
    & $ScriptBeforeApplying

    Write-Host "Adjusting [$Path] ..."
    # apply config on top of original, recursively merging objects
    jq.exe -s '.[0] * .[1]' $Path $appliedConfigPath `
        | Set-Content $Path -Encoding ASCII
}