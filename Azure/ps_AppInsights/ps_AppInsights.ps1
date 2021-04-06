$AI = "$PSScriptRoot\Microsoft.ApplicationInsights.dll"
[Reflection.Assembly]::LoadFile($AI)

$InstrumentationKey = ""
$TelClient = New-Object "Microsoft.ApplicationInsights.TelemetryClient"
$TelClient.InstrumentationKey = $InstrumentationKey

# Exception
try {  
    8/0 #DivideByZeroException
}
catch {  
    $TelException = New-Object "Microsoft.ApplicationInsights.DataContracts.ExceptionTelemetry"
    $TelException.Exception = $_.Exception
    $TelClient.TrackException($TelException)
    $TelClient.Flush()
}