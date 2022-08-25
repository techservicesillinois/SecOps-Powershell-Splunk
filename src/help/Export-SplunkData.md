---
external help file: UofISplunkCloud-help.xml
Module Name: UofISplunkCloud
online version:
schema: 2.0.0
---

# Export-SplunkData

## SYNOPSIS
Returns data from Splunk based on search parameters

## SYNTAX

```
Export-SplunkData [-Credential] <PSCredential> [-CloudDeploymentName] <String> [-Search] <String>
 [[-OutputMode] <String>] [-ConsoleOutput] [[-App] <String>] [[-Timeout] <Int32>] [[-EarliestTime] <String>]
 [[-LatestTime] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns data from Splunk based on search parameters

## EXAMPLES

### EXAMPLE 1
```
Export-SplunkData -CloudDeploymentName 'illinois' -Search 'index=test test_event' -Credential $Credential -ConsoleOutput -EarliestTime '-15m'
```

### EXAMPLE 2
```
Export-SplunkData -CloudDeploymentName 'illinois' -Search 'index=test | append [ | inputlookup test ]' -Credential $Credential -App 'illinois-urbana-security-techsvc-APP'
Note like in the above example, search commands that begin with | such as inputlookup and mstats must be fed a dummy index and an append to complete the search succesfully with the API.
https://github.com/splunk/splunk-tableau-wdc/issues/6#issuecomment-499229594
```

## PARAMETERS

### -Credential
Service account username and password with access to the search index being used in Splunk

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CloudDeploymentName
Name of your Splunk cloud deployment name ie 'illinois' for illinois.splunkcloud.com

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Search
Splunk search query for the data you would like returned

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputMode
Format of the data to return.
Default is CSV and CSVs will output as a file
Valid values: (csv | json | json_cols | json_rows | xml)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Csv
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConsoleOutput
Specify to return the data of the given format to the console.
No file will be created.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -App
Specify the Splunk app to search if required

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timeout
Number of minutes to wait for search results before timing out.
Default is 5

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 5
Accept pipeline input: False
Accept wildcard characters: False
```

### -EarliestTime
Sets the earliest (inclusive), respectively, time bounds for the search.
Can be a UTC time or a time relative to now ex: -5h for 5 hours ago.
1 indicates all time.
Default is 30m ago

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: -30m
Accept pipeline input: False
Accept wildcard characters: False
```

### -LatestTime
Sets the latest (exclusive), respectively, time bounds for the search.
Can be a UTC time or a time relative to now ex: -30m for 30m ago.
Default is now

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
