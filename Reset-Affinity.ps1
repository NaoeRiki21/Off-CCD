if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Resetting CPU affinity and priority for all running processes..." -ForegroundColor Cyan

# Calculate the true full mask for all logical processors, bypassing any inherited restrictions
$cores = [Environment]::ProcessorCount
if ($cores -ge 64) {
    $fullMask = [System.IntPtr]-1
} else {
    $fullMask = [System.IntPtr]((1L -shl $cores) - 1)
}

$processes = Get-Process | Where-Object { $_.Id -ne 0 -and $_.Id -ne 4 -and $_.Id -ne $PID }
$count = 0

foreach ($p in $processes) {
    try {
        $p.ProcessorAffinity = $fullMask
        $p.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal
        $count++
    } catch {
        # Ignore system protected processes or access denied
    }
}

Write-Host "Success! Reset $count processes to use all $cores cores (Normal Priority)." -ForegroundColor Green
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
