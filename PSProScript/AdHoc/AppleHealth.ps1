. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "Utilities",
    "AppleHealth",
    "ShieldsIO"
);
$Global:Session.Logging.OutputToHost = $true;
#$Global:Session.Logging.Config.DatabaseConnectionName
#$Global:Session.Logging.Config
#$Global:Session.AppleHealth.DatabaseType = "Sqlite";
#$Global:Session.AppleHealth.ConnectionName = "AppleHealth-SQlite";
#[void] $Global:Session.SQLite.SetConnection($Global:Session.AppleHealth.ConnectionName, $null, $true, [IO.Path]::Combine($Global:Session.DataDirectory, "Data.sqlite"));


$Global:Session.AppleHealth.ConnectionName = "AppleHealth-SQLServerLocalDB";
$Global:Session.AppleHealth.SetDatabaseType("SQLServerLocalDB");

$Global:Session.AppleHealth.DatabaseType = "SQLServer";
$Global:Session.AppleHealth.DatabaseType = "SQLServerLocalDB";
$Global:Session.AppleHealth.ConnectionName = "AppleHealth-SQLServerLocalDB";

#[void] $Global:Session.SQLServer.SetConnection($Global:Session.AppleHealth.ConnectionName, $null, $true, "localhost", "Bradley", $true, $null, $null);
[void] $Global:Session.AppleHealth.VerifyDatabase();
[void] $Global:Session.AppleHealth.ImportData();
[void] $Global:Session.AppleHealth.CreateYearlyStatisticsFile([DateTime]::UtcNow.Year, $Global:Session.DataDirectory);

$Global:Session.Logging.Close();
$Global:Session.Logging.ClearLogs();
