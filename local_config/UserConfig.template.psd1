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
        KeyScannedHosts = @("github.com")  # format: @("url1", "url2")
    }

    Python = @{
        GlobalVersion = "3.9.6"
        PipIndexUrl   = ""  # format: "https://artifactory.yourcompany.com/artifactory/api/pypi/pypi/simple"
        PoetryVersion = ""  # format: "1.4.1"
    }

    Golang = @{
        Version = "1.16.15"
    }

    Terraform = @{
        Version       = $null  # format: "1.2.2"
        TfLintVersion = $null
    }

    AwsDefaultRegion = "eu-central-1"

    KeyboardLanguagesInOrder = @("DE-ch", "EN-us", "HU-hu")

    Draft = $true
}
