. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "InformaticaAPI",
    "Databases.IICS"
);

#$Global:Job.Config is automatically loaded if a sibling file with an extension of .config.json is found for this script.
$Global:Job.Logging.WriteVariables("Config", @{
    "IICSDatabaseConnectionName" = $Global:Job.Config.IICSDatabaseConnectionName;
    "IICSAPIConnectionName" = $Global:Job.Config.IICSAPIConnectionName;
    "Projects" = $Global:Job.Config.Projects;
});

[String] $ExtractedDirectoryPath = $Global:Job.DataDirectory; # [IO.Path]::Combine($Global:Job.DataDirectory, "Extracted");
$Global:Job.Logging.WriteVariables("Paths", @{
    "ExtractedDirectoryPath" = $ExtractedDirectoryPath;
});

[Collections.ArrayList] $Global:AssetIds = [Collections.ArrayList]::new();
[Collections.Hashtable] $Global:Export = $null;

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

#region Gather Assets
$Global:Job.Execute("Gather Assets", {
    ForEach ($Project In $Global:Job.Config.Projects)
    {
        Try
        {
            $Global:Job.Logging.WriteEntry("Information", [String]::Format("Gathering assets for {0}", $Project));
            [void] $Global:AssetIds.AddRange($Global:Job.InformaticaAPI.GetAssets($Project));
        }
        Catch
        {
            $Global:Job.Logging.WriteExceptionWithData($_.Exception, $Project);
        }
    }
});
#endregion Gather Assets

#region Export Assets
$Global:Job.Execute("Export Assets", {
    Try
    {
        $Global:Export = $Global:Job.InformaticaAPI.ExportAssets($Global:AssetIds, $ExtractedDirectoryPath, $true, $true);
    }
    Catch
    {
        $Global:Job.Logging.WriteException($_.Exception);
    }
});
#endregion Export Assets

#region Clear Staged
$Global:Job.Execute("Clear Staged", {
    Try
    {
        $Global:Job.Databases.IICS.ClearStaged($Global:Job.Config.IICSDatabaseConnectionName, $true, $true, $false);
    }
    Catch
    {
        $Global:Job.Logging.WriteException($_.Exception);
    }
});
#endregion Clear Staged

#region Post Staged Assets
$Global:Job.Execute("Post Staged Assets", {
    Try
    {
        $Global:Job.Databases.IICS.PostStagedAssets($Global:Job.Config.IICSDatabaseConnectionName, $Global:Export.Assets);
    }
    Catch
    {
        $Global:Job.Logging.WriteException($_.Exception);
    }
});
#endregion Post Staged Assets

#region Post Staged Asset Files
$Global:Job.Execute("Post Staged Asset Files", {
    Try
    {
        $Global:Job.Databases.IICS.PostStagedAssetFiles($Global:Job.Config.IICSDatabaseConnectionName, $Global:Export.AssetFiles);
    }
    Catch
    {
        $Global:Job.Logging.WriteException($_.Exception);
    }
});
#endregion Post Staged Asset Files

#region Parse
$Global:Job.Execute("Parse", {
    Try
    {
        $Global:Job.Databases.IICS.Parse($Global:Job.Config.IICSDatabaseConnectionName);
    }
    Catch
    {
        $Global:Job.Logging.WriteException($_.Exception);
    }
});
#endregion Parse

$Global:Job.Logging.Close();
$Global:Job.Logging.ClearLogs();
