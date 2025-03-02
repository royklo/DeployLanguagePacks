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

    [Parameter(Mandatory=$false)]
    [ValidateSet(
        "Dateline Standard Time", "UTC-11", "Aleutian Standard Time", "Hawaiian Standard Time", "Marquesas Standard Time", 
        "Alaskan Standard Time", "UTC-09", "Pacific Standard Time (Mexico)", "UTC-08", "Pacific Standard Time", 
        "US Mountain Standard Time", "Mountain Standard Time (Mexico)", "Mountain Standard Time", "Central America Standard Time", 
        "Central Standard Time", "Easter Island Standard Time", "Central Standard Time (Mexico)", "Canada Central Standard Time", 
        "SA Pacific Standard Time", "Eastern Standard Time (Mexico)", "Eastern Standard Time", "Haiti Standard Time", 
        "Cuba Standard Time", "US Eastern Standard Time", "Turks And Caicos Standard Time", "Paraguay Standard Time", 
        "Atlantic Standard Time", "Venezuela Standard Time", "Central Brazilian Standard Time", "SA Western Standard Time", 
        "Pacific SA Standard Time", "Newfoundland Standard Time", "Tocantins Standard Time", "E. South America Standard Time", 
        "SA Eastern Standard Time", "Argentina Standard Time", "Greenland Standard Time", "Montevideo Standard Time", 
        "Magallanes Standard Time", "Saint Pierre Standard Time", "Bahia Standard Time", "UTC-02", "Azores Standard Time", 
        "Cape Verde Standard Time", "UTC", "GMT Standard Time", "Greenwich Standard Time", "Sao Tome Standard Time", 
        "Morocco Standard Time", "W. Europe Standard Time", "Central Europe Standard Time", "Romance Standard Time", 
        "Central European Standard Time", "W. Central Africa Standard Time", "Jordan Standard Time", "GTB Standard Time", 
        "Middle East Standard Time", "Egypt Standard Time", "E. Europe Standard Time", "Syria Standard Time", 
        "West Bank Standard Time", "South Africa Standard Time", "FLE Standard Time", "Israel Standard Time", 
        "Kaliningrad Standard Time", "Sudan Standard Time", "Libya Standard Time", "Namibia Standard Time", 
        "Arabic Standard Time", "Turkey Standard Time", "Arab Standard Time", "Belarus Standard Time", "Russian Standard Time", 
        "E. Africa Standard Time", "Iran Standard Time", "Arabian Standard Time", "Astrakhan Standard Time", 
        "Azerbaijan Standard Time", "Russia Time Zone 3", "Mauritius Standard Time", "Saratov Standard Time", 
        "Georgian Standard Time", "Volgograd Standard Time", "Caucasus Standard Time", "Afghanistan Standard Time", 
        "West Asia Standard Time", "Ekaterinburg Standard Time", "Pakistan Standard Time", "Qyzylorda Standard Time", 
        "India Standard Time", "Sri Lanka Standard Time", "Nepal Standard Time", "Central Asia Standard Time", 
        "Bangladesh Standard Time", "Omsk Standard Time", "Myanmar Standard Time", "SE Asia Standard Time", 
        "Altai Standard Time", "W. Mongolia Standard Time", "North Asia Standard Time", "N. Central Asia Standard Time", 
        "Tomsk Standard Time", "China Standard Time", "North Asia East Standard Time", "Singapore Standard Time", 
        "W. Australia Standard Time", "Taipei Standard Time", "Ulaanbaatar Standard Time", "Aus Central W. Standard Time", 
        "Transbaikal Standard Time", "Tokyo Standard Time", "North Korea Standard Time", "Korea Standard Time", 
        "Yakutsk Standard Time", "Cen. Australia Standard Time", "AUS Central Standard Time", "E. Australia Standard Time", 
        "AUS Eastern Standard Time", "West Pacific Standard Time", "Tasmania Standard Time", "Vladivostok Standard Time", 
        "Lord Howe Standard Time", "Bougainville Standard Time", "Russia Time Zone 10", "Magadan Standard Time", 
        "Norfolk Standard Time", "Sakhalin Standard Time", "Central Pacific Standard Time", "Russia Time Zone 11", 
        "New Zealand Standard Time", "UTC+12", "Fiji Standard Time", "Chatham Islands Standard Time", "UTC+13", 
        "Tonga Standard Time", "Samoa Standard Time", "Line Islands Standard Time"
    )]
    [string]$TimeZone,

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
$timezones = [PSCustomObject]@{      
    #https://secure.jadeworld.com/JADETech/JADE2020/OnlineDocumentation/content/resources/encyclosys2/jadetimezone_class/ianawindowstimezonemapping.htm
    "Etc/GMT+12"                     = "Dateline Standard Time"
    "Etc/GMT+11"                     = "UTC-11"
    "Pacific/Pago_Pago"              = "UTC-11"
    "Pacific/Niue"                   = "UTC-11"
    "Pacific/Midway"                 = "UTC-11"
    "America/Adak"                   = "Aleutian Standard Time"
    "Pacific/Honolulu"               = "Hawaiian Standard Time"
    "Pacific/Rarotonga"              = "Hawaiian Standard Time"
    "Pacific/Tahiti"                 = "Hawaiian Standard Time"
    "Pacific/Johnston"               = "Hawaiian Standard Time"
    "Etc/GMT+10"                     = "Hawaiian Standard Time"
    "Pacific/Marquesas"              = "Marquesas Standard Time"
    "America/Anchorage"              = "Alaskan Standard Time"
    "America/Juneau"                 = "Alaskan Standard Time"
    "America/Metlakatla"             = "Alaskan Standard Time"
    "America/Nome"                   = "Alaskan Standard Time"
    "America/Sitka"                  = "Alaskan Standard Time"
    "America/Yakutat"                = "Alaskan Standard Time"
    "Etc/GMT+9"                      = "UTC-09"
    "Pacific/Gambier"                = "UTC-09"
    "America/Tijuana"                = "Pacific Standard Time (Mexico)"
    "America/Santa_Isabel"           = "Pacific Standard Time (Mexico)"
    "Etc/GMT+8"                      = "UTC-08"
    "Pacific/Pitcairn"               = "UTC-08"
    "America/Los_Angeles"            = "Pacific Standard Time"
    "America/Vancouver"              = "Pacific Standard Time"
    "America/Dawson"                 = "Pacific Standard Time"
    "America/Whitehorse"             = "Pacific Standard Time"
    "PST8PDT"                        = "Pacific Standard Time"
    "America/Phoenix"                = "US Mountain Standard Time"
    "America/Dawson_Creek"           = "US Mountain Standard Time"
    "America/Creston"                = "US Mountain Standard Time"
    "America/Fort_Nelson"            = "US Mountain Standard Time"
    "America/Hermosillo"             = "US Mountain Standard Time"
    "Etc/GMT+7"                      = "US Mountain Standard Time"
    "America/Chihuahua"              = "Mountain Standard Time (Mexico)"
    "America/Mazatlan"               = "Mountain Standard Time (Mexico)"
    "America/Denver"                 = "Mountain Standard Time"
    "America/Edmonton"               = "Mountain Standard Time"
    "America/Cambridge_Bay"          = "Mountain Standard Time"
    "America/Inuvik"                 = "Mountain Standard Time"
    "America/Yellowknife"            = "Mountain Standard Time"
    "America/Ojinaga"                = "Mountain Standard Time"
    "America/Boise"                  = "Mountain Standard Time"
    "MST7MDT"                        = "Mountain Standard Time"
    "America/Guatemala"              = "Central America Standard Time"
    "America/Belize"                 = "Central America Standard Time"
    "America/Costa_Rica"             = "Central America Standard Time"
    "Pacific/Galapagos"              = "Central America Standard Time"
    "America/Tegucigalpa"            = "Central America Standard Time"
    "America/Managua"                = "Central America Standard Time"
    "America/El_Salvador"            = "Central America Standard Time"
    "Etc/GMT+6"                      = "Central America Standard Time"
    "America/Chicago"                = "Central Standard Time"
    "America/Winnipeg"               = "Central Standard Time"
    "America/Rainy_River"            = "Central Standard Time"
    "America/Rankin_Inlet"           = "Central Standard Time"
    "America/Resolute"               = "Central Standard Time"
    "America/Matamoros"              = "Central Standard Time"
    "America/Indiana/Knox"           = "Central Standard Time"
    "America/Indiana/Tell_City"      = "Central Standard Time"
    "America/Menominee"              = "Central Standard Time"
    "America/North_Dakota/Beulah"    = "Central Standard Time"
    "America/North_Dakota/Center"    = "Central Standard Time"
    "America/North_Dakota/New_Salem" = "Central Standard Time"
    "CST6CDT"                        = "Central Standard Time"
    "Pacific/Easter"                 = "Easter Island Standard Time"
    "America/Mexico_City"            = "Central Standard Time (Mexico)"
    "America/Bahia_Banderas"         = "Central Standard Time (Mexico)"
    "America/Merida"                 = "Central Standard Time (Mexico)"
    "America/Monterrey"              = "Central Standard Time (Mexico)"
    "America/Regina"                 = "Canada Central Standard Time"
    "America/Swift_Current"          = "Canada Central Standard Time"
    "America/Bogota"                 = "SA Pacific Standard Time"
    "America/Rio_Branco"             = "SA Pacific Standard Time"
    "America/Eirunepe"               = "SA Pacific Standard Time"
    "America/Coral_Harbour"          = "SA Pacific Standard Time"
    "America/Guayaquil"              = "SA Pacific Standard Time"
    "America/Jamaica"                = "SA Pacific Standard Time"
    "America/Cayman"                 = "SA Pacific Standard Time"
    "America/Panama"                 = "SA Pacific Standard Time"
    "America/Lima"                   = "SA Pacific Standard Time"
    "Etc/GMT+5"                      = "SA Pacific Standard Time"
    "America/Cancun"                 = "Eastern Standard Time (Mexico)"
    "America/New_York"               = "Eastern Standard Time"
    "America/Nassau"                 = "Eastern Standard Time"
    "America/Toronto"                = "Eastern Standard Time"
    "America/Iqaluit"                = "Eastern Standard Time"
    "America/Montreal"               = "Eastern Standard Time"
    "America/Nipigon"                = "Eastern Standard Time"
    "America/Pangnirtung"            = "Eastern Standard Time"
    "America/Thunder_Bay"            = "Eastern Standard Time"
    "America/Detroit"                = "Eastern Standard Time"
    "America/Indiana/Petersburg"     = "Eastern Standard Time"
    "America/Indiana/Vincennes"      = "Eastern Standard Time"
    "America/Indiana/Winamac"        = "Eastern Standard Time"
    "America/Kentucky/Monticello"    = "Eastern Standard Time"
    "America/Louisville"             = "Eastern Standard Time"
    "EST5EDT"                        = "Eastern Standard Time"
    "America/Port-au-Prince"         = "Haiti Standard Time"
    "America/Havana"                 = "Cuba Standard Time"
    "America/Indianapolis"           = "US Eastern Standard Time"
    "America/Indiana/Marengo"        = "US Eastern Standard Time"
    "America/Indiana/Vevay"          = "US Eastern Standard Time"
    "America/Grand_Turk"             = "Turks And Caicos Standard Time"
    "America/Asuncion"               = "Paraguay Standard Time"
    "America/Halifax"                = "Atlantic Standard Time"
    "Atlantic/Bermuda"               = "Atlantic Standard Time"
    "America/Glace_Bay"              = "Atlantic Standard Time"
    "America/Goose_Bay"              = "Atlantic Standard Time"
    "America/Moncton"                = "Atlantic Standard Time"
    "America/Thule"                  = "Atlantic Standard Time"
    "America/Caracas"                = "Venezuela Standard Time"
    "America/Cuiaba"                 = "Central Brazilian Standard Time"
    "America/Campo_Grande"           = "Central Brazilian Standard Time"
    "America/La_Paz"                 = "SA Western Standard Time"
    "America/Antigua"                = "SA Western Standard Time"
    "America/Anguilla"               = "SA Western Standard Time"
    "America/Aruba"                  = "SA Western Standard Time"
    "America/Barbados"               = "SA Western Standard Time"
    "America/St_Barthelemy"          = "SA Western Standard Time"
    "America/Kralendijk"             = "SA Western Standard Time"
    "America/Manaus"                 = "SA Western Standard Time"
    "America/Boa_Vista"              = "SA Western Standard Time"
    "America/Porto_Velho"            = "SA Western Standard Time"
    "America/Blanc-Sablon"           = "SA Western Standard Time"
    "America/Curacao"                = "SA Western Standard Time"
    "America/Dominica"               = "SA Western Standard Time"
    "America/Santo_Domingo"          = "SA Western Standard Time"
    "America/Grenada"                = "SA Western Standard Time"
    "America/Guadeloupe"             = "SA Western Standard Time"
    "America/Guyana"                 = "SA Western Standard Time"
    "America/St_Kitts"               = "SA Western Standard Time"
    "America/St_Lucia"               = "SA Western Standard Time"
    "America/Marigot"                = "SA Western Standard Time"
    "America/Martinique"             = "SA Western Standard Time"
    "America/Montserrat"             = "SA Western Standard Time"
    "America/Puerto_Rico"            = "SA Western Standard Time"
    "America/Lower_Princes"          = "SA Western Standard Time"
    "America/Port_of_Spain"          = "SA Western Standard Time"
    "America/St_Vincent"             = "SA Western Standard Time"
    "America/Tortola"                = "SA Western Standard Time"
    "America/St_Thomas"              = "SA Western Standard Time"
    "Etc/GMT+4"                      = "SA Western Standard Time"
    "America/Santiago"               = "Pacific SA Standard Time"
    "America/St_Johns"               = "Newfoundland Standard Time"
    "America/Araguaina"              = "Tocantins Standard Time"
    "America/Sao_Paulo"              = "E. South America Standard Time"
    "America/Cayenne"                = "SA Eastern Standard Time"
    "Antarctica/Rothera"             = "SA Eastern Standard Time"
    "Antarctica/Palmer"              = "SA Eastern Standard Time"
    "America/Fortaleza"              = "SA Eastern Standard Time"
    "America/Belem"                  = "SA Eastern Standard Time"
    "America/Maceio"                 = "SA Eastern Standard Time"
    "America/Recife"                 = "SA Eastern Standard Time"
    "America/Santarem"               = "SA Eastern Standard Time"
    "Atlantic/Stanley"               = "SA Eastern Standard Time"
    "America/Paramaribo"             = "SA Eastern Standard Time"
    "Etc/GMT+3"                      = "SA Eastern Standard Time"
    "America/Buenos_Aires"           = "Argentina Standard Time"
    "America/Argentina/La_Rioja"     = "Argentina Standard Time"
    "America/Argentina/Rio_Gallegos" = "Argentina Standard Time"
    "America/Argentina/Salta"        = "Argentina Standard Time"
    "America/Argentina/San_Juan"     = "Argentina Standard Time"
    "America/Argentina/San_Luis"     = "Argentina Standard Time"
    "America/Argentina/Tucuman"      = "Argentina Standard Time"
    "America/Argentina/Ushuaia"      = "Argentina Standard Time"
    "America/Catamarca"              = "Argentina Standard Time"
    "America/Cordoba"                = "Argentina Standard Time"
    "America/Jujuy"                  = "Argentina Standard Time"
    "America/Mendoza"                = "Argentina Standard Time"
    "America/Godthab"                = "Greenland Standard Time"
    "America/Montevideo"             = "Montevideo Standard Time"
    "America/Punta_Arenas"           = "Magallanes Standard Time"
    "America/Miquelon"               = "Saint Pierre Standard Time"
    "America/Bahia"                  = "Bahia Standard Time"
    "Etc/GMT+2"                      = "UTC-02"
    "America/Noronha"                = "UTC-02"
    "Atlantic/South_Georgia"         = "UTC-02"
    "Atlantic/Azores"                = "Azores Standard Time"
    "America/Scoresbysund"           = "Azores Standard Time"
    "Atlantic/Cape_Verde"            = "Cape Verde Standard Time"
    "Etc/GMT+1"                      = "Cape Verde Standard Time"
    "Etc/GMT"                        = "UTC"
    "America/Danmarkshavn"           = "UTC"
    "Etc/UTC"                        = "UTC"
    "Europe/London"                  = "GMT Standard Time"
    "Atlantic/Canary"                = "GMT Standard Time"
    "Atlantic/Faeroe"                = "GMT Standard Time"
    "Europe/Guernsey"                = "GMT Standard Time"
    "Europe/Dublin"                  = "GMT Standard Time"
    "Europe/Isle_of_Man"             = "GMT Standard Time"
    "Europe/Jersey"                  = "GMT Standard Time"
    "Europe/Lisbon"                  = "GMT Standard Time"
    "Atlantic/Madeira"               = "GMT Standard Time"
    "Atlantic/Reykjavik"             = "Greenwich Standard Time"
    "Africa/Ouagadougou"             = "Greenwich Standard Time"
    "Africa/Abidjan"                 = "Greenwich Standard Time"
    "Africa/Accra"                   = "Greenwich Standard Time"
    "Africa/Banjul"                  = "Greenwich Standard Time"
    "Africa/Conakry"                 = "Greenwich Standard Time"
    "Africa/Bissau"                  = "Greenwich Standard Time"
    "Africa/Monrovia"                = "Greenwich Standard Time"
    "Africa/Bamako"                  = "Greenwich Standard Time"
    "Africa/Nouakchott"              = "Greenwich Standard Time"
    "Atlantic/St_Helena"             = "Greenwich Standard Time"
    "Africa/Freetown"                = "Greenwich Standard Time"
    "Africa/Dakar"                   = "Greenwich Standard Time"
    "Africa/Lome"                    = "Greenwich Standard Time"
    "Africa/Sao_Tome"                = "Sao Tome Standard Time"
    "Africa/Casablanca"              = "Morocco Standard Time"
    "Africa/El_Aaiun"                = "Morocco Standard Time"
    "Europe/Berlin"                  = "W. Europe Standard Time"
    "Europe/Andorra"                 = "W. Europe Standard Time"
    "Europe/Vienna"                  = "W. Europe Standard Time"
    "Europe/Zurich"                  = "W. Europe Standard Time"
    "Europe/Busingen"                = "W. Europe Standard Time"
    "Europe/Gibraltar"               = "W. Europe Standard Time"
    "Europe/Rome"                    = "W. Europe Standard Time"
    "Europe/Vaduz"                   = "W. Europe Standard Time"
    "Europe/Luxembourg"              = "W. Europe Standard Time"
    "Europe/Monaco"                  = "W. Europe Standard Time"
    "Europe/Malta"                   = "W. Europe Standard Time"
    "Europe/Amsterdam"               = "W. Europe Standard Time"
    "Europe/Oslo"                    = "W. Europe Standard Time"
    "Europe/Stockholm"               = "W. Europe Standard Time"
    "Arctic/Longyearbyen"            = "W. Europe Standard Time"
    "Europe/San_Marino"              = "W. Europe Standard Time"
    "Europe/Vatican"                 = "W. Europe Standard Time"
    "Europe/Budapest"                = "Central Europe Standard Time"
    "Europe/Tirane"                  = "Central Europe Standard Time"
    "Europe/Prague"                  = "Central Europe Standard Time"
    "Europe/Podgorica"               = "Central Europe Standard Time"
    "Europe/Belgrade"                = "Central Europe Standard Time"
    "Europe/Ljubljana"               = "Central Europe Standard Time"
    "Europe/Bratislava"              = "Central Europe Standard Time"
    "Europe/Paris"                   = "Romance Standard Time"
    "Europe/Brussels"                = "Romance Standard Time"
    "Europe/Copenhagen"              = "Romance Standard Time"
    "Europe/Madrid"                  = "Romance Standard Time"
    "Africa/Ceuta"                   = "Romance Standard Time"
    "Europe/Warsaw"                  = "Central European Standard Time"
    "Europe/Sarajevo"                = "Central European Standard Time"
    "Europe/Zagreb"                  = "Central European Standard Time"
    "Europe/Skopje"                  = "Central European Standard Time"
    "Africa/Lagos"                   = "W. Central Africa Standard Time"
    "Africa/Luanda"                  = "W. Central Africa Standard Time"
    "Africa/Porto-Novo"              = "W. Central Africa Standard Time"
    "Africa/Kinshasa"                = "W. Central Africa Standard Time"
    "Africa/Bangui"                  = "W. Central Africa Standard Time"
    "Africa/Brazzaville"             = "W. Central Africa Standard Time"
    "Africa/Douala"                  = "W. Central Africa Standard Time"
    "Africa/Algiers"                 = "W. Central Africa Standard Time"
    "Africa/Libreville"              = "W. Central Africa Standard Time"
    "Africa/Malabo"                  = "W. Central Africa Standard Time"
    "Africa/Niamey"                  = "W. Central Africa Standard Time"
    "Africa/Ndjamena"                = "W. Central Africa Standard Time"
    "Africa/Tunis"                   = "W. Central Africa Standard Time"
    "Etc/GMT-1"                      = "W. Central Africa Standard Time"
    "Asia/Amman"                     = "Jordan Standard Time"
    "Europe/Bucharest"               = "GTB Standard Time"
    "Asia/Nicosia"                   = "GTB Standard Time"
    "Asia/Famagusta"                 = "GTB Standard Time"
    "Europe/Athens"                  = "GTB Standard Time"
    "Asia/Beirut"                    = "Middle East Standard Time"
    "Africa/Cairo"                   = "Egypt Standard Time"
    "Europe/Chisinau"                = "E. Europe Standard Time"
    "Asia/Damascus"                  = "Syria Standard Time"
    "Asia/Hebron"                    = "West Bank Standard Time"
    "Asia/Gaza"                      = "West Bank Standard Time"
    "Africa/Johannesburg"            = "South Africa Standard Time"
    "Africa/Bujumbura"               = "South Africa Standard Time"
    "Africa/Gaborone"                = "South Africa Standard Time"
    "Africa/Lubumbashi"              = "South Africa Standard Time"
    "Africa/Maseru"                  = "South Africa Standard Time"
    "Africa/Blantyre"                = "South Africa Standard Time"
    "Africa/Maputo"                  = "South Africa Standard Time"
    "Africa/Kigali"                  = "South Africa Standard Time"
    "Africa/Mbabane"                 = "South Africa Standard Time"
    "Africa/Lusaka"                  = "South Africa Standard Time"
    "Africa/Harare"                  = "South Africa Standard Time"
    "Etc/GMT-2"                      = "South Africa Standard Time"
    "Europe/Kyiv"                    = "FLE Standard Time"
    "Europe/Mariehamn"               = "FLE Standard Time"
    "Europe/Sofia"                   = "FLE Standard Time"
    "Europe/Tallinn"                 = "FLE Standard Time"
    "Europe/Helsinki"                = "FLE Standard Time"
    "Europe/Vilnius"                 = "FLE Standard Time"
    "Europe/Riga"                    = "FLE Standard Time"
    "Europe/Uzhgorod"                = "FLE Standard Time"
    "Europe/Zaporozhye"              = "FLE Standard Time"
    "Asia/Jerusalem"                 = "Israel Standard Time"
    "Europe/Kaliningrad"             = "Kaliningrad Standard Time"
    "Africa/Khartoum"                = "Sudan Standard Time"
    "Africa/Tripoli"                 = "Libya Standard Time"
    "Africa/Windhoek"                = "Namibia Standard Time"
    "Asia/Baghdad"                   = "Arabic Standard Time"
    "Europe/Istanbul"                = "Turkey Standard Time"
    "Asia/Riyadh"                    = "Arab Standard Time"
    "Asia/Bahrain"                   = "Arab Standard Time"
    "Asia/Kuwait"                    = "Arab Standard Time"
    "Asia/Qatar"                     = "Arab Standard Time"
    "Asia/Aden"                      = "Arab Standard Time"
    "Europe/Minsk"                   = "Belarus Standard Time"
    "Europe/Moscow"                  = "Russian Standard Time"
    "Europe/Kirov"                   = "Russian Standard Time"
    "Europe/Simferopol"              = "Russian Standard Time"
    "Africa/Nairobi"                 = "E. Africa Standard Time"
    "Antarctica/Syowa"               = "E. Africa Standard Time"
    "Africa/Djibouti"                = "E. Africa Standard Time"
    "Africa/Asmera"                  = "E. Africa Standard Time"
    "Africa/Addis_Ababa"             = "E. Africa Standard Time"
    "Indian/Comoro"                  = "E. Africa Standard Time"
    "Indian/Antananarivo"            = "E. Africa Standard Time"
    "Africa/Mogadishu"               = "E. Africa Standard Time"
    "Africa/Juba"                    = "E. Africa Standard Time"
    "Africa/Dar_es_Salaam"           = "E. Africa Standard Time"
    "Africa/Kampala"                 = "E. Africa Standard Time"
    "Indian/Mayotte"                 = "E. Africa Standard Time"
    "Etc/GMT-3"                      = "E. Africa Standard Time"
    "Asia/Tehran"                    = "Iran Standard Time"
    "Asia/Dubai"                     = "Arabian Standard Time"
    "Asia/Muscat"                    = "Arabian Standard Time"
    "Etc/GMT-4"                      = "Arabian Standard Time"
    "Europe/Astrakhan"               = "Astrakhan Standard Time"
    "Europe/Ulyanovsk"               = "Astrakhan Standard Time"
    "Asia/Baku"                      = "Azerbaijan Standard Time"
    "Europe/Samara"                  = "Russia Time Zone 3"
    "Indian/Mauritius"               = "Mauritius Standard Time"
    "Indian/Reunion"                 = "Mauritius Standard Time"
    "Indian/Mahe"                    = "Mauritius Standard Time"
    "Europe/Saratov"                 = "Saratov Standard Time"
    "Asia/Tbilisi"                   = "Georgian Standard Time"
    "Europe/Volgograd"               = "Volgograd Standard Time"
    "Asia/Yerevan"                   = "Caucasus Standard Time"
    "Asia/Kabul"                     = "Afghanistan Standard Time"
    "Asia/Tashkent"                  = "West Asia Standard Time"
    "Antarctica/Mawson"              = "West Asia Standard Time"
    "Asia/Oral"                      = "West Asia Standard Time"
    "Asia/Aqtau"                     = "West Asia Standard Time"
    "Asia/Aqtobe"                    = "West Asia Standard Time"
    "Asia/Atyrau"                    = "West Asia Standard Time"
    "Indian/Maldives"                = "West Asia Standard Time"
    "Indian/Kerguelen"               = "West Asia Standard Time"
    "Asia/Dushanbe"                  = "West Asia Standard Time"
    "Asia/Ashgabat"                  = "West Asia Standard Time"
    "Asia/Samarkand"                 = "West Asia Standard Time"
    "Etc/GMT-5"                      = "West Asia Standard Time"
    "Asia/Yekaterinburg"             = "Ekaterinburg Standard Time"
    "Asia/Karachi"                   = "Pakistan Standard Time"
    "Asia/Qyzylorda"                 = "Qyzylorda Standard Time"
    "Asia/Calcutta"                  = "India Standard Time"
    "Asia/Colombo"                   = "Sri Lanka Standard Time"
    "Asia/Katmandu"                  = "Nepal Standard Time"
    "Asia/Almaty"                    = "Central Asia Standard Time"
    "Antarctica/Vostok"              = "Central Asia Standard Time"
    "Asia/Urumqi"                    = "Central Asia Standard Time"
    "Indian/Chagos"                  = "Central Asia Standard Time"
    "Asia/Bishkek"                   = "Central Asia Standard Time"
    "Asia/Qostanay"                  = "Central Asia Standard Time"
    "Etc/GMT-6"                      = "Central Asia Standard Time"
    "Asia/Dhaka"                     = "Bangladesh Standard Time"
    "Asia/Thimphu"                   = "Bangladesh Standard Time"
    "Asia/Omsk"                      = "Omsk Standard Time"
    "Asia/Rangoon"                   = "Myanmar Standard Time"
    "Indian/Cocos"                   = "Myanmar Standard Time"
    "Asia/Bangkok"                   = "SE Asia Standard Time"
    "Antarctica/Davis"               = "SE Asia Standard Time"
    "Indian/Christmas"               = "SE Asia Standard Time"
    "Asia/Jakarta"                   = "SE Asia Standard Time"
    "Asia/Pontianak"                 = "SE Asia Standard Time"
    "Asia/Phnom_Penh"                = "SE Asia Standard Time"
    "Asia/Vientiane"                 = "SE Asia Standard Time"
    "Asia/Saigon"                    = "SE Asia Standard Time"
    "Etc/GMT-7"                      = "SE Asia Standard Time"
    "Asia/Barnaul"                   = "Altai Standard Time"
    "Asia/Hovd"                      = "W. Mongolia Standard Time"
    "Asia/Krasnoyarsk"               = "North Asia Standard Time"
    "Asia/Novokuznetsk"              = "North Asia Standard Time"
    "Asia/Novosibirsk"               = "N. Central Asia Standard Time"
    "Asia/Tomsk"                     = "Tomsk Standard Time"
    "Asia/Shanghai"                  = "China Standard Time"
    "Asia/Hong_Kong"                 = "China Standard Time"
    "Asia/Macau"                     = "China Standard Time"
    "Asia/Irkutsk"                   = "North Asia East Standard Time"
    "Asia/Singapore"                 = "Singapore Standard Time"
    "Antarctica/Casey"               = "Singapore Standard Time"
    "Asia/Brunei"                    = "Singapore Standard Time"
    "Asia/Makassar"                  = "Singapore Standard Time"
    "Asia/Kuala_Lumpur"              = "Singapore Standard Time"
    "Asia/Kuching"                   = "Singapore Standard Time"
    "Asia/Manila"                    = "Singapore Standard Time"
    "Etc/GMT-8"                      = "Singapore Standard Time"
    "Australia/Perth"                = "W. Australia Standard Time"
    "Asia/Taipei"                    = "Taipei Standard Time"
    "Asia/Ulaanbaatar"               = "Ulaanbaatar Standard Time"
    "Asia/Choibalsan"                = "Ulaanbaatar Standard Time"
    "Australia/Eucla"                = "Aus Central W. Standard Time"
    "Asia/Chita"                     = "Transbaikal Standard Time"
    "Asia/Tokyo"                     = "Tokyo Standard Time"
    "Asia/Jayapura"                  = "Tokyo Standard Time"
    "Pacific/Palau"                  = "Tokyo Standard Time"
    "Asia/Dili"                      = "Tokyo Standard Time"
    "Etc/GMT-9"                      = "Tokyo Standard Time"
    "Asia/Pyongyang"                 = "North Korea Standard Time"
    "Asia/Seoul"                     = "Korea Standard Time"
    "Asia/Yakutsk"                   = "Yakutsk Standard Time"
    "Asia/Khandyga"                  = "Yakutsk Standard Time"
    "Australia/Adelaide"             = "Cen. Australia Standard Time"
    "Australia/Broken_Hill"          = "Cen. Australia Standard Time"
    "Australia/Darwin"               = "AUS Central Standard Time"
    "Australia/Brisbane"             = "E. Australia Standard Time"
    "Australia/Lindeman"             = "E. Australia Standard Time"
    "Australia/Sydney"               = "AUS Eastern Standard Time"
    "Australia/Melbourne"            = "AUS Eastern Standard Time"
    "Pacific/Port_Moresby"           = "West Pacific Standard Time"
    "Antarctica/DumontDUrville"      = "West Pacific Standard Time"
    "Pacific/Truk"                   = "West Pacific Standard Time"
    "Pacific/Guam"                   = "West Pacific Standard Time"
    "Pacific/Saipan"                 = "West Pacific Standard Time"
    "Etc/GMT-10"                     = "West Pacific Standard Time"
    "Australia/Hobart"               = "Tasmania Standard Time"
    "Australia/Currie"               = "Tasmania Standard Time"
    "Asia/Vladivostok"               = "Vladivostok Standard Time"
    "Asia/Ust-Nera"                  = "Vladivostok Standard Time"
    "Australia/Lord_Howe"            = "Lord Howe Standard Time"
    "Pacific/Bougainville"           = "Bougainville Standard Time"
    "Asia/Srednekolymsk"             = "Russia Time Zone 10"
    "Asia/Magadan"                   = "Magadan Standard Time"
    "Pacific/Norfolk"                = "Norfolk Standard Time"
    "Asia/Sakhalin"                  = "Sakhalin Standard Time"
    "Pacific/Guadalcanal"            = "Central Pacific Standard Time"
    "Antarctica/Macquarie"           = "Central Pacific Standard Time"
    "Pacific/Ponape"                 = "Central Pacific Standard Time"
    "Pacific/Kosrae"                 = "Central Pacific Standard Time"
    "Pacific/Noumea"                 = "Central Pacific Standard Time"
    "Pacific/Efate"                  = "Central Pacific Standard Time"
    "Etc/GMT-11"                     = "Central Pacific Standard Time"
    "Asia/Kamchatka"                 = "Russia Time Zone 11"
    "Asia/Anadyr"                    = "Russia Time Zone 11"
    "Pacific/Auckland"               = "New Zealand Standard Time"
    "Antarctica/McMurdo"             = "New Zealand Standard Time"
    "Etc/GMT-12"                     = "UTC+12"
    "Pacific/Tarawa"                 = "UTC+12"
    "Pacific/Majuro"                 = "UTC+12"
    "Pacific/Kwajalein"              = "UTC+12"
    "Pacific/Nauru"                  = "UTC+12"
    "Pacific/Funafuti"               = "UTC+12"
    "Pacific/Wake"                   = "UTC+12"
    "Pacific/Wallis"                 = "UTC+12"
    "Pacific/Fiji"                   = "Fiji Standard Time"
    "Pacific/Chatham"                = "Chatham Islands Standard Time"
    "Etc/GMT-13"                     = "UTC+13"
    "Pacific/Enderbury"              = "UTC+13"
    "Pacific/Fakaofo"                = "UTC+13"
    "Pacific/Tongatapu"              = "Tonga Standard Time"
    "Pacific/Apia"                   = "Samoa Standard Time"
    "Pacific/Kiritimati"             = "Line Islands Standard Time"
    "Etc/GMT-14"                     = "Line Islands Standard Time"
}

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

