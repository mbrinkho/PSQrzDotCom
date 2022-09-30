Function Get-QRZLog {
    param(
        [Parameter(Mandatory = $true, HelpMessage = "This is your QRZ.com API Key.")][string]$APIKey,
        [string]$URL = 'https://logbook.qrz.com/api',
        [int]$Days = 1,
        [switch]$ShowResult
    )
    $EndDate = (Get-Date).ToString('yyyy-MM-dd')
    $StartDate = (Get-Date).AddDays(($Days * -1)).ToString('yyyy-MM-dd')
    $WebRequest = "$URL`?KEY=$APIKey&ACTION=FETCH&OPTION=BETWEEN:$StartDate+$EndDate,TYPE:ADIF"

    $WebReturn = Invoke-Webrequest $WebRequest
    $logDecoded = [System.Web.HttpUtility]::HtmlDecode($WebReturn)
    $LogSplit = $LogDecoded -split [char]10 | Select-Object $_

    $Output = @()
    Foreach ($LogLine in $LogSplit) {
        if ($LogLine -notmatch "^COUNT=") {
            if ($LogLine -eq '<eor>') {
                if ($ShowResult) { write-host "EOR FOUND" }
                $Output += $TempObj
                $TempObj = $null
            } else {
                if ($LogLine -match '<') {
                    if (!$Tempobj) {
                        if ($ShowResult) { write-host "CREATING NEW OBJECT" }
                        $TempObj = New-Object PSObject
                    }
                    if ($ShowResult) { write-host $LogLine }
                    $Split = $LogLine.Split(">")
                    $NameTemp = $split[0].Replace("<", '')
                    $Name = $NameTemp.Split(":")[0]
                    $Value = $Split[1]
                    if ($ShowResult) { write-host "$name : $Value" }
                    $TempObj | add-member -NotePropertyName $Name -NotePropertyValue $Value -Force
                }
            }
        }
    }
    Return $Output
}



