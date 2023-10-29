. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\FindLatestToolLexicographically.ps1

function SetupJetbrainsContextMenus {
    param (
        [string]$ToolName
    )

    $toolRootDir = FindLatestToolLexicographically -Vendor "JetBrains" -Tool $toolName

    $jetbrainsToolContextMenuConfigName = "JetbrainsToolContextMenu_$($toolName)"
    Configuration $jetbrainsToolContextMenuConfigName
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node "localhost" 
        {
            Script SetupContextMenus 
            {
                Credential = $UserCredential

                GetScript = {
                    # Do nothing
                }
                TestScript = {
                    $false  # always
                }
                SetScript = {
                    $toolName = $using:ToolName
                    $toolRootDir = $using:toolRootDir
                    $toolPath = "$toolRootDir\bin\$($toolName.ToLower())64.exe"
                    $toolIconPath = "$toolRootDir\bin\$($toolName.ToLower()).ico"
                    $subPath2Command = @{
                        "*"                    = "$toolPath `"%1`""  # file context menu
                        "Directory"            = "$toolPath `"%1`""  # dir context menu
                        "Directory\Background" = "$toolPath `"%V`""  # dir background context menu
                    }
                    New-PSDrive -Name "HKCR" -PSProvider Registry -Root HKEY_CLASSES_ROOT
                    foreach ($subPath in $subPath2Command.Keys) {
                        $regRootPath = "HKCR:\$subPath\shell\$toolName"
                        If (-not (Test-Path -LiteralPath $regRootPath)) {
                            New-Item -Path $regRootPath -Force
                        }
                        Set-Item -LiteralPath $regRootPath -Value "Open with $toolName" -Force
                        
                        Set-ItemProperty -LiteralPath $regRootPath -Name "Icon" -Type ExpandString -Value $toolIconPath -Force
                        
                        $regCmdPath = "$regRootPath\command"
                        If (-not (Test-Path -LiteralPath $regCmdPath)) {                    
                            New-Item -Path $regCmdPath -Force
                        }
                        Set-Item -LiteralPath $regCmdPath -Type String -Value $subPath2Command[$subPath] -Force
                    }
                }
            }
        }
    }
    ApplyDscConfiguration $jetbrainsToolContextMenuConfigName
}