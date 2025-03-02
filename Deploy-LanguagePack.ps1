# The language we want as new default. Language tag can be found here: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows?view=windows-11#language-packs
# A list of input locales can be found here: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs?view=windows-11#input-locales
# Geographical ID we want to set. GeoID can be found here: https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations

param (
    [Parameter(Mandatory = $false)]
    [ValidateSet(
        "af-ZA", "sq-AL", "ar-DZ", "ar-BH", "ar-EG", "ar-IQ", "ar-JO", "ar-KW", "ar-LB", "ar-LY", 
        "ar-MA", "ar-OM", "ar-QA", "ar-SA", "ar-SY", "ar-TN", "ar-AE", "ar-YE", "hy-AM", "az-AZ", 
        "be-BY", "bg-BG", "ca-ES", "zh-CN", "zh-HK", "zh-MO", "zh-SG", "zh-TW", "hr-HR", "cs-CZ", 
        "da-DK", "nl-BE", "nl-NL", "en-AU", "en-CA", "en-IN", "en-IE", "en-NZ", "en-GB", "en-US", 
        "et-EE", "fi-FI", "fr-BE", "fr-CA", "fr-FR", "fr-CH", "ka-GE", "de-AT", "de-DE", "de-LI", 
        "de-CH", "el-GR", "he-IL", "hi-IN", "hu-HU", "is-IS", "id-ID", "it-IT", "it-CH", "ja-JP", 
        "kk-KZ", "ko-KR", "lv-LV", "lt-LT", "mk-MK", "ms-MY", "mt-MT", "no-NO", "pl-PL", "pt-BR", 
        "pt-PT", "ro-RO", "ru-RU", "sr-RS", "sk-SK", "sl-SI", "es-AR", "es-CL", "es-CO", "es-CR", 
        "es-DO", "es-EC", "es-SV", "es-GT", "es-HN", "es-MX", "es-NI", "es-PA", "es-PY", "es-PE", 
        "es-PR", "es-ES", "es-UY", "es-VE", "sv-FI", "sv-SE", "th-TH", "tr-TR", "uk-UA", "vi-VN"
    )]
    [string]$languageTag,

    [Parameter(Mandatory = $false)]
    [switch]$AutoDetect,

    [Parameter(Mandatory = $false)]
    [switch]$AutoReboot,

    [Parameter(Mandatory = $false)]
    [switch]$rollback
)

Function Update-RegistryWithLanguageInfo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$InstalledLanguage,
        
        [Parameter(Mandatory = $true)]
        [string]$OriginalLanguage
    )

    # Create a registry key to store the installed language information
    $registryPath = "HKLM:\SOFTWARE\RK Solutions\LanguagePack"
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set the InstalledLanguage value in the registry
    Set-ItemProperty -Path $registryPath -Name "InstalledLanguage" -Value $InstalledLanguage -Force

    # Set the OriginalLanguage value in the registry for rollback
    Set-ItemProperty -Path $registryPath -Name "OriginalLanguage" -Value $OriginalLanguage -Force

    Write-Output "Registry key updated with installed language: $InstalledLanguage"
    Write-Output "Registry key updated with original language: $OriginalLanguage"
}

if (-not $languageTag -and -not $AutoDetect -and -not $rollback) {
    Write-Error "You must specify either -languageTag or -AutoDetect."
    exit 1
}

if ($AutoDetect -and $languageTag) {
    Write-Error "You cannot specify both -languageTag and -AutoDetect."
    exit 1
}

if ($rollback -and $AutoDetect) {
    Write-Error "You cannot specify both -rollback and -AutoDetect."
    exit 1
}

if ($rollback -and $languageTag) {
    Write-Error "You cannot specify both -rollback and -languageTag."
    exit 1
}

if ($rollback) {
    $registryPath = "HKLM:\SOFTWARE\RK Solutions\LanguagePack"
    $OriginalLanguage = Get-ItemPropertyValue -Path $registryPath -Name "OriginalLanguage" -ErrorAction SilentlyContinue
    if ($OriginalLanguage -eq $null) {
        Write-Output "Original language not found in registry"
        exit 1
    } else {
        Write-Output "Rolling back to original language: $OriginalLanguage"
        $languageTag = $OriginalLanguage
    }
}

