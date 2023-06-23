. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\ToIdentifier.ps1

function EnsureDownloadedUrl {
    param (
        [string]$Url,
        [string]$DownloadedPath = $null
    )

    if ($DownloadedPath -eq $null -or $DownloadedPath -eq "") {
        $DownloadedPath = "$DscWorkDir\$(Split-Path -Path $Url -Leaf)"
        Write-Host "No download path specified, using [$DownloadedPath]..."
    }

    if (Test-Path $DownloadedPath) {
        Write-Host "[$DownloadedPath] is already present, skipping download"
        return $DownloadedPath
    }
    
    Write-Host "Downloading [$Url] to [$DownloadedPath]..."
    $downloadConfigName = "Download_$(UrlToIdentifier $Url)"
    Configuration $downloadConfigName
    {
        Import-DscResource -ModuleName xPSDesiredStateConfiguration

        Node "localhost" 
        {
            xRemoteFile Download
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain

                DestinationPath = $DownloadedPath
                Uri             = $Url
            }
        }
    }
    ApplyDscConfiguration $downloadConfigName > $null  # suppress output to keep return value clean

    return $DownloadedPath
}

function EnsureExtractedUrl {
    param (
        [string]$Url,
        [string]$DownloadedPath = $null,
        [string]$ExtractedDir,
        [switch]$KeepDownloadedFile = $false
    )

    if (Test-Path $ExtractedDir) {
        Write-Host "[$ExtractedDir] is already present, skipping download and extraction"
        return
    }
    
    $DownloadedPath = EnsureDownloadedUrl -Url $Url -DownloadedPath $DownloadedPath
    Write-Host "Extracting [$DownloadedPath] to [$ExtractedDir] if needed..."
    $extractConfigName = "Extract_$(UrlToIdentifier $Url)"
    Configuration $extractConfigName
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node "localhost"
        {
            Archive Unzip
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain

                Ensure      = "Present"
                Path        = $DownloadedPath
                Destination = $ExtractedDir
            }
        }
    }
    ApplyDscConfiguration $extractConfigName

    if ($KeepDownloadedFile) {
        Write-Host "Keeping downloaded file [$DownloadedPath]..."
    } else {
        Write-Host "Removing downloaded file [$DownloadedPath]..."
        Remove-Item $DownloadedPath
    }
}
