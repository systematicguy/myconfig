. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

# as seen on https://gaelcolas.com/2017/11/05/pseudo-splatting-dsc-resources/
function Get-DscSplattedResource {
    [CmdletBinding()]
    Param(
        [String]
        $ResourceName,

        [String]
        $ExecutionName,

        [hashtable]
        $Properties
    )
    
    $stringBuilder = [System.Text.StringBuilder]::new()
    $null = $stringBuilder.AppendLine("Param([hashtable]`$Parameters)")
    $null = $stringBuilder.AppendLine(" $ResourceName $ExecutionName { ")
    foreach($PropertyName in $Properties.keys) {
        $null = $stringBuilder.AppendLine("  $PropertyName = `$(`$Parameters['$PropertyName'])")
    }
    $null = $stringBuilder.AppendLine("}")
    #Write-Host ("Generated Resource Block = {0}" -f $stringBuilder.ToString())
    
    [scriptblock]::Create($stringBuilder.ToString()).Invoke($Properties)
}