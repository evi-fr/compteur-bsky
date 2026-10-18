# Run after editing index.html and before committing a publication.
$ErrorActionPreference = 'Stop'
$pagePath = Join-Path $PSScriptRoot 'index.html'
$pageSource = [IO.File]::ReadAllText($pagePath)
$versionPattern = '<meta name="app-version" content="[^"]*">'
if ($pageSource -notmatch $versionPattern) { throw 'Missing app-version metadata.' }
$normalized = [regex]::Replace($pageSource, $versionPattern, '<meta name="app-version" content="">').Replace("`r`n", "`n")
$hasher = [Security.Cryptography.SHA256]::Create()
try { $version = ([BitConverter]::ToString($hasher.ComputeHash([Text.Encoding]::UTF8.GetBytes($normalized)))).Replace('-', '').ToLowerInvariant().Substring(0, 16) }
finally { $hasher.Dispose() }
$pageSource = [regex]::Replace($normalized, $versionPattern, '<meta name="app-version" content="' + $version + '">')
$encoding = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText($pagePath, $pageSource, $encoding)
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'bluesky.html'), $pageSource, $encoding)
Write-Output "Publication prepared: $version (index.html and bluesky.html synchronized)"
