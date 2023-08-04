[void] $Global:Session.LoadModule("Utilities");
[void] $Global:Session.LoadModule("Sqlite");

Add-Member `
    -InputObject $Global:Session.AppleHealth.Data `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Readings" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Readings `
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
            "Reading",
            @{ "Key" = $Key}
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Readings `
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
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Readings", "GetGUID.sql")),
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
    -InputObject $Global:Session.AppleHealth.Data.Readings `
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
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Readings", "GetByKey.sql")),
            @{ "Key" = $Key },
            @( "ReadingGUID", "Key", "DataProvider", "UnitOfMeasure", "Type", "CreationDate", "StartDate", "EndDate", "Value", "EntryDate", "EntryTime"),
            @{
                "ReadingGUID" = "Guid";
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
    -InputObject $Global:Session.AppleHealth.Data.Readings `
    -Name "GetByGUID" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $ReadingGUID
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Session.SQLite.GetRecords(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Readings", "GetByGUID.sql")),
            @{ "ReadingGUID" = $ReadingGUID},
            @( "ReadingGUID", "Key", "DataProvider", "UnitOfMeasure", "Type", "CreationDate", "StartDate", "EndDate", "Value", "EntryDate", "EntryTime"),
            @{
                "ReadingGUID" = "Guid";
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
    -InputObject $Global:Session.AppleHealth.Data.Readings `
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
            [Double] $Value,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryDate,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryTime
        )
        [Guid] $ReadingGUID = [Guid]::NewGuid();
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Readings", "Add.sql")),
            @{
                "ReadingGUID" = $ReadingGUID;
                "Key" = $Key;
                "DataProvider" = $DataProvider;
                "UnitOfMeasure" = $UnitOfMeasure;
                "Type" = $Type;
                "CreationDate" = $CreationDate;
                "StartDate" = $StartDate;
                "EndDate" = $EndDate;
                "Value" = $Value;
                "EntryDate" = $EntryDate;
                "EntryTime" = $EntryTime;
            }
        );
        [PSObject] $ReturnValue = $Global:Session.AppleHealth.Data.Readings.GetByKey($Key);
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Readings `
    -Name "Modify" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $ReadingGUID,

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
            [Double] $Value,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryDate,

            [Parameter(Mandatory=$true)]
            [Int64] $EntryTime
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Readings", "Modify.sql")),
            @{
                "ReadingGUID" = $ReadingGUID;
                "Key" = $Key;
                "DataProvider" = $DataProvider;
                "UnitOfMeasure" = $UnitOfMeasure;
                "Type" = $Type;
                "CreationDate" = $CreationDate;
                "StartDate" = $StartDate;
                "EndDate" = $EndDate;
                "Value" = $Value;
                "EntryDate" = $EntryDate;
                "EntryTime" = $EntryTime;
            }
        );
        Return $Global:Session.AppleHealth.Data.Readings.GetByGUID($ReadingGUID);
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Readings `
    -Name "Remove" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $ReadingGUID
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Readings", "Remove.sql")),
            @{ "ReadingGUID" = $ReadingGUID; }
        );
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Readings `
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
            [Double] $Value
        )
        Return $Global:Session.Utilities.HashString([String]::Format("{0}{1}{2}{3}{4}{5}{6}",
            $DataProvider,
            $UnitOfMeasure,
            $Type,
            $CreationDate.ToString("yyyyMMddHHmmssfffffff"),
            $StartDate.ToString("yyyyMMddHHmmssfffffff"),
            $EndDate.ToString("yyyyMMddHHmmssfffffff"),
            $Value.ToString()
        ));
    }
