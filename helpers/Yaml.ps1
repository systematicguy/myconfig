. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\ToIdentifier.ps1
. $RepoRoot\helpers\Chocolatey.ps1
. $RepoRoot\helpers\EnsureFile.ps1

EnsureChocoPackage -Name "yq"

function EnsureYamlConfig {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        # mutually exclusive parameters for the configuration:
        [Parameter(Mandatory=$true, ParameterSetName = "configPath")]
        [string]$YamlConfigPath,
        [Parameter(Mandatory=$true, ParameterSetName = "configObject")]
        [hashtable]$YamlConfigObject,

        [Parameter(Mandatory=$false)]
        [scriptblock]$ScriptBeforeApplying = {}
    )

    EnsureFile `
        -Path $Path
        #-EncodingIfMissing ASCII

    # work dir with datetime string and identifier
    $workDir = "$DscWorkDir\$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')_$(PathToIdentifier $Path)"
    New-Item -Path $workDir -ItemType Directory -Force

    $targetFileName = Split-Path $Path -Leaf
    
    if ($PSCmdlet.ParameterSetName -eq "configPath") {
        $appliedConfigPath = $YamlConfigPath 
    } else {
        # produce intermediate file based on config object:
        $appliedConfigPath = "$workDir\config_object_$targetFileName"
        $YamlConfigObject | ConvertTo-Yaml -Depth 100 | Set-Content $appliedConfigPath -Encoding ASCII
    } 

    # produce preview copying target and apply:
    $previewPath = "$workDir\preview_$targetFileName"
    Copy-Item -Path $Path -Destination $previewPath -Force
    yq.exe --inplace ". * load(\`"$appliedConfigPath\`")" $previewPath

    # calculate difference between affected and applied config
    $targetDiff = Compare-Object `
        (yq.exe -P 'sort_keys(..)' -o=props $previewPath) `
        (yq.exe -P 'sort_keys(..)' -o=props $Path)
    
    if ($targetDiff.Count -eq 0) {
        Write-Host "[$Path] is up to date"
        return
    } 
    Write-Host "The following settings are missing or different in [$Path]:"
    ($targetDiff | Where-Object SideIndicator -eq "<=").InputObject | Write-Output

    # call script block before applying config
    & $ScriptBeforeApplying

    Write-Host "Adjusting [$Path] ..."
    # apply config on top of original, recursively merging objects
    # yq.exe --inplace '. * load(\"applied.yaml\")' .\target.yaml
    yq.exe --inplace ". * load(\`"$appliedConfigPath\`")" $Path
}