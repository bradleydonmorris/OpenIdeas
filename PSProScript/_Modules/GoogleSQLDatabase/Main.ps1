[void] $Global:Session.LoadModule("SQLServer");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "GoogleSQLDatabase" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.GoogleSQLDatabase `
    -Name "ImportOrganizationalUnit" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $OrgUnitJSON
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "Google", "ImportOrganizationalUnit",
            @{ "OrgUnitJSON" = $OrgUnitJSON; }
        );
    };
Add-Member `
    -InputObject $Global:Session.GoogleSQLDatabase `
    -Name "ImportUser" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $UserJSON
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "Google", "ImportUser",
            @{ "UserJSON" = $UserJSON; }
        );
    };
Add-Member `
    -InputObject $Global:Session.GoogleSQLDatabase `
    -Name "ImportGroup" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $GroupJSON
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "Google", "ImportGroup",
            @{ "GroupJSON" = $GroupJSON; }
        );
    };
Add-Member `
    -InputObject $Global:Session.GoogleSQLDatabase `
    -Name "ProcessGroupMembershipChanges" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "Google", "ProcessGroupMembershipChanges",
            $null
        );
    };
Add-Member `
    -InputObject $Global:Session.GoogleSQLDatabase `
    -Name "RebuildIndexes" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "Google", "RebuildIndexes",
            $null
        );
    };
