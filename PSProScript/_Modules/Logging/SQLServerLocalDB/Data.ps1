[void] $Global:Session.LoadModule("SQLServerLocalDB");

Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Data" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.Logging.Data `
    -Name "VerifyDatabase" `
    -MemberType "ScriptMethod" `
    -Value {
        Param ()
        [void] $Global:Session.SQLServerLocalDB.CreateDatabaseIfNotExists($Global:Session.Logging.Config.DatabaseConnectionName);
        ForEach ($FileName In @(
            "Schema.sql",

            "Tables\Level.sql",
            "Tables\Project.sql",
            "Tables\Script.sql",
            "Tables\Invocation.sql",
            "Tables\Log.sql",
            "Tables\Entry.sql",
            "Tables\Variable.sql",
            "Tables\Timer.sql",

            "Views\Logs.sql",
            "Views\MostRecentLogs.sql",
            "Views\LogEntries.sql",
            "Views\MostRecentLogEntries.sql",
            "Views\Timers.sql"
            "Views\MostRecentTimers.sql",
            "Views\Variables.sql",
            "Views\MostRecentVariables.sql",

            "Procedures\ImportLog.sql",
            "Procedures\ClearLogs.sql"
        ))
        {
            $Global:Session.SQLServerLocalDB.Execute(
                $Global:Session.Logging.Config.DatabaseConnectionName,
                [IO.File]::ReadAllText(
                    [IO.Path]::Combine(
                        [IO.Path]::GetDirectoryName($PSCommandPath),
                        "SQLScripts",
                        $FileName)
                ),
                $null
            );
        }
    };
Add-Member `
    -InputObject $Global:Session.Logging.Data `
    -Name "SaveToDatabase" `
    -MemberType "ScriptMethod" `
    -Value {
        Param (
            [String] $LogJSON
        )
        $Global:Session.SQLServerLocalDB.ProcExecute($Global:Session.Logging.Config.DatabaseConnectionName, "Logging", "ImportLog", @{ "LogJSON" = $LogJSON });
    };
Add-Member `
    -InputObject $Global:Session.Logging.Data `
    -Name "ClearDatabaseLogs" `
    -MemberType "ScriptMethod" `
    -Value {
        Param ()
        $Global:Session.SQLServerLocalDB.ProcExecute($Global:Session.Logging.Config.DatabaseConnectionName, "Logging", "ClearLogs", @{
            "Project" = $Global:Session.Project;
            "Script" = $Global:Session.Script;
            "ScriptFilePath" = $Global:Session.ScriptFilePath;
            "Host" = $Global:Session.Host;
            "RetentionDays" = $Global:Session.Logging.Config.RetentionDays;
        });
    };
