Param
(
    [Parameter(Position=1, Mandatory=$false)]
    [String[]] $RequiredModules
)
[String] $JobsConfigFilePath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), ".psps-config.json");
If (![IO.File]::Exists($JobsConfigFilePath))
{
    ConvertTo-Json -InputObject @{
        "AlwaysLoadedModules" = @(
            "Variables",
            "Connections",
            "Logging",
            "Utilities",
            "NuGet"
        )
        "LoggingDefaults" = @{
            "RetentionDays" = 30
            "SMTPConnectionName" = "LoggingSMTP"
            "EmailRecipients" = @("changethis@example.com")
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
$Global:Session = ConvertFrom-Json -InputObject (Get-Content -Path $JobsConfigFilePath -Raw) -Depth 10;
Add-Member `
    -InputObject $Global:Session `
    -NotePropertyName "Modules" `
    -NotePropertyValue ([Collections.Hashtable]::new());
Add-Member `
    -InputObject $Global:Session `
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
        If (!$Global:Session.Modules.ContainsKey($Name))
        {
            [String] $ModuleFilePath = ([IO.Path]::Combine($Global:Session.Directories.Modules, "$Name\Main.ps1"));
            If ([IO.File]::Exists($ModuleFilePath))
            {
                [void] $Global:Session.Modules.Add($Name, $ModuleFilePath);
                . $ModuleFilePath;
            }
            Else
            {
                Throw [System.IO.FileNotFoundException]::new("File not found for Module ", $Name);
            }
        }
    }
Add-Member `
    -InputObject $Global:Session `
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
        $ReturnValue = $Global:Session.Modules.ContainsKey($Name);
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session `
    -Name "GetAvailableModules" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        ForEach ($Directory In (Get-ChildItem -Path $Global:Session.Directories.Modules -Directory))
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
                    -NotePropertyValue ($Global:Session.IsModuleLoaded($Directory.Name));
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
    -InputObject $Global:Session `
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
        If (!$Global:Session.IsModuleLoaded($Name))
        {
            $Global:Session.LoadModule($Name);
        }
        [String] $DocFilePath = ([IO.Path]::Combine($Global:Session.Directories.Modules, $Name, "Doc.json"));
        $Doc = [Ordered]@{
            "Name" = $Name;
            "Description" = "";
            "Properties" = [Collections.Generic.List[PSObject]]::new();
            "Methods" = [Collections.Generic.List[PSObject]]::new();
        };
        ForEach ($Property In ($Global:Session."$Name" | Get-Member -MemberType NoteProperty))
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
        ForEach ($ScriptMethod In ($Global:Session."$Name" | Get-Member -MemberType ScriptMethod))
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
    -InputObject $Global:Session `
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
        [String] $DocFilePath = ([IO.Path]::Combine($Global:Session.Directories.Modules, $Name, "Doc.json"));
        [String] $ReadMeFilePath = ([IO.Path]::Combine($Global:Session.Directories.Modules, $Name, "README.md"));
        If ([IO.File]::Exists($DocFilePath))
        {
            $Doc = ConvertFrom-Json -InputObject ([IO.File]::ReadAllText($DocFilePath));
            [String] $README = [String]::Format("# {0}`n", $Doc.Name);
            $README += [String]::Format("## {0}`n`n", $Doc.Description);
            If ($Doc.Requires.Count -gt 0)
            {
                $RequiresList = "";
                ForEach ($ModuleName In $Doc.Requires)
                {
                    $RequiresList += [String]::Format(
                        " [{0}](_Modules/{0}/README.md),",
                        $ModuleName
                    );
                }
                If ($RequiresList.EndsWith(","))
                {
                    $RequiresList = $RequiresList.Substring(0, ($RequiresList.Length - 1))
                }
                $README += [String]::Format(
                    "- ### Requires{0}  `n",
                    $RequiresList
                );
            }
            ForEach ($Property In $Doc.Properties)
            {
                $README += [String]::Format(
                    "- ### {0} ``[property]```n    {1}`n",
                    $Property.Name,
                    $Property.Description
                );
            }
            ForEach ($Method In $Doc.Methods)
            {
                If (![String]::IsNullOrEmpty($Method.Returns) -and $Method.Returns -ne "void")
                {
                    $README += [String]::Format(
                        "- ### {0} ``[method]```n    Returns: ``{1}``  `n    {2}",
                        $Method.Name,
                        $Method.Returns,
                        $Method.Description
                    );
                }
                Else
                {
                    $README += [String]::Format(
                        "- ### ``Method`` {0}`n    {1}",
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
                                "    - {0} ``{1}``  `n        {2}`n`n",
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
        -InputObject $Global:Session `
        -NotePropertyName "Config" `
        -NotePropertyValue (ConvertFrom-Json -InputObject ([IO.File]::ReadAllText($ConfigFilePath)));
}
Add-Member `
    -InputObject $Global:Session `
    -TypeName "String" `
    -NotePropertyName "Project" `
    -NotePropertyValue ([IO.Path]::GetFileNameWithoutExtension([IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)));
Add-Member `
    -InputObject $Global:Session `
    -TypeName "String" `
    -NotePropertyName "Script" `
    -NotePropertyValue ([IO.Path]::GetFileNameWithoutExtension($MyInvocation.PSCommandPath));
Add-Member `
    -InputObject $Global:Session `
    -TypeName "String" `
    -NotePropertyName "DataDirectory" `
    -NotePropertyValue ([IO.Path]::Combine($Global:Session.Directories.DataRoot, $Global:Session.Project, $Global:Session.Script));

If (![IO.Directory]::Exists($Global:Session.DataDirectory))
{
    [void] [IO.Directory]::CreateDirectory($Global:Session.DataDirectory);
}

#These modules must always be loaded.
ForEach ($ModuleName In $Global:Session.AlwaysLoadedModules)
{
    [void] $Global:Session.LoadModule($ModuleName);
}

#Load additional modules that may be required
ForEach ($ModuleName In $RequiredModules)
{
    [void] $Global:Session.LoadModule($ModuleName);
}
