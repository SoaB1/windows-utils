Write-Host "$PSScriptRoot"

Import-Module "$PSScriptRoot\common.psm1"
$BaseDir = "$PSScriptRoot\..\temp"

$files = @(
    # Discord
    @{
        Uri     = "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x64"
        OutFile = "${BaseDir}\DiscordSetup.exe"
    },
    # Steam
    @{
        Uri     = "https://cdn.fastly.steamstatic.com/client/installer/SteamSetup.exe"
        OutFile = "${BaseDir}\SteamSetup.exe"
    },
    # Spotify
    @{
        Uri     = "https://download.scdn.co/SpotifySetup.exe"
        OutFile = "${BaseDir}\SpotifySetup.exe"
    },
    # Adobe Creative Cloud
    @{
        Uri     = "https://prod-rel-ffc-ccm.oobesaas.adobe.com/adobe-ffc-external/core/v1/wam/download?sapCode=KCCC&productName=Creative%20Cloud"
        OutFile = "${BaseDir}\Creative_Cloud_Set-Up.exe"
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
