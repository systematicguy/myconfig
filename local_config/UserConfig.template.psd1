@{
    # see more: Computer\HKEY_CURRENT_USER\Volatile Environment
    CorpDomain = "BIG"
    UserName   = "horvathda"
    UserDir    = "C:\Users\horvathda"
    UserBinDir = "C:\Users\horvathda\bin"
    NoProxy    = "localhost"

    PxProxy = @{
        Version = "0.8.3"  # https://github.com/genotrance/px/issues/182
        PxIni = @{
            proxy = @{
                #server   = 
                #auth     = "BASIC"
                #username = 
                gateway  = 1
                # make sure there are no localhost, 127.0.0.* in the following list:
                #noproxy  = 
            }
            settings = @{
                workers = 5
            }
        }
    }

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

    Wsl = @{
        Distro   = "https://aka.ms/wslubuntu2204"  # https://learn.microsoft.com/en-us/windows/wsl/install-manual#downloading-distributions
        UserName = "david"
    }

    KeyboardLanguagesInOrder = @("DE-ch", "EN-us", "HU-hu")

    Draft = $true
}
