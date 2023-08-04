[void] $Global:Session.LoadModule("Utilities");
[void] $Global:Session.LoadModule("Sqlite");

Add-Member `
    -InputObject $Global:Session.AppleHealth.Data `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Correlations" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "Exists" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Key
        )
        [Boolean] $ReturnValue = $false;
        [Int64] $Count = $Global:Session.SQLite.GetTableRowCount(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            "Correlation",
            @{ "Key" = $Key}
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "GetGUID" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Guid])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Key
        )
        [Guid] $ReturnValue = [Guid]::Empty;
        [Object] $Result = $Global:Session.SQLite.GetScalar(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Correlations", "GetGUID.sql")),
            @{ "Key" = $Key },
            "Guid"
        );
        If ($Result -is [Guid])
        {
            $ReturnValue = $Result;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "GetByKey" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Key
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Session.SQLite.GetRecords(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Correlations", "GetByKey.sql")),
            @{ "Key" = $Key },
            @( "CorrelationGUID", "Key", "DataProvider", "Type", "CreationDate", "StartDate", "EndDate", "EntryDate", "EntryTime"),
            @{
                "CorrelationGUID" = "Guid";
                "CreationDate" = "DateTime";
                "StartDate" = "DateTime";
                "EndDate" = "DateTime";
            }
        );
        If ($Records.Count -eq 1)
        {
            Return $Records[0];
        }
        Else
        {
            Return $null;
        }
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "GetByGUID" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $CorrelationGUID
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Session.SQLite.GetRecords(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Correlations", "GetByGUID.sql")),
            @{ "CorrelationGUID" = $CorrelationGUID},
            @( "CorrelationGUID", "Key", "DataProvider", "Type", "CreationDate", "StartDate", "EndDate", "EntryDate", "EntryTime"),
            @{
                "CorrelationGUID" = "Guid";
                "CreationDate" = "DateTime";
                "StartDate" = "DateTime";
                "EndDate" = "DateTime";
            }
        );
        If ($Records.Count -eq 1)
        {
            Return $Records[0];
        }
        Else
        {
            Return $null;
        }
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "GetReadingByGUIDs" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $CorrelationGUID,

            [Parameter(Mandatory=$true)]
            [Guid] $ReadingGUID
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Session.SQLite.GetRecords(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Correlations", "GetReadingByGUIDs.sql")),
            @{
                "CorrelationGUID" = $CorrelationGUID;
                "ReadingGUID" = $ReadingGUID
            },
            @( "CorrelationGUID", "ReadingGUID" ),
            @{
                "CorrelationGUID" = "Guid";
                "ReadingGUID" = "Guid";
            }
        );
        If ($Records.Count -eq 1)
        {
            Return $Records[0];
        }
        Else
        {
            Return $null;
        }
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "Add" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Key,

            [Parameter(Mandatory=$true)]
            [String] $DataProvider,

            [Parameter(Mandatory=$true)]
            [String] $Type,

            [Parameter(Mandatory=$true)]
            [DateTime] $CreationDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $StartDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $EndDate,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryDate,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryTime
        )
        [Guid] $CorrelationGUID = [Guid]::NewGuid();
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Correlations", "Add.sql")),
            @{
                "CorrelationGUID" = $CorrelationGUID;
                "Key" = $Key;
                "DataProvider" = $DataProvider;
                "Type" = $Type;
                "CreationDate" = $CreationDate;
                "StartDate" = $StartDate;
                "EndDate" = $EndDate;
                "EntryDate" = $EntryDate;
                "EntryTime" = $EntryTime;
            }
        );
        [PSObject] $ReturnValue = $Global:Session.AppleHealth.Data.Correlations.GetByKey($Key);
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "AddReading" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $CorrelationGUID,

            [Parameter(Mandatory=$true)]
            [Guid] $ReadingGUID
        )
        [PSObject] $ReturnValue = $Global:Session.AppleHealth.Data.Correlations.GetReadingByGUIDs($CorrelationGUID, $ReadingGUID);
        If (-not $ReturnValue)
        {
            $Global:Session.SQLite.Execute(
                $Global:Session.AppleHealth.Data.ActiveConnectionName,
                [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Correlations", "AddReading.sql")),
                @{
                    "CorrelationGUID" = $CorrelationGUID;
                    "ReadingGUID" = $ReadingGUID;
                }
            );
            $ReturnValue = $Global:Session.AppleHealth.Data.Correlations.GetReadingByGUIDs($CorrelationGUID, $ReadingGUID);
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "Modify" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $CorrelationGUID,

            [Parameter(Mandatory=$true)]
            [String] $Key,

            [Parameter(Mandatory=$true)]
            [String] $DataProvider,

            [Parameter(Mandatory=$true)]
            [String] $Type,

            [Parameter(Mandatory=$true)]
            [DateTime] $CreationDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $StartDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $EndDate,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryDate,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryTime
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Correlations", "Modify.sql")),
            @{
                "CorrelationGUID" = $CorrelationGUID;
                "Key" = $Key;
                "DataProvider" = $DataProvider;
                "Type" = $Type;
                "CreationDate" = $CreationDate;
                "StartDate" = $StartDate;
                "EndDate" = $EndDate;
                "EntryDate" = $EntryDate;
                "EntryTime" = $EntryTime;
            }
        );
        Return $Global:Session.AppleHealth.Data.Correlations.GetByGUID($ReadingGUID);
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "Remove" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $CorrelationGUID
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Correlations", "Remove.sql")),
            @{ "CorrelationGUID" = $CorrelationGUID; }
        );
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "RemoveReadings" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $CorrelationGUID
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Correlations", "RemoveReadings.sql")),
            @{ "CorrelationGUID" = $CorrelationGUID; }
        );
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "RemoveReading" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $CorrelationGUID,
        
            [Parameter(Mandatory=$true)]
            [Guid] $ReadingGUID
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Correlations", "RemoveReading.sql")),
            @{
                "CorrelationGUID" = $CorrelationGUID;
                "ReadingGUID" = $ReadingGUID;
            }
        );
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Correlations `
    -Name "BuildKeyFromAttributes" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $DataProvider,

            [Parameter(Mandatory=$true)]
            [String] $Type,

            [Parameter(Mandatory=$true)]
            [DateTime] $CreationDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $StartDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $EndDate
        )
        [String] $ReturnValue = $null;
        [Double] $ParsedValue = 0
        If ([Double]::TryParse($Value, [ref]$ParsedValue))
        {
            $ReturnValue = $Global:Session.Utilities.HashString([String]::Format("{0}{1}{2}{3}{4}",
                $DataProvider,
                $Type,
                $CreationDate.ToString("yyyyMMddHHmmssfffffff"),
                $StartDate.ToString("yyyyMMddHHmmssfffffff"),
                $EndDate.ToString("yyyyMMddHHmmssfffffff")
            ));
        }
        Return $ReturnValue;
    }
