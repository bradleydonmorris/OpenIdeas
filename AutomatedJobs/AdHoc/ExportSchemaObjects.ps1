. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "ScriptSQLServerDatabase"
);

[String] $SQLInstance = "tsd-sql02-aws.fox.local";
[String] $Database = "Reports_Library";
[String] $Schema = "Google";
[String] $OutputDirectoryPath = "C:\SQLExports\temp";

Clear-Host;
$SQLInstance = $Global:Job.Prompts.StringResponse("SQL Instance", $SQLInstance);
$Database = $Global:Job.Prompts.StringResponse("SQL Database", $Database);
$Schema = $Global:Job.Prompts.StringResponse("SQL Schema", $Schema);
$OutputDirectoryPath = $Global:Job.Prompts.StringResponse("Output Folder", $OutputDirectoryPath);

$Global:Job.Logging.WriteVariables("Config", @{
    "SQL Instance" = $SQLInstance;
    "Database" = $Database;
    "Schema" = $Schema;
    "Output Folder Path" = $OutputDirectoryPath;
});

Clear-Host;
$Global:Job.Prompts.DisplayHashTable("Variables", 180, [Ordered]@{
    "SQL Instance" = $SQLInstance;
    "Database" = $Database;
    "Schema" = $Schema;
    "Output Folder Path" = $OutputDirectoryPath;
});

$Global:Job.Logging.TimedExecute("GenerateScriptsByDependency", {
    $Global:Job.ScriptSQLServerDatabase.GenerateScriptsByDependency(
        $SQLInstance,
        $Database,
        $Schema,
        $null,
        $OutputDirectoryPath,
        $null
    );
});

$Global:Job.Logging.Close();
$Global:Job.Logging.ClearLogs();
