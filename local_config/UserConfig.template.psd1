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

    WindowsTerminal = @{
        "settings.json" = @{
            # theme = "system"
        }
    }

    Wsl = @{
        Distro   = "https://aka.ms/wslubuntu2204"  # https://learn.microsoft.com/en-us/windows/wsl/install-manual#downloading-distributions
        UserName = "david"

        # https://learn.microsoft.com/en-us/windows/wsl/wsl-config
        ".wslconfig" = @{
            wsl2 = @{
                # https://joe.blog.freemansoft.com/2022/01/setting-your-memory-and-swap-for-wsl2.html
                memory     = "2GB"
                swap       = "4GB"
                # processors = 4
                # guiApplications = "false"
            }
        }
        "/etc/wsl.conf" = @{
            interop = @{
                enabled = "false"
                appendWindowsPath = "false"
            }
            automount = @{
                options = "metadata,umask=22,fmask=111"
            }
        }
    }

    DockerDesktop = @{
        mayStopDockerDesktop = $false  # if $false, the script will throw an error if docker desktop is running 
        fallbackSettingsVersion = 29  # if no settings.json present, this will be the default value of "settingsVersion"
        "settings.json" = @{
            #  https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json?view=powershell-7.3#-noenumerate

            #integratedWslDistros = @()
            enableIntegrationWithDefaultWslDistro = $true
            #displaySwitchWinLinContainers = $true
            
            autoStart = $false
            #activeOrganizationName = ""
            #useCredentialHelper = $true
            #credentialHelper = "docker-credential-wincred.exe"
            disableTips = $true
            disableUpdate = $false
            #openUIOnStartupDisabled = $false
            analyticsEnabled = $true
            
            disableHardwareAcceleration = $false
            displayRestartDialog = $true
            #displayedElectronPopup = @()
            
            acceptCanaryUpdates = $false
            useNightlyBuildUpdates = $false
            autoDownloadUpdates = $true
            
            themeSource = "system"
            #containerTerminal = "integrated"
            #allowExperimentalFeatures = $true
            
            # this contains merely logs:
            #dataFolder = "C:\\ProgramData\\DockerDesktop\\vm-data"
            
            # these are ineffective if turning on WSL integration (enableIntegrationWithDefaultWslDistro):
            #memoryMiB = 2048
            #swapMiB = 1024
            #cpus = 2
            #diskSizeMiB = 65536
            #diskTRIM = $true
            
            #vpnkitCIDR = "192.168.65.0/24"
            #socksProxyPort = 0
            #proxyHttpMode = "system"
            #overrideProxyHttp = ""
            #overrideProxyHttps = ""
            #overrideProxyExclude = ""

            #filesharingDirectories = @()
            
            #kubernetesEnabled = $false
            #showKubernetesSystemContainers = $false
            #kubernetesInitialInstallPerformed = $false
            
            #useGrpcfuse = $true
            #networkType = "gvisor"
            #useVpnkit = $true
            #vpnKitMaxPortIdleTime = 300
            #vpnKitTransparentProxy = $false
            
            useWindowsContainers = $false
            noWindowsContainers = $false
            
            wslEngineEnabled = $true
            #wslEnableGrpcfuse = $false
            runWinServiceInWslMode = $false
            #customWslDistroDir = ""
            
            licenseTermsVersion = 2
            
            #useContainerdSnapshotter = $false
            #lifecycleTimeoutSeconds = 600
            
            #enhancedContainerIsolation = $false
            
            #showMacInstall = $false
            
            #extensionsEnabled = $true
            #onlyMarketplaceExtensions = $false
            #showExtensionsSystemContainers = $false
            
            #useBackgroundIndexing = $true
            
            #dockerBinInstallPath = "system"
            
            #enableDefaultDockerSocket = $true
            
            #updateHostsFile = $false
            #requireVmnetd = $false
        }
    }

    KeyboardLanguagesInOrder = @("DE-ch", "EN-us", "HU-hu")

    Draft = $true
}
