param (
    [string]$ConfigFilePath
)

# Variables
$TenGigaBitAdpterDesc = "Marvell AQtion 10Gbit Network Adapter"
$GigaBitAdpterDesc = "Intel(R) Ethernet Controller (3) I225-V"

# Get the network adapter
$TenGigaBitAdpter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.InterfaceDescription -like "*$TenGigaBitAdpterDesc*"}
$GigaBitAdpter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.InterfaceDescription -like "*$GigaBitAdpterDesc*"}

# Read the IP configuration from a file
if (Test-Path $ConfigFilePath) {
    $Config = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json
} else {
    Write-Error "Configuration file not found: $ConfigFilePath"
    exit 1
}

# Configure the 10Gbit adapter
if ($null -ne $TenGigaBitAdpter) {
    # Disable DHCP and set static IP
    $TenGigaBitAdpter | Set-NetIPInterface -Dhcp Disabled

    $NewName = $Config.DefaultLAN.name
    $IsDefault = $Config.DefaultLAN.default
    $Ipv4Address = $Config.DefaultLAN.ipv4.address
    $Ipv4PrefixLength = $Config.DefaultLAN.ipv4.prefixLength
    $Ipv4DefaultGateway = $Config.DefaultLAN.ipv4.defaultGateway
    $Ipv4DnsServers = $Config.DefaultLAN.ipv4.dns

    if ($IsDefault -eq $true) {
        try {
            $TenGigaBitAdpter | Rename-NetAdapter -NewName $NewName -ErrorAction Stop
            $TenGigaBitAdpter | New-NetIPAddress -IPAddress $Ipv4Address -PrefixLength $Ipv4PrefixLength -DefaultGateway $Ipv4DefaultGateway -ErrorAction Stop
            $TenGigaBitAdpter | Set-DnsClientServerAddress -ServerAddresses $Ipv4DnsServers -ErrorAction Stop
            Write-Host "Configured 10Gbit adapter with static IP: $Ipv4Address"
        } catch {
            Write-Error "Failed to configure the 10Gbit adapter: $_"
        }
    } else {
        try {
            $TenGigaBitAdpter | Rename-NetAdapter -NewName $NewName -ErrorAction Stop
            $TenGigaBitAdpter | New-NetIPAddress -IPAddress $Ipv4Address -PrefixLength $Ipv4PrefixLength -ErrorAction Stop
            $TenGigaBitAdpter | Set-DnsClientServerAddress -ServerAddresses $Ipv4DnsServers -ErrorAction Stop
            Write-Host "Configured 10Gbit adapter with static IP: $Ipv4Address"
        } catch {
            Write-Error "Failed to configure the 10Gbit adapter: $_"
        }
    }
}

# Configure the Gigabit adapter
if ($null -ne $GigaBitAdpter) {
    # Disable DHCP and set static IP
    $GigaBitAdpter | Set-NetIPInterface -Dhcp Disabled

    $NewName = $Config.ManagementLAN.name
    $IsDefault = $Config.ManagementLAN.default
    $Ipv4Address = $Config.ManagementLAN.ipv4.address
    $Ipv4PrefixLength = $Config.ManagementLAN.ipv4.prefixLength
    $Ipv4DefaultGateway = $Config.ManagementLAN.ipv4.defaultGateway
    $Ipv4DnsServers = $Config.ManagementLAN.ipv4.dns

    if ($IsDefault -eq $true) {
        try {
            $GigaBitAdpter | Rename-NetAdapter -NewName $NewName -ErrorAction Stop
            $GigaBitAdpter | New-NetIPAddress -IPAddress $Ipv4Address -PrefixLength $Ipv4PrefixLength -DefaultGateway $Ipv4DefaultGateway -ErrorAction Stop
            $GigaBitAdpter | Set-DnsClientServerAddress -ServerAddresses $Ipv4DnsServers -ErrorAction Stop
            Write-Host "Configured Gigabit adapter with static IP: $Ipv4Address"
        } catch {
            Write-Error "Failed to configure the Gigabit adapter: $_"
        }
    } else {
        try {
            $GigaBitAdpter | Rename-NetAdapter -NewName $NewName -ErrorAction Stop
            $GigaBitAdpter | New-NetIPAddress -IPAddress $Ipv4Address -PrefixLength $Ipv4PrefixLength -ErrorAction Stop
            $GigaBitAdpter | Set-DnsClientServerAddress -ServerAddresses $Ipv4DnsServers -ErrorAction Stop
            Write-Host "Configured Gigabit adapter with static IP: $Ipv4Address"
        } catch {
            Write-Error "Failed to configure the Gigabit adapter: $_"
        }
    }
}
