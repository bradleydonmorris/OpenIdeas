. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "SQLDatabaseJson"
);

[String] $SQLInstance = "localhost";
[String] $Database = "Integrations";
[String] $Schema = "ActiveDirectory";
[String] $InputFolderPath = "C:\Users\bmorris\source\repos\FRACDEV\automated-jobs\_Modules\Databases.ActiveDirectory";
[String] $OutputScriptPath = [IO.Path]::Combine($InputFolderPath, "Output.sql");
[Boolean] $ClearStructure = $false;
[Boolean] $DropSchema = $false;
[Boolean] $OverrideFileGroups = $false;
[String]  $HeapFileGroupName = "PRIMARY";
[String] $IndexFileGroupName = "PRIMARY";
[String] $LobFileGroupName = "PRIMARY";

$SQLInstance = $Global:Job.Prompts.StringResponse("SQL Instance", $SQLInstance);
$Database = $Global:Job.Prompts.StringResponse("SQL Database", $Database);
$Schema = $Global:Job.Prompts.StringResponse("SQL Schema", $Schema);
$InputFolderPath = $Global:Job.Prompts.StringResponse("Input Folder", $InputFolderPath);
$OutputScriptPath = $Global:Job.Prompts.StringResponse("Output File", $OutputScriptPath);
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

