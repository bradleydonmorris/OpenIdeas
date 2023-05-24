. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "GoogleAPI",
    "Databases.Google"
);

#$Global:Job.Config is automatically loaded if a sibling file with an extension of .config.json is found for this script.
$Global:Job.Logging.WriteVariables("Valirables", @{
    "GoogleDatabase" = $Global:Job.Config.GoogleDatabase;
    "GoogleConnectionName" = $Global:Job.Config.GoogleConnectionName;
});

$Global:Job.Logging.Timers.Add("Organizational Unit Import");
$Global:Job.Logging.Timers.Start("Organizational Unit Import");
$Global:Job.Logging.WriteEntry("Information", "Importing Organizational Unit Changes");
ForEach ($OrgUnit In $Global:Job.GoogleAPI.GetOrgUnits($Global:Job.Config.GoogleConnectionName))
{
    $Global:Job.Logging.WriteEntry("Information", (
        "Importing Org Unit " +
        $OrgUnit.orgUnitPath
    ));
    [String] $OrgUnitJSON = [String]::Empty;
    Try
    {
        $OrgUnitJSON = ConvertTo-Json -InputObject $OrgUnit -Depth 100;
        $Global:Job.Databases.Google.ImportOrganizationalUnit($Global:Job.Config.DatabaseConnectionName, $OrgUnitJSON);
    }
    Catch
    {
        $Global:Job.Logging.WriteExceptionWithData($_.Exception, $OrgUnitJSON);
    }
}
$Global:Job.Logging.Timers.Stop("Organizational Unit Import");

$Global:Job.Logging.Timers.Add("Group Import");
$Global:Job.Logging.Timers.Start("Group Import");
$Global:Job.Logging.WriteEntry("Information", "Importing Group Changes");
ForEach ($Group In $Global:Job.GoogleAPI.GetGroups($Global:Job.Config.GoogleConnectionName, $true))
{
    $Global:Job.Logging.WriteEntry("Information", (
        "Importing Group " +
        $Group.name
    ));
    [String] $GroupJSON = [String]::Empty;
    Try
    {
        $GroupJSON = ConvertTo-Json -InputObject $Group -Depth 100;
        $Global:Job.Databases.Google.ImportGroup($Global:Job.Config.DatabaseConnectionName, $GroupJSON);
    }
    Catch
    {
        $Global:Job.Logging.WriteExceptionWithData($_.Exception, $GroupJSON);
    }
}
$Global:Job.Logging.Timers.Stop("Group Import");

$Global:Job.Logging.Timers.Add("User Import");
$Global:Job.Logging.Timers.Start("User Import");
$Global:Job.Logging.WriteEntry("Information", "Importing User Changes");
ForEach ($User In $Global:Job.GoogleAPI.GetUsers($Global:Job.Config.GoogleConnectionName))
{
    $Global:Job.Logging.WriteEntry("Information", (
        "Importing User " +
        $User.primaryEmail
    ));
    [String] $UserJSON = [String]::Empty;
    Try
    {
        $UserJSON = ConvertTo-Json -InputObject $User -Depth 100;
        $Global:Job.Databases.Google.ImportUser($Global:Job.Config.DatabaseConnectionName, $UserJSON);
    }
    Catch
    {
        $Global:Job.Logging.WriteExceptionWithData($_.Exception, $UserJSON);
    }
}
$Global:Job.Logging.Timers.Stop("User Import");



$Global:Job.Logging.Timers.Add("Processing Group Membership Changes");
$Global:Job.Logging.Timers.Start("Processing Group Membership Changes");
$Global:Job.Logging.WriteEntry("Information", "Processing Group Membership Changes");
Try { $Global:Job.Databases.Google.ProcessGroupMembershipChanges($Global:Job.Config.DatabaseConnectionName); }
    Catch { $Global:Job.Logging.WriteException($_.Exception); }
$Global:Job.Logging.Timers.Stop("Processing Group Membership Changes");

$Global:Job.Logging.Close();
$Global:Job.Logging.ClearLogs();
