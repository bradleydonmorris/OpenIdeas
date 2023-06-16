. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "InformaticaAPI",
    "Databases.IICS"
);

#$Global:Session.Config is automatically loaded if a sibling file with an extension of .config.json is found for this script.
$Global:Session.Logging.WriteVariables("Config", @{
    "IICSDatabaseConnectionName" = $Global:Session.Config.IICSDatabaseConnectionName;
    "IICSAPIConnectionName" = $Global:Session.Config.IICSAPIConnectionName;
    "Projects" = $Global:Session.Config.Projects;
});

[String] $ExtractedDirectoryPath = $Global:Session.DataDirectory; # [IO.Path]::Combine($Global:Session.DataDirectory, "Extracted");
$Global:Session.Logging.WriteVariables("Paths", @{
    "ExtractedDirectoryPath" = $ExtractedDirectoryPath;
});

[Collections.Generic.List[String]] $Global:AssetIds = [Collections.Generic.List[String]]::new();
[Collections.Generic.List[PSObject]] $Global:Export = $null;

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

#region Gather Assets
$Global:Session.Execute("Gather Assets", {
    ForEach ($Project In $Global:Session.Config.Projects)
    {
        Try
        {
            $Global:Session.Logging.WriteEntry("Information", [String]::Format("Gathering assets for {0}", $Project));
            [void] $Global:AssetIds.AddRange($Global:Session.InformaticaAPI.GetAssets($Project));
        }
        Catch
        {
            $Global:Session.Logging.WriteExceptionWithData($_.Exception, $Project);
        }
    }
});
#endregion Gather Assets

#region Export Assets
$Global:Session.Execute("Export Assets", {
    Try
    {
        $Global:Export = $Global:Session.InformaticaAPI.ExportAssets($Global:AssetIds, $ExtractedDirectoryPath, $true, $true);
    }
    Catch
    {
        $Global:Session.Logging.WriteException($_.Exception);
    }
});
#endregion Export Assets

#region Clear Staged
$Global:Session.Execute("Clear Staged", {
    Try
    {
        $Global:Session.Databases.IICS.ClearStaged($Global:Session.Config.IICSDatabaseConnectionName, $true, $true, $false);
    }
    Catch
    {
        $Global:Session.Logging.WriteException($_.Exception);
    }
});
#endregion Clear Staged

#region Post Staged Assets
$Global:Session.Execute("Post Staged Assets", {
    Try
    {
        $Global:Session.Databases.IICS.PostStagedAssets($Global:Session.Config.IICSDatabaseConnectionName, $Global:Export.Assets);
    }
    Catch
    {
        $Global:Session.Logging.WriteException($_.Exception);
    }
});
#endregion Post Staged Assets

#region Post Staged Asset Files
$Global:Session.Execute("Post Staged Asset Files", {
    Try
    {
        $Global:Session.Databases.IICS.PostStagedAssetFiles($Global:Session.Config.IICSDatabaseConnectionName, $Global:Export.AssetFiles);
    }
    Catch
    {
        $Global:Session.Logging.WriteException($_.Exception);
    }
});
#endregion Post Staged Asset Files

#region Parse
$Global:Session.Execute("Parse", {
    Try
    {
        $Global:Session.Databases.IICS.Parse($Global:Session.Config.IICSDatabaseConnectionName);
    }
    Catch
    {
        $Global:Session.Logging.WriteException($_.Exception);
    }
});
#endregion Parse

$Global:Session.Logging.Close();
$Global:Session.Logging.ClearLogs();
