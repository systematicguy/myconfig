. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1

function isNumeric($x) {
    return $x -is [byte]  -or $x -is [int16]  -or $x -is [int32]  -or $x -is [int64]  `
       -or $x -is [sbyte] -or $x -is [uint16] -or $x -is [uint32] -or $x -is [uint64] `
       -or $x -is [float] -or $x -is [double] -or $x -is [decimal]
}

function EnsureRegistry {
    param (
        [hashtable]$RegistryConfig,
        [string]$ValueType = "",
        [string]$Purpose = ""
    )

    if ($Purpose -eq "") {
        $Purpose = (Get-Date).ToString("yyyyMMddHHmmss")
    }
    $registryConfigName = "Registry_$Purpose"
    Configuration $registryConfigName
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node "localhost"
        {
            foreach ($regKey in $RegistryConfig.Keys) 
            {
                foreach ($valueName in $RegistryConfig[$regKey].Keys)
                {
                    $value = $RegistryConfig[$regKey][$valueName]
                    if ($ValueType -ne "") {
                        $thisValueType = $ValueType
                    } elseif (isNumeric($value)) {
                        $thisValueType = "Dword"
                    } elseif ($value -is [string]) {
                        $thisValueType = "String"
                    } else {
                        throw "Unable to determine value type for [$valueName] with value [$value] and type [$($value.GetType().Name)]"
                    }

                    Registry "$($registryConfigName)_$($regKey)_$($valueName)_$($thisValueType)"
                    {
                        PsDscRunAsCredential = $UserCredentialAtComputerDomain
                        
                        Key       = $regKey
                        ValueName = $valueName
                        ValueType = $thisValueType
                        ValueData = $value
                    }
                }
            }
        }
    }
    ApplyDscConfiguration $registryConfigName
}
