$ConfigFile = "C:\ValheimServer\control.config"
$Config = Get-Content $ConfigFile | ConvertFrom-Json

$LogFile = $(join-path ($config.forceinstalldir) ($config.logfile))

Function Start-Valheim {
        $env:SteamAppId="892970"
        $valargs = "-nographics -batchmode -name `"$($config.servername)`" -port $($config.port) -world `"$($config.world)`" -password `"$($config.password)`" -logfile `"$($LogFile)`""
        Start-Process "$($config.forceinstalldir)\valheim_server.exe" -ArgumentList $valargs
}

Function Stop-Valheim($ProcessID) {
        #Sends Ctrl+C to the Valheim window, which saves the server first and shuts down cleanly
        $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("Add-Type -Names 'w' -Name 'k' -M '[DllImport(""kernel32.dll"")]public static extern bool FreeConsole();[DllImport(""kernel32.dll"")]public static extern bool AttachConsole(uint p);[DllImport(""kernel32.dll"")]public static extern bool SetConsoleCtrlHandler(uint h, bool a);[DllImport(""kernel32.dll"")]public static extern bool GenerateConsoleCtrlEvent(uint e, uint p);public static void SendCtrlC(uint p){FreeConsole();AttachConsole(p);GenerateConsoleCtrlEvent(0, 0);}';[w.k]::SendCtrlC($ProcessID)"))
        start-process powershell.exe -argument "-nologo -noprofile -executionpolicy bypass -EncodedCommand $encodedCommand" -NoNewWindow
        write-Status "Waiting for Process $($ProcessID) to stop."
        Do {
            #Write-host "." -NoNewline            
            #Start-Sleep -Seconds 1
            New-UDProgress -Circular -ProgressColor Blue
        }
        while (get-process valheim_server -ErrorAction SilentlyContinue)
        Write-Status "PID '$($ProcessID)' stopped."        
}

Function Get-ValheimStatus{
    $Process = get-process valheim_server -ErrorAction SilentlyContinue
    If($Process){
        $RunningStatus= $True
        $ID = $Process.Id
    }else{
        $RunningStatus= $False
    }
    
    $Results = @{"Active"=$RunningStatus;"ID"=$ID}
    Return $Results
}   

Function Write-Status([string]$Message) {
        $Input = " $(Get-Date): $Message"
        $ExistingValue = (Get-UDElement -Id 'Status').Value

        Set-UDElement -Id 'Status' -Properties @{
            Value = "$Input `n $ExistingValue"
        }    
}

New-UDDashboard -Title 'PowerShell Universal' -Pages @(
    # Create a page using the menu to the right ->   
    # Reference the page here with Get-UDPage
    Get-UDPage -Name 'Valheim'
)

