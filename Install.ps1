param()
$ErrorActionPreference='Stop'
$root=$PSScriptRoot
if($root -match '[^\x00-\x7F]'){throw 'Extract to an English path, e.g. C:\SimCare.'}
$conda=Get-Command conda -ErrorAction SilentlyContinue
if(-not $conda){throw 'Conda was not found. Add conda to PATH or run this script from an Anaconda PowerShell Prompt.'}
$envPath=Join-Path $root '.conda-env'
$python=Join-Path $envPath 'python.exe'
if((Test-Path -LiteralPath $envPath) -and -not(Test-Path -LiteralPath $python)){
 throw 'Incomplete Conda environment at .conda-env. Remove that directory after checking it, then rerun Install.ps1.'
}
if(Test-Path -LiteralPath $python){
 & conda env update --prefix $envPath --file (Join-Path $root 'environment.yml') --prune
}else{
 & conda env create --prefix $envPath --file (Join-Path $root 'environment.yml')
}
if($LASTEXITCODE -ne 0){throw 'Conda dependency installation failed; check the Conda output and network connectivity'}
if(-not(Test-Path -LiteralPath $python)){throw 'Conda completed without creating python.exe'}
$env:PATH="$envPath;$envPath\Scripts;$envPath\Library\bin;$env:PATH"
& $python -c 'import fastapi, httpx, numpy, onnxruntime, PIL, sherpa_onnx, sqlalchemy, uvicorn, websockets'
if($LASTEXITCODE -ne 0){throw 'A required Python dependency could not be imported'}
& $python "$root/initialize.py"
if($LASTEXITCODE -ne 0){throw 'Initialization failed'}
& $python "$root/create_admin.py"
if($LASTEXITCODE -ne 0){throw 'Administrator setup failed'}
Write-Host 'Setup complete. Place domain certificate in certs/server.pem and certs/server-key.pem, then run Start.ps1.'
