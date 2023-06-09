Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Lookups" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Lookups `
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
        [Int64] $Count = $Global:Job.SQLite.GetTableRowCount(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
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
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Lookups `
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
        [Int641] $Count = $Global:Job.SQLite.GetScalar(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups_IsInUse.sql")),
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
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Lookups `
    -Name "GetAll" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Lookup
        )
        Return $Global:Job.SQLite.GetRecords(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups_GetAll.sql")).Replace("`$(Lookup)", $Lookup),
            $null,
            @( "Name" ),
            $null
        );
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Lookups `
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
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups_Add.sql")).Replace("`$(Lookup)", $Lookup),
            @{ "Name" = $Name; }
        );
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Lookups `
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
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups_Rename.sql")).Replace("`$(Lookup)", $Lookup),
            @{
                "OldName" = $OldName;
                "NewName" = $NewName;
            }
        );
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Lookups `
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
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Lookups_Remove.sql")).Replace("`$(Lookup)", $Lookup),
            @{ "Name" = $Name; }
        );
    }
