. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\Downloader.ps1

# https://www.copytrans.net/download-zip?program=CTH
$copyTransHeicDownloadUrl = "https://www.copytrans.net/bin/CopyTransHEICforWindowsv2.000.exe"

$copyTransHeicExePath = EnsureDownloadedUrl `
    -Url $copyTransHeicDownloadUrl `
    -DownloadedPath $copyTransHeicExePath

LogTodo -Message "Please install CopyTrans HEIC for Windows from [$copyTransHeicExePath] manually"