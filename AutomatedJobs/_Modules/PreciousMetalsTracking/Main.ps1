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
            [String] $DatabasePath
        )
        $Global:Job.SQLite.CreateDatabase(
            $DatabasePath,
            [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "CreateSchema.sql")
        );
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -Name "GetVendorByName" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $DatabasePath,

            [Parameter(Mandatory=$true)]
            [String] $VendorName
        )
        $Records = $Global:Job.SQLite.GetRecords(
            $DatabasePath,
            [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "VendorGetByName.sql"),
            @{ "VendorName" = $VendorName},
            @("VendorGUID", "Name", "WebSite")
        );
        Return $Records;
    }
