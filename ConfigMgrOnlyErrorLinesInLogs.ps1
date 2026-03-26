$logPath    = "C:\Windows\CCM\Logs"
$outputFile = "C:\Temp\CCM_Log_Errors.txt"

# check these logs
$includedLogs = @(
    "ClientIDManagerStartup.log",
    "ClientLocation.log",
    "LocationServices.log",
    "PolicyAgent.log",
    "CcmMessaging.log",
    "CcmEval.log",
    "CcmExec.log",
    "ExecMgr.log",
    "InventoryAgent.log",
    "WUAHandler.log",
    "UpdatesDeployment.log",
    "UpdatesHandler.log",
    "UpdatesStore.log",
    "ScanAgent.log",
    "CAS.log",
    "ContentTransferManager.log",
    "DataTransferService.log"
)

# regex for error searching
$regexError = '(?i)\b(error|failed|failure|fatal|exception|0x[0-9a-f]{4,8})\b'

$results = New-Object System.Collections.Generic.HashSet[string]

Get-ChildItem -Path $logPath -Filter *.log |
Where-Object { $includedLogs -contains $_.Name } |
ForEach-Object {

    $logName = $_.Name

    Get-Content -Path $_.FullName -ErrorAction SilentlyContinue |
    ForEach-Object {

        if ($_ -match '<!\[LOG\[(.*?)\]LOG\]!>') {

            $logMessage = $matches[1]

            if ($logMessage -match $regexError) {
                $results.Add("$logName : $logMessage") | Out-Null
            }
        }
    }
}

$results |
Sort-Object |
Set-Content -Path $outputFile -Encoding UTF8
