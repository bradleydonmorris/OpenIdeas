[String] $Instance = "tcp:localhost";
[String] $Database = "Trash";

[Collections.Hashtable] $Parameters = [Collections.Hashtable]@{
    "SchemaName" = "Audit";
    "TableFileGroup" = "PRIMARY";
    "TextFileGroup" = "PRIMARY";
    "IndexFileGroup" = "PRIMARY";
}

[String] $InvokeSQLScriptFilePath = [IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), "CommonPSFunctions", "SQLFunctions.ps1");
[String] $ObjectsScriptPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Audit.sql");
[String] $ObjectCreationHelpersDirectoryPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), "ObjectCreationHelpers");
. $InvokeSQLScriptFilePath

Invoke-SQLScript `
    -Instance $Instance `
    -Database $Database `
    -CommandText ([IO.File]::ReadAllText([IO.Path]::Combine($ObjectCreationHelpersDirectoryPath, "CreateHelperFunctions.sql")));

Invoke-SQLScript `
    -Instance $Instance `
    -Database $Database `
    -CommandText ([IO.File]::ReadAllText($ObjectsScriptPath)) `
    -Parameters $Parameters

Invoke-SQLScript `
    -Instance $Instance `
    -Database $Database `
    -CommandText ([IO.File]::ReadAllText([IO.Path]::Combine($ObjectCreationHelpersDirectoryPath, "DropHelperFunctions.sql")));

