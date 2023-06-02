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
Add-Member `
    -InputObject $Global:Job `
    -NotePropertyName "Modules" `
    -NotePropertyValue ([Collections.Hashtable]::new());
Add-Member `
    -InputObject $Global:Job `
    -Name "LoadModule" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        If ($Name.EndsWith(".ps1"))
        {
            $Name = [IO.Path]::GetFileNameWithoutExtension($Name);
        }
        If (!$Global:Job.Modules.ContainsKey($Name))
        {
            [String] $ModuleFilePath = ([IO.Path]::Combine($Global:Job.Directories.Modules, "$Name\Main.ps1"));
            If ([IO.File]::Exists($ModuleFilePath))
            {
                [void] $Global:Job.Modules.Add($Name, $ModuleFilePath);
                . $ModuleFilePath;
            }
        }
    }
Add-Member `
    -InputObject $Global:Job `
    -Name "IsModuleLoaded" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Boolean] $ReturnValue = $false;
        If ($Name.EndsWith(".ps1"))
        {
            $Name = [IO.Path]::GetFileNameWithoutExtension($Name);
        }
        $ReturnValue = $Global:Job.Modules.ContainsKey($Name);
        Return $ReturnValue;
    }

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

#These modules must always be loaded.
[void] $Global:Job.LoadModule("Logging");
[void] $Global:Job.LoadModule("Utilities");
[void] $Global:Job.LoadModule("Connections");
[void] $Global:Job.LoadModule("Databases");
[void] $Global:Job.LoadModule("NuGet");

#Load additional modules that may be required
ForEach ($Module In $RequiredModules)
{
    [void] $Global:Job.LoadModule($Module);
}

