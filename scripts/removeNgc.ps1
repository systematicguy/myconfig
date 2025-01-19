# Define the path to the folder
$folderPath = "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc"

# Take ownership of the folder and its subfolders/files
takeown /F $folderPath /R /D Y

# Grant full control permissions to the current user
icacls $folderPath /grant "$($env:USERNAME):(F)" /T /C

Write-Host "Ownership and full control permissions granted to the current user for the folder and its children."

Remove-Item -Path $folderPath -Recurse -Force

Write-Host "The folder and its children have been removed."

start-process ms-settings:signinoptions