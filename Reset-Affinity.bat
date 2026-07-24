@echo off
chcp 65001 >nul
setlocal

:: 检查管理员权限 (Check Admin Rights)
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 正在请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ----------------------------------------------------
echo Off-CCD 一键还原核心分配与优先级
echo 正在还原系统中所有运行中进程的核心分配...
echo ----------------------------------------------------
echo.

:: 执行核心 PowerShell 还原逻辑 (Execute PowerShell reset logic inline)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$defaultAffinity = (Get-Process -Id $PID).ProcessorAffinity; $count=0; foreach ($p in (Get-Process | Where-Object { $_.Id -ne 0 -and $_.Id -ne 4 -and $_.Id -ne $PID })) { try { $p.ProcessorAffinity = $defaultAffinity; $p.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal; $count++ } catch {} }; Write-Host '还原成功！已将 ' $count ' 个进程还原为系统默认状态（全核心调度/普通优先级）。' -ForegroundColor Green"

echo.
pause
