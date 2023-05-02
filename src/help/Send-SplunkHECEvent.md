---
external help file: UofISplunkCloud-help.xml
Module Name: UofISplunkCloud
online version:
schema: 2.0.0
---

# Send-SplunkHECEvent

## SYNOPSIS
Sends one or more PowerShell objects to a Splunk HTTP Event Collector (HEC) endpoint as a json object.

## SYNTAX

```
Send-SplunkHECEvent [-EventData] <PSObject> [-HecToken] <PSCredential> [-Source] <String>
 [-Sourcetype] <String> [[-SplunkHost] <String>] [[-HecUri] <String>] [[-RequestSize] <Int32>]
 [-SkipCertificateCheck] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends one or more PowerShell objects to a Splunk HTTP Event Collector endpoint as a json object. 
A single HTTP request sends multiple events to Splunk.

## EXAMPLES

### EXAMPLE 1
```
Send-SplunkHECEvent -HecToken $Credential -HecUri 'https://splunk.example.com:8088/services/collector' -EventData $ObjectArray -Sourcetype 'vendor:product:type:technology/format' -Source 'script.ps1'
```

### EXAMPLE 2
```
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
```

Requires -Version 7

## PARAMETERS

### -EventData
PowerShell object to send to Splunk HEC in json format.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -HecToken
Splunk HEC Token as a PSCredential object. 
Token must be supplied as the password.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
Splunk source value that will be set for the event.

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

### -Sourcetype
Splunk sourcetype value that will be set for the event.

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

### -SplunkHost
Splunk host value that will be set for the event.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: [System.Net.Dns]::GetHostName()
Accept pipeline input: False
Accept wildcard characters: False
```

### -HecUri
Splunk HEC URI to which the event will be sent to. 
Defaults to localhost.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Https://localhost:8088/services/collector
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequestSize
Number of PowerShell objects (multiple Splunk events) to include in a single HTTP Request to Splunk HEC.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipCertificateCheck
Switch to skip the TLS certificate checking.

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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
