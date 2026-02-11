param(
  [string]$Root = ".",
  [string[]]$Extensions = @(".py", ".md", ".json", ".bat", ".txt", ".yml", ".yaml", ".toml", ".ini", ".cfg"),
  [string[]]$ExcludePathContains = @("\autobots-env\", "\assets\"),
  # Find the standalone "autobots" token (any case) but ignore compound names like "autobots-ai".
  [string]$Pattern = "(?i)(?<![A-Za-z0-9_-])autobots(?![A-Za-z0-9_-])"
)

$rootPath = (Resolve-Path -LiteralPath $Root).Path

$files =
  Get-ChildItem -Path $rootPath -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object {
    $full = $_.FullName
    $extOk = $Extensions -contains $_.Extension.ToLowerInvariant()
    if (-not $extOk) { return $false }
    foreach ($bad in $ExcludePathContains) {
      if ($full -like ("*" + $bad + "*")) { return $false }
    }
    return $true
  }

$hits = 0
foreach ($f in $files) {
  try {
    $content = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction Stop
  } catch {
    continue
  }
  if ($null -eq $content) { continue }
  if ($content -match $Pattern) {
    $hits += 1
    Write-Host ("MATCH: " + $f.FullName)
  }
}

if ($hits -eq 0) {
  Write-Host "No matches found."
} else {
  Write-Host ("Total files with matches: " + $hits)
  exit 2
}
