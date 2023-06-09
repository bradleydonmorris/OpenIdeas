[void] $Global:Job.LoadModule("Sqlite");

Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "PreciousMetalsTracking" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -Name "Open" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath
        )
        [void] $Global:Job.PreciousMetalsTracking.Data.SetActiveConnection($FilePath);
        [void] $Global:Job.PreciousMetalsTracking.Data.VerifyDatabase();
        [void] $Global:Job.PreciousMetalsTracking.Menus.ShowMainMenu();
    }


. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.ps1"));
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.Lookups.ps1"));
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.Vendors.ps1"));
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Menus.ps1"));
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Outputs.ps1"));
