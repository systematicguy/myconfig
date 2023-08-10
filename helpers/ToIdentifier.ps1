function PathToIdentifier() {
    param (
        [string]$Path
    )
    return $Path.`
        Replace(":", "_").`
        Replace("/", "_").`
        Replace("\", "_").`
        Replace(".", "_").`
        Replace("-", "_").`
        Replace(" ", "_")
}

function UrlToIdentifier() {
    param (
        [string]$Url
    )
    return $Url.`
        Replace(":", "_").`
        Replace("/", "_").`
        Replace(".", "_").`
        Replace("-", "_").`
        Replace(" ", "_")
}