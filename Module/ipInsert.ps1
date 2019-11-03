<#

    Modul zum automatischen wiederherstellen extrahierter statischer IP Konfigurationen

    Autor: incredibleIceTea
    Version: 0.

#>

<#  CHANGELOG
        
#>

$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$filePath =  Join-Path -Path $desktopPath -ChildPath "ipconfig.txt"
$adapter = Get-NetAdapter

foreach($a in $adapter){
    foreach($line in Get-Content $filePath){
        $line = $line.Split("|")
        if($line[0] -eq $a.name -and $line[1] -eq $a.macAddress){
            foreach($l in $line[2].Split(" ")){
                if($l.length -gt 0){
                    Write-Host $l
                }
            }
        }
    }
}