param(
  [Parameter(Mandatory=$true)]
  [string[]]$Paths
)

foreach ($p in $Paths) {
  if (-not (Test-Path -LiteralPath $p)) { continue }
  $content = Get-Content -LiteralPath $p -Raw
  # Ensure stable Unicode handling (helps tools/editors detect UTF-8 reliably).
  Set-Content -LiteralPath $p -Value $content -Encoding utf8BOM
  Write-Host ("Re-encoded as UTF-8 BOM: " + $p)
}
