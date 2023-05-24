. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), "CommonPSFunctions", "ScriptSQLDatabase.ps1"));

[String] $Instance = "localhost";
[String] $Database = "Integrations";
[String] $OutputDirectoryPath = "C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\ObjectCreationHelpers\tempOutput";
If ([IO.Directory]::Exists($OutputDirectoryPath))
{
    [void] [IO.Directory]::Delete($OutputDirectoryPath, $true);
}
[void] [IO.Directory]::CreateDirectory($OutputDirectoryPath);

[Collections.ArrayList] $SQLObjectInfos = Get-SQLDependencies -Instance "tsd-sql02-aws.fox.local" -Database "Reports_Library";
[Int32] $PadLength = ($SQLObjectInfos | Sort-Object -Property "CreateOrder" | Select-Object -Property "CreateOrder" -Last 1).CreateOrder.ToString().Length;
ForEach ($SQLObjectInfo In ($SQLObjectInfos | Sort-Object -Property "CreateOrder"))
{
    [String] $OutputFilePath = [IO.Path]::Combine(
        $OutputDirectoryPath,
        [String]::Format(
            "{0}-{1}-{2}.sql",
            $SQLObjectInfo.CreateOrder.ToString().PadLeft($PadLength, "0"),
            $SQLObjectInfo.SimpleType,
            $SQLObjectInfo.QualifiedName
        )
    );
    [String] $Content = $null;
    Switch ($SQLObjectInfo.SimpleType)
    {
        "Table" { $Content = Get-SQLTableCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
        "View" { $Content = Get-SQLModuleCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
        "Procedure" { $Content = Get-SQLModuleCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
        "Function" { $Content = Get-SQLModuleCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
    }
    [void] [IO.File]::WriteAllText($OutputFilePath, $Content);
}
