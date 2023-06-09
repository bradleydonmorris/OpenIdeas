Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Data" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -TypeName "System.String" `
    -NotePropertyName "ActiveConnectionName" `
    -NotePropertyValue "";
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "SetActiveConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath
        )
        $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName = [String]::Format(
            "{0}_{1}_{2}",
            $Global:Job.Collection,
            $Global:Job.Script,
            [DateTime]::UtcNow.ToString("yyyyMMddHHmmss")
        )
        [void] $Global:Job.SQLite.SetConnection(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            $FilePath,
            "In memory only",
            $false
        );
    }
Add-Member `
    -InputObject $Global:Job.PreciousMetalsTracking.Data `
    -Name "VerifyDatabase" `
    -MemberType "ScriptMethod" `
    -Value {
        $Global:Job.Sqlite.CreateIfNotFound(
            $Global:Job.PreciousMetalsTracking.Data.ActiveConnectionName,
            [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SQLScripts", "CreateSchema.sql")),
            $null
        );
    }
