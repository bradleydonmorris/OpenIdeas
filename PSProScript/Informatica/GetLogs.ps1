. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "InformaticaAPI",
    "Databases.IICS"
);

#$Global:Session.Config is automatically loaded if a sibling file with an extension of .config.json is found for this script.
$Global:Session.Logging.WriteVariables("Config", @{
    "IICSDatabaseConnectionName" = $Global:Session.Config.IICSDatabaseConnectionName;
    "IICSAPIConnectionName" = $Global:Session.Config.IICSAPIConnectionName;
    "KeepLogsForDays" = $Global:Session.Config.KeepLogsForDays;
});

[DateTime] $Global:LastDatabaseStartTime = [DateTime]::MinValue;
[Collections.Generic.List[String]] $Global:LogFiles = [Collections.Generic.List[String]]::new();


#region Establish IICS Session
$Global:Session.Execute("Establish IICS Session", {
    Try
    {
        $Global:Session.InformaticaAPI.GetSession($Global:Session.Config.IICSAPIConnectionName);
    }
    Catch
    {
        $Global:Session.Logging.WriteException($_.Exception);
    }
});
#endregion Establish IICS Session

#region Get Start Time
$Global:Session.Execute("Get Start Time", {
    $Global:LastDatabaseStartTime = $Global:Session.Databases.IICS.GetActivityLogLastStartTime($Global:Session.Config.IICSDatabaseConnectionName);
    $Global:Session.Logging.WriteVariables("StartTime", @{
        "LastDatabaseStartTime" = $Global:LastDatabaseStartTime;
    });
});
#endregion Get Start Time

#region Export Activity Logs
$Global:Session.Execute("Export Activity Logs", {
    Try
    {
        $Global:LogFiles = $Global:Session.InformaticaAPI.ExportLogs($Global:Session.DataDirectory, $Global:LastDatabaseStartTime);
    }
    Catch
    {
        $Global:Session.Logging.WriteExceptionWithData($_.Exception, $Project);
    }
});
#endregion Export Activity Logs

#region Clear Staged
$Global:Session.Execute("Clear Staged", {
    Try
    {
        $Global:Session.Databases.IICS.ClearStaged($Global:Session.Config.IICSDatabaseConnectionName, $false, $false, $true);
    }
    Catch
    {
        $Global:Session.Logging.WriteException($_.Exception);
    }
});
#endregion Clear Staged

#region Post Staged Activity Logs
$Global:Session.Execute("Post Staged Activity Logs", {
    ForEach ($FilePath In $Global:LLogFiles)
    {
        Try
        {
            $Global:Session.Databases.IICS.PostStagedActivityLogs(
                $Global:Session.Config.IICSDatabaseConnectionName,
                [IO.File]::ReadAllText($FilePath)
            );
            [void] [IO.File]::Delete($FilePath);
        }
        Catch
        {
            $Global:Session.Logging.WriteException($_.Exception);
        }
    }
});
#endregion Post Staged Activity Logs

#region Parse Activity Logs
$Global:Session.Execute("Parse Activity Logs", {
    Try
    {
        $Global:Session.Databases.IICS.ParseActivityLogs($Global:Session.Config.IICSDatabaseConnectionName);
    }
    Catch
    {
        $Global:Session.Logging.WriteException($_.Exception);
    }
});
#endregion Parse Activity Logs

#region Remove Old Activity Logs
$Global:Session.Execute("Remove Old Activity Logs", {
    If ($Global:Session.Config.KeepLogsForDays -gt 0)
    {
        Try
        {
            $Global:Session.Databases.IICS.RemoveOldActivityLogs($Global:Session.Config.KeepLogsForDays);
        }
        Catch
        {
            $Global:Session.Logging.WriteException($_.Exception);
        }
    }
    Else
    {
        $Global:Session.Logging.WriteEntry("Information", [String]::Format("No activity logs were removed. KeepLogsForDays is set to {0}", $Global:Session.Config.KeepLogsForDays));
    }
});
#endregion Remove Old Activity Logs

$Global:Session.Logging.Close();
$Global:Session.Logging.ClearLogs();
