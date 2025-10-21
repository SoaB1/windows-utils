# Configure application settings
Import-Module "$PSScriptRoot\common.psm1"
$ConfigPath = "$PSScriptRoot\..\config"

# Configure StarShip
if (starship.exe --version) {
    Write-Host "StarShip is already installed"
    $StarshipConfigDir = "$env:USERPROFILE\.config"
    if (!(Test-Path $StarshipConfigDir)) {
        New-Item -ItemType Directory -Path $StarshipConfigDir | Out-Null
    }
    $StarshipConfigPath = Join-Path -Path $StarshipConfigDir -ChildPath "starship.toml"
    Copy-Item -Path "$ConfigPath\starship.toml" -Destination $StarshipConfigPath -Force
    Write-Host "StarShip configuration applied."
}
else {
    Write-Host "StarShip is not installed. Please install StarShip first."
}

# Configure PowerShell settings
Write-Host "Configuring PowerShell settings..."
$PowerShellConfigDir = $PROFILE.CurrentUserAllHosts
if (!(Test-Path $PowerShellConfigDir)) {
    New-Item -ItemType Directory -Path (Split-Path -Path $PowerShellConfigDir) | Out-Null
    $PowerShellConfigPath = Join-Path -Path (Split-Path -Path $PowerShellConfigDir) -ChildPath "Microsoft.PowerShell_profile.ps1"
    Copy-Item -Path "$ConfigPath\PowerShell_profile.ps1" -Destination $PowerShellConfigPath -Force
    Write-Host "PowerShell profile created at $PowerShellConfigPath"
}

# Login Tailscale
if (tailscale.exe --version) {
    Write-Host "Tailscale is already installed"
    Start-Process -FilePath "tailscale.exe" -ArgumentList "up" -NoNewWindow -Wait
}
else {
    Write-Host "Tailscale is not installed. Please install Tailscale first."
}

# Configure VSCode settings
if (code --version) {
    $VSCodeSettingsDir = "$env:APPDATA\Code\User"
    $VsCodeConfigArry = @(
        @{
            Path        = "$ConfigPath\vscode_settings.json"
            Destination = "$VSCodeSettingsDir\settings.json"
        },
        @{
            Path        = "$ConfigPath\vscode_keybindings.json"
            Destination = "$VSCodeSettingsDir\keybindings.json"
        }
    )
    Write-Host "VSCode is already installed"
    if (!(Test-Path $VSCodeSettingsDir)) {
        New-Item -ItemType Directory -Path $VSCodeSettingsDir | Out-Null
        foreach ($vscodeconfig in $VsCodeConfigArry) {
            try {
                Copy-Item -Path $vscodeconfig.Path -Destination $vscodeconfig.Destination -Force
                Write-Host "VSCode configuration applied: $($vscodeconfig.Destination)"
            }
            catch {
                Write-Host "Failed to apply VSCode configuration: $($_.Exception.Message)"
            }
        }
    }
}
