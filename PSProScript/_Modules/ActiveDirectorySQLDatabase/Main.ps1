[void] $Global:Session.LoadModule("SQLServer");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "ActiveDirectorySQLDatabase" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.ActiveDirectorySQLDatabase `
    -Name "GetUserLastWhenChangedTime" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([DateTime])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [DateTime] $ReturnValue = [DateTime]::new(1970, 1, 1, 0, 0, 0);
        [Object] $Result = $Global:Session.SQLServer.ProcGetScalar(
            $ConnectionName, "ActiveDirectory", "GetUserLastWhenChangedTime",
            $null
        );
        If ($Result -is [DateTime])
            { $ReturnValue = $Result; }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.ActiveDirectorySQLDatabase `
    -Name "GetGroupLastWhenChangedTime" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([DateTime])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [DateTime] $ReturnValue = [DateTime]::new(1970, 1, 1, 0, 0, 0);
        [Object] $Result = $Global:Session.SQLServer.ProcGetScalar(
            $ConnectionName, "ActiveDirectory", "GetGroupLastWhenChangedTime",
            $null
        );
        If ($Result -is [DateTime])
            { $ReturnValue = $Result; }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.ActiveDirectorySQLDatabase `
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
            $ConnectionName, "ActiveDirectory", "ImportUser",
            @{ "UserJSON" = $UserJSON; }
        );
    };
Add-Member `
    -InputObject $Global:Session.ActiveDirectorySQLDatabase `
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
            $ConnectionName, "ActiveDirectory", "ImportGroup",
            @{ "GroupJSON" = $GroupJSON; }
        );
    };
Add-Member `
    -InputObject $Global:Session.ActiveDirectorySQLDatabase `
    -Name "ProcessManagerialChanges" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "ActiveDirectory", "ProcessManagerialChanges",
            $null
        );
    };
Add-Member `
    -InputObject $Global:Session.ActiveDirectorySQLDatabase `
    -Name "ProcessGroupMembershipChanges" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "ActiveDirectory", "ProcessGroupMembershipChanges",
            $null
        );
    };
Add-Member `
    -InputObject $Global:Session.ActiveDirectorySQLDatabase `
    -Name "ProcessGroupManagerChanges" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "ActiveDirectory", "ProcessGroupManagerChanges",
            $null
        );
    };
Add-Member `
    -InputObject $Global:Session.ActiveDirectorySQLDatabase `
    -Name "RebuildIndexes" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "ActiveDirectory", "RebuildIndexes",
            $null
        );
    };
