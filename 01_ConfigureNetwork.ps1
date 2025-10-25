param (
    [string]$ConfigFilePath
)

# Variables
# Read the IP configuration from a file
if (Test-Path $ConfigFilePath) {
    $Config = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json
}
else {
    Write-Error "Configuration file not found: $ConfigFilePath"
    exit 1
}

$DefaultAdapterSrc = $Config.DefaultLAN.src
$ManagementAdapterSrc = $Config.ManagementLAN.src

# Get the network adapter
$DefaultAdapter = Get-NetAdapter | Where-Object { $_.Name -like "*$DefaultAdapterSrc*" }
$ManagementAdapter = Get-NetAdapter | Where-Object { $_.Name -like "*$ManagementAdapterSrc*" }

# Configure the Default adapter
$NewName = $Config.DefaultLAN.name
$IsDefault = $Config.DefaultLAN.default
$Ipv4Address = $Config.DefaultLAN.ipv4.address
$Ipv4PrefixLength = $Config.DefaultLAN.ipv4.prefix
$Ipv4DefaultGateway = $Config.DefaultLAN.ipv4.gateway
$Ipv4DnsServers = $Config.DefaultLAN.ipv4.dns

if ($IsDefault -eq $true) {
    try {
        # Disable DHCP and set static IP
        $DefaultAdapter | Set-NetIPInterface -Dhcp Disabled > $null
        $DefaultAdapter | New-NetIPAddress -IPAddress $Ipv4Address -PrefixLength $Ipv4PrefixLength -DefaultGateway $Ipv4DefaultGateway -ErrorAction Stop > $null
        $DefaultAdapter | Set-DnsClientServerAddress -ServerAddresses $Ipv4DnsServers -ErrorAction Stop > $null
        if (Get-NetAdapter | Where-Object { $_.Name -eq $NewName }) {
            Write-Host "Adapter with name $NewName already exists. Skipping rename."
        }
        else {
            $DefaultAdapter | Rename-NetAdapter -NewName $NewName -ErrorAction Stop > $null
        }
        Write-Host "Configured Default adapter with static IP: $Ipv4Address"
    }
    catch {
        Write-Error "Failed to configure the Default adapter: $_"
    }
    finally {
        Start-Sleep -Seconds 10
        Get-NetIPConfiguration -InterfaceAlias $NewName
    }
}
else {
    try {
        $DefaultAdapter | New-NetIPAddress -IPAddress $Ipv4Address -PrefixLength $Ipv4PrefixLength -ErrorAction Stop > $null
        $DefaultAdapter | Set-DnsClientServerAddress -ServerAddresses $Ipv4DnsServers -ErrorAction Stop > $null
        if (Get-NetAdapter | Where-Object { $_.Name -eq $NewName }) {
            Write-Host "Adapter with name $NewName already exists. Skipping rename."
        }
        else {
            $DefaultAdapter | Rename-NetAdapter -NewName $NewName -ErrorAction Stop > $null
        }
        Write-Host "Configured Default adapter with static IP: $Ipv4Address"
    }
    catch {
        Write-Error "Failed to configure the Default adapter: $_"
    }
    finally {
        Start-Sleep -Seconds 10
        Get-NetIPConfiguration -InterfaceAlias $NewName
    }
}

# Configure the Management adapter
if ($null -ne $ManagementAdapter) {
    $NewName = $Config.ManagementLAN.name
    $IsDefault = $Config.ManagementLAN.default
    $Ipv4Address = $Config.ManagementLAN.ipv4.address
    $Ipv4PrefixLength = $Config.ManagementLAN.ipv4.prefix
    $Ipv4DefaultGateway = $Config.ManagementLAN.ipv4.gateway
    $Ipv4DnsServers = $Config.ManagementLAN.ipv4.dns

    if ($IsDefault -eq $true) {
        try {
            # Disable DHCP and set static IP
            $ManagementAdapter | Set-NetIPInterface -Dhcp Disabled > $null
            $ManagementAdapter | New-NetIPAddress -IPAddress $Ipv4Address -PrefixLength $Ipv4PrefixLength -DefaultGateway $Ipv4DefaultGateway -ErrorAction Stop > $null
            $ManagementAdapter | Set-DnsClientServerAddress -ServerAddresses $Ipv4DnsServers -ErrorAction Stop > $null
            if (Get-NetAdapter | Where-Object { $_.Name -eq $NewName }) {
                Write-Host "Adapter with name $NewName already exists. Skipping rename."
            }
            else {
                $ManagementAdapter | Rename-NetAdapter -NewName $NewName -ErrorAction Stop > $null
            }
            Write-Host "Configured Management adapter with static IP: $Ipv4Address"
        }
        catch {
            Write-Error "Failed to configure the Management adapter: $_"
        }
        finally {
            Start-Sleep -Seconds 30
            Get-NetIPConfiguration -InterfaceAlias $NewName
        }
    }
    else {
        try {
            # Disable DHCP and set static IP
            $ManagementAdapter | Set-NetIPInterface -Dhcp Disabled > $null
            $ManagementAdapter | New-NetIPAddress -IPAddress $Ipv4Address -PrefixLength $Ipv4PrefixLength -ErrorAction Stop > $null
            $ManagementAdapter | Set-DnsClientServerAddress -ServerAddresses $Ipv4DnsServers -ErrorAction Stop > $null
            if (Get-NetAdapter | Where-Object { $_.Name -eq $NewName }) {
                Write-Host "Adapter with name $NewName already exists. Skipping rename."
            }
            else {
                $ManagementAdapter | Rename-NetAdapter -NewName $NewName -ErrorAction Stop > $null
            }
            Write-Host "Configured Management adapter with static IP: $Ipv4Address"
        }
        catch {
            Write-Error "Failed to configure the Management adapter: $_"
        }
        finally {
            Start-Sleep -Seconds 30
            Get-NetIPConfiguration -InterfaceAlias $NewName
        }
    }
}

Write-Host "Network configuration completed."
