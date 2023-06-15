Clear-Host;
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "ScriptSQLServerDatabase"
);

[String] $SQLInstance = "TUL-IT-WL-19";
[String] $Database = "Integrations";
[String] $Schema = "Google";
[String] $JSONFilePath = "C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\AutomatedJobs\_Modules\Databases.Google\DatabaseObjects.json";
[String] $HeapFileGroup = "PRIMARY";
[String] $LobFileGroup = "PRIMARY";
[String] $IndexFileGroup = "PRIMARY";
[Boolean] $WhatIf = $false;

$SQLInstance = $Global:Session.Prompts.StringResponse("SQL Instance", $SQLInstance);
$Database = $Global:Session.Prompts.StringResponse("SQL Database", $Database);
$Schema = $Global:Session.Prompts.StringResponse("SQL Schema", $Schema);
$JSONFilePath = $Global:Session.Prompts.StringResponse("JSON File", $JSONFilePath);
$HeapFileGroup = $Global:Session.Prompts.StringResponse("Heap File Group", $HeapFileGroup);
$LobFileGroup = $Global:Session.Prompts.StringResponse("Lob File Group", $LobFileGroup);
$IndexFileGroup = $Global:Session.Prompts.StringResponse("Index File Group", $IndexFileGroup);
$WhatIf = $Global:Session.Prompts.BooleanResponse("Do `"What If`" only?", $WhatIf);

$Global:Session.Logging.WriteVariables("Config", @{
    "SQL Instance" = $SQLInstance;
    "Database" = $Database;
    "Schema" = $Schema;
    "JSON File Path" = $JSONFilePath;
    "Heap File Group" = $HeapFileGroup;
    "Lob File Group" = $LobFileGroup;
    "Index File Group" = $IndexFileGroup;
    "What If" = $WhatIf;
});

Clear-Host;
$Global:Session.Prompts.DisplayHashTable("Variables", 180, [Ordered]@{
    "SQL Instance" = $SQLInstance;
    "Database" = $Database;
    "Schema" = $Schema;
    "JSON File Path" = $JSONFilePath;
    "Heap File Group" = $HeapFileGroup;
    "Lob File Group" = $LobFileGroup;
    "Index File Group" = $IndexFileGroup;
    "What If" = $WhatIf;
});

If ($WhatIf)
{
    Try
    {
        $Global:Session.Logging.TimedExecute("ImportFromJSONWhatIf", {
            $Global:Session.Logging.WriteEntry("Information", [String]::Format("Building What If for JSON File {0}", $JSONFilePath));
            [String] $WhatIfFilePath = [IO.Path]::Combine(
                [IO.Path]::GetDirectoryName($JSONFilePath),
                "WhatIf.tsv"
            );
            $Global:Session.ScriptSQLServerDatabase.ImportFromJSONWhatIf(
                $JSONFilePath,
                $SQLInstance, $Database, $Schema, $HeapFileGroup, $LobFileGroup, $IndexFileGroup, $true,
                $WhatIfFilePath
            );
            $Global:Session.Logging.WriteEntry("Information", [String]::Format("What If file built {0}", $WhatIfFilePath));
            Write-Host -Object "What If file created:`r`n`t$WhatIfFilePath";
        });
    }
    Catch
    {
        $Global:Session.Logging.WriteExceptionWithData($_.Exception, $JSONFilePath);
    }
}
Else
{
    $Global:Session.Logging.TimedExecute("ImportFromJSON", {
        Try
        {
            $Global:Session.Logging.WriteEntry("Information", [String]::Format("Importing JSON File {0}", $JSONFilePath));
            $Global:Session.ScriptSQLServerDatabase.ImportFromJSON(
                $JSONFilePath,
                $SQLInstance, $Database, $Schema, $HeapFileGroup, $LobFileGroup, $IndexFileGroup, $true
            );
        }
        Catch
        {
            $Global:Session.Logging.WriteExceptionWithData($_.Exception, $JSONFilePath);
        }
    });
}

$Global:Session.Logging.Close();
$Global:Session.Logging.ClearLogs();
