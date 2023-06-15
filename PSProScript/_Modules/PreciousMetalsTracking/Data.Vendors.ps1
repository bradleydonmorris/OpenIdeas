Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Vendors" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Vendors `
    -Name "Exists" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Boolean] $ReturnValue = $false;
        [Int64] $Count = $Global:Session.SQLite.GetTableRowCount(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            "Vendor",
            @{ "Name" = $Name}
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Vendors `
    -Name "IsInUse" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Boolean] $ReturnValue = $false;
        [Int64] $Count = $Global:Session.SQLite.GetScalar(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendors", "IsInUse.sql")),
            @{ "Name" = $Name; }
        );
        If ($Count -gt 0)
        {
            $ReturnValue = $true;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Vendors `
    -Name "GetByName" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $VendorName
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Session.SQLite.GetRecords(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendors", "GetByName.sql")),
            @{ "VendorName" = $VendorName },
            @( "VendorGUID", "Name", "WebSite" ),
            @{ "VendorGUID" = "Guid" }
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
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Vendors `
    -Name "GetByGUID" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $VendorGUID
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Session.SQLite.GetRecords(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendors", "GetByGUID.sql")),
            @{ "VendorGUID" = $VendorGUID},
            @( "VendorGUID", "Name", "WebSite" ),
            @{ "VendorGUID" = "Guid" }
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
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Vendors `
    -Name "Add" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [String] $WebSite
        )
        [PSObject] $ReturnValue = $Global:Session.PreciousMetalsTracking.Data.Vendors.GetByName($Name);
        If (-not $ReturnValue)
        {
            [Guid] $VendorGUID = [Guid]::NewGuid();
            $Global:Session.SQLite.Execute(
                $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
                [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendors", "Add.sql")),
                @{
                    "VendorGUID" = $VendorGUID;
                    "Name" = $Name;
                    "WebSite" = $WebSite;
                }
            );
            $ReturnValue = $Global:Session.PreciousMetalsTracking.Data.Vendors.GetByName($Name);
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Vendors `
    -Name "Modify" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $VendorGUID,

            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [String] $WebSite
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendors", "Modify.sql")),
            @{
                "VendorGUID" = $VendorGUID;
                "Name" = $Name;
                "WebSite" = $WebSite;
            }
        );
        Return $Global:Session.PreciousMetalsTracking.Data.Vendors.GetByGUID($VendorGUID);
    }
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data.Vendors `
    -Name "Remove" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $VendorGUID
        )
        $Global:Session.SQLite.Execute(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendors", "Remove.sql")),
            @{ "VendorGUID" = $VendorGUID; }
        );
    }
