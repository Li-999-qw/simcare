$ErrorActionPreference='Stop'
$root=$PSScriptRoot
if(Test-Path "$root/nginx/logs/nginx.pid"){& "$root/nginx/nginx.exe" -p "$root/nginx/" -s quit}
$procs=Get-CimInstance Win32_Process | Where-Object { $_.Name -in @('python.exe','pythonw.exe') -and $_.ExecutablePath -like "$root\*" -and $_.CommandLine -like ('*'+$root+'*') }
foreach($proc in $procs){Stop-Process -Id $proc.ProcessId}
Write-Host 'Package processes stopped. Data retained.'
