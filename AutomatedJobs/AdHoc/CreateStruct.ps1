. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "ScriptSQLServerDatabase"
);

[String] $SQLInstance = "tsd-sql02-aws.fox.local";
[String] $Database = "Reports_Library";
[String] $Schema = "IICS";
[String] $OutputDirectoryPath = "D:\SQLExports\temp";

$Global:Job.ScriptSQLServerDatabase.CreateScriptFromJSON(
    "C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\AutomatedJobs\_Modules\Databases.IICS\DatabaseObjects.json",
    $Schema, "PRIMARY", "PRIMARY", "PRIMARY"
);



# [String] $JSON = [IO.File]::ReadAllText("C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\AutomatedJobs\_Modules\Databases.IICS\DatabaseObjects.json");
# $SQLObjectInfos = ConvertFrom-Json -InputObject $JSON;
# ForEach ($SQLObjectInfo In $SQLObjectInfos | Where-Object -FilterScript {
#     $_.SimpleType -eq "Procedure" -or
#     $_.SimpleType -eq "Function" -or
#     $_.SimpleType -eq "View"
# })
# {
#     [String] $FilePath = "C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\AutomatedJobs\_Modules\Databases.IICS\DatabaseObjectsDefinitions\" +
#         $SQLObjectInfo.Name + ".sql";
#     [void] [IO.File]::WriteAllText($FilePath, $SQLObjectInfo.Details.CreateScript);
# }