$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$filePath =  Join-Path -Path $desktopPath -ChildPath "ipconfig.txt"
$iptable = Get-NetIPAddress
$adapters = Get-NetAdapter

$ret = @()
$header = "MACADDRESS SPECIAL INTERFACENAME IP"
$ret += $header
foreach($ip in $iptable){
    if($null -ne $ip.IPv4Address){
        if($ip.suffixOrigin -eq "manual"){
            $name = $ip.InterfaceAlias
            $suffix = $ip.suffixOrigin
            $address = $ip.IPv4Address
            foreach($a in $adapters){
                if($a.name = $name){
                    $mac = $a.macAddress
                }
            }   
            $str = "$mac $suffix $name $address"
            $ret += $str
        }
    }
}
$ret | Out-File -FilePath $filePath