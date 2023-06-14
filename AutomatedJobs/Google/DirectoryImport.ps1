. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "GoogleAPI",
    "GoogleSQLDatabase"
);

#$Global:Session.Config is automatically loaded if a sibling file with an extension of .config.json is found for this script.
$Global:Session.Logging.WriteVariables("Valirables", @{
    "GoogleDatabase" = $Global:Session.Config.GoogleDatabase;
    "GoogleAPIConnectionName" = $Global:Session.Config.GoogleAPIConnectionName;
});

$Global:Session.Logging.TimedExecute("ImportOrgUnits", {
    Try
    {
        ForEach ($OrgUnit In $Global:Session.GoogleAPI.GetOrgUnits($Global:Session.Config.GoogleAPIConnectionName))
        {
            [void] $Global:Session.Logging.WriteEntry("Information", (
                "Importing Org Unit " +
                $OrgUnit.orgUnitPath
            ));
            [String] $OrgUnitJSON = [String]::Empty;
            Try
            {
                $OrgUnitJSON = ConvertTo-Json -InputObject $OrgUnit -Depth 100;
                [void] $Global:Session.GoogleSQLDatabases.ImportOrganizationalUnit($Global:Session.Config.DatabaseConnectionName, $OrgUnitJSON);
            }
            Catch
            {
                [void] $Global:Session.Logging.WriteExceptionWithData($_.Exception, $OrgUnitJSON);
            }
        }
    }
    Catch
    {
        [void] $Global:Session.Logging.WriteException($_.Exception);
    }
});

$Global:Session.Logging.TimedExecute("ImportUsers", {
    Try
    {
        ForEach ($User In $Global:Session.GoogleAPI.GetUsers($Global:Session.Config.GoogleAPIConnectionName))
        {
            [void] $Global:Session.Logging.WriteEntry("Information", (
                "Importing User " +
                $User.primaryEmail
            ));
            [String] $UserJSON = [String]::Empty;
            Try
            {
                $UserJSON = ConvertTo-Json -InputObject $User;
                [void] $Global:Session.GoogleSQLDatabases.ImportUser($Global:Session.Config.DatabaseConnectionName, $UserJSON);
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
        ForEach ($Group In $Global:Session.GoogleAPI.GetGroups($Global:Session.Config.GoogleAPIConnectionName))
        {
            [void] $Global:Session.Logging.WriteEntry("Information", (
                "Importing Group " +
                $Group.name
            ));
            [String] $GroupJSON = [String]::Empty;
            Try
            {
                $GroupJSON = ConvertTo-Json -InputObject $Group;
                [void] $Global:Session.GoogleSQLDatabases.ImportGroup($Global:Session.Config.DatabaseConnectionName, $GroupJSON);
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

$Global:Session.Logging.TimedExecute("ProcessGroupMembershipChanges", {
    Try { [void] $Global:Session.GoogleSQLDatabases.ProcessGroupMembershipChanges($Global:Session.Config.DatabaseConnectionName); }
    Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
});

$Global:Session.Logging.TimedExecute("RebuildIndexes", {
    Try { [void] $Global:Session.GoogleSQLDatabases.RebuildIndexes($Global:Session.Config.DatabaseConnectionName); }
    Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
});

$Global:Session.Logging.Close();
$Global:Session.Logging.ClearLogs();
