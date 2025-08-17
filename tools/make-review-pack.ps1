$ErrorActionPreference = "Stop"
New-Item -Force -ItemType Directory review | Out-Null
try { $base = (git merge-base origin/main HEAD).Trim() } catch { $base = (git rev-parse HEAD~1).Trim() }
$files = git diff --name-status "$base...HEAD"
$stat  = git diff --stat "$base...HEAD"
$diff  = git diff --unified=3 "$base...HEAD"
$max = 120000
if ($diff.Length -gt $max) { $diff = $diff.Substring(0, $max) + "`n... (truncated) ..." }
@"
# Review Bundle

## Base
$base

## Changed files
$files

## Diffstat
$stat

## Diff (truncated)
```diff
$diff


"@ | Set-Content review/bundle.md -Encoding UTF8
Write-Host "Wrote review/bundle.md — paste it here for a deep audit."