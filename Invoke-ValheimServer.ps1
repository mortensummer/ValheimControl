[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("Start", "Stop", "Update", "Status")]
    [String]$Action
)

# Change this appropriately
$ConfigFile = "D:\Repos\ValheimControl\config.json"
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
        write-host "Waiting for Process $($ProcessID) to stop." -NoNewline
        Do {
            Write-host "." -NoNewline            
            Start-Sleep -Seconds 1
        }
        while (get-process valheim_server -ErrorAction SilentlyContinue)
        Write-Output "`nPID '$($ProcessID)' stopped."        
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

Switch ($Action){
    "Start" {
        Write-Output "Starting..."
        If(-Not $(Get-ValheimStatus).Active){
            Start-Valheim
        }
    }
    "Stop" {
        If($(Get-ValheimStatus).Active){
            Write-Output "Stopping..."
            Stop-Valheim $(Get-ValheimStatus).ID
        }else{
            Write-Output "Not Started - doing nothing."
        }
    }
    "Update" {
        $ValheimWasRunning = $false
        If($(Get-ValheimStatus).Active){
            Write-Output "Stopping server..."
            Stop-Valheim $(Get-ValheimStatus).ID
            $ValheimWasRunning = $true
        }
        Write-Output "Updating server..."
        Start-Process "$($config.steamcmd)" -ArgumentList "+force_install_dir `"$($config.forceinstalldir)`" +login anonymous +app_update $($config.gameid) validate +exit" -wait
        If ($ValheimWasRunning){
            Start-Valheim
        }
    }

    "Status" {
        $Status = Get-ValheimStatus
        If($Status.Active -eq $true){
            Write-Output "Valheim Server running on Process ID '$($Status.ID)'"
        }
        else{
            Write-Output "Valheim Server is not running."
        }
    }
}