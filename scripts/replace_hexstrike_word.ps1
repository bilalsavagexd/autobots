param(
  [string]$Root = ".",
  [string[]]$Extensions = @(".py", ".md", ".json", ".bat", ".txt", ".yml", ".yaml", ".toml", ".ini", ".cfg"),
  [string[]]$ExcludePathContains = @("\autobots-env\", "\assets\"),
  # Replace the standalone "autobots" token (any case) but DO NOT touch compound names like
  # "autobots-ai", "autobots_env", "autobots-env", etc.
  [string]$Pattern = "(?i)(?<![A-Za-z0-9_-])autobots(?![A-Za-z0-9_-])",
  [string]$Replacement = "Autobots"
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

$updated = 0
$touched = New-Object System.Collections.Generic.List[string]

foreach ($f in $files) {
  try {
    $content = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction Stop
  } catch {
    continue
  }

  if ($null -eq $content) { continue }
  if ($content -notmatch $Pattern) { continue }

  $newContent = [regex]::Replace($content, $Pattern, $Replacement)
  if ($newContent -eq $content) { continue }

  Set-Content -LiteralPath $f.FullName -Value $newContent -Encoding utf8
  $updated += 1
  $touched.Add($f.FullName) | Out-Null
}

Write-Host ("Updated files: " + $updated)
if ($updated -gt 0) {
  Write-Host "Touched:"
  $touched | Sort-Object | ForEach-Object { Write-Host (" - " + $_) }
}
