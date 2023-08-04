[void] $Global:Session.LoadModule("Utilities");
[void] $Global:Session.LoadModule("Sqlite");

Add-Member `
    -InputObject $Global:Session.AppleHealth.Data `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "WorkoutStatistics" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.WorkoutStatistics `
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
            "WorkoutStatistic",
            @{ "Key" = $Key}
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.WorkoutStatistics `
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
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "WorkoutStatistics", "GetGUID.sql")),
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
    -InputObject $Global:Session.AppleHealth.Data.WorkoutStatistics `
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
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "WorkoutStatistics", "GetByKey.sql")),
            @{ "Key" = $Key },
            @( "WorkoutStatisticGUID", "Key", "WorkoutGUID", "UnitOfMeasure", "Type", "Aggregate", "StartDate", "EndDate", "Value", "EntryDate", "EntryTime"),
            @{
                "WorkoutStatisticGUID" = "Guid";
                "WorkoutGUID" = "Guid";
                "CreationDate" = "DateTime";
                "StartDate" = "DateTime";
                "EndDate" = "DateTime";
                "Value" = "Double";
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
    -InputObject $Global:Session.AppleHealth.Data.WorkoutStatistics `
    -Name "GetByGUID" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $WorkoutStatisticGUID
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Session.SQLite.GetRecords(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "WorkoutStatistics", "GetByGUID.sql")),
            @{ "WorkoutStatisticGUID" = $WorkoutStatisticGUID},
            @( "WorkoutStatisticGUID", "Key", "WorkoutGUID", "UnitOfMeasure", "Type", "Aggregate", "StartDate", "EndDate", "Value", "EntryDate", "EntryTime"),
            @{
                "WorkoutStatisticGUID" = "Guid";
                "WorkoutGUID" = "Guid";
                "CreationDate" = "DateTime";
                "StartDate" = "DateTime";
                "EndDate" = "DateTime";
                "Value" = "Double";
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
    -InputObject $Global:Session.AppleHealth.Data.WorkoutStatistics `
    -Name "Add" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Key,

            [Parameter(Mandatory=$true)]
            [Guid] $WorkoutGUID,

            [Parameter(Mandatory=$true)]
            [String] $UnitOfMeasure,

            [Parameter(Mandatory=$true)]
            [String] $Type,

            [Parameter(Mandatory=$true)]
            [String] $Aggregate,

            [Parameter(Mandatory=$true)]
            [DateTime] $StartDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $EndDate,

            [Parameter(Mandatory=$true)]
            [Double] $Value,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryDate,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryTime
        )
        [Guid] $WorkoutStatisticGUID = [Guid]::NewGuid();
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "WorkoutStatistics", "Add.sql")),
            @{
                "WorkoutStatisticGUID" = $WorkoutStatisticGUID;
                "WorkoutGUID" = $WorkoutGUID;
                "Key" = $Key;
                "UnitOfMeasure" = $UnitOfMeasure;
                "Type" = $Type;
                "Aggregate" = $Aggregate;
                "StartDate" = $StartDate;
                "EndDate" = $EndDate;
                "Value" = $Value;
                "EntryDate" = $EntryDate;
                "EntryTime" = $EntryTime;
            }
        );
        [PSObject] $ReturnValue = $Global:Session.AppleHealth.Data.WorkoutStatistics.GetByKey($Key);
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.WorkoutStatistics `
    -Name "Modify" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $WorkoutStatisticGUID,

            [Parameter(Mandatory=$true)]
            [Guid] $WorkoutGUID,

            [Parameter(Mandatory=$true)]
            [String] $Key,

            [Parameter(Mandatory=$true)]
            [String] $UnitOfMeasure,

            [Parameter(Mandatory=$true)]
            [String] $Type,

            [Parameter(Mandatory=$true)]
            [String] $Aggregate,

            [Parameter(Mandatory=$true)]
            [DateTime] $StartDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $EndDate,

            [Parameter(Mandatory=$true)]
            [Double] $Value,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryDate,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryTime
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "WorkoutStatistics", "Modify.sql")),
            @{
                "WorkoutStatisticGUID" = $WorkoutStatisticGUID;
                "WorkoutGUID" = $WorkoutGUID;
                "Key" = $Key;
                "UnitOfMeasure" = $UnitOfMeasure;
                "Type" = $Type;
                "Aggregate" = $Aggregate;
                "StartDate" = $StartDate;
                "EndDate" = $EndDate;
                "Value" = $Value;
                "EntryDate" = $EntryDate;
                "EntryTime" = $EntryTime;
            }
        );
        Return $Global:Session.AppleHealth.Data.WorkoutStatistics.GetByGUID($WorkoutStatisticGUID);
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.WorkoutStatistics `
    -Name "Remove" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $WorkoutStatisticGUID
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "WorkoutStatistics", "Remove.sql")),
            @{ "WorkoutStatisticGUID" = $WorkoutStatisticGUID; }
        );
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.WorkoutStatistics `
    -Name "BuildKeyFromAttributes" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $WorkoutGUID,

            [Parameter(Mandatory=$true)]
            [String] $UnitOfMeasure,

            [Parameter(Mandatory=$true)]
            [String] $Type,

            [Parameter(Mandatory=$true)]
            [String] $Aggregate,

            [Parameter(Mandatory=$true)]
            [DateTime] $StartDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $EndDate,

            [Parameter(Mandatory=$true)]
            [Double] $Value
        )
        Return $Global:Session.Utilities.HashString([String]::Format("{0}{1}{2}{3}{4}{5}{6}",
            $WorkoutGUID.ToString("N"),
            $UnitOfMeasure,
            $Type,
            $Aggregate,
            $StartDate.ToString("yyyyMMddHHmmssfffffff"),
            $EndDate.ToString("yyyyMMddHHmmssfffffff"),
            $Value.ToString()
        ));
    }
