<#
.Synopsis
    Updates a Splunk lookup table with the provided CSV. This function requires loading the CSV into memory and should not be used with large files.
.DESCRIPTION
    Updates a Splunk lookup table with the provided CSV. This function requires loading the CSV into memory and should not be used with large files.
.PARAMETER Credential
    Service account username and password with access to the search index being used in Splunk
.PARAMETER CloudDeploymentName
    Name of your Splunk cloud deployment name ie 'illinois' for illinois.splunkcloud.com
.PARAMETER LookupName
    Name of your lookup in Splunk ie 'test.csv'
.PARAMETER NewCSVPath
    Path to the CSV that will replace the lookup at the lookup name provided ie '.\test_2022-14-03.csv'
.PARAMETER App
    Specify the Splunk app to use if required ie 'illinois-urbana-security-techsvc-APP'
.EXAMPLE
    Update-SplunkLookup -Credential $Credential -CloudDeploymentName 'illinois' -LookupName 'test.csv' -NewCSVPath '.\test_2022-14-03.csv' -App 'illinois-urbana-security-techsvc-APP'
#>
function Update-SplunkLookup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$true)]
        [String]$CloudDeploymentName,
        [Parameter(Mandatory=$true)]
        [String]$LookupName,
        [Parameter(Mandatory=$true)]
        [String]$NewCSVPath,
        [String]$App
    )

    process {
        #Set the Base URI depending on whether or not an app was specified
        If($App){
            $BaseURI = "https://$($CloudDeploymentName).splunkcloud.com:8089/servicesNS/$($Credential.UserName)/$($App)"
        }
        Else{
            $BaseURI = "https://$($CloudDeploymentName).splunkcloud.com:8089/services"
        }
        #Support -WhatIf feature of this function because it makes system changes
        If($PSCmdlet.ShouldProcess("$($BaseURI)/data/lookup-table-files/$($LookupName)")){
            #Test that the lookup exists
            $IVRSplat = @{
                Credential = $Credential
                Method = 'GET'
                #Use a different URI depending on if an App is specified or not
                URI = "$($BaseURI)/data/lookup-table-files/"
                Body =  @{
                    count = 0
                }
            }
            $Lookups = Invoke-RestMethod @IVRSplat
            If($Lookups.Title -contains $LookupName){
                Write-Verbose -Message "Lookup $($LookupName) found. Proceeding to update."
            }
            Else{
                Throw "Lookup $($LookupName) not found. Please try again. You may need to specify a Splunk app to search within."
            }

            #Update the lookup, which requires transformation of the CSV file
            $CSVJson = Import-Csv $NewCSVPath -Encoding 'utf8BOM' | ConvertTo-Json
            #Escapes any escapes \ and escaped quotes \" in the json elements, then escapes any quotes in the json body
            #Solution from dmarling here: https://community.splunk.com/t5/Getting-Data-In/how-to-upload-csv-data-file-into-splunk-by-using-REST-API-Can/td-p/442884
            $EscapingEscapedEscapes = $CSVJson -replace '\\\\', '\\\\\\'
            $EscapingEscapedQuotes = $EscapingEscapedEscapes -replace '([^\\])\\"','$1\\\"'
            $FileEscaped = $EscapingEscapedQuotes -replace '([\n\r]\s+)"(.*)":(\s+)"(.*)"(,?[\n\r])','$1\"$2\":$3\"$4\"$5'
            $Search = '| makeresults count=1 | fields - _time | eval data="'+$FileEscaped+'" | eval data=trim(data, "[]") | rex field=data mode=sed "s/(\s+)\},/\1}█/g" | makemv data delim="█" | mvexpand data | eval data="[".data."]" | spath input=data | fields - data | rename "{}.*" as * | outputlookup '+$LookupName+''
            $IVRSplat = @{
                Credential = $Credential
                Method = 'POST'
                #Use a different URI depending on if an App is specified or not
                URI = "$($BaseURI)/search/jobs"
                Body =  @{
                    output_mode = 'csv'
                    exec_mode = 'oneshot'
                    count = 0
                    search = "$($Search)"
                }
            }
            $Results = Invoke-RestMethod @IVRSplat
            Write-Verbose -Message "$($Results)"
        }
    }
    end {
    }
}
