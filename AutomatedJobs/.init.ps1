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
            "Packages" = "C:\Users\bmorris\source\repos\FRACDEV\automated-jobs\_Packages"
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
Add-Member `
    -InputObject $Global:Job `
    -Name "GetAvailableModules" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        ForEach ($Directory In (Get-ChildItem -Path $Global:Job.Directories.Modules -Directory))
        {
            [String] $MainFilePath = [IO.Path]::Combine($Directory.FullName, "Main.ps1");
            [String] $ReadMeFilePath = [IO.Path]::Combine($Directory.FullName, "README.md");
            [String] $DocFilePath = [IO.Path]::Combine($Directory.FullName, "Doc.json");
            If ([IO.File]::Exists($MainFilePath))
            {
                [PSObject] $Module = [PSObject]::new();
                Add-Member `
                    -InputObject $Module `
                    -TypeName "System.String" `
                    -NotePropertyName "Name" `
                    -NotePropertyValue $Directory.Name;
                Add-Member `
                    -InputObject $Module `
                    -TypeName "System.String" `
                    -NotePropertyName "DirectoryPath" `
                    -NotePropertyValue $Directory.FullName;
                Add-Member `
                    -InputObject $Module `
                    -TypeName "System.String" `
                    -NotePropertyName "MainFilePath" `
                    -NotePropertyValue $MainFilePath;
                Add-Member `
                    -InputObject $Module `
                    -TypeName "System.Boolean" `
                    -NotePropertyName "IsLoaded" `
                    -NotePropertyValue ($Global:Job.IsModuleLoaded($Directory.Name));
                Add-Member `
                    -InputObject $Module `
                    -TypeName "System.String" `
                    -NotePropertyName "ReadMeFilePath" `
                    -NotePropertyValue $ReadMeFilePath; 
                Add-Member `
                    -InputObject $Module `
                    -TypeName "System.String" `
                    -NotePropertyName "DocFilePath" `
                    -NotePropertyValue $DocFilePath; 
                [void] $ReturnValue.Add([PSObject]$Module);
            }
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job `
    -Name "CreateModuleDocFile" `
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
        If (!$Global:Job.IsModuleLoaded($Name))
        {
            $Global:Job.LoadModule($Name);
        }
        [String] $DocFilePath = ([IO.Path]::Combine($Global:Job.Directories.Modules, $Name, "Doc.json"));
        $Doc = [Ordered]@{
            "Name" = $Name;
            "Description" = "";
            "Properties" = [Collections.Generic.List[PSObject]]::new();
            "Methods" = [Collections.Generic.List[PSObject]]::new();
        };
        ForEach ($Property In ($Global:Job."$Name" | Get-Member -MemberType NoteProperty))
        {
            [String] $TypeName = $Property.Definition.Substring(0, $Property.Definition.IndexOf(" "));
            Switch ($TypeName)
            {
                "byte" { $TypeName = "System.Byte"; }
                "short" { $TypeName = "System.Int16"; }
                "int" { $TypeName = "System.Int32"; }
                "long" { $TypeName = "System.Int64"; }
                "float" { $TypeName = "System.Single"; }
                "double" { $TypeName = "System.Double"; }
                "decimal" { $TypeName = "System.Decimal"; }
                "string" { $TypeName = "System.String"; }
            }
            [void] $Doc.Properties.Add([Ordered]@{
                "Name" = $Property.Name;
                "Type" = $TypeName;
                "Description" = "";
            });
        }
        ForEach ($ScriptMethod In ($Global:Job."$Name" | Get-Member -MemberType ScriptMethod))
        {
            [void] $Doc.Methods.Add([Ordered]@{
                "Name" = $ScriptMethod.Name;
                "Description" = "";
                "Returns" = "";
                "Arguments" = @([Ordered]@{
                    "Name" = "ArgName";
                    "Type" = "System.String";
                    "Description" = "";
                });
            });
            
        }
        $Doc | ConvertTo-Json -Depth 10 | Out-File -FilePath $DocFilePath;
    }
Add-Member `
    -InputObject $Global:Job `
    -Name "CreateModuleReadMeFile" `
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
        [String] $DocFilePath = ([IO.Path]::Combine($Global:Job.Directories.Modules, $Name, "Doc.json"));
        [String] $ReadMeFilePath = ([IO.Path]::Combine($Global:Job.Directories.Modules, $Name, "README.md"));
        If ([IO.File]::Exists($DocFilePath))
        {
            $Doc = ConvertFrom-Json -InputObject ([IO.File]::ReadAllText($DocFilePath));
            [String] $README = [String]::Format("# {0}`n", $Doc.Name);
            $README += [String]::Format("## {0}`n`n", $Doc.Description);
            ForEach ($Property In $Doc.Properties)
            {
                $README += [String]::Format(
                    "- ### {0}`n    {1}`n",
                    $Property.Name,
                    $Property.Description
                );
            }
            ForEach ($Method In $Doc.Methods)
            {
                If (![String]::IsNullOrEmpty($Method.Returns) -and $Method.Returns -ne "void")
                {
                    $README += [String]::Format(
                        "- ### {0}`n    Returns: {1}  `n    {2}",
                        $Method.Name,
                        $Method.Returns,
                        $Method.Description
                    );
                }
                Else
                {
                    $README += [String]::Format(
                        "- ### {0}`n    {1}",
                        $Method.Name,
                        $Method.Description
                    );
                }
                If ($Method.Arguments)
                {
                    If ($Method.Arguments.Count -gt 0)
                    {
                        $README += "  `n"
                        ForEach ($Argument In $Method.Arguments)
                        {
                            $README += [String]::Format(
                                "    - {0} ({1})  `n        {2}`n",
                                $Argument.Name,
                                $Argument.Type,
                                $Argument.Description
                            );
                        }
                    }
                    Else
                    {
                        $README += "`n";
                    }
                }
                Else
                {
                    $README += "`n";
                }
            }
            [void] [IO.File]::WriteAllText($ReadMeFilePath, $README);
        }
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
    -NotePropertyName "Project" `
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
    -NotePropertyValue ([IO.Path]::Combine($Global:Job.Directories.DataRoot, $Global:Job.Project, $Global:Job.Script));

If (![IO.Directory]::Exists($Global:Job.DataDirectory))
{
    [void] [IO.Directory]::CreateDirectory($Global:Job.DataDirectory);
}

#These modules must always be loaded.
[void] $Global:Job.LoadModule("Logging");
[void] $Global:Job.LoadModule("Utilities");
[void] $Global:Job.LoadModule("NuGet");
[void] $Global:Job.LoadModule("Connections");

#Load additional modules that may be required
ForEach ($Module In $RequiredModules)
{
    [void] $Global:Job.LoadModule($Module);
}
