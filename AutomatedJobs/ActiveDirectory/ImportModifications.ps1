. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "ActiveDirectory",
    "ActiveDirectorySQLDatabase"
);


#$Global:Session.Config is automatically loaded if a sibling file with an extension of .config.json is found for this script.

[void] $Global:Session.Logging.WriteVariables("Valirables", @{
    "DatabaseConnectionName" = $Global:Session.Config.DatabaseConnectionName;
    "ActiveDirectoryConnectionName" = $Global:Session.Config.ActiveDirectoryConnectionName;
});

#Use these to determine the date/time from existing data in SQL Server.
[DateTime] $UsersChangedSince = $Global:Session.ActiveDirectorySQLDatabase.GetUserLastWhenChangedTime($Global:Session.Config.DatabaseConnectionName);
[DateTime] $GroupsChangedSince = $Global:Session.ActiveDirectorySQLDatabase.GetGroupLastWhenChangedTime($Global:Session.Config.DatabaseConnectionName);
#Use these to force load of all data.
#[DateTime] $UsersChangedSince = [DateTime]::SpecifyKind([DateTime]::new(1970, 1, 1, 0, 0, 0), [System.DateTimeKind]::Utc);
#[DateTime] $GroupsChangedSince = [DateTime]::SpecifyKind([DateTime]::new(1970, 1, 1, 0, 0, 0), [System.DateTimeKind]::Utc);

#Use these for debug
#[DateTime] $UsersChangedSince = [DateTime]::SpecifyKind([DateTime]::new(2022, 10, 15, 0, 0, 0), [System.DateTimeKind]::Utc);
#[DateTime] $GroupsChangedSince = [DateTime]::SpecifyKind([DateTime]::new(2022, 1, 1, 0, 0, 0), [System.DateTimeKind]::Utc);

[void] $Global:Session.Logging.WriteVariables("SinceChangedTimes", @{
    "UsersChangedSince" = $UsersChangedSince.ToString("yyyy-MM-ddTHH:mm:ss.fffffffK");
    "GroupsChangedSince" = $GroupsChangedSince.ToString("yyyy-MM-ddTHH:mm:ss.fffffffK");
});

$Global:Session.Logging.TimedExecute("ImportUsers", {
    Try
    {
        ForEach ($UserDistinguishedName In $Global:Session.ActiveDirectory.GetChangedUsers($Global:Session.Config.ActiveDirectoryConnectionName, $UsersChangedSince))
        {
            [void] $Global:Session.Logging.WriteEntry("Information", (
                "Importing User " +
                $UserDistinguishedName
            ));
            [String] $UserJSON = [String]::Empty;
            Try
            {
                $User = $Global:Session.ActiveDirectory.GetUser($Global:Session.Config.ActiveDirectoryConnectionName, $UserDistinguishedName);
                $UserJSON = ConvertTo-Json -InputObject $User;
                [void] $Global:Session.ActiveDirectorySQLDatabase.ImportUser($Global:Session.Config.DatabaseConnectionName, $UserJSON);
            }
            Catch
            {
                [void] $Global:Session.Logging.WriteExceptionWithData($_.Exception, $UserJSON);
            }
        }
    }
    Catch
    {
        [void] $Global:Session.Logging.WriteException($_.Exception);
    }
});

$Global:Session.Logging.TimedExecute("ImportGroups", {
    Try
    {
        ForEach ($GroupDistinguishedName In $Global:Session.ActiveDirectory.GetChangedGroups($Global:Session.Config.ActiveDirectoryConnectionName, $GroupsChangedSince))
        {
            [void] $Global:Session.Logging.WriteEntry("Information", (
                "Importing Group " +
                $GroupDistinguishedName
            ));
            [String] $GroupJSON = [String]::Empty;
            Try
            {
                $Group = $Global:Session.ActiveDirectory.GetGroup($Global:Session.Config.ActiveDirectoryConnectionName, $GroupDistinguishedName);
                $GroupJSON = ConvertTo-Json -InputObject $Group;
                [void] $Global:Session.ActiveDirectorySQLDatabase.ImportGroup($Global:Session.Config.DatabaseConnectionName, $GroupJSON);
            }
            Catch
            {
                [void] $Global:Session.Logging.WriteExceptionWithData($_.Exception, $GroupJSON);
            }
        }
    }
    Catch
    {
        [void] $Global:Session.Logging.WriteException($_.Exception);
    }
});

$Global:Session.Logging.TimedExecute("ProcessingManagerialChanges", {
    Try { [void] $Global:Session.ActiveDirectorySQLDatabase.ProcessManagerialChanges($Global:Session.Config.DatabaseConnectionName); }
    Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
});

$Global:Session.Logging.TimedExecute("ProcessGroupMembershipChanges", {
    Try { [void] $Global:Session.ActiveDirectorySQLDatabase.ProcessGroupMembershipChanges($Global:Session.Config.DatabaseConnectionName); }
    Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
});

$Global:Session.Logging.TimedExecute("ProcessGroupManagerChanges", {
    Try { [void] $Global:Session.ActiveDirectorySQLDatabase.ProcessGroupManagerChanges($Global:Session.Config.DatabaseConnectionName); }
    Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
});

$Global:Session.Logging.TimedExecute("RebuildIndexes", {
    Try { [void] $Global:Session.ActiveDirectorySQLDatabase.RebuildIndexes($Global:Session.Config.DatabaseConnectionName); }
    Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
});

$Global:Session.Logging.Close();
$Global:Session.Logging.ClearLogs();
