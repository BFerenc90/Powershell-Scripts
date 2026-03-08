$logPath = "C:\Windows\CCM\Logs"
$outputFile = "C:\Temp\CCM_Log_Errors.txt"

# these logs will be skipped
$excludeLogs = "CoManagementHandler","SensorManagedProvider","mtrmgr"

# keywords for searching in the logs
$regexError = '(?i)(error|failed|failure|fatal|exception|0x[0-9a-f]+)'

$results = @()

Get-ChildItem $logPath -Filter *.log | Where-Object {
    $name = $_.Name
    -not ($excludeLogs | Where-Object { $name -like "*$_*" })
} | ForEach-Object {

    $logName = $_.Name

    Get-Content $_.FullName | ForEach-Object {

        if ($_ -match '<!\[LOG\[(.*?)\]LOG\]!>') {

            $logMessage = $matches[1]

            if ($logMessage -match $regexError) {

                $results += "$logName : $logMessage"
            }
        }
    }
}

# remove the duplications
$results |
Sort-Object -Unique |
Set-Content $outputFile
