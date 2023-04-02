# Invoke-ValheimServer

## Summary
A script to manage the running of a Valheim Dedicated Server. 
Stores some settings in config.json.
Requires [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD#Downloading_SteamCMD) for the updating process. 

This was written so it could be controlled via [PowerShell Universal](https://www.ironmansoftware.com/powershell-universal/), so my wife could start\stop the server with ease in my absence. 

Thanks to [Thomas Mjelde](https://github.com/tmmjelde) for his [script](https://github.com/tmmjelde/Valheim-Dedicated-Windows) that got me started. 

## Examples
### Start the Valheim Dedicated Server
```PowerShell
PS> Invoke-ValheimServer.ps1 -Action Start
```

### Stop the Valheim Dedicated Server
```PowerShell
PS> Invoke-ValheimServer.ps1 -Action Stop
```

### Get Status of the Valheim Dedicated Server
```PowerShell
PS> Invoke-ValheimServer.ps1 -Action Status
```

### Update the Valheim Dedicated Server

```PowerShell
PS> Invoke-ValheimServer.ps1 -Action Start
```
Note: If the server is running before updating, it will get restarted automatically. If the server is started, it will be gracefully shutdown. 

## Config File
Update this config file with desired settings. 
```json
{
    "servername":  "myservername",
    "world": "Dedicated",
    "port": "2456",
    "password": "asecretpasswordplease",
    "gameid":  "896660",
    "steamcmd":  "C:\\Steamcmd\\steamcmd.exe",
    "forceinstalldir":  "C:\\valheim-server",
    "logfile": "server.log"
}
```