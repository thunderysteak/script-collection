############################################################################
# Simple script that harvests Vray log files, looks for errors or warnings #
# and posts them to a Discord channel. This script is used in this guide:  #
# https://thunderysteak.github.io/powershell-in-maxscript                  #
############################################################################

$webhookUri = "Put your webhook here"
$CurrentTimeStamp = Get-Date -Format "dddd MM/dd/yyyy HH:mm"
$LogFileContents = Get-content -tail 20 $env:temp\vraylog.txt |Select-String  -Pattern "warning"
$LogFileError = Get-content -tail 20 $env:temp\vraylog.txt |Select-String  -Pattern "error"
$LogFileWarningContent = Get-content $env:temp\vraylog.txt |Select-String  -Pattern "warning:"
$LogFileErrorContent = Get-content $env:temp\vraylog.txt |Select-String  -Pattern "error:"

if($LogFileContents -like'*0 error(s)*') {
    $MessageContent = "3DS Max render finished at " + $CurrentTimeStamp + "`nRender status:`n" + $LogFileContents
    } else {
    $MessageContent = “3DS Max render failed at ” + $CurrentTimeStamp + "!`nPlease check the %temp%\vraylog.txt file for CUDA errors." + "`n" + $LogFileWarningContent + $LogFileErrorContent
    }

$JSON = @{
    "content" = $MessageContent
} | ConvertTo-Json

Invoke-WebRequest -Uri $webhookUri -Method POST -Body $JSON
