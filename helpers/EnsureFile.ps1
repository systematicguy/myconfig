function EnsureFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [System.Text.Encoding]$EncodingIfMissing = $null
    )

    $parentPath = Split-Path -Path $Path -Parent
    if (-not (Test-Path -Path $parentPath)) {
        New-Item -Path $parentPath -ItemType Directory -Force
    }
    
    if (-not (Test-Path -Path $Path)) {
        if ($EncodingIfMissing -eq $null) {
            New-Item -Path $Path -ItemType File
        }
        else {
            $null | Set-Content -Path $Path -Encoding $EncodingIfMissing
        }
    }
}
