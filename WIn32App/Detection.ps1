$registryPath = "HKLM:\SOFTWARE\RK Solutions\LanguagePack"
$installedLanguage = "nl-NL"

$Result = Get-ItemPropertyValue -Path $registryPath -Name "InstalledLanguage" -ErrorAction SilentlyContinue | Where-Object { $_ -eq $installedLanguage } 

if ($Result -eq $null) {
    Write-Host "Language not installed"
    exit 1
} else {
    Write-Host "Language installed"
    exit 0
}