<#
.Synopsis
    Returns data from Splunk based on search parameters
.DESCRIPTION
    Returns data from Splunk based on search parameters
.PARAMETER Credential
    Service account username and password with access to the search index being used in Splunk
.PARAMETER CloudDeploymentName
    Name of your Splunk cloud deployment name ie 'illinois' for illinois.splunkcloud.com
.PARAMETER Search
    Splunk search query for the data you would like returned
.PARAMETER OutputMode
    Format of the data to return. Default is CSV and CSVs will output as a file
    Valid values: (csv | json | json_cols | json_rows | xml)
.PARAMETER ConsoleOutput
    Specify to return the data of the given format to the console. No file will be created.
.PARAMETER App
    Specify the Splunk app to search if required
.PARAMETER Timeout
    Number of minutes to wait for search results before timing out. Default is 5
.PARAMETER EarliestTime
    Sets the earliest (inclusive), respectively, time bounds for the search. Can be a UTC time or a time relative to now ex: -5h for 5 hours ago. 1 indicates all time.
    Default is 30m ago
.PARAMETER LatestTime
    Sets the latest (exclusive), respectively, time bounds for the search. Can be a UTC time or a time relative to now ex: -30m for 30m ago. Default is now
.EXAMPLE
    Export-SplunkData -CloudDeploymentName 'illinois' -Search 'index=test test_event' -Credential $Credential -ConsoleOutput -EarliestTime '-15m'
.EXAMPLE
    Export-SplunkData -CloudDeploymentName 'illinois' -Search 'index=test | append [ | inputlookup test ]' -Credential $Credential -App 'illinois-urbana-security-techsvc-APP'
    Note like in the above example, search commands that begin with | such as inputlookup and mstats must be fed a dummy index and an append to complete the search succesfully with the API.
    https://github.com/splunk/splunk-tableau-wdc/issues/6#issuecomment-499229594
#>
function Export-SplunkData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$true)]
        [String]$CloudDeploymentName,
        [Parameter(Mandatory=$true)]
        [String]$Search,
        [ValidateSet("csv","json","json_cols","json_rows","xml")]
        [String]$OutputMode = "csv",
        [Switch]$ConsoleOutput,
        [String]$App,
        [Int]$Timeout = 5,
        [String]$EarliestTime = '-30m',
        [String]$LatestTime

    )

    process {
        #Set the Base URI depending on whether or not an app was specified
        If($App){
            $BaseURI = "https://$($CloudDeploymentName).splunkcloud.com:8089/servicesNS/$($Credential.UserName)/$($App)"
        }
        Else{
            $BaseURI = "https://$($CloudDeploymentName).splunkcloud.com:8089/services"
        }

        #Create the search, this returns an SID for the search
        $IVRSplat = @{
            Credential = $Credential
            Method = 'POST'
            URI = "$($BaseURI)/search/jobs"
            Body =  @{
                search = "search $($Search)"
                output_mode = 'json'
                earliest_time = $EarliestTime
                latest_time = $LatestTime
            }
        }
        $SearchJob = Invoke-RestMethod @IVRSplat

        #Check the status of the search to ensure it is finished before we get the results
        $IVRSplat = @{
            Credential = $Credential
            Method = 'GET'
            URI = "$($BaseURI)/search/jobs/$($SearchJob.sid)/"
            Body =  @{
                output_mode = 'json'
            }
        }
        $SearchMetaData = Invoke-RestMethod @IVRSplat
        $Status = $SearchMetaData.entry.content.dispatchState
        $Seconds = 0
        #Wait for the search to parse and keep checking its status until it's no longer running or the timeout elapses
        While((($Status -eq 'PARSING') -or ($Status -eq 'RUNNING')) -and ($Seconds -le ($Timeout*60))){
            Start-Sleep -Seconds 5
            $Seconds += 5
            Write-Verbose -Message 'Search is still running...'
            $SearchMetaData = Invoke-RestMethod @IVRSplat
            $Status = $SearchMetaData.entry.content.dispatchState
        }
        If($Seconds -ge ($Timeout*60)){
            If($Status -eq 'RUNNING'){
                Throw "Search timeout has elapsed while the search was still running. Try increasing the timeout."
            }
            Else{
                Throw "Search timeout has elapsed. Try increasing the timeout. The status of your search at the time of this error was: $($Status)"
            }
        }
        If($Status -eq 'FAILED'){
            Throw "Search has FAILED. `n $($SearchMetaData.entry.Content.messages.text)"
        }
        ElseIf($Status -ne 'DONE'){
            Throw "Search did not complete successfully. The status of your search is $($Status). `n $($SearchMetaData.entry.Content.messages.text)"
        }

        #Now that the search is 'DONE', use the SID for our search to get the results
        $IVRSplat = @{
            Credential = $Credential
            Method = 'GET'
            URI = "$($BaseURI)/search/jobs/$($SearchJob.sid)/results"
            Body =  @{
                output_mode = $OutputMode
                count = '0'
            }
        }
        $Results = Invoke-RestMethod @IVRSplat

        #Return results
        If(!($Results)){
            Write-Output -InputObject "No results"
        }
        ElseIf($ConsoleOutput){
            $Results
        }
        ElseIf($OutputMode -eq 'csv'){
            $Results | Out-File -Path ".\SearchResults_$(Get-Date -Format yyyyMMdd-HHmmss).csv"
            Write-Output -InputObject "SearchResults_$(Get-Date -Format yyyyMMdd-HHmmss).csv"
        }
        ElseIf($OutputMode -like 'json*'){
            $Results | Out-File -Path ".\SearchResults_$(Get-Date -Format yyyyMMdd-HHmmss).json"
            Write-Output -InputObject "SearchResults_$(Get-Date -Format yyyyMMdd-HHmmss).json"
        }
        ElseIf($OutputMode -eq 'xml'){
            $Results | Out-File -Path ".\SearchResults_$(Get-Date -Format yyyyMMdd-HHmmss).xml"
            Write-Output -InputObject "SearchResults_$(Get-Date -Format yyyyMMdd-HHmmss).xml"
        }
        else{
            $Results | Out-File -Path ".\SearchResults_$(Get-Date -Format yyyyMMdd-HHmmss)"
            Write-Output -InputObject "SearchResults_$(Get-Date -Format yyyyMMdd-HHmmss)"
        }
    }
    end {
    }
}
