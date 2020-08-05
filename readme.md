# DotupZabbixEssentials

Install the Zabbix agent (5.0.2) on remote computers

## Installation
```powershell
Install-Module DotupZabbixEssentials
```

## Usage

```powershell

# Get all AD servers
$servers = Get-ADComputer -filter * -Properties operatingsystem | Where-Object { $_.operatingsystem -like "*server*" }

# Get the admin user for all servers
$credential = Get-Credential

# INstall zabbix on each server
$servers.forEach{
  Write-Host "Installing Zabbix on $($_.Name)"

  Install-ZabbixAgent -ComputerName $_.Name -Credential $credential -Server 192.168.15.32 -ServerActive  192.168.15.32
}

Write-Host "Multi installation completed"

```


# TODO
- Only download once
- Version selector
- x86/x64 detection
