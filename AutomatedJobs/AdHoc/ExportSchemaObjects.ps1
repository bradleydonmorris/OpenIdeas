. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "ScriptSQLServerDatabase"
);

[String] $SQLInstance = "tsd-sql02-aws.fox.local";
[String] $Database = "Reports_Library";
[String] $Schema = "Google";
[String] $OutputDirectoryPath = "C:\SQLExports\temp";

Clear-Host;
$SQLInstance = $Global:Session.Prompts.StringResponse("SQL Instance", $SQLInstance);
$Database = $Global:Session.Prompts.StringResponse("SQL Database", $Database);
$Schema = $Global:Session.Prompts.StringResponse("SQL Schema", $Schema);
$OutputDirectoryPath = $Global:Session.Prompts.StringResponse("Output Folder", $OutputDirectoryPath);

$Global:Session.Logging.WriteVariables("Config", @{
    "SQL Instance" = $SQLInstance;
    "Database" = $Database;
    "Schema" = $Schema;
    "Output Folder Path" = $OutputDirectoryPath;
});

Clear-Host;
$Global:Session.Prompts.DisplayHashTable("Variables", 180, [Ordered]@{
    "SQL Instance" = $SQLInstance;
    "Database" = $Database;
    "Schema" = $Schema;
    "Output Folder Path" = $OutputDirectoryPath;
});

$Global:Session.Logging.TimedExecute("GenerateScriptsByDependency", {
    $Global:Session.ScriptSQLServerDatabase.GenerateScriptsByDependency(
        $SQLInstance,
        $Database,
        $Schema,
        $null,
        $OutputDirectoryPath,
        $null
    );
});

$Global:Session.Logging.Close();
$Global:Session.Logging.ClearLogs();
