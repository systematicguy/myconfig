function EnsureFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$false)]
        [string]$EncodingIfMissing = $null,

        [Parameter(Mandatory=$false)]
        [string]$ContentIfMissing = ""
    )

    $parentPath = Split-Path -Path $Path -Parent
    if (-not (Test-Path -Path $parentPath)) {
        Write-Host "Creating parent directory [$parentPath]..."
        New-Item -Path $parentPath -ItemType Directory -Force
    }
    
    if (-not (Test-Path -Path $Path)) {
        if ("$EncodingIfMissing" -eq "") {
            Write-Host "Creating file [$Path]..."
            New-Item -Path $Path -ItemType File

            if ("$ContentIfMissing" -ne "") {
                $ContentIfMissing | Out-File -FilePath $Path
            }
        }
        else {
            Write-Host "Creating file [$Path] with encoding [$EncodingIfMissing]..."
            $null | Set-Content -Path $Path -Encoding $EncodingIfMissing

            if ("$ContentIfMissing" -ne "") {
                $ContentIfMissing | Out-File -FilePath $Path -Encoding $EncodingIfMissing
            }
        }
        
    }
}
