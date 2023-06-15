Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Data" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data `
    -TypeName "System.String" `
    -NotePropertyName "ActiveConnectionName" `
    -NotePropertyValue "";
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data `
    -Name "SetActiveConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath
        )
        $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName = [String]::Format(
            "{0}_{1}_{2}",
            $Global:Session.Project,
            $Global:Session.Script,
            [DateTime]::UtcNow.ToString("yyyyMMddHHmmss")
        )
        [void] $Global:Session.SQLite.SetConnection(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            $FilePath,
            "In memory only",
            $false
        );
    }
Add-Member `
    -InputObject $Global:Session.PreciousMetalsTracking.Data `
    -Name "VerifyDatabase" `
    -MemberType "ScriptMethod" `
    -Value {
        $Global:Session.Sqlite.CreateIfNotFound(
            $Global:Session.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "CreateSchema.sql")),
            $null
        );
    }