# Check if the language pack is already installed
$installedLanguages = (Get-WinUserLanguageList).LanguageTag
$InstalledCulture = (Get-Culture).Name
$InstalledHomeLocation = (Get-WinHomeLocation).GeoId
$InstalledTimezone = (Get-TimeZone).Id

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
        $UserLanguageList = New-WinUserLanguageList -Language $languageSettings.Tag
        if ($OldList) {
            $UserLanguageList += $OldList | Where-Object { $_.LanguageTag -ne $languageSettings.Tag }
        }
        Set-WinUserLanguageList -LanguageList $UserLanguageList -Force -WarningAction Ignore | Out-Null

        # Set regional settings
        Write-Output "Configuring regional settings..."
        Set-WinHomeLocation -GeoId $languageSettings.GeoId | Out-Null
        Set-Culture -CultureInfo $languageSettings.Tag | Out-Null

        # Set timezone
        Write-Output "Configuring timezone..."

        if ($timezone) {
            Set-TimeZone -Id $timezone 
        }
        else { 
            Set-TimeZone -Id $languageSettings.Timezone
        }

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
    if (-not $OriginalLanguage) {
    Update-RegistryWithLanguageInfo -InstalledLanguage $languageSettings.Tag -OriginalLanguage $InstalledCulture
    exit 0
    }
}

