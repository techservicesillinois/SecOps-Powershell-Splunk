# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

### Changed

### Removed

## [1.1.4] - 2024-10-17

### Changed

- Export-SplunkData.ps1: Added new parameters "Offset" and "MaxResults" to add the functionality of offsetting results due to the 50000 event limit within the Splunk Cloud API.

## [1.1.3] - 2023-05-01

### Changed

- Send-SplunkHECEvent.ps1 now has a parameter `SkipCertificateCheck` to allow for connections to dev environments with self-signed certificates on the HEC endpoint.

## [1.1.2] - 2023-03-31

### Changed

- Added "count" parameter and set to 0 so results are no longer limited to 100.

## [1.1.1] - 2022-09-06

### Changed

- Provided a fix in Send-SplunkHECEvent.ps1 to address a case where Splunk was treating unicode quotation characters as U+0022. PowerShell escapes U+0022 with ConvertTo-Json. This fix also escapes the other unicode quotation characters to prevent an error from Splunk HEC.
- Added a parameter to the ConvertTo-Json command to allow processing of deeper JSON objects.

## [1.1.0] - 2022-08-23

### Added

- Send-SplunkHECEvent which sends one or more PowerShell objects to a Splunk HTTP Event Collector (HEC) endpoint as a json object.

## [1.0.2] - 2022-04-22

### Added

- Comments explaining API workaround for search commands that begin with '|'
- More specific error output conditions
- Output for no results

### Changed

- While condition changed to better track if search is still running

## [1.0.1] - 2022-03-21

### Changed

- MIT License replaced with U of I / NCSA License

### Added

- EOL and EOS dates to README
- Whatif functionality / SupportShouldProcess to Update-SplunkLookup

### Removed

- Trailing whitespace

## [1.0.0] - 2022-03-17

### Added

- Initialized repository with existing functions Update-SplunkLookup and Export-SplunkData
