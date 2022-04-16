function echoBar() {
    Write-Host "==============================="
}

echoBar
Write-Host "Starting the script for Setup Windows10..."
Start-Sleep -s 5
if (winget --version) {
    Write-Host "Winget is already installed"
}
else {
    Write-Host "Winget is not installed, installing..."
    Write-Host "Please install Winget before continuing."
    Write-Host 'https://www.microsoft.com/p/app-installer/9nblggh4nns1#activetab=pivot:overviewtab'
    exit
}
echoBar
Write-Host "Starting the install chocolatey..."
Start-Sleep -s 5
powershell.exe -ExecutionPolicy RemoteSigned -File ./utils/install-chocolatey.ps1
Start-Sleep -s 5
if (choco --version) {
    echoBar
    Write-Host "Done installing chocolatey!"
    Write-Host -NoNewline "version: "
    choco.exe --version
}
else {
    echoBar
    Write-Error "ERROR: Chocolatey is not installed!"
    exit
}
Start-Sleep -s 5
echoBar
Write-Host "Starting the install Windows Terminal..."
winget install --id=Microsoft.WindowsTerminal -e --silent
if (winget list --id=Microsoft.WindowsTerminal) {
    echoBar
    Write-Host "Done installing Microsoft.WindowsTerminal!"
    winget list --id=Microsoft.WindowsTerminal
}
else {
    echoBar
    Write-Error "ERROR: Microsoft.WindowsTerminal is not installed!"
    exit
}
Start-Sleep -s 5
echoBar
Write-Host "Starting the install Visual Studio Code..."
winget.exe install --id Microsoft.VisualStudioCode -e --silent
if (winget list --id=Microsoft.VisualStudioCode) {
    echoBar
    Write-Host "Done installing Microsoft.VisualStudioCode!"
    Write-Host "Version: "
    winget list --id=Microsoft.VisualStudioCode
}
else {
    echoBar
    Write-Error "ERROR: Microsoft.VisualStudioCode is not installed!"
    exit
}
Start-Sleep -s 5
echoBar

Write-Host "Starting the install GoogleChrome..."
winget.exe install --id Google.Chrome -e --silent
if (winget.exe list --id=Google.Chrome) {
    echoBar
    Write-Host "Done installing Google.Chrome!"
    Write-Host "Version: "
    winget.exe list --id=Google.Chrome
}
else {
    echoBar
    Write-Error "ERROR: Google.Chrome is not installed!"
    exit
}


if (Test-Path $Profile) {
    Copy-Item -Force .\config\pwsh-profile.ps1 $Profile
}
Write-Host $Profile



Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
