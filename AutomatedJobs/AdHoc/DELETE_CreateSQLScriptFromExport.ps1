. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "SQLDatabaseJson"
);

[String] $Schema = "ActiveDirectory";
[String] $InputFolderPath = "C:\Users\bmorris\source\repos\FRACDEV\automated-jobs\_Modules\Databases.ActiveDirectory";
[Boolean] $ClearStructure = $true;
[Boolean] $DropSchema = $true;
[Boolean] $OverrideFileGroups = $true;
[String] $HeapFileGroupName = "PRIMARY";
[String] $IndexFileGroupName = "PRIMARY";
[String] $LobFileGroupName = "PRIMARY";
[String] $OutputScriptPath = [IO.Path]::Combine($InputFolderPath, "Output.sql");

$Schema = $Global:Job.Prompts.StringResponse("SQL Schema", $Schema);
$InputFolderPath = $Global:Job.Prompts.StringResponse("Input Folder", $InputFolderPath);
$ClearStructure = $Global:Job.Prompts.BooleanResponse("Do you wish to drop all existing objects in $Schema before creating the new objects?");
If ($ClearStructure)
{
    $DropSchema = $Global:Job.Prompts.BooleanResponse("Do you wish to drop the schema $Schema?");
}
$OverrideFileGroups = $Global:Job.Prompts.BooleanResponse("Do you wish override the file groups?");
If ($OverrideFileGroups)
{
    $HeapFileGroupName = $Global:Job.Prompts.StringResponse("Heap File Group", $HeapFileGroupName);
    $IndexFileGroupName = $Global:Job.Prompts.StringResponse("Index File Group", $IndexFileGroupName);
    $LobFileGroupName = $Global:Job.Prompts.StringResponse("Lob File Group", $LobFileGroupName);
}
$OutputScriptPath = $Global:Job.Prompts.StringResponse("Output File", $OutputScriptPath);

[Collections.Specialized.OrderedDictionary] $Variables = [Ordered]@{
    "Schema" = $Schema;
    "Input Folder Path" = $InputFolderPath;
    "Output Script Path" = $OutputScriptPath;
    "Clear Structure" = $ClearStructure;
}
If ($ClearStructure -and $DropSchema)
{
    [void] $Variables.Add("Drop Schema", $DropSchema);
}
If ($OverrideFileGroups)
{
    [void] $Variables.Add("Heap File Group", $HeapFileGroupName);
    [void] $Variables.Add("Index File Group", $IndexFileGroupName);
    [void] $Variables.Add("Lob File Group", $LobFileGroupName);
}

Clear-Host;
$Global:Job.Prompts.WriteHashTable("Variables", 180, $Variables);

[Collections.ArrayList] $SQLScripts = $Global:Job.SQLDatabaseJson.BuildSQLScripts(
    $Schema,
    $ClearStructure,
    $DropSchema,
    $OverrideFileGroups,
    $HeapFileGroupName,
    $IndexFileGroupName,
    $LobFileGroupName,
    $InputFolderPath
);

[String] $OutputContent = $Global:Job.Prompts.OutputHashTableToText("", 150, $Variables);
$OutputContent = "/" + $OutputContent.Substring(1).Substring(0, ($OutputContent.Length - 2)) + "/`r`n`r`n";

ForEach ($SQLScript In ($SQLScripts | Sort-Object -Property "Sequence"))
{
    $OutputContent += [String]::Format("GO`r`n--{0} {1} {2}`r`nGO`r`n{3}`r`nGO`r`n", $SQLScript.Mode, $SQLScript.Type, $SQLScript.Name, $SQLScript.Script)
}
$OutputContent = $OutputContent.Replace("`r`nGO`r`nGO`r`n", "`r`nGO`r`n");
[void] [IO.File]::WriteAllText($OutputScriptPath, $OutputContent);
