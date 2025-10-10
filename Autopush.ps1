# Autopush.ps1 (polling, simple & robust)
# يراقب مجلد المشروع كل 3 ثواني: لو فيه تغييرات -> git add + commit + push

param([string]$Path=".", [string]$Branch="main")

$ErrorActionPreference = "SilentlyContinue"

# حدد المسار الكامل للمجلد المراد مراقبته
$Path = (Resolve-Path $Path).Path

# حدد مسار git (إن لم يكن في PATH)
$git = Join-Path $env:ProgramFiles 'Git\cmd\git.exe'
if (-not (Test-Path $git)) { $git = 'git' }

Set-Location $Path
Write-Host "Polling $Path (branch: $Branch). Press Ctrl+C to stop."
Write-Host "Using git at: $git"

try {
  while ($true) {
    # لو فيه أي تغييرات غير مضافة/ملتزم بها
    $changes = & $git status --porcelain
    if ($changes) {
      & $git add -A
      & $git commit -m ("[auto] sync: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) | Out-Null
      $pushOut = & $git push origin $Branch 2>&1
      if ($LASTEXITCODE -eq 0) {
        Write-Host ("Pushed at " + (Get-Date -Format "HH:mm:ss"))
      } else {
        Write-Host "Push failed:"
        Write-Host $pushOut
      }
    }
    Start-Sleep -Seconds 3
  }
}
finally {
  Write-Host "Stopped."
}
