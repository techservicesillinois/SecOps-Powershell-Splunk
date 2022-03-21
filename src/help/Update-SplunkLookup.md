---
external help file: UofISplunkCloud-help.xml
Module Name: UofISplunkCloud
online version:
schema: 2.0.0
---

# Update-SplunkLookup

## SYNOPSIS
Updates a Splunk lookup table with the provided CSV.
This function requires loading the CSV into memory and should not be used with large files.

## SYNTAX

```
Update-SplunkLookup [-Credential] <PSCredential> [-CloudDeploymentName] <String> [-LookupName] <String>
 [-NewCSVPath] <String> [[-App] <String>] [<CommonParameters>]
```

## DESCRIPTION
Updates a Splunk lookup table with the provided CSV.
This function requires loading the CSV into memory and should not be used with large files.

## EXAMPLES

### EXAMPLE 1
```
Update-SplunkLookup -Credential $Credential -CloudDeploymentName 'illinois' -LookupName 'test.csv' -NewCSVFilePath '.\test_2022-14-03.csv' -App 'illinois-urbana-security-techsvc-APP'
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

### -LookupName
Name of your lookup in Splunk ie 'test.csv'

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

### -NewCSVPath
Path to the CSV that will replace the lookup at the lookup name provided ie '.\test_2022-14-03.csv'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -App
Specify the Splunk app to use if required ie 'illinois-urbana-security-techsvc-APP'

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
