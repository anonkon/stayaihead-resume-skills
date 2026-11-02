# Installs the stayaihead-resume-skills Claude Code skills into ~/.claude/skills/
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1
$ErrorActionPreference = "Stop"

$SrcDir = Join-Path $PSScriptRoot "skills"
$DestDir = Join-Path $HOME ".claude\skills"
$Skills = @("build-profile", "tailor-job", "no-ai-slop")

New-Item -ItemType Directory -Force -Path $DestDir | Out-Null

foreach ($skill in $Skills) {
    $target = Join-Path $DestDir $skill
    if (Test-Path $target) {
        $ans = Read-Host "Skill '$skill' already exists at $target. Overwrite? [y/N]"
        if ($ans -notmatch '^[Yy]$') {
            Write-Host "Skipping $skill"
            continue
        }
        Remove-Item -Recurse -Force $target
    }
    Copy-Item -Recurse (Join-Path $SrcDir $skill) $target
    Write-Host "Installed $skill -> $target"
}

New-Item -ItemType Directory -Force -Path (Join-Path $HOME ".claude\resume") | Out-Null

Write-Host ""
Write-Host "Done. In Claude Code, run:"
Write-Host "  /build-profile   to set up your career profile"
Write-Host "  /tailor-job      to generate a tailored CV + cover letter for a job description"