# Define the language mapping hash table with timezone information
$languageMap = @{
    "af-ZA" = @{ Language = "Afrikaans (South Africa)"; Tag = "af-ZA"; GeoId = 209; Timezone = "South Africa Standard Time" }
    "sq-AL" = @{ Language = "Albanian (Albania)"; Tag = "sq-AL"; GeoId = 6; Timezone = "Central Europe Standard Time" }
    "ar-DZ" = @{ Language = "Arabic (Algeria)"; Tag = "ar-DZ"; GeoId = 4; Timezone = "W. Central Africa Standard Time" }
    "ar-BH" = @{ Language = "Arabic (Bahrain)"; Tag = "ar-BH"; GeoId = 17; Timezone = "Arabian Standard Time" }
    "ar-EG" = @{ Language = "Arabic (Egypt)"; Tag = "ar-EG"; GeoId = 67; Timezone = "Egypt Standard Time" }
    "ar-IQ" = @{ Language = "Arabic (Iraq)"; Tag = "ar-IQ"; GeoId = 121; Timezone = "Arabian Standard Time" }
    "ar-JO" = @{ Language = "Arabic (Jordan)"; Tag = "ar-JO"; GeoId = 126; Timezone = "Jordan Standard Time" }
    "ar-KW" = @{ Language = "Arabic (Kuwait)"; Tag = "ar-KW"; GeoId = 136; Timezone = "Arab Standard Time" }
    "ar-LB" = @{ Language = "Arabic (Lebanon)"; Tag = "ar-LB"; GeoId = 139; Timezone = "Middle East Standard Time" }
    "ar-LY" = @{ Language = "Arabic (Libya)"; Tag = "ar-LY"; GeoId = 148; Timezone = "E. Europe Standard Time" }
    "ar-MA" = @{ Language = "Arabic (Morocco)"; Tag = "ar-MA"; GeoId = 159; Timezone = "Morocco Standard Time" }
    "ar-OM" = @{ Language = "Arabic (Oman)"; Tag = "ar-OM"; GeoId = 164; Timezone = "Arabian Standard Time" }
    "ar-QA" = @{ Language = "Arabic (Qatar)"; Tag = "ar-QA"; GeoId = 197; Timezone = "Arab Standard Time" }
    "ar-SA" = @{ Language = "Arabic (Saudi Arabia)"; Tag = "ar-SA"; GeoId = 205; Timezone = "Arab Standard Time" }
    "ar-SY" = @{ Language = "Arabic (Syria)"; Tag = "ar-SY"; GeoId = 222; Timezone = "Syria Standard Time" }
    "ar-TN" = @{ Language = "Arabic (Tunisia)"; Tag = "ar-TN"; GeoId = 234; Timezone = "W. Central Africa Standard Time" }
    "ar-AE" = @{ Language = "Arabic (U.A.E.)"; Tag = "ar-AE"; GeoId = 224; Timezone = "Arabian Standard Time" }
    "ar-YE" = @{ Language = "Arabic (Yemen)"; Tag = "ar-YE"; GeoId = 261; Timezone = "Arab Standard Time" }
    "hy-AM" = @{ Language = "Armenian (Armenia)"; Tag = "hy-AM"; GeoId = 7; Timezone = "Caucasus Standard Time" }
    "az-AZ" = @{ Language = "Azerbaijani (Azerbaijan)"; Tag = "az-AZ"; GeoId = 5; Timezone = "Azerbaijan Standard Time" }
    "be-BY" = @{ Language = "Belarusian (Belarus)"; Tag = "be-BY"; GeoId = 29; Timezone = "Belarus Standard Time" }
    "bg-BG" = @{ Language = "Bulgarian (Bulgaria)"; Tag = "bg-BG"; GeoId = 35; Timezone = "FLE Standard Time" }
    "ca-ES" = @{ Language = "Catalan (Spain)"; Tag = "ca-ES"; GeoId = 217; Timezone = "Romance Standard Time" }
    "zh-CN" = @{ Language = "Chinese (China)"; Tag = "zh-CN"; GeoId = 45; Timezone = "China Standard Time" }
    "zh-HK" = @{ Language = "Chinese (Hong Kong SAR)"; Tag = "zh-HK"; GeoId = 104; Timezone = "China Standard Time" }
    "zh-MO" = @{ Language = "Chinese (Macao SAR)"; Tag = "zh-MO"; GeoId = 151; Timezone = "China Standard Time" }
    "zh-SG" = @{ Language = "Chinese (Singapore)"; Tag = "zh-SG"; GeoId = 215; Timezone = "Singapore Standard Time" }
    "zh-TW" = @{ Language = "Chinese (Taiwan)"; Tag = "zh-TW"; GeoId = 237; Timezone = "Taipei Standard Time" }
    "hr-HR" = @{ Language = "Croatian (Croatia)"; Tag = "hr-HR"; GeoId = 108; Timezone = "Central Europe Standard Time" }
    "cs-CZ" = @{ Language = "Czech (Czech Republic)"; Tag = "cs-CZ"; GeoId = 75; Timezone = "Central Europe Standard Time" }
    "da-DK" = @{ Language = "Danish (Denmark)"; Tag = "da-DK"; GeoId = 61; Timezone = "Romance Standard Time" }
    "nl-BE" = @{ Language = "Dutch (Belgium)"; Tag = "nl-BE"; GeoId = 21; Timezone = "Romance Standard Time" }
    "nl-NL" = @{ Language = "Dutch (Netherlands)"; Tag = "nl-NL"; GeoId = 176; Timezone = "W. Europe Standard Time" }
    "en-AU" = @{ Language = "English (Australia)"; Tag = "en-AU"; GeoId = 12; Timezone = "AUS Eastern Standard Time" }
    "en-CA" = @{ Language = "English (Canada)"; Tag = "en-CA"; GeoId = 39; Timezone = "Eastern Standard Time" }
    "en-IN" = @{ Language = "English (India)"; Tag = "en-IN"; GeoId = 113; Timezone = "India Standard Time" }
    "en-IE" = @{ Language = "English (Ireland)"; Tag = "en-IE"; GeoId = 68; Timezone = "GMT Standard Time" }
    "en-NZ" = @{ Language = "English (New Zealand)"; Tag = "en-NZ"; GeoId = 183; Timezone = "New Zealand Standard Time" }
    "en-GB" = @{ Language = "English (United Kingdom)"; Tag = "en-GB"; GeoId = 242; Timezone = "GMT Standard Time" }
    "en-US" = @{ Language = "English (United States)"; Tag = "en-US"; GeoId = 244; Timezone = "Pacific Standard Time" }
    "et-EE" = @{ Language = "Estonian (Estonia)"; Tag = "et-EE"; GeoId = 70; Timezone = "FLE Standard Time" }
    "fi-FI" = @{ Language = "Finnish (Finland)"; Tag = "fi-FI"; GeoId = 77; Timezone = "FLE Standard Time" }
    "fr-BE" = @{ Language = "French (Belgium)"; Tag = "fr-BE"; GeoId = 21; Timezone = "Romance Standard Time" }
    "fr-CA" = @{ Language = "French (Canada)"; Tag = "fr-CA"; GeoId = 39; Timezone = "Eastern Standard Time" }
    "fr-FR" = @{ Language = "French (France)"; Tag = "fr-FR"; GeoId = 84; Timezone = "Romance Standard Time" }
    "fr-CH" = @{ Language = "French (Switzerland)"; Tag = "fr-CH"; GeoId = 223; Timezone = "W. Europe Standard Time" }
    "ka-GE" = @{ Language = "Georgian (Georgia)"; Tag = "ka-GE"; GeoId = 88; Timezone = "Georgian Standard Time" }
    "de-AT" = @{ Language = "German (Austria)"; Tag = "de-AT"; GeoId = 14; Timezone = "W. Europe Standard Time" }
    "de-DE" = @{ Language = "German (Germany)"; Tag = "de-DE"; GeoId = 94; Timezone = "W. Europe Standard Time" }
    "de-LI" = @{ Language = "German (Liechtenstein)"; Tag = "de-LI"; GeoId = 145; Timezone = "W. Europe Standard Time" }
    "de-CH" = @{ Language = "German (Switzerland)"; Tag = "de-CH"; GeoId = 223; Timezone = "W. Europe Standard Time" }
    "el-GR" = @{ Language = "Greek (Greece)"; Tag = "el-GR"; GeoId = 98; Timezone = "GTB Standard Time" }
    "he-IL" = @{ Language = "Hebrew (Israel)"; Tag = "he-IL"; GeoId = 117; Timezone = "Israel Standard Time" }
    "hi-IN" = @{ Language = "Hindi (India)"; Tag = "hi-IN"; GeoId = 113; Timezone = "India Standard Time" }
    "hu-HU" = @{ Language = "Hungarian (Hungary)"; Tag = "hu-HU"; GeoId = 109; Timezone = "Central Europe Standard Time" }
    "is-IS" = @{ Language = "Icelandic (Iceland)"; Tag = "is-IS"; GeoId = 110; Timezone = "Greenwich Standard Time" }
    "id-ID" = @{ Language = "Indonesian (Indonesia)"; Tag = "id-ID"; GeoId = 111; Timezone = "SE Asia Standard Time" }
    "it-IT" = @{ Language = "Italian (Italy)"; Tag = "it-IT"; GeoId = 118; Timezone = "W. Europe Standard Time" }
    "it-CH" = @{ Language = "Italian (Switzerland)"; Tag = "it-CH"; GeoId = 223; Timezone = "W. Europe Standard Time" }
    "ja-JP" = @{ Language = "Japanese (Japan)"; Tag = "ja-JP"; GeoId = 122; Timezone = "Tokyo Standard Time" }
    "kk-KZ" = @{ Language = "Kazakh (Kazakhstan)"; Tag = "kk-KZ"; GeoId = 137; Timezone = "Central Asia Standard Time" }
    "ko-KR" = @{ Language = "Korean (Korea)"; Tag = "ko-KR"; GeoId = 134; Timezone = "Korea Standard Time" }
    "lv-LV" = @{ Language = "Latvian (Latvia)"; Tag = "lv-LV"; GeoId = 140; Timezone = "FLE Standard Time" }
    "lt-LT" = @{ Language = "Lithuanian (Lithuania)"; Tag = "lt-LT"; GeoId = 141; Timezone = "FLE Standard Time" }
    "mk-MK" = @{ Language = "Macedonian (North Macedonia)"; Tag = "mk-MK"; GeoId = 19618; Timezone = "Central Europe Standard Time" }
    "ms-MY" = @{ Language = "Malay (Malaysia)"; Tag = "ms-MY"; GeoId = 167; Timezone = "Singapore Standard Time" }
    "mt-MT" = @{ Language = "Maltese (Malta)"; Tag = "mt-MT"; GeoId = 163; Timezone = "Central Europe Standard Time" }
    "no-NO" = @{ Language = "Norwegian (Norway)"; Tag = "no-NO"; GeoId = 177; Timezone = "W. Europe Standard Time" }
    "pl-PL" = @{ Language = "Polish (Poland)"; Tag = "pl-PL"; GeoId = 191; Timezone = "Central Europe Standard Time" }
    "pt-BR" = @{ Language = "Portuguese (Brazil)"; Tag = "pt-BR"; GeoId = 32; Timezone = "E. South America Standard Time" }
    "pt-PT" = @{ Language = "Portuguese (Portugal)"; Tag = "pt-PT"; GeoId = 193; Timezone = "GMT Standard Time" }
    "ro-RO" = @{ Language = "Romanian (Romania)"; Tag = "ro-RO"; GeoId = 200; Timezone = "GTB Standard Time" }
    "ru-RU" = @{ Language = "Russian (Russia)"; Tag = "ru-RU"; GeoId = 203; Timezone = "Russian Standard Time" }
    "sr-RS" = @{ Language = "Serbian (Serbia)"; Tag = "sr-RS"; GeoId = 271; Timezone = "Central Europe Standard Time" }
    "sk-SK" = @{ Language = "Slovak (Slovakia)"; Tag = "sk-SK"; GeoId = 143; Timezone = "Central Europe Standard Time" }
    "sl-SI" = @{ Language = "Slovenian (Slovenia)"; Tag = "sl-SI"; GeoId = 212; Timezone = "Central Europe Standard Time" }
    "es-AR" = @{ Language = "Spanish (Argentina)"; Tag = "es-AR"; GeoId = 11; Timezone = "Argentina Standard Time" }
    "es-CL" = @{ Language = "Spanish (Chile)"; Tag = "es-CL"; GeoId = 46; Timezone = "Pacific SA Standard Time" }
    "es-CO" = @{ Language = "Spanish (Colombia)"; Tag = "es-CO"; GeoId = 51; Timezone = "SA Pacific Standard Time" }
    "es-CR" = @{ Language = "Spanish (Costa Rica)"; Tag = "es-CR"; GeoId = 54; Timezone = "Central America Standard Time" }
    "es-DO" = @{ Language = "Spanish (Dominican Republic)"; Tag = "es-DO"; GeoId = 65; Timezone = "SA Western Standard Time" }
    "es-EC" = @{ Language = "Spanish (Ecuador)"; Tag = "es-EC"; GeoId = 66; Timezone = "SA Pacific Standard Time" }
    "es-SV" = @{ Language = "Spanish (El Salvador)"; Tag = "es-SV"; GeoId = 72; Timezone = "Central America Standard Time" }
    "es-GT" = @{ Language = "Spanish (Guatemala)"; Tag = "es-GT"; GeoId = 99; Timezone = "Central America Standard Time" }
    "es-HN" = @{ Language = "Spanish (Honduras)"; Tag = "es-HN"; GeoId = 106; Timezone = "Central America Standard Time" }
    "es-MX" = @{ Language = "Spanish (Mexico)"; Tag = "es-MX"; GeoId = 166; Timezone = "Central Standard Time (Mexico)" }
    "es-NI" = @{ Language = "Spanish (Nicaragua)"; Tag = "es-NI"; GeoId = 182; Timezone = "Central America Standard Time" }
    "es-PA" = @{ Language = "Spanish (Panama)"; Tag = "es-PA"; GeoId = 192; Timezone = "SA Pacific Standard Time" }
    "es-PY" = @{ Language = "Spanish (Paraguay)"; Tag = "es-PY"; GeoId = 185; Timezone = "Paraguay Standard Time" }
    "es-PE" = @{ Language = "Spanish (Peru)"; Tag = "es-PE"; GeoId = 187; Timezone = "SA Pacific Standard Time" }
    "es-PR" = @{ Language = "Spanish (Puerto Rico)"; Tag = "es-PR"; GeoId = 202; Timezone = "SA Western Standard Time" }
    "es-ES" = @{ Language = "Spanish (Spain)"; Tag = "es-ES"; GeoId = 217; Timezone = "Romance Standard Time" }
    "es-UY" = @{ Language = "Spanish (Uruguay)"; Tag = "es-UY"; GeoId = 246; Timezone = "Montevideo Standard Time" }
    "es-VE" = @{ Language = "Spanish (Venezuela)"; Tag = "es-VE"; GeoId = 249; Timezone = "Venezuela Standard Time" }
    "sv-FI" = @{ Language = "Swedish (Finland)"; Tag = "sv-FI"; GeoId = 77; Timezone = "FLE Standard Time" }
    "sv-SE" = @{ Language = "Swedish (Sweden)"; Tag = "sv-SE"; GeoId = 221; Timezone = "W. Europe Standard Time" }
    "th-TH" = @{ Language = "Thai (Thailand)"; Tag = "th-TH"; GeoId = 227; Timezone = "SE Asia Standard Time" }
    "tr-TR" = @{ Language = "Turkish (Türkiye)"; Tag = "tr-TR"; GeoId = 235; Timezone = "Turkey Standard Time" }
    "uk-UA" = @{ Language = "Ukrainian (Ukraine)"; Tag = "uk-UA"; GeoId = 241; Timezone = "FLE Standard Time" }
    "vi-VN" = @{ Language = "Vietnamese (Vietnam)"; Tag = "vi-VN"; GeoId = 251; Timezone = "SE Asia Standard Time" }
}

