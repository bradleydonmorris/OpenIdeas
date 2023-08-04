[void] $Global:Session.LoadModule("Utilities");
[void] $Global:Session.LoadModule("Sqlite");

Add-Member `
    -InputObject $Global:Session.AppleHealth.Data `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Workouts" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Workouts `
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
            "Workout",
            @{ "Key" = $Key}
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Workouts `
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
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Workouts", "GetGUID.sql")),
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
    -InputObject $Global:Session.AppleHealth.Data.Workouts `
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
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Workouts", "GetByKey.sql")),
            @{ "Key" = $Key },
            @( "WorkoutGUID", "Key", "DataProvider", "UnitOfMeasure", "Type", "CreationDate", "StartDate", "EndDate", "Duration", "EntryDate", "EntryTime"),
            @{
                "WorkoutGUID" = "Guid";
                "CreationDate" = "DateTime";
                "StartDate" = "DateTime";
                "EndDate" = "DateTime";
                "Duration" = "Double";
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
    -InputObject $Global:Session.AppleHealth.Data.Workouts `
    -Name "GetByGUID" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $WorkoutGUID
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Session.SQLite.GetRecords(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Workouts", "GetByGUID.sql")),
            @{ "WorkoutGUID" = $WorkoutGUID},
            @( "WorkoutGUID", "Key", "DataProvider", "UnitOfMeasure", "Type", "CreationDate", "StartDate", "EndDate", "Duration", "EntryDate", "EntryTime"),
            @{
                "WorkoutGUID" = "Guid";
                "CreationDate" = "DateTime";
                "StartDate" = "DateTime";
                "EndDate" = "DateTime";
                "Duration" = "Double";
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
    -InputObject $Global:Session.AppleHealth.Data.Workouts `
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
            [String] $UnitOfMeasure,

            [Parameter(Mandatory=$true)]
            [String] $Type,

            [Parameter(Mandatory=$true)]
            [DateTime] $CreationDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $StartDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $EndDate,

            [Parameter(Mandatory=$true)]
            [Double] $Duration,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryDate,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryTime
        )
        [Guid] $WorkoutGUID = [Guid]::NewGuid();
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Workouts", "Add.sql")),
            @{
                "WorkoutGUID" = $WorkoutGUID;
                "Key" = $Key;
                "DataProvider" = $DataProvider;
                "UnitOfMeasure" = $UnitOfMeasure;
                "Type" = $Type;
                "CreationDate" = $CreationDate;
                "StartDate" = $StartDate;
                "EndDate" = $EndDate;
                "Duration" = $Duration;
                "EntryDate" = $EntryDate;
                "EntryTime" = $EntryTime;
            }
        );
        [PSObject] $ReturnValue = $Global:Session.AppleHealth.Data.Workouts.GetByKey($Key);
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Workouts `
    -Name "Modify" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $WorkoutGUID,

            [Parameter(Mandatory=$true)]
            [String] $Key,

            [Parameter(Mandatory=$true)]
            [String] $DataProvider,

            [Parameter(Mandatory=$true)]
            [String] $UnitOfMeasure,

            [Parameter(Mandatory=$true)]
            [String] $Type,

            [Parameter(Mandatory=$true)]
            [DateTime] $CreationDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $StartDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $EndDate,

            [Parameter(Mandatory=$true)]
            [Double] $Duration,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryDate,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryTime
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Workouts", "Modify.sql")),
            @{
                "WorkoutGUID" = $WorkoutGUID;
                "Key" = $Key;
                "DataProvider" = $DataProvider;
                "UnitOfMeasure" = $UnitOfMeasure;
                "Type" = $Type;
                "CreationDate" = $CreationDate;
                "StartDate" = $StartDate;
                "EndDate" = $EndDate;
                "Duration" = $Duration;
                "EntryDate" = $EntryDate;
                "EntryTime" = $EntryTime;
            }
        );
        Return $Global:Session.AppleHealth.Data.Workouts.GetByGUID($WorkoutGUID);
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Workouts `
    -Name "Remove" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $WorkoutGUID
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Workouts", "Remove.sql")),
            @{ "WorkoutGUID" = $WorkoutGUID; }
        );
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Workouts `
    -Name "BuildKeyFromAttributes" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $DataProvider,

            [Parameter(Mandatory=$true)]
            [String] $UnitOfMeasure,

            [Parameter(Mandatory=$true)]
            [String] $Type,

            [Parameter(Mandatory=$true)]
            [DateTime] $CreationDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $StartDate,

            [Parameter(Mandatory=$true)]
            [DateTime] $EndDate,

            [Parameter(Mandatory=$true)]
            [Double] $Duration
        )
        Return $Global:Session.Utilities.HashString([String]::Format("{0}{1}{2}{3}{4}{5}{6}",
            $DataProvider,
            $UnitOfMeasure,
            $Type,
            $CreationDate.ToString("yyyyMMddHHmmssfffffff"),
            $StartDate.ToString("yyyyMMddHHmmssfffffff"),
            $EndDate.ToString("yyyyMMddHHmmssfffffff"),
            $Duration.ToString()
        ));
    }
