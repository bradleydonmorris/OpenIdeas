[void] $Global:Session.LoadModule("Connections");
[void] $Global:Session.LoadModule("SQLServer");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "IICSSQLDatabase" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.IICSSQLDatabase `
    -Name "ClearStaged" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [Boolean] $ClearAsset,

            [Parameter(Mandatory=$true)]
            [Boolean] $ClearAssetFile,

            [Parameter(Mandatory=$true)]
            [Boolean] $ClearActivityLog
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "IICS", "ClearStaged",
            @{
                "ClearAsset" = $ClearAsset;
                "ClearAssetFile" = $ClearAssetFile;
                "ClearActivityLog" = $ClearActivityLog;
            }
        );
    };
Add-Member `
    -InputObject $Global:Session.IICSSQLDatabase `
    -Name "PostStagedAssets" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $AssetsJSON
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "IICS", "PostStagedAssets",
            @{ "AssetsJSON" = $AssetsJSON; }
        );
    };
Add-Member `
    -InputObject $Global:Session.IICSSQLDatabase `
    -Name "PostStagedAssetFiles" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $FederatedId,

            [Parameter(Mandatory=$true)]
            [String] $FileName,

            [Parameter(Mandatory=$true)]
            [String] $FileType,

            [Parameter(Mandatory=$true)]
            [String] $Content
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "IICS", "PostStagedAssetFile",
            @{
                "AssetsJSON" = $AssetsJSON;
                "FileName" = $FileName;
                "FileType" = $FileType;
                "Content" = $Content;
            }
        );
    };
Add-Member `
    -InputObject $Global:Session.IICSSQLDatabase `
    -Name "PostStagedActivityLogs" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $JSON
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "IICS", "PostStagedActivityLogs",
            @{ "JSON" = $JSON; }
        );
    };
Add-Member `
    -InputObject $Global:Session.IICSSQLDatabase `
    -Name "Parse" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "IICS", "Parse",
            $null
        );
    };
Add-Member `
    -InputObject $Global:Session.IICSSQLDatabase `
    -Name "ParseActivityLogs" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [void] $Global:Session.SQLServer.ProcExecute(
            $ConnectionName, "IICS", "ParseActivityLogs",
            $null
        );
    };
Add-Member `
    -InputObject $Global:Session.IICSSQLDatabase `
    -Name "GetActivityLogLastStartTime" `
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
            $ConnectionName, "ActiveDirectory", "GetActivityLogLastStartTime",
            $null
        );
        If ($Result -is [DateTime])
            { $ReturnValue = $Result; }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.IICSSQLDatabase `
    -Name "RemoveOldActivityLogs" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [Int32] $KeepLogsForDays
        )
        If ($KeepLogsForDays -gt 0)
        {
            [void] $Global:Session.SQLServer.ProcExecute(
                $ConnectionName, "IICS", "RemoveOldActivityLogs",
                @{ "KeepLogsForDays" = $KeepLogsForDays; }
            );
        }
    };