if ($AutoDetect) {
    Function Get-IPLocation {
        [CmdletBinding()]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
            [String[]] $IP
        )
        begin {
    
        }
        process {
            foreach ($address in $IP) {
                $Result = Invoke-RestMethod -Uri "http://ipwho.is/$address" -Method GET -ContentType "application/json" -ErrorAction Stop
                $Result | Add-Member -MemberType NoteProperty -Name IP -Value $IP -Force
                $Result
    
            }
    
        }
        end {
    
        }
    }
    
    Function Get-PublicIP {
        (Invoke-WebRequest http://ifconfig.me/ip ).Content
    }
    
    $PublicIP = Get-PublicIP
    
    $country = (Get-IPLocation -IP $publicip).country
    
    $CurrentLanguage = $languageMap.Values | Where-Object { $_.Language -match $country } 
    
    Clear-Host
    
    Write-Host "Country: $country"
    Write-Host "Language: $($CurrentLanguage.Language)"
    Write-Host "Geo ID: $($CurrentLanguage.GeoID)"
    Write-Host "Tag: $($CurrentLanguage.Tag)"
    Write-Host "Public IP: $PublicIP"
    
    $languageTag = $CurrentLanguage.Tag

}

# Validate and get language settings
$languageSettings = $languageMap[$languageTag]
if ($null -eq $languageSettings) {
    Write-Output "Invalid language tag: $languageTag" -ForegroundColor Red
    Write-Output "Valid options are: $($languageMap.Keys -join ', ')"
    exit 1
}

