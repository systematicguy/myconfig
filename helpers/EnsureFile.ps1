function EnsureFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [string]$EncodingIfMissing = $null
    )

    $parentPath = Split-Path -Path $Path -Parent
    if (-not (Test-Path -Path $parentPath)) {
        Write-Host "Creating parent directory [$parentPath]..."
        New-Item -Path $parentPath -ItemType Directory -Force
    }
    
    if (-not (Test-Path -Path $Path)) {
        if ($EncodingIfMissing -eq $null) {
            Write-Host "Creating file [$Path]..."
            New-Item -Path $Path -ItemType File
        }
        else {
            Write-Host "Creating file [$Path] with encoding [$EncodingIfMissing]..."
            $null | Set-Content -Path $Path -Encoding $EncodingIfMissing
        }
    }
}
