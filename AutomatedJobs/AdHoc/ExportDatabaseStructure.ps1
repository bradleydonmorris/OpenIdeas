. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "SQLDatabaseJson"
);

[String] $SQLInstance = "localhost";
[String] $Database = "Integrations";
[String] $Schema = "ActiveDirectory";
[String] $OutputFolderPath = "C:\Users\bmorris\source\repos\FRACDEV\automated-jobs\_Modules\Databases.ActiveDirectory";


$SQLInstance = $Global:Job.Prompts.StringResponse("SQL Instance", $SQLInstance);
$Database = $Global:Job.Prompts.StringResponse("SQL Database", $Database);
$Schema = $Global:Job.Prompts.StringResponse("SQL Schema", $Schema);
$OutputFolderPath = $Global:Job.Prompts.StringResponse("Output Folder", $OutputFolderPath);

Clear-Host;
$Global:Job.Prompts.WriteHashTable("Variables", 180, [Ordered]@{
    "SQL Instance" = $SQLInstance;
    "Database" = $Database;
    "Schema" = $Schema;
    "Output Folder Path" = $OutputFolderPath;
});

$Global:Job.SQLDatabaseJson.Export(
    $SQLInstance,
    $Database,
    $Schema,
    $OutputFolderPath
);
