[void] $Global:Session.LoadModule("Prompts");
[void] $Global:Session.LoadModule("Sqlite");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "PreciousMetalsTracking" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking `
    -Name "Open" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath
        )
        [void] $Global:Session.PreciousMetalsTracking.Data.SetActiveConnection($FilePath);
        [void] $Global:Session.PreciousMetalsTracking.Data.VerifyDatabase();
        [void] $Global:Session.PreciousMetalsTracking.Menus.ShowMainMenu();
    }
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking `
    -Name "Exit" `
    -MemberType "ScriptMethod" `
    -Value {
        $Global:Session.PreciousMetalsTracking.Messages.ShowExit();
    }


. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.ps1"));
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.Lookups.ps1"));
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.Vendors.ps1"));
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Data.Items.ps1"));
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Messages.ps1"));
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Menus.ps1"));
