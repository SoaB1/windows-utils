Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Import-Module "$PSScriptRoot\utils\common.psm1"

# Variables
$WingetPackages = @(
    "Microsoft.VisualStudioCode",
    "Google.Chrome",
    "7zip.7zip",
    "Starship.Starship",
    "DeepL.DeepL"
)

# Main
echoBar
Write-Host "Starting the script for Setup Windows11..."
Start-Sleep -s 5

# Setup workspace
$Folders = @(
    "$PSScriptRoot\temp",
    "$PSScriptRoot\logs"
)

foreach ($folder in $Folders) {
    if (-Not (Test-Path -Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "Created folder: $folder"
    } else {
        Write-Host "Folder already exists: $folder"
    }
}

# Logging
$LogFile = "$PSScriptRoot\logs\setup-$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Start-Transcript -Path $LogFile -Append

# Check if winget is installed
if (winget --version) {
    Write-Host "Winget is already installed"
}
else {
    Write-Host "Winget is not installed, installing..."
    Write-Host "Please install Winget before continuing."
    Write-Host 'https://www.microsoft.com/p/app-installer/9nblggh4nns1#activetab=pivot:overviewtab'
    exit
}
Start-Sleep -s 5

# Install packages
foreach ($package in $WingetPackages) {
    echoBar
    Write-Host "Starting the install $package..."
    if (winget list --id=$package) {
        Write-Host "$package is already installed"
        winget list --id=$package
    } else {
        Write-Host "$package is not installed, installing..."
        try {
            winget.exe install --id $package -e --silent
            winget list --id=$package
        }
        catch {
            Write-Error "ERROR: Failed to install $package"
        }
    }
    Start-Sleep -s 5
}

# Install WSL
echoBar
Write-Host "Starting the install WSL..."
if (wsl --version) {
    Write-Host "WSL is already installed"
    wsl --version
} else {
    Write-Host "WSL is not installed, installing..."
    try {
        wsl --install
        wsl --version
    }
    catch {
        Write-Error "ERROR: Failed to install WSL"
    }
}

# Download other installers
echoBar
Write-Host "Starting the download other installers..."
Invoke-Expression "$PSScriptRoot\utils\01_download-files.ps1"

# Finish
Stop-Transcript
Write-Host "Setup script completed. Log file saved:`n$LogFile"
