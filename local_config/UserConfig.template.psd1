@{
    # see more: Computer\HKEY_CURRENT_USER\Volatile Environment
    CorpDomain = "BIG"
    UserName   = "horvathda"
    UserDir    = "C:\Users\horvathda"
    UserBinDir = "C:\Users\horvathda\bin"
    NoProxy    = "localhost"

    Git = @{
        UserName  = "horvathda"
        UserEmail = "david.horvath@big.com"
    }

    SshKey = @{
        Type            = "ed25519"
        Comment         = "david.horvath@big.com"
        KeyScannedHosts = @()
    }

    Python = @{
        GlobalVersion = "3.9.6"
        PipIndexUrl   = ""
        PoetryVersion = ""
    }

    Golang = @{
        Version = "1.16.15"
    }

    Terraform = @{
        Version = ""
        TfLintVersion = ""
    }

    KeyboardLanguagesInOrder = @("DE-ch", "EN-us", "HU-hu")

    Draft = $true
}
