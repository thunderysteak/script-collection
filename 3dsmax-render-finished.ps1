﻿############################################################################
# Simple script that harvests Vray log files, looks for errors or warnings #
# and posts them to a Discord channel. This script is used in this guide:  #
# https://thunderysteak.github.io/powershell-in-maxscript                  #
############################################################################

#If you want to get a notification, add your discord ID into brackets followed by @, for example: "<@105275532018495488>"
$discordMentionList = ""
#Define your webhook URL
$webhookUri = ""
#Use custom avatar?
$discordUseAvatar = "false"
$discordAvatarUrl = ""
#Use custom avatars for errors and warnings? Custom avatar needs to be enabled.
$discordCustomErrorAV = "false"
$discordWarningAvUrl = ""
$discordErrorAvUrl = ""


$CurrentTimeStamp = Get-Date -Format "dddd MM/dd/yyyy HH:mm"
$getLastRenderStatus = Get-content $env:temp\vraylog.txt |Select-String  -Pattern "error\(s\), * "
if($getLastRenderStatus.count -eq 0){
$MessageContent = "3DS Max has completed a render at " + $CurrentTimeStamp + ", but unable to determine the result!" + "`nManual intervention required. Please verify that logs are getting populated correctly!"
}
else{
$renderStatus = $getLastRenderStatus[$getLastRenderStatus.Count – 1]
$getLogLinesCount = (Get-content $env:temp\vraylog.txt).count
$getLastSessionStart = (Select-String -Path $env:temp\vraylog.txt -Pattern "error\(s\), * ").lineNumber 
$lastSessionLog = (Get-Content -Path $env:temp\vraylog.txt)[$getLastSessionStart[-2]..$getLogLinesCount]
if($renderStatus -Match '0 error\(s\), 0 warning\(s\)*'){
        $MessageContent = "3DS Max render finished at " + $CurrentTimeStamp + "`nRender status:`n" + $renderStatus
    } 
    elseif ($renderStatus -Match 'warning: 0 error\(s\), \w* warning\(s\)*') {
        #Safety in case the script mistakely detects warnings or errors even when none are to be found
        $WarningCount = 0
        $LogFileWarningContent = $lastSessionLog |Select-String  -Pattern "warning: *"
        $WarningCount = $LogFileWarningContent | Measure-Object -Character;
        $LogFileWarningSize = $WarningCount.Characters
            #Discord supports maximum 2000 characters in a message
            if($LogFileWarningSize -ge 900){
                $LogFileWarning = "`nToo many warnings in log file, cannot post log! Make sure Vray is clearing logs correctly!`nPlease check the %temp%\vraylog.txt file for warnings!"
            }
            else{
                $LogFileWarning = $LogFileWarningContent
            }
            if ($discordCustomErrorAV -eq "true"){
            $discordAvatarUrl = $discordWarningAvUrl
            }
        $MessageContent = "3DS Max render finished at " + $CurrentTimeStamp + " with warnings!" + "`nRender status:`n" + $renderStatus + "`n" +"`nLogs:`n" +$LogFileWarning
    }
    elseif ($renderStatus -Match 'warning: \w* error\(s\), \w* warning\(s\)*') {
        $LogFileErrorContent = Get-content $lastSessionLog |Select-String  -Pattern "error: *" 
        #Safety in case the script mistakely detects warnings or errors even when none are to be found
        $ErrorCount = 0
        $ErrorCount = $LogFileErrorContent | Measure-Object -Character;
        $LogFileErrorSize = $ErrorCount.Characters
            #Discord supports maximum 2000 characters in a message
            if($LogFileErrorSize -ge 900){
                $LogFileError += "`nToo many errors in log file, cannot post log! Make sure Vray is clearing logs correctly!"
            }
            else{
                $LogFileError = $LogFileErrorContent
            }
            if ($discordCustomErrorAV -eq "true"){
            $discordAvatarUrl = $discordErrorAvUrl
            }
        $MessageContent = “3DS Max render failed at ” + $CurrentTimeStamp + "!`nPlease check the %temp%\vraylog.txt file for CUDA errors." + "`n" + $renderStatus + "`n" + "`nLogs:`n" + $LogFileError
    }
    else{
    $MessageContent = "3DS Max has completed a render at " + $CurrentTimeStamp + ", but unable to determine the result!" + "`nManual intervention required. Please verify that logs are getting populated correctly!"
    }

if($lastSessionLog -Match 'Using \d* hosts for distributed rendering'){
        $getDRNodeCount = $lastSessionLog |Select-String  -Pattern "Using \d* hosts for distributed rendering"
        $MessageContent += "`n" + "`n" + "Distributed rendering is being used, warnings and errors are for client only." + "`n" + $getDRNodeCount
    } 
}
$MessageContent += "`n" + $discordMentionList
if ($discordUseAvatar -eq "true"){
    $JSON = @{
        "avatar_url" = $discordAvatarUrl
        "content" = $MessageContent
    } | ConvertTo-Json
}
else{
    $JSON = @{
        "content" = $MessageContent
    } | ConvertTo-Json
}
Invoke-RestMethod -Uri $webhookUri  -Method Post -Body $JSON -ContentType "application/json"
