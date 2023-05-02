. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

Configuration PowerConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName GroupPolicyDsc

    Node "localhost"
    {
        Registry "HibernateEnabled"  
        {
            Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power"
            ValueName = "HibernateEnabled"
            ValueType = "Dword"
            ValueData = 1
        }

        Registry "System_ShowHibernateOption"  
        {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System"
            ValueName = "ShowHibernateOption"
            ValueType = "Dword"
            ValueData = 1
        }

        Registry "Explorer_ShowHibernateOption"  
        {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer"
            ValueName = "ShowHibernateOption"
            ValueType = "Dword"
            ValueData = 1
        }
    }
}

ApplyDscConfiguration "PowerConfig"
