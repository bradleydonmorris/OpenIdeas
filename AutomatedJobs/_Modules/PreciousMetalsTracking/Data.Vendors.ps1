Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Vendors" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Vendors `
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
        [Int64] $Count = $Global:Job.SQLite.GetTableRowCount(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
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
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Vendors `
    -Name "GetByName" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $VendorName
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Job.SQLite.GetRecords(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendor_GetByName.sql")),
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
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Vendors `
    -Name "GetByGUID" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $VendorGUID
        )
        [Collections.Generic.List[PSObject]] $Records = $Global:Job.SQLite.GetRecords(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendor_GetByGUID.sql")),
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
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Vendors `
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
        [PSObject] $ReturnValue = $Global:Job.PreciousMetalsTracking.Data.GetVendorByName($Name);
        If (-not $ReturnValue)
        {
            [Guid] $VendorGUID = [Guid]::NewGuid();
            $Global:Job.SQLite.Execute(
                $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
                [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendor_Add.sql")),
                @{
                    "VendorGUID" = $VendorGUID;
                    "Name" = $Name;
                    "WebSite" = $WebSite;
                }
            );
            $ReturnValue = $Global:Job.PreciousMetalsTracking.Data.GetVendorByName($Name);
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Vendors `
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
        [Guid] $VendorGUID = [Guid]::NewGuid();
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendor_Modify.sql")),
            @{
                "VendorGUID" = $VendorGUID;
                "Name" = $Name;
                "WebSite" = $WebSite;
            }
        );
        Return $Global:Job.PreciousMetalsTracking.Data.GetVendorByGUID($VendorGUID);
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data.Vendors `
    -Name "Remove" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [Guid] $VendorGUID
        )
        $Global:Job.SQLite.Execute(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "Vendor_Remove.sql")),
            @{ "VendorGUID" = $VendorGUID; }
        );
    }
