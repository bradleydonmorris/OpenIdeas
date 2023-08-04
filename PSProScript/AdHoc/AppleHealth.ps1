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

$Global:Session.AppleHealth.DatabaseType = "SQLServer";
$Global:Session.AppleHealth.ConnectionName = "AppleHealth-SQLServer";

#[void] $Global:Session.SQLServer.SetConnection($Global:Session.AppleHealth.ConnectionName, $null, $true, "localhost", "Bradley", $true, $null, $null);
[void] $Global:Session.AppleHealth.ImportData();
[void] $Global:Session.AppleHealth.CreateYearlyStatisticsFile([DateTime]::UtcNow.Year, $Global:Session.DataDirectory);


# [Int32] $Year = [DateTime]::UtcNow.Year;
# [void] $Global:Session.Variables.Set("YearlyStatistics_Year", $Year);
# [void] $Global:Session.Variables.Set("YearlyStatistics", $Global:Session.AppleHealth.GetYearlyStatistics($Global:Session.Variables.Get("YearlyStatistics_Year")));

# $YearlyStatistics = $Global:Session.Variables.Get("YearlyStatistics");

# [Collections.Generic.List[PSObject]] $Series = [Collections.Generic.List[PSObject]]::new();
# [PSObject] $Record = [PSObject]::new();
# Add-Member -InputObject $Record -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue "Weight";
# Add-Member -InputObject $Record -TypeName "System.Drawing.Color" -NotePropertyName "Color" -NotePropertyValue ([System.Drawing.Color]::FromArgb(255, 0, 0, 255));
# Add-Member -InputObject $Record -TypeName "System.Collections.Generic.List[PSObject]" -NotePropertyName "Values" -NotePropertyValue ([Collections.Generic.List[PSObject]]::new());
# ForEach ($Value In $YearlyStatistics.Weight.Values)
# {
#     $Record.Values.Add(
#     [PSCustomObject]@{
#         "XValue" = $Value.Date;
#         "YValue" = $Value.Weight;
#     });
# }
# [void] $Series.Add([PSObject]$Record);
# $Series[0]

$Global:Session.Logging.Close();
$Global:Session.Logging.ClearLogs();
