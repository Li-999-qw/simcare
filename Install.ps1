param()
$ErrorActionPreference='Stop'
$root=$PSScriptRoot
if($root -match '[^\x00-\x7F]'){throw 'Extract to an English path, e.g. C:\SimCare.'}
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$python=Join-Path $root 'runtime/python/python.exe'
if(-not(Test-Path $python)){
 New-Item -ItemType Directory -Force "$root/runtime" | Out-Null
 $installer="$root/runtime/python-installer.exe"
 Invoke-WebRequest 'https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe' -OutFile $installer -UseBasicParsing
 $sig=Get-AuthenticodeSignature -LiteralPath $installer
 if($sig.Status -ne 'Valid' -or $sig.SignerCertificate.Subject -notmatch 'Python Software Foundation'){throw 'Python installer signature verification failed'}
 $p=Start-Process -FilePath $installer -ArgumentList @('/quiet','InstallAllUsers=0','Include_launcher=0','Include_test=0','PrependPath=0',('TargetDir="'+$root+'\runtime\python"')) -WindowStyle Hidden -Wait -PassThru
 if($p.ExitCode -notin @(0,3010)){throw 'Python installation failed'}
}
& $python -m venv "$root/.venv"
if($LASTEXITCODE -ne 0){throw 'Could not create virtual environment'}
$python="$root/.venv/Scripts/python.exe"
& $python -m pip install -r "$root/requirements.txt"
if($LASTEXITCODE -ne 0){throw 'Dependency installation failed; check outbound Internet connectivity'}
& $python "$root/initialize.py"
if($LASTEXITCODE -ne 0){throw 'Initialization failed'}
& $python "$root/create_admin.py"
if($LASTEXITCODE -ne 0){throw 'Administrator setup failed'}
Write-Host 'Setup complete. Place domain certificate in certs/server.pem and certs/server-key.pem, then run Start.ps1.'
