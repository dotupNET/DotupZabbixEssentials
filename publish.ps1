Import-Module DotupPsEssentials;
Import-Module DotupPsModuleGenerator;

$path = Get-Location;
$PowershellApiKey = "EnterYourPowershellApiKey";
Publish-PsModule -Path $path -APIKey $PowershellApiKey -IncrementVersion;
