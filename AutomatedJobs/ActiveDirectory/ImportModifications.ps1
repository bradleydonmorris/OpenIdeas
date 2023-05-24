. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "ActiveDirectory",
    "Databases.ActiveDirectory"
);


#$Global:Job.Config is automatically loaded if a sibling file with an extension of .config.json is found for this script.

$Global:Job.Logging.WriteVariables("Valirables", @{
    "DatabaseConnectionName" = $Global:Job.Config.DatabaseConnectionName;
    "LDAPConnectionName" = $Global:Job.Config.LDAPConnectionName;
});

#Use these to determine the date/time from existing data in SQL Server.
[DateTime] $UsersChangedSince = $Global:Job.Databases.ActiveDirectory.GetUserLastWhenChangedTime($Global:Job.Config.DatabaseConnectionName);
[DateTime] $GroupsChangedSince = $Global:Job.Databases.ActiveDirectory.GetGroupLastWhenChangedTime($Global:Job.Config.DatabaseConnectionName);

#Use these to force load of all data.
#[DateTime] $UsersChangedSince = [DateTime]::SpecifyKind([DateTime]::new(1970, 1, 1, 0, 0, 0), [System.DateTimeKind]::Utc);
#[DateTime] $GroupsChangedSince = [DateTime]::SpecifyKind([DateTime]::new(1970, 1, 1, 0, 0, 0), [System.DateTimeKind]::Utc);

#Use these for debug
#[DateTime] $UsersChangedSince = [DateTime]::SpecifyKind([DateTime]::new(2022, 10, 15, 0, 0, 0), [System.DateTimeKind]::Utc);
#[DateTime] $GroupsChangedSince = [DateTime]::SpecifyKind([DateTime]::new(2022, 1, 1, 0, 0, 0), [System.DateTimeKind]::Utc);

$Global:Job.Logging.WriteVariables("Valirables", @{
    "UsersChangedSince" = $UsersChangedSince.ToString("yyyy-MM-ddTHH:mm:ss.fffffffK");
    "GroupsChangedSince" = $GroupsChangedSince.ToString("yyyy-MM-ddTHH:mm:ss.fffffffK");
});

#Setting up timers used in this job.
$Global:Job.Logging.Timers.Add("User Import");
$Global:Job.Logging.Timers.Add("Group Import");
$Global:Job.Logging.Timers.Add("Processing Managerial Changes");
$Global:Job.Logging.Timers.Add("Processing Group Membership Changes");
$Global:Job.Logging.Timers.Add("Processing Group Manager Changes");
$Global:Job.Logging.Timers.Add("Rebuilding Indexes");

$Global:Job.Logging.Timers.Start("User Import");
$Global:Job.Logging.WriteEntry("Information", "Importing User Changes");
ForEach ($UserDistinguishedName In $Global:Job.ActiveDirectory.GetChangedUsers($Global:Job.Config.LDAPConnectionName, $UsersChangedSince))
{
    $Global:Job.Logging.WriteEntry("Information", (
        "Importing User " +
        $UserDistinguishedName
    ));
    [String] $UserJSON = [String]::Empty;
    Try
    {
        $User = $Global:Job.ActiveDirectory.GetUser($Global:Job.Config.LDAPConnectionName, $UserDistinguishedName);
        $UserJSON = ConvertTo-Json -InputObject $User;
        $Global:Job.Databases.ActiveDirectory.ImportUser($Global:Job.Config.DatabaseConnectionName, $UserJSON);
    }
    Catch
    {
        $Global:Job.Logging.WriteExceptionWithData($_.Exception, $UserJSON);
    }
}
$Global:Job.Logging.Timers.Stop("User Import");

$Global:Job.Logging.Timers.Start("Group Import");
$Global:Job.Logging.WriteEntry("Information", "Importing Group Changes");
ForEach ($GroupDistinguishedName In $Global:Job.ActiveDirectory.GetChangedGroups($Global:Job.Config.LDAPConnectionName, $GroupsChangedSince))
{
    $Global:Job.Logging.WriteEntry("Information", (
        "Importing Group " +
        $GroupDistinguishedName
    ));
    [String] $GroupJSON = [String]::Empty;
    Try
    {
        $Group = $Global:Job.ActiveDirectory.GetGroup($Global:Job.Config.LDAPConnectionName, $GroupDistinguishedName);
        $GroupJSON = ConvertTo-Json -InputObject $Group;
        $Global:Job.Databases.ActiveDirectory.ImportGroup($Global:Job.Config.DatabaseConnectionName, $GroupJSON);
    }
    Catch
    {
        $Global:Job.Logging.WriteExceptionWithData($_.Exception, $GroupJSON);
    }
}
$Global:Job.Logging.Timers.Stop("Group Import");

$Global:Job.Logging.Timers.Start("Processing Managerial Changes");
$Global:Job.Logging.WriteEntry("Information", "Processing Managerial Changes");
Try { $Global:Job.Databases.ActiveDirectory.ProcessManagerialChanges($Global:Job.Config.DatabaseConnectionName); }
    Catch { $Global:Job.Logging.WriteException($_.Exception); }
$Global:Job.Logging.Timers.Stop("Processing Managerial Changes");

$Global:Job.Logging.Timers.Start("Processing Group Membership Changes");
$Global:Job.Logging.WriteEntry("Information", "Processing Group Membership Changes");
Try { $Global:Job.Databases.ActiveDirectory.ProcessGroupMembershipChanges($Global:Job.Config.DatabaseConnectionName); }
    Catch { $Global:Job.Logging.WriteException($_.Exception); }
$Global:Job.Logging.Timers.Stop("Processing Group Membership Changes");

$Global:Job.Logging.Timers.Start("Processing Group Manager Changes");
$Global:Job.Logging.WriteEntry("Information", "Processing Group Manager Changes");
Try { $Global:Job.Databases.ActiveDirectory.ProcessGroupManagerChanges($Global:Job.Config.DatabaseConnectionName); }
    Catch { $Global:Job.Logging.WriteException($_.Exception); }
$Global:Job.Logging.Timers.Stop("Processing Group Manager Changes");


$Global:Job.Logging.Timers.Start("Rebuilding Indexes");
$Global:Job.Logging.WriteEntry("Information", "Rebuilding Indexes");
Try { $Global:Job.Databases.ActiveDirectory.RebuildIndexes($Global:Job.Config.DatabaseConnectionName); }
    Catch { $Global:Job.Logging.WriteException($_.Exception); }
$Global:Job.Logging.Timers.Stop("Rebuilding Indexes");

$Global:Job.Logging.Close();
$Global:Job.Logging.ClearLogs();
