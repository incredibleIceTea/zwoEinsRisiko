<#

    Modul zum auslesen statischer IP-Konfigurationen aller Netzwerk-Adapter

    Erstellt auf dem Desktop die "ipconfig.txt" die pro statisch konfiguriertem
    Adapter folgenden Datensatz enthält

    [STR]          [STR]       [STR]  [STR]
    ADAPTER NAME | MACADRESSE | IPS | STANDARDGATEWAYS

    IPS sowie STANDARDGATEWAYS haben folgendes format:
    IP/GW           IP/GW
    xxx.xxx.xxx.xxx xxx.xxx.xxx.xxx

    Autor: incredibleIceTea
    Version: 0.2c

#>

<#  CHANGELOG

    0.2:
        -Änderung des Skriptpablaufs in:
            Filterung aller Netzwerk Adapter
                Feststellung ob Adapter aktiv
                Filterung zugehöriger IPAdressen
                    Feststellung zugehöriger IPAdressen
                        Überprüfung auf manuelle Einstellungen
                            Boolean "manuelleEinstellungen" setzen
                        Speicherung zugehöriger IPAdresse
                Filterung zugehöriger Standard Gateways
                    Feststellung zugehöriger StandardGateways
                        Speicherung zugehörigem StandardGateway
                Anpassung der gespeicherten Daten zum Adapter
                Boolean "manuelleEinstellungen" Überprüfung
                    Übergabe gespeicherter Daten
            Überprüfung der größe der übergebenen Daten
                Ablage der übergebenen Daten

        -Anpassung des Exportstrings in:
            ADAPTER NAME | MACADRESSE | IPS | STANDARDGATEWAYS

    0.1b: 
        -Kommentare hinzugefügt     
#>

<#
    Variablen:
        $desktopPath        : Pfad zum aktuellen Desktop
        $filePath           : Kombination aus $desktopPath und filename "ipconfig.txt"
        $iptable            : Liste aller NetIpAddressObjekte
        $adapter            : Liste aller NetAdapterObjekte
        $standardGateways   : Liste aller IP4RouteTableWMIObjekte
        $output             : Array zum Speichern aller Übergabewerte
#>
$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$filePath =  Join-Path -Path $desktopPath -ChildPath "ipconfig.txt"
$iptable = Get-NetIPAddress
$adapter = Get-NetAdapter
$standardGateways = Get-WmiObject -Class Win32_IP4RouteTable
$output = @()

# Durchsuchen nach aktiven Adaptern
foreach($a in $adapter){
    if($a.status -eq "up"){

        <# Variablen
            $ret            : Variable zur Anpassung des übergabewerts an $output
            $ipv4Address    : Variable zur Speicherung aller zugehörigen IPAdressen
            $gateWay        : Variable zur Speicherung aller zugehörigen StandardGateways
            $manualSetting  : Boolen zur Speicherung ob (1) manuelle Einstellungen vorgenommen wurden
        #>
        $ret = @()
        $ipv4Address = @()
        $gateWays = @()
        $manualSetting = $false
        
        # Durchsuchen nach IPObjekt mit beschriebenem IPv4Address Feld das dem momentanen Adapter entspricht
        foreach($ip in $iptable){
            if($null -ne $ip.IPv4Address){
                if($ip.ifIndex -eq $a.ifIndex){
                    # Überprüfung des suffixOrigin zur Feststellung von manueller Konfiguration
                    if($ip.suffixOrigin -eq "manual"){
                        # Setzen des Boolean 
                        $manualSetting = $true
                    }
                    # Speicherung der IPAdresse
                    $ipv4Address += $ip.IPv4Address
                }
            }
        }
        # Durchsuchen nach GatewayObjekt nach außen das dem Adapter entspricht
        foreach($gw in $standardGateways){
            if($gw.destination -eq '0.0.0.0' -and $gw.mask -eq '0.0.0.0'){
                if($gw.interfaceIndex -eq $a.interfaceIndex){
                    # Speicherung des Nexthops als standardGateway
                    $gateWays += $gw.nexthop
                }
            }
        }
        # Anpassung des Datensatzes zur Speicherung "|" wird als Trennzeichen der einzelnen Felder benutzt
        $ipv4Address += "|"
        $ret = $a.InterfaceAlias+"|"+$a.macAddress+"|"+$ipv4Address+$gateWays
        # Überprüfung ob Datensatz manuelle Einstellung ist
        if($manualSetting -eq $true){
            # Übergabe an $output
            $output +=$ret
        }
    }
}
# Überprüfung ob $output Daten enthält
if($output.length -ne 0){
    # Speichern des Datensatzes in $filePath
    $output | Out-File -FilePath $filePath
}