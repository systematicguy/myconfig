. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\EnsureScheduledTaskAndStart.ps1

. $RepoToolsDir\GitConfig.ps1
. $RepoToolsDir\SshKey.ps1
. $RepoToolsDir\PowershellConfig.ps1  # TODO validate if still needed

$sshAgentScriptPath = "$RepoRoot\config\powershell_profile\ssh_agent_for_git.ps1"

$outputFile = "$DscWorkDir\SshAgentForGit.txt"
Configuration SshAgent
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName PowerShellModule

    Node "localhost"
    {        
        # I password-protect my ssh keys. The git config credential.helper manager-core is taking care of my interactive shells.
        # There are use cases when I need to employ non-interactive shells to clone from ssh://git@...  urls. 
        # One use case is package managers using git dependencies.
        # The followings come because of this requirement:
        PSModuleResource PoshGit
        {
            PsDscRunAsCredential = $UserCredential
            Module_Name          = "posh-git"
            InstallScope         = 'currentuser'
            Ensure               = "Present"
        }

        # https://github.com/dahlbyk/posh-sshell
        PSModuleResource PoshSshell
        {
            PsDscRunAsCredential = $UserCredential
            Module_Name          = "posh-sshell"
            InstallScope         = 'currentuser'
            Ensure               = "Present"
        }

        Service SshAgent 
        {
            DependsOn  = @("[PSModuleResource]PoshGit", "[PSModuleResource]PoshSshell")
            Name        = "Ssh-Agent"
            StartupType = "Manual"
            State       = "Running"
        }
    }
}
ApplyDscConfiguration "SshAgent"

EnsureScheduledTaskAndStart `
    -TaskName "Start SSH Agent" `
    -ScriptPath $sshAgentScriptPath `
    -SkipStartDecisionScript {
        $runningProcesses = Get-Process Ssh-Agent -ErrorAction SilentlyContinue
        if ($runningProcesses) {
            $true
        } else {
            $false
        }
    }

LogTodo -Message "To reload and add new ssh keys, start powershell and execute ssh-add"
