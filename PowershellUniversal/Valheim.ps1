
# Change this appropriately
<#
$Status = Get-ValheimStatus
If($Status.Active){
    Write-Status "INITIAL STATE: Server is running"
}else{
    Write-Status "INITIAL STATE: Server is stopped"
}
#>

New-UDButton -Text 'Start' -OnClick {
    If(-Not $(Get-ValheimStatus).Active){
        Start-Valheim
        $Status = Get-ValheimStatus
        Write-Status "Status of Valheim: $($Status.Active). Process ID is '$($Status.ID)'" 
    }else{
        Write-Status "Already started"
    }
}

New-UDButton -Text 'Stop' -OnClick {
    If($(Get-ValheimStatus).Active){
        Stop-Valheim $(Get-ValheimStatus).ID
        $Status = Get-ValheimStatus
        Write-Status "Status of Valheim: $($Status.Active)." 
    }else{
        Write-Status "Server not started. Nothing to do."
    }
}

New-UDButton -Text 'Update' -OnClick {
    $ValheimWasRunning = $false
    If($(Get-ValheimStatus).Active){
        Write-Status "Stopping Valheim first..."
        Stop-Valheim $(Get-ValheimStatus).ID
        $ValheimWasRunning = $true
    }
    Write-Status "Updating server. Please be patient. Will report the status when complete."
    Start-Process "$($config.steamcmd)" -ArgumentList "+force_install_dir `"$($config.forceinstalldir)`" +login anonymous +app_update $($config.gameid) validate +exit" -wait
    If ($ValheimWasRunning){
        Start-Valheim
        $Status = Get-ValheimStatus
        Write-Status "Finished update routine. Status of Valheim: $($Status.Active). Process ID is '$($Status.ID)'" 
    }
}

New-UDButton -Text 'Status' -OnClick {
    $Status = Get-ValheimStatus
    If($Status.Active -eq $true){
        Write-Status "Valheim Server running on Process ID is '$($Status.ID)'"
    }
    else{
        Write-Status "Valheim Server is not running."
    }
}

New-UDButton -Text 'Server Log' -OnClick {
    Write-Status "Displaying $Logfile"
    $LogOutput = Get-Content $Logfile -Raw
    Show-UDModal -Content {
        New-UDTextbox -Value $LogOutput -Multiline -FullWidth -RowsMax 20 -Disabled
        New-UDButton -Text "Close" -OnClick {Hide-UDModal}
    } -Persistent -FullWidth
}

New-UDTextbox -Id 'Status' -Multiline -FullWidth -RowsMax 10 -Disabled

New-UDButton -Text 'Clear History' -OnClick {
    Set-UDElement -Id 'Status' -Properties @{
        Value = ""
    }   
}
