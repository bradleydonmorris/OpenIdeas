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

Add-Member `
    -InputObject $Global:Job `
    -Name "Execute" `
    -MemberType "ScriptMethod" `
    -Value {
        [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [ScriptBlock] $ScriptBlock
        )
        $Global:Job.Logging.WriteEntry("Information", [String]::Format("Executing {0}", $Name));
        $Global:Job.Logging.Timers.Add($Name);
        $Global:Job.Logging.Timers.Start($Name);
        $ScriptBlock.Invoke();
        $Global:Job.Logging.Timers.Stop($Name);
    };
Add-Member `
    -InputObject $Global:Job `
    -Name "ExecuteAll" `
    -MemberType "ScriptMethod" `
    -Value {
        [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$true)]
            [Collections.Hashtable] $Scripts
        )
        ForEach ($ScriptKey In $Scripts.Keys)
        {
            If ($Scripts[$ScriptKey] -is [ScriptBlock])
            {
                $Global:Job.Logging.WriteEntry("Information", [String]::Format("Executing {0}", $ScriptKey));
                $Global:Job.Logging.Timers.Add($ScriptKey);
                $Global:Job.Logging.Timers.Start($ScriptKey);
                $Scripts[$ScriptKey].Invoke();
                $Global:Job.Logging.Timers.Stop($ScriptKey);
            }
        }
    };
Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Utilities" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Utilities `
    -Name "ParseFileNameTime" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([DateTime])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath,
    
            [Parameter(Mandatory=$false)]
            [String] $DateTimeFormatString,
    
            [Parameter(Mandatory=$false)]
            [Int32] $DateTimeStartPosition
        )
        [DateTime] $Results = [DateTime]::MinValue;
        [String] $FileName = [IO.Path]::GetFileName($FilePath);
        If ($FileName.Length -ge ($DateTimeStartPosition + $DateTimeFormatString.Length))
        {
            [String] $FileDateStamp = $FileName.Substring($DateTimeStartPosition, $DateTimeFormatString.Length);
            [DateTime] $ResultDateTime = [DateTime]::MinValue;
            If ([DateTime]::TryParseExact(
                                            $FileDateStamp, $DateTimeFormatString,
                                            [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None,
                                            [ref]$ResultDateTime))
            {
                $Results = $ResultDateTime;
            }
        }
        Else
        {
            $Results = [DateTime]::MinValue;
        }
        Return $Results
    };
