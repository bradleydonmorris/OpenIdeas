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

$SQLInstance = $Global:Job.Prompts.StringResponse("SQL Instance", $SQLInstance);
$Database = $Global:Job.Prompts.StringResponse("SQL Database", $Database);
$Schema = $Global:Job.Prompts.StringResponse("SQL Schema", $Schema);
$JSONFilePath = $Global:Job.Prompts.StringResponse("JSON File", $JSONFilePath);
$HeapFileGroup = $Global:Job.Prompts.StringResponse("Heap File Group", $HeapFileGroup);
$LobFileGroup = $Global:Job.Prompts.StringResponse("Lob File Group", $LobFileGroup);
$IndexFileGroup = $Global:Job.Prompts.StringResponse("Index File Group", $IndexFileGroup);

$Global:Job.Logging.WriteVariables("Config", @{
    "SQL Instance" = $SQLInstance;
    "Database" = $Database;
    "Schema" = $Schema;
    "JSON File Path" = $JSONFilePath;
    "Heap File Group" = $HeapFileGroup;
    "Lob File Group" = $LobFileGroup;
    "Index File Group" = $IndexFileGroup;
});

Clear-Host;
$Global:Job.Prompts.DisplayHashTable("Variables", 180, [Ordered]@{
    "SQL Instance" = $SQLInstance;
    "Database" = $Database;
    "Schema" = $Schema;
    "JSON File Path" = $JSONFilePath;
    "Heap File Group" = $HeapFileGroup;
    "Lob File Group" = $LobFileGroup;
    "Index File Group" = $IndexFileGroup;
});

$Global:Job.Logging.Execute("GenerateScriptsByDependency", {
    $Global:Job.ScriptSQLServerDatabase.ImportFromJSON(
        $JSONFilePath,
        $SQLInstance, $Database, $Schema, $HeapFileGroup, $LobFileGroup, $IndexFileGroup, $true
    );
});

$Global:Job.Logging.Close();
$Global:Job.Logging.ClearLogs();




<#
        Set-Content -Path "C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\AutomatedJobs\AdHoc\CreateStruct.txt" -Value "Sequence`tOrder`tMode`tType`tName";
        ForEach ($NamedSQLScript In ($NamedSQLScripts | Sort-Object -Property "Sequence"))
        {
            Add-Content -Path "C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\AutomatedJobs\AdHoc\CreateStruct.txt" -Value ([String]::Format(
                "{0}`t{1}`t{2}`t{3}`t{4}",
                $NamedSQLScript.Sequence,
                $NamedSQLScript.Order,
                $NamedSQLScript.Mode,
                $NamedSQLScript.Type,
                $NamedSQLScript.Name
            ));
        }


#>