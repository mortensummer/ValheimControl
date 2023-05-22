# How many backups to keep before pruning older copies
$NumToKeep = 25

# Where to save backups (Default is C:\Users\(USERNAME)\Appdata\LocalLow\IronGate\ValheimBackups)
$BackupFolderPath = "C:\ValheimBackups"

# Name of each unique backup file (This gets today's date and appends the file)
$BackupName = Get-Date -Format "yyyyMMdd-HHmm"

# Server world file location (Default is C:\Users\(USERNAME)\Appdata\LocalLow\IronGate\Valheim)
$Worldsavelocation = "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim"

$Subfolders = @(
    'worlds_local',
    'characters'
)

Function Create-Archive([string]$Path,[string]$Destination,[string]$BackupName){
    write-host "Creating Archive '$BackupName.zip' at '$Destination'"
    Compress-Archive -path "$Path" -destinationpath $Destination\$BackupName.zip -Update 
}

# Create the backup directory
If(!(test-path $BackupFolderPath)){
      New-Item -ItemType Directory -Force -Path $BackupFolderPath
}

foreach ($Folder in $SubFolders){
    foreach ($file in Get-ChildItem -Recurse "$Worldsavelocation\$folder"){
        if ((get-date).AddMinutes(-5) -gt $file.CreationTime){
            Create-Archive -Path "$Worldsavelocation/$folder" -Destination $BackupFolderPath -BackupName $BackupName
            break
        }else{
            write-host Server recently saved, waiting 5 minutes and taking backup.
            start-sleep -Seconds 300
            Create-Archive -Path "$Worldsavelocation/$folder" -Destination $BackupFolderPath -BackupName $BackupName 
            break
        }
    }
}

Write-host "Backup complete you will find your backup compressed at '$BackupFolderPath' named '$BackupName.zip'"

#Prune Backups
write-host "Pruning backups. You are keeping $NumToKeep backups"

Get-ChildItem "$BackupFolderPath" -Recurse |
    where-object {-not $_.PsIsContainer} |
    sort-object CreationTime -desc |
    select-object -Skip "$NumToKeep" |
     Remove-Item -Force

write-host "Pruning complete"
