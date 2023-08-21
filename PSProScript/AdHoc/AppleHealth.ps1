. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "Utilities",
    "AppleHealth",
    "ShieldsIO"
);

$Global:Session.Logging.OutputToHost = $true;

#$Global:Session.AppleHealth.DatabaseType = "Sqlite";
#$Global:Session.AppleHealth.ConnectionName = "AppleHealth-SQlite";
#[void] $Global:Session.SQLite.SetConnection($Global:Session.AppleHealth.ConnectionName, $null, $true, [IO.Path]::Combine($Global:Session.DataDirectory, "Data.sqlite"));

#[void] $Global:Session.AppleHealth.SetDatabaseConnection("AppleHealth-SQLServer");
[void] $Global:Session.AppleHealth.SetDatabaseConnection("AppleHealth-SQLServerLocalDB");
[void] $Global:Session.AppleHealth.VerifyDatabase();
[void] $Global:Session.AppleHealth.ImportData();
If ($Global:Session.Variables.Get("IsImported"))
{
    [void] $Global:Session.AppleHealth.CreateYearlyStatisticsFile([DateTime]::UtcNow.Year, $Global:Session.DataDirectory);
}
[void] $Global:Session.AppleHealth.CopyReports("C:\Users\bmorris\source\repos\bradleydonmorris\LifeBook\Activities\Health\Reports");

$Global:Session.Logging.Close();
$Global:Session.Logging.ClearLogs();
