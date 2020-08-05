function Install-ZabbixAgent {
  param(
    [Parameter(
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0
    )]
    [Switch]$EnableRemoteCommands,
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 1
    )]
    [String]$Server,
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 2
    )]
    [String]$ServerActive,
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 3
    )]
    [String]$ComputerName,
    [System.Management.Automation.PSCredential]
    $Credential = $(Get-Credential)
  )
  
  $ErrorActionPreference = Stop

  $params = New-Object -TypeName System.Collections.Generic.List[`String];

  # ENABLEREMOTECOMMANDS
  if ($EnableRemoteCommands) { $params.Add("ENABLEREMOTECOMMANDS=1"); }
  # SERVER
  if ($Server) { $params.Add("SERVER=$Server"); }
  # SERVERACTIVE
  if ($ServerActive) { $params.Add("SERVERACTIVE=$ServerActive"); }

  $out = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
    param(
      [string]$instArgs
    )

    $downloadPath = "c:\temp"
    $url = "https://www.zabbix.com/downloads/5.0.2/zabbix_agent-5.0.2-windows-amd64-openssl.msi"

    # Create download folder
    if (!(Test-path $downloadPath)) {
      mkdir $downloadPath 
    }

    $file = $(Join-Path $downloadPath "zabbixagent5.msi")

    # Download if not exists
    if (!(Test-Path $file)) {
      Write-Host "Downloading zabbix agent installer to $file"
      Invoke-WebRequest $url -OutFile $file
    }

    # Log file
    $DataStamp = get-date -Format yyyyMMddTHHmmss
    $logFile = '{0}-{1}.log' -f $file, $DataStamp

    # Arguments for MSI installer
    $MSIArguments = New-Object -TypeName System.Collections.Generic.List[`String];

    $MSIArguments.Add("/i")               # install
    $MSIArguments.Add('"{0}"' -f $file)   # msi package to install
    $MSIArguments.Add("/qn")              # quiet, no window
    $MSIArguments.Add("/norestart")       # supress restart
    $MSIArguments.Add("/L*v")             # Log verbose..
    $MSIArguments.Add($logFile)           #..to this file

    # Arguments for zabbix setup
    $instArgs.ForEach{ $MSIArguments.Add($_.Trim()) };

    Write-Host "MSI args: $([string]::Join(" ", $MSIArguments))";

    # Install
    $Out = Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
    Write-Host "Result: $Out"

    Write-Host "Installation completed"
  } -ArgumentList $params

  Write-Host $out

}

# Install-ZabbixAgent -Server 192.168.15.32 -ServerActive  192.168.15.32

# $servers = Get-ADComputer -filter * -Properties operatingsystem | Where-Object { $_.operatingsystem -like "*server*" }

#$servers.forEach{
#  Write-Host "$($_.Name)"
#}