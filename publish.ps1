#!/usr/bin/env pwsh
# Rebuild the outdoor log from its source folder and publish to GitHub Pages.
# Usage:  .\publish.ps1
# See CLAUDE.md. --out must stay "docs": build_site.py calls shutil.rmtree on it,
# so pointing it at the repo root would delete .git.

$ErrorActionPreference = "Stop"

$py     = "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe"
$source = "G:\My Drive\claude_cowork\OUTPUTS\Outdoor Log"
$repo   = $PSScriptRoot
$out    = Join-Path $repo "docs"

if (-not (Test-Path $py))     { throw "Python not found at $py" }
if (-not (Test-Path $source)) { throw "Source folder not found: $source (is Google Drive mounted?)" }

& $py (Join-Path $source "build_site.py") --root $source --out $out
if ($LASTEXITCODE -ne 0) { throw "build_site.py failed with exit code $LASTEXITCODE" }

# build_site.py deletes and recreates docs/, so both of these must be rewritten
# on every build. CNAME is what keeps the custom domain bound to the site;
# .nojekyll stops Pages running the files through Jekyll.
Set-Content -Encoding ascii -NoNewline (Join-Path $out "CNAME") "wildlife.lauriebryce.com"
Set-Content -Encoding ascii -NoNewline (Join-Path $out ".nojekyll") ""

# Guard the two constraints that matter most, in case the source drifts.
$index = Get-Content (Join-Path $out "index.html") -Raw
if ($index -notmatch 'name="robots"\s+content="noindex') { throw "ABORT: noindex meta tag missing from built index.html" }
if ($index -notmatch 'name="referrer"\s+content="no-referrer"') { throw "ABORT: no-referrer meta tag missing from built index.html" }

git -C $repo add -A
if (git -C $repo status --porcelain) {
    git -C $repo commit -m "Rebuild site"
    git -C $repo push
    Write-Host "Published. GitHub Pages usually redeploys within a minute." -ForegroundColor Green
} else {
    Write-Host "Nothing changed - no commit made." -ForegroundColor Yellow
}
