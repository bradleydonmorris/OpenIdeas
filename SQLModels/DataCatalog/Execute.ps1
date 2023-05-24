[String] $Instance = "tcp:tul-it-wl-19";
[String] $Database = "Trash";

[Collections.Hashtable] $Parameters = [Collections.Hashtable]@{
    "TableFileGroup" = "PRIMARY";
    "TextFileGroup" = "PRIMARY";
    "IndexFileGroup" = "PRIMARY";
    "DropObjects" = $false;
}

[Collections.Hashtable] $AuditParameters = $Parameters;
$AuditParameters += @{ "SchemaName" = "DataCatalogAudit"; }

[Collections.Hashtable] $DataCatalogParameters = $Parameters;
$DataCatalogParameters += @{
    "SchemaName" = "DataCatalog";
    "AuditSchemaName" = $AuditParameters.SchemaName;
}

[String] $AuditObjectsScriptPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), "Audit", "Audit.sql");
[String] $DataCatalogObjectsScriptPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "DataCatalog.sql");
[String] $ObjectCreationHelpersDirectoryPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), "ObjectCreationHelpers");
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), "CommonPSFunctions", "SQLFunctions.ps1"));

Invoke-SQLScript `
    -Instance $Instance `
    -Database $Database `
    -CommandText ([IO.File]::ReadAllText([IO.Path]::Combine($ObjectCreationHelpersDirectoryPath, "CreateHelperFunctions.sql")));

Invoke-SQLScript `
    -Instance $Instance `
    -Database $Database `
    -CommandText ([IO.File]::ReadAllText($AuditObjectsScriptPath)) `
    -Parameters $AuditParameters

Invoke-SQLScript `
    -Instance $Instance `
    -Database $Database `
    -CommandText ([IO.File]::ReadAllText($DataCatalogObjectsScriptPath)) `
    -Parameters $DataCatalogParameters

Invoke-SQLScript `
    -Instance $Instance `
    -Database $Database `
    -CommandText ([IO.File]::ReadAllText([IO.Path]::Combine($ObjectCreationHelpersDirectoryPath, "DropHelperFunctions.sql")));
