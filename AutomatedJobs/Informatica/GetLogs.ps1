. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "InformaticaAPI",
    "Databases.IICS"
);

#$Global:Job.Config is automatically loaded if a sibling file with an extension of .config.json is found for this script.
$Global:Job.Logging.WriteVariables("Config", @{
    "IICSDatabaseConnectionName" = $Global:Job.Config.IICSDatabaseConnectionName;
    "IICSAPIConnectionName" = $Global:Job.Config.IICSAPIConnectionName;
    "KeepLogsForDays" = $Global:Job.Config.KeepLogsForDays;
});

[DateTime] $Global:LastDatabaseStartTime = [DateTime]::MinValue;
[Collections.ArrayList] $Global:LogFiles = [Collections.ArrayList]::new();


#region Establish IICS Session
$Global:Job.Execute("Establish IICS Session", {
    Try
    {
        $Global:Job.InformaticaAPI.GetSession($Global:Job.Config.IICSAPIConnectionName);
    }
    Catch
    {
        $Global:Job.Logging.WriteException($_.Exception);
    }
});
#endregion Establish IICS Session

#region Get Start Time
$Global:Job.Execute("Get Start Time", {
    $Global:LastDatabaseStartTime = $Global:Job.Databases.IICS.GetActivityLogLastStartTime($Global:Job.Config.IICSDatabaseConnectionName);
    $Global:Job.Logging.WriteVariables("StartTime", @{
        "LastDatabaseStartTime" = $Global:LastDatabaseStartTime;
    });
});
#endregion Get Start Time

#region Export Activity Logs
$Global:Job.Execute("Export Activity Logs", {
    Try
    {
        $Global:LogFiles = $Global:Job.InformaticaAPI.ExportLogs($Global:Job.DataDirectory, $Global:LastDatabaseStartTime);
    }
    Catch
    {
        $Global:Job.Logging.WriteExceptionWithData($_.Exception, $Project);
    }
});
#endregion Export Activity Logs

#region Clear Staged
$Global:Job.Execute("Clear Staged", {
    Try
    {
        $Global:Job.Databases.IICS.ClearStaged($Global:Job.Config.IICSDatabaseConnectionName, $false, $false, $true);
    }
    Catch
    {
        $Global:Job.Logging.WriteException($_.Exception);
    }
});
#endregion Clear Staged

#region Post Staged Activity Logs
$Global:Job.Execute("Post Staged Activity Logs", {
    ForEach ($FilePath In $Global:LLogFiles)
    {
        Try
        {
            $Global:Job.Databases.IICS.PostStagedActivityLogs(
                $Global:Job.Config.IICSDatabaseConnectionName,
                [IO.File]::ReadAllText($FilePath)
            );
            [void] [IO.File]::Delete($FilePath);
        }
        Catch
        {
            $Global:Job.Logging.WriteException($_.Exception);
        }
    }
});
#endregion Post Staged Activity Logs

#region Parse Activity Logs
$Global:Job.Execute("Parse Activity Logs", {
    Try
    {
        $Global:Job.Databases.IICS.ParseActivityLogs($Global:Job.Config.IICSDatabaseConnectionName);
    }
    Catch
    {
        $Global:Job.Logging.WriteException($_.Exception);
    }
});
#endregion Parse Activity Logs

#region Remove Old Activity Logs
$Global:Job.Execute("Remove Old Activity Logs", {
    If ($Global:Job.Config.KeepLogsForDays -gt 0)
    {
        Try
        {
            $Global:Job.Databases.IICS.RemoveOldActivityLogs($Global:Job.Config.KeepLogsForDays);
        }
        Catch
        {
            $Global:Job.Logging.WriteException($_.Exception);
        }
    }
    Else
    {
        $Global:Job.Logging.WriteEntry("Information", [String]::Format("No activity logs were removed. KeepLogsForDays is set to {0}", $Global:Job.Config.KeepLogsForDays));
    }
});
#endregion Remove Old Activity Logs

$Global:Job.Logging.Close();
$Global:Job.Logging.ClearLogs();
