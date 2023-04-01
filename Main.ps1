[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("Start", "Stop", "Update", "Status")]
    [String]$Action
)

# Change this appropriately
$ConfigFile = "D:\Repos\ValheimControl\config.json"
$Config = Get-Content $ConfigFile | ConvertFrom-Json

Function Start-Valheim {
        $env:SteamAppId="892970"
        $valargs = "-nographics -batchmode -name `"$($config.servername)`" -port $($config.port) -world `"$($config.world)`" -password `"$($config.password)`" -logfile `"$(join-path ($config.forceinstalldir) ($config.logfile))`""
        Start-Process "$($config.forceinstalldir)\valheim_server.exe" -ArgumentList $valargs
}

Function Stop-Valheim($ProcessID) {
    #Sends Ctrl+C to the Valheim window, which saves the server first and shuts down cleanly
        $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("Add-Type -Names 'w' -Name 'k' -M '[DllImport(""kernel32.dll"")]public static extern bool FreeConsole();[DllImport(""kernel32.dll"")]public static extern bool AttachConsole(uint p);[DllImport(""kernel32.dll"")]public static extern bool SetConsoleCtrlHandler(uint h, bool a);[DllImport(""kernel32.dll"")]public static extern bool GenerateConsoleCtrlEvent(uint e, uint p);public static void SendCtrlC(uint p){FreeConsole();AttachConsole(p);GenerateConsoleCtrlEvent(0, 0);}';[w.k]::SendCtrlC($ProcessID)"))
        start-process powershell.exe -argument "-nologo -noprofile -executionpolicy bypass -EncodedCommand $encodedCommand"
        write-host "Waiting for Process $($ProcessID) to stop." -NoNewline
        Do {
            Write-host "." -NoNewline            
            Start-Sleep -Seconds 1
        }
        while (Get-Process -ID (Get-ValheimStatus).Id)
        Write-Output "PID '$($ProcessID)' stopped."        
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
        Write-Output "Stopping..."
        If($($ValheimStatus.Active)){
            Stop-Valheim $(Get-ValheimStatus).ID
        }
    }
    "Update" {
        Write-Output "Update $Action"
    }
    "Status" {
        Write-Output "Status $Action"
    }

}