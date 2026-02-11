param(
  [string]$Root = ".",
  [string[]]$Extensions = @(".py", ".md", ".json", ".bat", ".txt", ".yml", ".yaml", ".toml", ".ini", ".cfg"),
  [string[]]$ExcludePathContains = @("\autobots-env\", "\assets\")
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

# Revert specific compound-name substitutions that would otherwise imply renaming folders/files.
$pairs = @(
  @("Autobots-ai", "autobots-ai"),
  @("Autobots-env", "autobots-env"),
  @("assets/Autobots-logo.png", "assets/autobots-logo.png"),
  @("company/Autobots-ai", "company/autobots-ai")
)

$updated = 0
foreach ($f in $files) {
  try {
    $content = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction Stop
  } catch {
    continue
  }
  if ($null -eq $content) { continue }

  $new = $content
  foreach ($p in $pairs) {
    $new = $new.Replace($p[0], $p[1])
  }

  if ($new -ne $content) {
    Set-Content -LiteralPath $f.FullName -Value $new -Encoding utf8
    $updated += 1
  }
}

Write-Host ("Reverted compound-name changes in files: " + $updated)
