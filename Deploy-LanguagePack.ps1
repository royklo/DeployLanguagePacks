# The language we want as new default. Language tag can be found here: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows?view=windows-11#language-packs
# A list of input locales can be found here: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs?view=windows-11#input-locales
# Geographical ID we want to set. GeoID can be found here: https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations

param (
    [Parameter(Mandatory=$false)]
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

    
    [Parameter(Mandatory=$false)]
    [switch]$AutoDetect,

    [Parameter(Mandatory=$false)]
    [switch]$AutoReboot

)

if (-not $languageTag -and -not $AutoDetect) {
    Write-Error "You must specify either -languageTag or -AutoDetect."
    exit 1
}

# Define the language mapping hash table
$languageMap = @{
    "af-ZA" = @{ Language = "Afrikaans (South Africa)"; Tag = "af-ZA"; GeoId = 209 }
    "sq-AL" = @{ Language = "Albanian (Albania)"; Tag = "sq-AL"; GeoId = 6 }
    "ar-DZ" = @{ Language = "Arabic (Algeria)"; Tag = "ar-DZ"; GeoId = 4 }
    "ar-BH" = @{ Language = "Arabic (Bahrain)"; Tag = "ar-BH"; GeoId = 17 }
    "ar-EG" = @{ Language = "Arabic (Egypt)"; Tag = "ar-EG"; GeoId = 67 }
    "ar-IQ" = @{ Language = "Arabic (Iraq)"; Tag = "ar-IQ"; GeoId = 121 }
    "ar-JO" = @{ Language = "Arabic (Jordan)"; Tag = "ar-JO"; GeoId = 126 }
    "ar-KW" = @{ Language = "Arabic (Kuwait)"; Tag = "ar-KW"; GeoId = 136 }
    "ar-LB" = @{ Language = "Arabic (Lebanon)"; Tag = "ar-LB"; GeoId = 139 }
    "ar-LY" = @{ Language = "Arabic (Libya)"; Tag = "ar-LY"; GeoId = 148 }
    "ar-MA" = @{ Language = "Arabic (Morocco)"; Tag = "ar-MA"; GeoId = 159 }
    "ar-OM" = @{ Language = "Arabic (Oman)"; Tag = "ar-OM"; GeoId = 164 }
    "ar-QA" = @{ Language = "Arabic (Qatar)"; Tag = "ar-QA"; GeoId = 197 }
    "ar-SA" = @{ Language = "Arabic (Saudi Arabia)"; Tag = "ar-SA"; GeoId = 205 }
    "ar-SY" = @{ Language = "Arabic (Syria)"; Tag = "ar-SY"; GeoId = 222 }
    "ar-TN" = @{ Language = "Arabic (Tunisia)"; Tag = "ar-TN"; GeoId = 234 }
    "ar-AE" = @{ Language = "Arabic (U.A.E.)"; Tag = "ar-AE"; GeoId = 224 }
    "ar-YE" = @{ Language = "Arabic (Yemen)"; Tag = "ar-YE"; GeoId = 261 }
    "hy-AM" = @{ Language = "Armenian (Armenia)"; Tag = "hy-AM"; GeoId = 7 }
    "az-AZ" = @{ Language = "Azerbaijani (Azerbaijan)"; Tag = "az-AZ"; GeoId = 5 }
    "be-BY" = @{ Language = "Belarusian (Belarus)"; Tag = "be-BY"; GeoId = 29 }
    "bg-BG" = @{ Language = "Bulgarian (Bulgaria)"; Tag = "bg-BG"; GeoId = 35 }
    "ca-ES" = @{ Language = "Catalan (Spain)"; Tag = "ca-ES"; GeoId = 217 }
    "zh-CN" = @{ Language = "Chinese (China)"; Tag = "zh-CN"; GeoId = 45 }
    "zh-HK" = @{ Language = "Chinese (Hong Kong SAR)"; Tag = "zh-HK"; GeoId = 104 }
    "zh-MO" = @{ Language = "Chinese (Macao SAR)"; Tag = "zh-MO"; GeoId = 151 }
    "zh-SG" = @{ Language = "Chinese (Singapore)"; Tag = "zh-SG"; GeoId = 215 }
    "zh-TW" = @{ Language = "Chinese (Taiwan)"; Tag = "zh-TW"; GeoId = 237 }
    "hr-HR" = @{ Language = "Croatian (Croatia)"; Tag = "hr-HR"; GeoId = 108 }
    "cs-CZ" = @{ Language = "Czech (Czech Republic)"; Tag = "cs-CZ"; GeoId = 75 }
    "da-DK" = @{ Language = "Danish (Denmark)"; Tag = "da-DK"; GeoId = 61 }
    "nl-BE" = @{ Language = "Dutch (Belgium)"; Tag = "nl-BE"; GeoId = 21 }
    "nl-NL" = @{ Language = "Dutch (Netherlands)"; Tag = "nl-NL"; GeoId = 176 }
    "en-AU" = @{ Language = "English (Australia)"; Tag = "en-AU"; GeoId = 12 }
    "en-CA" = @{ Language = "English (Canada)"; Tag = "en-CA"; GeoId = 39 }
    "en-IN" = @{ Language = "English (India)"; Tag = "en-IN"; GeoId = 113 }
    "en-IE" = @{ Language = "English (Ireland)"; Tag = "en-IE"; GeoId = 68 }
    "en-NZ" = @{ Language = "English (New Zealand)"; Tag = "en-NZ"; GeoId = 183 }
    "en-GB" = @{ Language = "English (United Kingdom)"; Tag = "en-GB"; GeoId = 242 }
    "en-US" = @{ Language = "English (United States)"; Tag = "en-US"; GeoId = 244 }
    "et-EE" = @{ Language = "Estonian (Estonia)"; Tag = "et-EE"; GeoId = 70 }
    "fi-FI" = @{ Language = "Finnish (Finland)"; Tag = "fi-FI"; GeoId = 77 }
    "fr-BE" = @{ Language = "French (Belgium)"; Tag = "fr-BE"; GeoId = 21 }
    "fr-CA" = @{ Language = "French (Canada)"; Tag = "fr-CA"; GeoId = 39 }
    "fr-FR" = @{ Language = "French (France)"; Tag = "fr-FR"; GeoId = 84 }
    "fr-CH" = @{ Language = "French (Switzerland)"; Tag = "fr-CH"; GeoId = 223 }
    "ka-GE" = @{ Language = "Georgian (Georgia)"; Tag = "ka-GE"; GeoId = 88 }
    "de-AT" = @{ Language = "German (Austria)"; Tag = "de-AT"; GeoId = 14 }
    "de-DE" = @{ Language = "German (Germany)"; Tag = "de-DE"; GeoId = 94 }
    "de-LI" = @{ Language = "German (Liechtenstein)"; Tag = "de-LI"; GeoId = 145 }
    "de-CH" = @{ Language = "German (Switzerland)"; Tag = "de-CH"; GeoId = 223 }
    "el-GR" = @{ Language = "Greek (Greece)"; Tag = "el-GR"; GeoId = 98 }
    "he-IL" = @{ Language = "Hebrew (Israel)"; Tag = "he-IL"; GeoId = 117 }
    "hi-IN" = @{ Language = "Hindi (India)"; Tag = "hi-IN"; GeoId = 113 }
    "hu-HU" = @{ Language = "Hungarian (Hungary)"; Tag = "hu-HU"; GeoId = 109 }
    "is-IS" = @{ Language = "Icelandic (Iceland)"; Tag = "is-IS"; GeoId = 110 }
    "id-ID" = @{ Language = "Indonesian (Indonesia)"; Tag = "id-ID"; GeoId = 111 }
    "it-IT" = @{ Language = "Italian (Italy)"; Tag = "it-IT"; GeoId = 118 }
    "it-CH" = @{ Language = "Italian (Switzerland)"; Tag = "it-CH"; GeoId = 223 }
    "ja-JP" = @{ Language = "Japanese (Japan)"; Tag = "ja-JP"; GeoId = 122 }
    "kk-KZ" = @{ Language = "Kazakh (Kazakhstan)"; Tag = "kk-KZ"; GeoId = 137 }
    "ko-KR" = @{ Language = "Korean (Korea)"; Tag = "ko-KR"; GeoId = 134 }
    "lv-LV" = @{ Language = "Latvian (Latvia)"; Tag = "lv-LV"; GeoId = 140 }
    "lt-LT" = @{ Language = "Lithuanian (Lithuania)"; Tag = "lt-LT"; GeoId = 141 }
    "mk-MK" = @{ Language = "Macedonian (North Macedonia)"; Tag = "mk-MK"; GeoId = 19618 }
    "ms-MY" = @{ Language = "Malay (Malaysia)"; Tag = "ms-MY"; GeoId = 167 }
    "mt-MT" = @{ Language = "Maltese (Malta)"; Tag = "mt-MT"; GeoId = 163 }
    "no-NO" = @{ Language = "Norwegian (Norway)"; Tag = "no-NO"; GeoId = 177 }
    "pl-PL" = @{ Language = "Polish (Poland)"; Tag = "pl-PL"; GeoId = 191 }
    "pt-BR" = @{ Language = "Portuguese (Brazil)"; Tag = "pt-BR"; GeoId = 32 }
    "pt-PT" = @{ Language = "Portuguese (Portugal)"; Tag = "pt-PT"; GeoId = 193 }
    "ro-RO" = @{ Language = "Romanian (Romania)"; Tag = "ro-RO"; GeoId = 200 }
    "ru-RU" = @{ Language = "Russian (Russia)"; Tag = "ru-RU"; GeoId = 203 }
    "sr-RS" = @{ Language = "Serbian (Serbia)"; Tag = "sr-RS"; GeoId = 271 }
    "sk-SK" = @{ Language = "Slovak (Slovakia)"; Tag = "sk-SK"; GeoId = 143 }
    "sl-SI" = @{ Language = "Slovenian (Slovenia)"; Tag = "sl-SI"; GeoId = 212 }
    "es-AR" = @{ Language = "Spanish (Argentina)"; Tag = "es-AR"; GeoId = 11 }
    "es-CL" = @{ Language = "Spanish (Chile)"; Tag = "es-CL"; GeoId = 46 }
    "es-CO" = @{ Language = "Spanish (Colombia)"; Tag = "es-CO"; GeoId = 51 }
    "es-CR" = @{ Language = "Spanish (Costa Rica)"; Tag = "es-CR"; GeoId = 54 }
    "es-DO" = @{ Language = "Spanish (Dominican Republic)"; Tag = "es-DO"; GeoId = 65 }
    "es-EC" = @{ Language = "Spanish (Ecuador)"; Tag = "es-EC"; GeoId = 66 }
    "es-SV" = @{ Language = "Spanish (El Salvador)"; Tag = "es-SV"; GeoId = 72 }
    "es-GT" = @{ Language = "Spanish (Guatemala)"; Tag = "es-GT"; GeoId = 99 }
    "es-HN" = @{ Language = "Spanish (Honduras)"; Tag = "es-HN"; GeoId = 106 }
    "es-MX" = @{ Language = "Spanish (Mexico)"; Tag = "es-MX"; GeoId = 166 }
    "es-NI" = @{ Language = "Spanish (Nicaragua)"; Tag = "es-NI"; GeoId = 182 }
    "es-PA" = @{ Language = "Spanish (Panama)"; Tag = "es-PA"; GeoId = 192 }
    "es-PY" = @{ Language = "Spanish (Paraguay)"; Tag = "es-PY"; GeoId = 185 }
    "es-PE" = @{ Language = "Spanish (Peru)"; Tag = "es-PE"; GeoId = 187 }
    "es-PR" = @{ Language = "Spanish (Puerto Rico)"; Tag = "es-PR"; GeoId = 202 }
    "es-ES" = @{ Language = "Spanish (Spain)"; Tag = "es-ES"; GeoId = 217 }
    "es-UY" = @{ Language = "Spanish (Uruguay)"; Tag = "es-UY"; GeoId = 246 }
    "es-VE" = @{ Language = "Spanish (Venezuela)"; Tag = "es-VE"; GeoId = 249 }
    "sv-FI" = @{ Language = "Swedish (Finland)"; Tag = "sv-FI"; GeoId = 77 }
    "sv-SE" = @{ Language = "Swedish (Sweden)"; Tag = "sv-SE"; GeoId = 221 }
    "th-TH" = @{ Language = "Thai (Thailand)"; Tag = "th-TH"; GeoId = 227 }
    "tr-TR" = @{ Language = "Turkish (Türkiye)"; Tag = "tr-TR"; GeoId = 235 }
    "uk-UA" = @{ Language = "Ukrainian (Ukraine)"; Tag = "uk-UA"; GeoId = 241 }
    "vi-VN" = @{ Language = "Vietnamese (Vietnam)"; Tag = "vi-VN"; GeoId = 251 }
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

$installedLanguages = (Get-WinUserLanguageList).LanguageTag
$InstalledCulture = (Get-Culture).Name
$InstalledHomeLocation = (Get-WinHomeLocation).GeoId

if ($installedLanguages -contains $languageSettings.Tag -and $InstalledCulture -eq $languageSettings.Tag -and $InstalledHomeLocation -eq $languageSettings.GeoId) {
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
        Set-WinUserLanguageList -LanguageList $UserLanguageList -Force -WarningAction Ignore| Out-Null

        # Set regional settings
        Write-Output "Configuring regional settings..."
        Set-WinHomeLocation -GeoId $languageSettings.GeoId | Out-Null
        Set-Culture -CultureInfo $languageSettings.Tag | Out-Null

        # Copy settings to system
        Write-Output "Copying settings to system..." 
        Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true | Out-Null

        Write-Output "Language configuration completed successfully!" 

        if ($AutoReboot) {
        Write-Output "Rebooting system..."
        shutdown.exe /r /t 10 /f /d p:4:1 /c "Rebooting to apply language changes"
        #exit 3010  # Special exit code for system change requiring restart
        }
    }
    catch {
        Write-Output "Error occurred during language configuration: $($_.Exception.Message)"
        exit 1
    }
}

