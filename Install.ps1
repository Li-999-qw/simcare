param()
$ErrorActionPreference='Stop'
$root=$PSScriptRoot
if($root -match '[^\x00-\x7F]'){throw 'Extract to an English path, e.g. C:\SimCare.'}
$conda=Get-Command conda -ErrorAction SilentlyContinue
if(-not $conda){throw 'Conda was not found. Add conda to PATH or run this script from an Anaconda PowerShell Prompt.'}
$envPath=Join-Path $root '.conda-env'
$python=Join-Path $envPath 'python.exe'
$condaHistory=Join-Path $envPath 'conda-meta\history'
if((Test-Path -LiteralPath $envPath) -and (-not(Test-Path -LiteralPath $python) -or -not(Test-Path -LiteralPath $condaHistory))){
 $failedEnv=Join-Path $root ('.conda-env.failed-'+(Get-Date -Format 'yyyyMMdd-HHmmss'))
 $rootFull=(Resolve-Path -LiteralPath $root).Path.TrimEnd('\')
 $envFull=[IO.Path]::GetFullPath($envPath)
 $failedFull=[IO.Path]::GetFullPath($failedEnv)
 $safePrefix=$rootFull+'\'
 if(-not $envFull.StartsWith($safePrefix,[StringComparison]::OrdinalIgnoreCase) -or
    -not $failedFull.StartsWith($safePrefix,[StringComparison]::OrdinalIgnoreCase) -or
    ((Get-Item -LiteralPath $envPath).Attributes -band [IO.FileAttributes]::ReparsePoint)){
  throw 'The incomplete Conda environment cannot be moved safely. Check .conda-env manually.'
 }
 Move-Item -LiteralPath $envPath -Destination $failedEnv
 Write-Warning "Preserved the incomplete Conda environment at $failedEnv"
}
$logs=Join-Path $root 'logs'
New-Item -ItemType Directory -Path $logs -Force | Out-Null
$condaLog=Join-Path $logs 'install-conda.log'
"Conda environment prefix: $envPath" | Set-Content -LiteralPath $condaLog -Encoding UTF8
$savedErrorPreference=$ErrorActionPreference
$ErrorActionPreference='Continue'
try {
 if(Test-Path -LiteralPath $python){
  & conda env update --prefix $envPath --file (Join-Path $root 'environment.yml') --prune *>&1 | Tee-Object -FilePath $condaLog -Append
 }else{
  & conda env create --prefix $envPath --file (Join-Path $root 'environment.yml') *>&1 | Tee-Object -FilePath $condaLog -Append
 }
 $condaExitCode=$LASTEXITCODE
}finally{
 $ErrorActionPreference=$savedErrorPreference
}
if($condaExitCode -ne 0){throw "Conda dependency installation failed. Full output: $condaLog"}
if(-not(Test-Path -LiteralPath $python)){throw 'Conda completed without creating python.exe'}
$env:PATH="$envPath;$envPath\Scripts;$envPath\Library\bin;$env:PATH"
& $python -c 'import fastapi, httpx, numpy, onnxruntime, PIL, sherpa_onnx, sqlalchemy, uvicorn, websockets'
if($LASTEXITCODE -ne 0){throw 'A required Python dependency could not be imported'}
& $python "$root/initialize.py"
if($LASTEXITCODE -ne 0){throw 'Initialization failed'}
& $python "$root/create_admin.py"
if($LASTEXITCODE -ne 0){throw 'Administrator setup failed'}
Write-Host 'Setup complete. Place domain certificate in certs/server.pem and certs/server-key.pem, then run Start.ps1.'
