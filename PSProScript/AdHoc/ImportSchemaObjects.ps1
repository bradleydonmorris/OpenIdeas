Clear-Host;
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "ScriptSQLServerDatabase"
);

$Global:Session.Variables.Set("SQLConnectionName", "ActiveDirectoryDatabase");
# $Global:Session.Variables.Set("SQLInstance",  "TUL-IT-WL-19");
# $Global:Session.Variables.Set("Database",  "Integrations");
$Global:Session.Variables.Set("Schema",  "ActiveDirectory");
$Global:Session.Variables.Set("JSONFilePath",  "C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\PSProScript\_Modules\ActiveDirectorySQLDatabase\DatabaseObjects.json");
$Global:Session.Variables.Set("HeapFileGroup",  "ActiveDirectory");
$Global:Session.Variables.Set("LobFileGroup",  "ActiveDirectory");
$Global:Session.Variables.Set("IndexFileGroup", "ActiveDirectory");
$Global:Session.Variables.Set("WhatIf", $false);

[void] $Global:Session.Variables.Set("SQLConnectionName",
    $Global:Session.Prompts.StringResponse("SQL Connection Name", $Global:Session.Variables.Get("SQLConnectionName")));
# [void] $Global:Session.Variables.Set("SQLInstance",
#     $Global:Session.Prompts.StringResponse("SQL Instance", $Global:Session.Variables.Get("SQLInstance")));
# [void] $Global:Session.Variables.Set("Database",
#     $Global:Session.Prompts.StringResponse("SQL Database", $Global:Session.Variables.Get("Database")));
[void] $Global:Session.Variables.Set("Schema",
    $Global:Session.Prompts.StringResponse("SQL Schema", $Global:Session.Variables.Get("Schema")));
[void] $Global:Session.Variables.Set("JSONFilePath",
    $Global:Session.Prompts.StringResponse("JSON File", $Global:Session.Variables.Get("JSONFilePath")));
[void] $Global:Session.Variables.Set("HeapFileGroup",
    $Global:Session.Prompts.StringResponse("Heap File Group", $Global:Session.Variables.Get("HeapFileGroup")));
[void] $Global:Session.Variables.Set("LobFileGroup",
    $Global:Session.Prompts.StringResponse("Lob File Group", $Global:Session.Variables.Get("LobFileGroup")));
[void] $Global:Session.Variables.Set("IndexFileGroup",
    $Global:Session.Prompts.StringResponse("Index File Group", $Global:Session.Variables.Get("IndexFileGroup")));
[void] $Global:Session.Variables.Set("WhatIf",
    $Global:Session.Prompts.BooleanResponse("Do `"What If`" only?", $Global:Session.Variables.Get("WhatIf")));

$Global:Session.Logging.WriteVariables("Config", @{
    "SQL Connection Name" = $Global:Session.Variables.Get("SQLConnectionName");
    "Schema" = $Global:Session.Variables.Get("Schema");
    "JSON File Path" = $Global:Session.Variables.Get("JSONFilePath");
    "Heap File Group" = $Global:Session.Variables.Get("HeapFileGroup");
    "Lob File Group" = $Global:Session.Variables.Get("LobFileGroup");
    "Index File Group" = $Global:Session.Variables.Get("IndexFileGroup");
    "What If" = $Global:Session.Variables.Get("WhatIf");
});

Clear-Host;
# $Global:Session.Prompts.DisplayHashTable("Variables", 180, [Ordered]@{
#     "SQL Instance" = $SQLInstance;
#     "Database" = $Database;
#     "Schema" = $Schema;
#     "JSON File Path" = $JSONFilePath;
#     "Heap File Group" = $HeapFileGroup;
#     "Lob File Group" = $LobFileGroup;
#     "Index File Group" = $IndexFileGroup;
#     "What If" = $false;
# });

If ($WhatIf)
{
    Try
    {
        $Global:Session.Logging.TimedExecute("ImportFromJSONWhatIf", {
            $Global:Session.Logging.WriteEntry("Information", [String]::Format("Building What If for JSON File {0}", $JSONFilePath));
            [String] $WhatIfFilePath = [IO.Path]::Combine(
                [IO.Path]::GetDirectoryName($Global:Session.Variables.Get("JSONFilePath")),
                "WhatIf.tsv"
            );
            $Global:Session.ScriptSQLServerDatabase.ImportFromJSONWhatIf(
                $Global:Session.Variables.Get("SQLConnectionName"),
                $Global:Session.Variables.Get("JSONFilePath"),
                $Global:Session.Variables.Get("Schema"),
                $Global:Session.Variables.Get("HeapFileGroup"),
                $Global:Session.Variables.Get("LobFileGroup"),
                $Global:Session.Variables.Get("IndexFileGroup"),
                $true,
                $WhatIfFilePath
            );
            $Global:Session.Logging.WriteEntry("Information", [String]::Format("What If file built {0}", $WhatIfFilePath));
            Write-Host -Object "What If file created:`r`n`t$WhatIfFilePath";
        });
    }
    Catch
    {
        $Global:Session.Logging.WriteExceptionWithData($_.Exception, $Global:Session.Variables.Get("JSONFilePath"));
    }
}
Else
{
    $Global:Session.Logging.TimedExecute("ImportFromJSON", {
        Try
        {
            $Global:Session.Logging.WriteEntry("Information", [String]::Format("Importing JSON File {0}", $Global:Session.Variables.Get("JSONFilePath")));
            Write-Host ($Global:Session.Variables.Get("JSONFilePath"));
            $Global:Session.ScriptSQLServerDatabase.ImportFromJSON(
                $Global:Session.Variables.Get("SQLConnectionName"),
                $Global:Session.Variables.Get("JSONFilePath"),
                $Global:Session.Variables.Get("Schema"),
                $Global:Session.Variables.Get("HeapFileGroup"),
                $Global:Session.Variables.Get("LobFileGroup"),
                $Global:Session.Variables.Get("IndexFileGroup"),
                $true
            );
        }
        Catch
        {
            $Global:Session.Logging.WriteExceptionWithData($_.Exception, $Global:Session.Variables.Get("JSONFilePath"));
        }
    });
}

$Global:Session.Logging.Close();
$Global:Session.Logging.ClearLogs();
