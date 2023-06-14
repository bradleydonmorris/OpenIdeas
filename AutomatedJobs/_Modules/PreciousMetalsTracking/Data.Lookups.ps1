Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Lookups" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Lookups `
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
        [Int64] $Count = $Global:Session.SQLite.GetTableRowCount(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
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
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Lookups `
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
        [Int64] $Count = $Global:Session.SQLite.GetScalar(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
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
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Lookups `
    -Name "GetAll" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Lookup
        )
        Return $Global:Session.SQLite.GetRecords(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups", "GetAll.sql")).Replace("`$(Lookup)", $Lookup),
            $null,
            @( "Name" ),
            $null
        );
    }
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Lookups `
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
        $Global:Session.SQLite.Execute(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups", "Add.sql")).Replace("`$(Lookup)", $Lookup),
            @{ "Name" = $Name; }
        );
    }
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Lookups `
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
        $Global:Session.SQLite.Execute(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups", "Rename.sql")).Replace("`$(Lookup)", $Lookup),
            @{
                "OldName" = $OldName;
                "NewName" = $NewName;
            }
        );
    }
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Lookups `
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
        $Global:Session.SQLite.Execute(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups", "Remove.sql")).Replace("`$(Lookup)", $Lookup),
            @{ "Name" = $Name; }
        );
    }
