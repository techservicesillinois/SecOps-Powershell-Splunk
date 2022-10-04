function Send-SplunkHECEvent {
    <#
    .SYNOPSIS
        Sends one or more PowerShell objects to a Splunk HTTP Event Collector (HEC) endpoint as a json object.
    .DESCRIPTION
        Sends one or more PowerShell objects to a Splunk HTTP Event Collector endpoint as a json object.  A single HTTP request sends multiple events to Splunk.
    .PARAMETER HecToken
        Splunk HEC Token as a PSCredential object.  Token must be supplied as the password.
    .PARAMETER HecUri
        Splunk HEC URI to which the event will be sent to.  Defaults to localhost.
    .PARAMETER EventData
        PowerShell object to send to Splunk HEC in json format.
    .PARAMETER Source
        Splunk source value that will be set for the event.
    .PARAMETER Sourcetype
        Splunk sourcetype value that will be set for the event.
    .PARAMETER SplunkHost
        Splunk host value that will be set for the event.
    .PARAMETER RequestSize
        Number of PowerShell objects (multiple Splunk events) to include in a single HTTP Request to Splunk HEC.
    .EXAMPLE
        Send-SplunkHECEvent -HecToken $Credential -HecUri 'https://splunk.example.com:8088/services/collector' -EventData $ObjectArray -Sourcetype 'vendor:product:type:technology/format' -Source 'script.ps1'
    .EXAMPLE
        $EventSplat = @{
            HecToken = $Token
            HecUri = 'https://splunk.example.com:8088/services/collector'
            EventData = $EventData
            Source = "script.ps1"
            SourceType = 'vendor:product:type:technology/format'
            SplunkHost = 'server.example.com'
            RequestSize = 25
        }
        Send-SplunkHECEvent @EventSplat
    #>
    #Requires -Version 7

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$EventData,

        [Parameter(Mandatory = $true)]
        [PSCredential]$HecToken,

        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Sourcetype,

        [string]$SplunkHost = [System.Net.Dns]::GetHostName(),

        [string]$HecUri = 'https://localhost:8088/services/collector',

        [int]$RequestSize = 10
    )

    Begin {
        [string]$BulkEvent = ""
        [int]$count = 0
        [Array]$EventArray = @()
    }

    Process {
        # process potential objects from the pipeline or passed with a parameter
        $EventArray += $EventData
    }

    End {
        # Process events into a multi-event json object of size $RequestSize
        # All events are sent in a single request if $EventArray.Count < $RequestSize
        for ($i = 0; $i -lt $EventArray.Count; $i++) {
            $Body = @{
                'host' = $SplunkHost
                'sourcetype' = $Sourcetype
                'source' = $Source
                'event' = $EventArray[$i]
            } | ConvertTo-Json -Depth 5 -Compress

            # ConvertTo-Json escapes unicode U+0022 quotes automatically
            # https://www.ietf.org/rfc/rfc8259.txt
            # Splunk HEC seems to interpret other unicode quotes as legitimate quotes
            # Escape these quotes to prevent a HEC error of: text":"Invalid data format","code":6,"
            $Body = $Body -replace "`u{201c}", "\`u{201c}" -replace "`u{201d}", "\`u{201d}" -replace "`u{201f}", "\`u{201f}"

            $BulkEvent += $Body
            $count++

            if ($count -eq $RequestSize -or ($i+1 -eq $EventArray.Count)) {
                # Setup parameters for REST call
                $RestSplat = @{
                    URI = $HecUri
                    Headers = @{
                        'Authorization' = "Splunk $($HecToken.GetNetworkCredential().Password)"
                    }
                    Method = 'POST'
                    MaximumRetryCount = 3
                    RetryIntervalSec = 5
                    Body = $BulkEvent
                }

                # Send event(s) to Splunk HEC endpoint
                if ($PSCmdlet.ShouldProcess($RestSplat['Body'], 'Sending')) {
                    Write-Verbose "HTTP Request contains $($count) event(s)"
                    Invoke-RestMethod @RestSplat | Out-Null
                }

                # Reset to create a new multi-event Body
                $count = 0
                $BulkEvent = ""
            }
        }
    }
}