Write-Output "Selected language: $($languageSettings.Language) - $($languageSettings.Tag)"

if (-not $rollback) {
    # Get the current language settings
    $installedLanguages = (Get-WinUserLanguageList).LanguageTag
    $InstalledCulture = (Get-Culture).Name
    $InstalledHomeLocation = (Get-WinHomeLocation).GeoId
    $InstalledTimezone = (Get-TimeZone).Id
}

if ($installedLanguages -contains $languageSettings.Tag -and $InstalledCulture -eq $languageSettings.Tag -and $InstalledHomeLocation -eq $languageSettings.GeoId -and $InstalledTimezone -eq $languageSettings.Timezone) {
    Write-Output "Language pack is already installed and configured correctly. Skipping the installation step."
    exit 0
} else {
    try {
        # Install language pack and change the language of the OS
        Write-Output "Installing language pack..."
        Install-Language -Language $languageSettings.Tag -CopyToSettings -ErrorAction Stop | Out-Null

        # Configure new language defaults under current user
        Write-Output "Setting UI language override..." 
        Set-WinUILanguageOverride -Language $languageSettings.Tag | Out-Null

        # Update the preferred language list
        Write-Output "Updating language list..."
        $OldList = Get-WinUserLanguageList
        $UserLanguageList = New-WinUserLanguageList -Language $languageSettings.Tag | Out-Null
        $UserLanguageList += $OldList | Where-Object { $_.LanguageTag -ne $languageSettings.Tag }
        Set-WinUserLanguageList -LanguageList $UserLanguageList -Force -WarningAction Ignore | Out-Null

        # Set regional settings
        Write-Output "Configuring regional settings..."
        Set-WinHomeLocation -GeoId $languageSettings.GeoId | Out-Null
        Set-Culture -CultureInfo $languageSettings.Tag | Out-Null

        # Set timezone
        Write-Output "Configuring timezone..."
        Set-TimeZone -Id $languageSettings.Timezone | Out-Null

        # Copy settings to system
        Write-Output "Copying settings to system..." 
        Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true | Out-Null

        Write-Output "Language configuration completed successfully!" 

        if ($AutoReboot) {
            Write-Output "Rebooting system..."
            shutdown.exe /r /t 10 /f /d p:4:1 /c "Rebooting to apply language changes"
            #exit 3010  # Special exit code for system change requiring restart
        }
    } catch {
        Write-Output "Error occurred during language configuration: $($_.Exception.Message)"
        exit 1
    }
}

# Call the function to update the registry
if ($rollback) {
    Update-RegistryWithLanguageInfo -InstalledLanguage $OriginalLanguage -OriginalLanguage $languageSettings.Tag
    Write-Output "Rollback completed successfully!"
    exit 0
} else {
    Update-RegistryWithLanguageInfo -InstalledLanguage $languageSettings.Tag -OriginalLanguage $InstalledCulture
    exit 0
}

