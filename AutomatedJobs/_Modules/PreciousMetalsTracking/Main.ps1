[void] $Global:Job.LoadModule("Sqlite");

Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "PreciousMetalsTracking" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -Name "VerifyDatabase" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        $Global:Job.SQLite.Execute(
            $ConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "CreateSchema.sql")),
            $null
        );
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -Name "GetVendorByName" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Hashtable])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $VendorName
        )
        [Collections.ArrayList] $Records = $Global:Job.SQLite.GetRecords(
            $ConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "GetVendorByName.sql")),
            @{ "VendorName" = $VendorName },
            @("VendorGUID", "Name", "WebSite"),
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
    -InputObject $Global:Job.PreciousMetalsTracking `
    -Name "GetVendorByGUID" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Hashtable])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [Guid] $VendorGUID
        )
        [Collections.ArrayList] $Records = $Global:Job.SQLite.GetRecords(
            $ConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "GetVendorByGUID.sql")),
            @{ "VendorGUID" = $VendorGUID},
            @("VendorGUID", "Name", "WebSite"),
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
    -InputObject $Global:Job.PreciousMetalsTracking `
    -Name "AddVendor" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [String] $WebSite
        )
        [Int64] $RecordCount = $Global:Job.SQLite.GetTableRowCount($ConnectionName, "Vendor", @{ "Name" = $Name; });
        If ($RecordCount -eq 0)
        {
            [Guid] $VendorGUID = [Guid]::NewGuid();
            $Global:Job.SQLite.Execute(
                $ConnectionName,
                [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "AddVendor.sql")),
                @{
                    "VendorGUID" = $VendorGUID;
                    "Name" = $Name;
                    "WebSite" = $WebSite;
                }
            );
        }
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -Name "RemoveVendor" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [Guid] $VendorGUID
        )
        $Global:Job.SQLite.Execute(
            $ConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "RemoveVendor.sql")),
            @{ "VendorGUID" = $VendorGUID; }
        );
    }
