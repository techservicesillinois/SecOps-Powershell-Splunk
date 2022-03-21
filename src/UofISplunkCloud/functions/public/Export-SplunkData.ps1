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
    Sets the earliest (inclusive), respectively, time bounds for the search. Can be a UTC time or a time relative to now ex: -5h for 5 hours ago
    Default is 30m ago
.PARAMETER LatestTime
    Sets the latest (exclusive), respectively, time bounds for the search. Can be a UTC time or a time relative to now ex: -30m for 30m ago. Default is now
.EXAMPLE
    Export-SplunkData -CloudDeploymentName 'illinois' -Search 'index=security-qualysvm_techsvc | stats count by sourcetype' -Credential $Credential -App 'illinois-urbana-security-techsvc-APP'
.EXAMPLE
    Export-SplunkData -CloudDeploymentName 'illinois' -Search 'index=test test_event' -Credential $Credential -ConsoleOutput -EarliestTime '-15m'
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
        While(($Status -ne 'DONE') -or ($Seconds -ge ($Timeout*60))){
            Start-Sleep -Seconds 5
            $Seconds += 5
            $SearchMetaData = Invoke-RestMethod @IVRSplat
            $Status = $SearchMetaData.entry.content.dispatchState
        }
        If($Seconds -ge ($Timeout*60)){
            Throw "Search timeout has elapsed. Try increasing the timeout. The status of your search at the time of this error was: $($Status)"
        }

        #Now that the search is 'DONE', use the SID for our search to get the results
        $IVRSplat = @{
            Credential = $Credential
            Method = 'GET'
            URI = "$($BaseURI)/search/jobs/$($SearchJob.sid)/results"
            Body =  @{
                output_mode = $OutputMode
            }
        }
        $Results = Invoke-RestMethod @IVRSplat

        #Return results 
        If($ConsoleOutput){
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
