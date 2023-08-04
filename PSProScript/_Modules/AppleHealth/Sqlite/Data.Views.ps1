[void] $Global:Session.LoadModule("Utilities");
[void] $Global:Session.LoadModule("Sqlite");

Add-Member `
    -InputObject $Global:Session.AppleHealth.Data `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Views" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Views `
    -Name "BloodPressure" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        ForEach ($Record In $Global:Session.SQLite.GetRecords(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Views", "BloodPressure.sql")),
            $null,
            @( "EntryGUID", "EntryDate", "EntryTime", "Key", "DataProvider", "Type", "CreationDate", "StartDate", "EndDate", "UnitOfMeasure", "Systolic", "Diastolic" ),
            @{
                "EntryGUID" = "Guid";
                "CreationDate" = "DateTime";
                "StartDate" = "DateTime";
                "EndDate" = "DateTime";
                "Systolic" = "Double";
                "Diastolic" = "Double";
            }
        ))
        {
            Add-Member `
                -InputObject $Record `
                -TypeName "System.DateTime" `
                -NotePropertyName "EntryDateTimeUTC" `
                -NotePropertyValue $Global:Session.Utilities.DateTimeUTCFromSplitInt($Date, $Time);
            Add-Member `
                -InputObject $Record `
                -TypeName "System.DateTime" `
                -NotePropertyName "EntryDateTimeLocal" `
                -NotePropertyValue ($Record.EntryDateTimeUTC.ToLocalTime());
            [void] $ReturnValue.Add($Record);
        }
        Return $ReturnValue;
    }
    Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Views `
    -Name "Weight" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        ForEach ($Record In $Global:Session.SQLite.GetRecords(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Views", "Weight.sql")),
            $null,
            @( "EntryGUID", "EntryDate", "EntryTime", "Key", "DataProvider", "Type", "CreationDate", "StartDate", "EndDate", "UnitOfMeasure", "Weight" ),
            @{
                "EntryGUID" = "Guid";
                "CreationDate" = "DateTime";
                "StartDate" = "DateTime";
                "EndDate" = "DateTime";
                "Weight" = "Double";
            }
        ))
        {
            Add-Member `
                -InputObject $Record `
                -TypeName "System.DateTime" `
                -NotePropertyName "EntryDateTimeUTC" `
                -NotePropertyValue $Global:Session.Utilities.DateTimeUTCFromSplitInt($Date, $Time);
            Add-Member `
                -InputObject $Record `
                -TypeName "System.DateTime" `
                -NotePropertyName "EntryDateTimeLocal" `
                -NotePropertyValue ($Record.EntryDateTimeUTC.ToLocalTime());
            [void] $ReturnValue.Add($Record);
        }
        Return $ReturnValue;
    }