[Collections.Specialized.OrderedDictionary] $Variables = [Ordered]@{
    "SQL Instance" = $SQLInstance;
    "Database" = $Database;
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

# [Collections.ArrayList] $ReturnValue = [Collections.ArrayList]::new();
# If ($InputFolderPath.EndsWith("DatabaseObjects.json"))
# {
#     $InputFolderPath = [IO.Path]::GetDirectoryName($InputFolderPath);
# }
# [String] $DatabaseObjectsPath = [IO.Path]::Combine($InputFolderPath, "DatabaseObjects.json");
# [String] $DefinitionsFolderPath = [IO.Path]::Combine($InputFolderPath, "DatabaseObjectsDefinitions");
# $DatabaseObjects = [IO.File]::ReadAllText($DatabaseObjectsPath) |
#     ConvertFrom-Json -Depth 100;

# If ($HeapFileGroupName)
# {
#     $DatabaseObjects.Storage.HeapFileGroupName = $HeapFileGroupName;
# }
# If ($IndexFileGroupName)
# {
#     $DatabaseObjects.Storage.IndexFileGroupName = $IndexFileGroupName;
# }
# If ($LobFileGroupName)
# {
#     $DatabaseObjects.Storage.LobFileGroupName = $LobFileGroupName;
# }
# [Int32] $LastSequence = 0;
# If ($ClearStructure)
# {
#     ForEach ($Item In ($DatabaseObjects.DropSequence | Sort-Object -Property "Sequence"))
#     {
#         $LastSequence = $Item.Sequence;
#         [void] $ReturnValue.Add(@{
#             "Mode" = "Drop";
#             "Sequence" = $LastSequence;
#             "Type" = $Item.Type;
#             "Name" = [String]::Format("[{0}].[{1}]", $Schema, $Item.Name);
#             "Script" = [String]::Format("DROP {0} IF EXISTS [{1}].[{2}]", $Item.Type.ToUpper(), $Schema, $Item.Name);
#         });
#     }
#     If ($DropSchema)
#     {
#         $LastSequence ++;
#         [void] $ReturnValue.Add(@{
#             "Mode" = "Drop";
#             "Sequence" = $LastSequence;
#             "Type" = "Schema";
#             "Name" = [String]::Format("[{0}]", $Schema);
#             "Script" = [String]::Format("DROP SCHEMA IF EXISTS [{0}]", $Schema);
#         });
#     }
# }
# $LastSequence ++;
# [void] $ReturnValue.Add(@{
#     "Mode" = "Create";
#     "Sequence" = $LastSequence;
#     "Type" = "Schema";
#     "Name" = [String]::Format("[{0}]", $Schema);
#     "Script" = [String]::Format("CREATE SCHEMA [{0}]", $Schema);
# });
# ForEach ($Table In ($DatabaseObjects.Tables | Sort-Object -Property "Sequence"))
# {
#     [String] $HeapFileGroup
#     [String] $LobFileGroup
#     $HeapFileGroup = (
#         (
#             ($Table.FileGroup -eq "DEFAULT_HEAP_FILE_GROUP") -or
#             $OverrideFileGroups
#         ) ?
#         $DatabaseObjects.Storage.HeapFileGroupName :
#         $Table.FileGroup
#     )
#     If (![String]::IsNullOrEmpty($Table.LobFileGroupName))
#     {
#         $LobFileGroup = (
#             (
#                 ($Table.LobFileGroupName -eq "DEFAULT_LOB_FILE_GROUP") -or
#                 $OverrideFileGroups
#             ) ?
#             $DatabaseObjects.Storage.LobFileGroupName :
#             $Table.LobFileGroupName
#         )
#     }
#     Else
#     {
#         $LobFileGroup = $null;
#     }
#     $LastSequence ++;
#     [void] $ReturnValue.Add(@{
#         "Mode" = "Create";
#         "Sequence" = $LastSequence;
#         "Type" = "Table";
#         "Name" = [String]::Format("[{0}].[{1}]", $Schema, $Table.Name);
#         "Script" = $Global:Job.SQLDatabaseJson.GetTableCreate(
#             $Schema,
#             $Table.Name,
#             $Table.Columns,
#             $HeapFileGroup,
#             $LobFileGroup
#         );
#     });

#     ForEach ($Index In $Table.Indexes)
#     {
#         If ($Index.Name -eq "IX_tempHeap_GroupIdt")
#         {
#             $LastSequence ++;
#             [void] $ReturnValue.Add(@{
#                 "Mode" = "Create";
#                 "Sequence" = $LastSequence;
#                 "Type" = "Index";
#                 "Name" = [String]::Format("[{0}].[{1}].[{2}]", $Schema, $Table.Name, $Index.Name);
#                 "Script" = $Global:Job.SQLDatabaseJson.GetIndexCreate(
#                     $Schema,
#                     $Table.Name,
#                     $Index.Name,
#                     $Index.IsUnique,
#                     $Index.Columns,
#                     $Index.IncludeColumns,
#                     (
#                         (
#                             ($Index.FileGroup -eq "DEFAULT_INDEX_FILE_GROUP") -or
#                             $OverrideFileGroups
#                         ) ?
#                         $DatabaseObjects.Storage.IndexFileGroupName :
#                         $Index.FileGroup
#                     )
#                 );
#             });
#         }
#     }
# }
# ForEach ($Module In ($DatabaseObjects.Modules | Sort-Object -Property "Sequence"))
# {
#     [String] $ContentFile = [IO.Path]::Combine($DefinitionsFolderPath, $Module.ContentFileReference);
#     [String] $ModuleScript = $null;
#     Switch($Module.Type)
#     {
#         "Function"
#         {
#             $ModuleScript = $Global:Job.SQLDatabaseJson.GetFunctionCreate($Schema, $Module.Name, $Module.Returns, $Module.Parameters, $ContentFile);
#         }
#         "Procedure"
#         {
#             $ModuleScript = $Global:Job.SQLDatabaseJson.GetProcedureCreate($Schema, $Module.Name, $Module.Parameters, $ContentFile);
#         }
#         "View"
#         {
#             $ModuleScript = $Global:Job.SQLDatabaseJson.GetViewCreate($Schema, $Module.Name, $ContentFile);
#         }
#     }
#     $LastSequence ++;
#     [void] $ReturnValue.Add(@{
#         "Mode" = "Create";
#         "Sequence" = $LastSequence;
#         "Type" = $Module.Type;
#         "Name" = [String]::Format("[{0}].[{1}]", $Schema, $Module.Name);
#         "Script" = $ModuleScript
#     });

# }
Clear-Host;
Set-Content -Path $OutputScriptPath -Value "";
ForEach ($ObjectScript In ($ReturnValue | Sort-Object -Property "Sequence"))
{
    [String]::Format("GO`n---{0}`t{1}`t{2}GO`n{3}`nGO`n", $ObjectScript.Mode, $ObjectScript.Type, $ObjectScript.Name, $ObjectScript.Script) |
        Add-Content -Path $OutputScriptPath;
}
$ReturnValue;