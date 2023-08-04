[void] $Global:Session.LoadModule("Sqlite");

Add-Member `
    -InputObject $Global:Session.AppleHealth.Data `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Lookups" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Lookups `
    -Name "Exists" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Lookup,

            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Boolean] $ReturnValue = $false;
        [Int64] $Count = $Global:Session.Sqlite.GetTableRowCount(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            $Lookup,
            @{ "Name" = $Name; }
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Lookups `
    -Name "IsInUse" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Lookup,

            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Boolean] $ReturnValue = $false;
        [Int64] $Count = $Global:Session.Sqlite.GetScalar(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups", "IsInUse.sql")),
            @{
                "Lookup" = $Lookup;
                "Name" = $Name;
            }
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Lookups `
    -Name "GetAll" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Lookup
        )
        Return $Global:Session.Sqlite.GetRecords(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups", "GetAll.sql")).Replace("`$(Lookup)", $Lookup),
            $null,
            @( "Name" ),
            $null
        );
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Lookups `
    -Name "Add" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Lookup,

            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        $Global:Session.Sqlite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups", "Add.sql")).Replace("`$(Lookup)", $Lookup),
            @{ "Name" = $Name; }
        );
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Lookups `
    -Name "Rename" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Lookup,

            [Parameter(Mandatory=$true)]
            [String] $OldName,

            [Parameter(Mandatory=$true)]
            [String] $NewName
        )
        $Global:Session.Sqlite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups", "Rename.sql")).Replace("`$(Lookup)", $Lookup),
            @{
                "OldName" = $OldName;
                "NewName" = $NewName;
            }
        );
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data.Lookups `
    -Name "Remove" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Lookup,

            [Parameter(Mandatory=$true)]
            [Guid] $Name
        )
        $Global:Session.Sqlite.Execute(
            $Global:Session.AppleHealth.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups", "Remove.sql")).Replace("`$(Lookup)", $Lookup),
            @{ "Name" = $Name; }
        );
    }
