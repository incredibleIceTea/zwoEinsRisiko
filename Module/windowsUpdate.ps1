<#

    Modul zum automatischen Windows update

    Autor: incredibleIceTea
    Version: 0.

#>

<#  CHANGELOG
        
#>

function checkModule($moduleName){
    $ret = get-module -name pswindowsupdate
    return $ret.length
}

if(checkModule){
    Write-Output "pew"
}else{
    Write-Output "go on..."
}