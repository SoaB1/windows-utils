if (pwsh.exe --version) {
    Write-Host "Done installing PowerShell.`r`nPowerShell version:"
    pwsh.exe --version
}
Else {
    Write-Error "PowerShell is not installed"
    return $false
}

Start-Sleep -s 5
Write-Host "Hello World"