Write-Host "$PSScriptRoot"

Import-Module "$PSScriptRoot\common.psm1"
$BaseDir = "$PSScriptRoot\..\temp"

$files = @(
    # Discord
    @{
        Uri     = "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x64"
        OutFile = "${BaseDir}\Cdrive\DiscordSetup.exe"
    },
    # Steam
    @{
        Uri     = "https://cdn.fastly.steamstatic.com/client/installer/SteamSetup.exe"
        OutFile = "${BaseDir}\Cdrive\SteamSetup.exe"
    },
    # Spotify
    @{
        Uri     = "https://download.scdn.co/SpotifySetup.exe"
        OutFile = "${BaseDir}\Cdrive\SpotifySetup.exe"
    },
    # Adobe Creative Cloud
    @{
        Uri     = "https://prod-rel-ffc-ccm.oobesaas.adobe.com/adobe-ffc-external/core/v1/wam/download?sapCode=KCCC&productName=Creative%20Cloud"
        OutFile = "${BaseDir}\Fdrive\Creative_Cloud_Set-Up.exe"
    },
    # Tailscale
    @{
        Uri     = "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe"
        OutFile = "${BaseDir}\Cdrive\tailscale-setup-latest.exe"
    },
    # G Hub
    @{
        Uri     = "https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe"
        OutFile = "${BaseDir}\Cdrive\lghub_installer.exe"
    },
    # Keyboard Driver
    @{
        Uri     = "https://s3-gear-cdn.s3.ap-northeast-1.amazonaws.com/VSPO!+Keyboard_setup_2.1.89(WIN20250606).zip"
        OutFile = "${BaseDir}\Cdrive\VSPO!+Keyboard_setup_2.1.89(WIN20250606).zip"
    },
    # Nvidia Driver
    @{
        Uri     = "https://jp.download.nvidia.com/Windows/581.42/581.42-desktop-win10-win11-64bit-international-dch-whql.exe"
        OutFile = "${BaseDir}\Cdrive\581.42-desktop-win10-win11-64bit-international-dch-whql.exe"
    },
    # Nvidia Broadcast
    @{
        Uri     = "https://international.download.nvidia.com/Windows/broadcast/2.0.2/NVIDIA_Broadcast_v2.0.2.31240911.exe"
        OutFile = "${BaseDir}\Cdrive\NVIDIA_Broadcast_v2.0.2.31240911.exe"
    }
)

$jobs = @()

foreach ($file in $files) {
    $jobs += Start-ThreadJob -Name $file.OutFile -ScriptBlock {
        $params = $Using:file
        Invoke-WebRequest @params
    }
}

Write-Host "Downloads started..."
echoBar
Wait-Job -Job $jobs

foreach ($job in $jobs) {
    Receive-Job -Job $job
}
