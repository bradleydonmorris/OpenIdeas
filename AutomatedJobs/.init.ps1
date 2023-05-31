Param
(
    [Parameter(Position=1, Mandatory=$false)]
    [String[]] $RequiredModules
)
[String] $JobsConfigFilePath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), ".jobs-config.json");
If (![IO.File]::Exists($JobsConfigFilePath))
{
    ConvertTo-Json -InputObject @{
        "LoggingDefaults" = @{
            "RetentionDays" = 30
            "SMTPConnectionName" = "LoggingSMTP"
            "EmailRecipients" = "changethis@example.com"
        }
        "Directories" = @{
            "CodeRoot" = "C:\Users\bmorris\source\repos\FRACDEV\automated-jobs"
            "Modules" = "C:\Users\bmorris\source\repos\FRACDEV\automated-jobs\_Modules"
            "DataRoot" = "C:\JobsWorkspace\Data"
            "LogsRoot" = "C:\JobsWorkspace\Logs"
            "ConnectionsRoot" = "C:\JobsWorkspace\Connections"
        }
    } | Set-Content -Path $JobsConfigFilePath;
}
$Global:Job = ConvertFrom-Json -InputObject (Get-Content -Path $JobsConfigFilePath -Raw) -Depth 10;


[String] $ConfigFilePath = [IO.Path]::ChangeExtension($MyInvocation.PSCommandPath, "config.json");

If ([IO.File]::Exists($ConfigFilePath))
{
    Add-Member `
        -InputObject $Global:Job `
        -NotePropertyName "Config" `
        -NotePropertyValue (ConvertFrom-Json -InputObject ([IO.File]::ReadAllText($ConfigFilePath)));
}
Add-Member `
    -InputObject $Global:Job `
    -TypeName "String" `
    -NotePropertyName "Collection" `
    -NotePropertyValue ([IO.Path]::GetFileNameWithoutExtension([IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)));
Add-Member `
    -InputObject $Global:Job `
    -TypeName "String" `
    -NotePropertyName "Script" `
    -NotePropertyValue ([IO.Path]::GetFileNameWithoutExtension($MyInvocation.PSCommandPath));
Add-Member `
    -InputObject $Global:Job `
    -TypeName "String" `
    -NotePropertyName "DataDirectory" `
    -NotePropertyValue ([IO.Path]::Combine($Global:Job.Directories.DataRoot, $Global:Job.Collection, $Global:Job.Script));
If (![IO.Directory]::Exists($Global:Job.DataDirectory))
{
    [void] [IO.Directory]::CreateDirectory($Global:Job.DataDirectory);
}

[Collections.Hashtable] $Local:Modules = [Collections.Hashtable]::new();

[String] $LoggingModuleFilePath = ([IO.Path]::Combine($Global:Job.Directories.Modules, "Logging\Main.ps1"));
If ([IO.File]::Exists($LoggingModuleFilePath))
{
    [void] $Local:Modules.Add("Logging", $LoggingModuleFilePath);
    . $LoggingModuleFilePath;
}

[String] $UtilitiesModuleFilePath = ([IO.Path]::Combine($Global:Job.Directories.Modules, "Utilities\Main.ps1"));
If ([IO.File]::Exists($UtilitiesModuleFilePath))
{
    [void] $Local:Modules.Add("Utilities", $UtilitiesModuleFilePath);
    . $UtilitiesModuleFilePath;
}

[String] $ConnectionsModuleFilePath = ([IO.Path]::Combine($Global:Job.Directories.Modules, "Connections\Main.ps1"));
If ([IO.File]::Exists($ConnectionsModuleFilePath))
{
    [void] $Local:Modules.Add("Connections", $ConnectionsModuleFilePath);
    . $ConnectionsModuleFilePath;
}

[String] $DatabasesModuleFilePath = ([IO.Path]::Combine($Global:Job.Directories.Modules, "Databases\Main.ps1"));
If ([IO.File]::Exists($DatabasesModuleFilePath))
{
    [void] $Local:Modules.Add("Databases", $DatabasesModuleFilePath);
    . $DatabasesModuleFilePath;
}

ForEach ($Module In $RequiredModules)
{
    If ($Module.EndsWith(".ps1"))
    {
        $Module = [IO.Path]::GetFileNameWithoutExtension($Module);
    }
    If (!$Local:Modules.ContainsKey($Module))
    {
        [String] $ModuleFilePath = ([IO.Path]::Combine($Global:Job.Directories.Modules, "$Module\Main.ps1"));
        If ([IO.File]::Exists($ModuleFilePath))
        {
            [void] $Local:Modules.Add($Module, $ModuleFilePath);
            . $ModuleFilePath;
        }
    }
}

Add-Member `
    -InputObject $Global:Job `
    -NotePropertyName "Modules" `
    -NotePropertyValue ([PSCustomObject]$Local:Modules);
