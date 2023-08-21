[void] $Global:Session.LoadModule("Connections");

If (![IO.Directory]::Exists($Global:Session.Directories.LogsRoot))
{
    [void] [IO.Directory]::CreateDirectory($Global:Session.Directories.LogsRoot);
}
[String] $DirectoryPath = [IO.Path]::Combine($Global:Session.Directories.LogsRoot, $Global:Session.Project, $Global:Session.Script);
[String] $ConfigFilePath = [IO.Path]::Combine($DirectoryPath, ".config.json");
If (![IO.Directory]::Exists($DirectoryPath))
{
    [void] [IO.Directory]::CreateDirectory($DirectoryPath);
}
If (![IO.File]::Exists($ConfigFilePath))
{
    ConvertTo-Json -InputObject @{
        "RetentionDays" = $Global:Session.LoggingDefaults.RetentionDays
        "EmailRecipients" = $Global:Session.LoggingDefaults.EmailRecipients
        "DatabaseConnectionName" = $Global:Session.LoggingDefaults.DatabaseConnection;
        "SMTPConnectionName" = $Global:Session.LoggingDefaults.SMTPConnectionName
    } | Set-Content -Path $ConfigFilePath;
}
$Config = ConvertFrom-Json -InputObject (Get-Content -Path $ConfigFilePath -Raw) -Depth 20;

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Logging" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

#region Properties
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "System.Guid" `
    -NotePropertyName "LogGUID" `
    -NotePropertyValue ([Guid]::NewGUID());
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "System.DateTime" `
    -NotePropertyName "OpenLogTime" `
    -NotePropertyValue ([DateTime]::MinValue);
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "System.DateTime" `
    -NotePropertyName "CloseLogTime" `
    -NotePropertyValue ([DateTime]::MinValue);
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "System.TimeSpan" `
    -NotePropertyName "ElapsedLogTime" `
    -NotePropertyValue ([DateTime]::MinValue);
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "String" `
    -NotePropertyName "DirectoryPath" `
    -NotePropertyValue $DirectoryPath;
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "String" `
    -NotePropertyName "ConfigFilePath" `
    -NotePropertyValue $ConfigFilePath;
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "String" `
    -NotePropertyName "LogFileTimestamp" `
    -NotePropertyValue ([DateTime]::UtcNow.ToString("yyyyMMdd_HHmmss"));
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "String" `
    -NotePropertyName "LogFileNameTemplate" `
    -NotePropertyValue ($Global:Session.Logging.LogFileTimestamp + ".{0}.{1}.txt");
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "String" `
    -NotePropertyName "LogFilePathTemplate" `
    -NotePropertyValue ([IO.Path]::Combine($Global:Session.Logging.DirectoryPath, ($Global:Session.Logging.LogFileTimestamp + ".{0}.{1}.txt")));
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "Int32" `
    -NotePropertyName "LastLogFileNumber" `
    -NotePropertyValue (0);
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "String" `
    -NotePropertyName "CurrentLogFilePath" `
    -NotePropertyValue ([IO.Path]::Combine(
        $Global:Session.Logging.DirectoryPath, 
        [String]::Format(
            $Global:Session.Logging.LogFilePathTemplate,
            "000",
            "LOG"
        )
    ));
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "String" `
    -NotePropertyName "JSONFilePath" `
    -NotePropertyValue ([IO.Path]::Combine(
        $Global:Session.Logging.DirectoryPath,
        [String]::Format(
            "{0}.json",
            $Global:Session.Logging.LogFileTimestamp
        )
    ));
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "System.Boolean" `
    -NotePropertyName "OutputToHost" `
    -NotePropertyValue ($false);
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "Int32" `
    -NotePropertyName "LastEntryNumber" `
    -NotePropertyValue (0);
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "System.Collections.Generic.List[PSObject]" `
    -NotePropertyName "Entries" `
    -NotePropertyValue ([Collections.Generic.List[PSObject]]::new());
#endregion Properties

#region LevelCounts
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "LevelCounts" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.Logging.LevelCounts `
    -TypeName "Int32" `
    -NotePropertyName "Information" `
    -NotePropertyValue 0;
Add-Member `
    -InputObject $Global:Session.Logging.LevelCounts `
    -TypeName "Int32" `
    -NotePropertyName "Warning" `
    -NotePropertyValue 0;
Add-Member `
    -InputObject $Global:Session.Logging.LevelCounts `
    -TypeName "Int32" `
    -NotePropertyName "Error" `
    -NotePropertyValue 0;
Add-Member `
    -InputObject $Global:Session.Logging.LevelCounts `
    -TypeName "Int32" `
    -NotePropertyName "Debug" `
    -NotePropertyValue 0;
Add-Member `
    -InputObject $Global:Session.Logging.LevelCounts `
    -TypeName "Int32" `
    -NotePropertyName "Fatal" `
    -NotePropertyValue 0;
#endregion LevelCounts

#region Timers
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Timers" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.Logging.Timers `
    -TypeName "System.Collections.Hashtable" `
    -NotePropertyName "TimerCollection" `
    -NotePropertyValue ([Collections.Hashtable]::new());
Add-Member `
    -InputObject $Global:Session.Logging.Timers `
    -TypeName "System.Collections.Generic.List[String]" `
    -NotePropertyName "TimerOrder" `
    -NotePropertyValue ([Collections.Generic.List[String]]::new());
Add-Member `
    -InputObject $Global:Session.Logging.Timers `
    -TypeName "String" `
    -NotePropertyName "TimersFilePath" `
    -NotePropertyValue ([IO.Path]::Combine(
        $Global:Session.Logging.DirectoryPath, 
        [String]::Format(
            $Global:Session.Logging.LogFilePathTemplate,
            "000",
            "TIMERS"
        )
    ));
Add-Member `
    -InputObject $Global:Session.Logging.Timers `
    -Name "Add" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$false)]
            [String] $Name
        )
        If ($Global:Session.Logging.Timers.TimerCollection.ContainsKey($Name))
        {
            Throw [Exception]::new("Timer $Name already exists.");
        }
        Else
        {
            [void] $Global:Session.Logging.Timers.TimerOrder.Add($Name);
            [void] $Global:Session.Logging.Timers.TimerCollection.Add($Name, @{
                "BeginTime" = [DateTime]::UtcNow;
                "EndTime" = [DateTime]::MinValue;
                "ElapsedTime" = [TimeSpan]::MinValue;
                "State" = "Not Started";
            });
        }
    };
Add-Member `
    -InputObject $Global:Session.Logging.Timers `
    -Name "AddWithTimes" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [DateTime] $BeginTime,

            [Parameter(Mandatory=$true)]
            [DateTime] $EndTime
        )
        If ($Global:Session.Logging.Timers.TimerCollection.ContainsKey($Name))
        {
            Throw [Exception]::new("Timer $Name already exists.");
        }
        Else
        {
            [void] $Global:Session.Logging.Timers.TimerOrder.Add($Name);
            [void] $Global:Session.Logging.Timers.TimerCollection.Add($Name, @{
                "BeginTime" = $BeginTime;
                "EndTime" = $EndTime;
                "ElapsedTime" = ($EndTime - $BeginTime);
                "State" = "Stopped";
            });
        }
    };
Add-Member `
    -InputObject $Global:Session.Logging.Timers `
    -Name "Start" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$false)]
            [String] $Name
        )
        If (!$Global:Session.Logging.Timers.TimerCollection.ContainsKey($Name))
        {
            Throw [Exception]::new("Timer $Name not found.");
        }
        ElseIf ($Global:Session.Logging.Timers.TimerCollection[$Name].State -eq "Started")
        {
            Throw [Exception]::new("Timer $Name already started.");
        }
        ElseIf ($Global:Session.Logging.Timers.TimerCollection[$Name].State -eq "Stopped")
        {
            Throw [Exception]::new("Timer $Name already stopped.");
        }
        Else
        {
            $Global:Session.Logging.Timers.TimerCollection[$Name].BeginTime = [DateTime]::UtcNow;
            $Global:Session.Logging.Timers.TimerCollection[$Name].EndTime = [DateTime]::MinValue;
            $Global:Session.Logging.Timers.TimerCollection[$Name].ElapsedTime = [TimeSpan]::MinValue;
            $Global:Session.Logging.Timers.TimerCollection[$Name].State = "Started";
        }
    };
Add-Member `
    -InputObject $Global:Session.Logging.Timers `
    -Name "Stop" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$false)]
            [String] $Name
        )
        If (!$Global:Session.Logging.Timers.TimerCollection.ContainsKey($Name))
        {
            Throw [Exception]::new("Timer $Name not found.");
        }
        ElseIf ($Global:Session.Logging.Timers.TimerCollection[$Name].State -eq "Created")
        {
            Throw [Exception]::new("Timer $Name not started.");
        }
        ElseIf ($Global:Session.Logging.Timers.TimerCollection[$Name].State -eq "Stopped")
        {
            Throw [Exception]::new("Timer $Name already stopped.");
        }
        Else
        {
            $Global:Session.Logging.Timers.TimerCollection[$Name].EndTime = [DateTime]::UtcNow;
            $Global:Session.Logging.Timers.TimerCollection[$Name].ElapsedTime = (
                $Global:Session.Logging.Timers.TimerCollection[$Name].EndTime -
                $Global:Session.Logging.Timers.TimerCollection[$Name].BeginTime
            );
            $Global:Session.Logging.Timers.TimerCollection[$Name].State = "Stopped";
        }
    };
Add-Member `
    -InputObject $Global:Session.Logging.Timers `
    -Name "Get" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([System.Management.Automation.PSObject])]
        Param
        (
            [Parameter(Mandatory=$false)]
            [String] $Name
        )
        [System.Management.Automation.PSObject] $Results = $null;
        If (!$Global:Session.Logging.Timers.TimerCollection.ContainsKey($Name))
        {
            Throw [Exception]::new("Timer $Name not found.");
        }
        Else
        {
            $Results = $Global:Session.Logging.Timers.TimerCollection[$Name];
        }
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Session.Logging.Timers `
    -Name "WriteTimersFile" `
    -MemberType "ScriptMethod" `
    -Value {
            [Int32] $MaximumNameLength = 0;
            ForEach($Key In $Global:Session.Logging.Timers.TimerCollection.Keys)
            {
                If ($Key.Length -gt $MaximumNameLength)
                {
                    $MaximumNameLength = $Key.Length;
                }
            }
            Set-Content -Path $Global:Session.Logging.Timers.TimersFilePath `
                -Value (
                    "Name".PadRight($MaximumNameLength) + 
                    "  " + "Begin Time".PadRight(28) +
                    "  " + "End Time".PadRight(28) +
                    "  " + "Elapsed Seconds"
                );
            ForEach($Key In $Global:Session.Logging.Timers.TimerCollection.Keys)
            {
                Add-Content -Path $Global:Session.Logging.Timers.TimersFilePath `
                    -Value (
                        $Key.PadRight($MaximumNameLength) + 
                        "  " + $Global:Session.Logging.Timers.TimerCollection[$Key].BeginTime.ToString("yyyy-MM-dd HH:mm:ss.fffffffZ") +
                        "  " + $Global:Session.Logging.Timers.TimerCollection[$Key].EndTime.ToString("yyyy-MM-dd HH:mm:ss.fffffffZ") +
                        "  " + $Global:Session.Logging.Timers.TimerCollection[$Key].ElapsedTime.TotalSeconds.ToString()
                    );
            }
    };
Add-Member `
    -InputObject $Global:Session.Logging.Timers `
    -Name "GetTimersSimplified" `
    -MemberType "ScriptMethod" `
    -Value {
            [OutputType([Collections.Generic.List[PSObject]])]
            [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
            ForEach ($Key In $Global:Session.Logging.Timers.TimerOrder)
            {
                [void] $ReturnValue.Add([PSObject]@{
                    "Sequence" = ($Global:Session.Logging.Timers.TimerOrder.IndexOf($Key) + 1);
                    "Name" = $Key;
                    "BeginTime" = $Global:Session.Logging.Timers.TimerCollection[$Key].BeginTime.ToString("yyyy-MM-dd HH:mm:ss.fffffffZ");
                    "EndTime" = $Global:Session.Logging.Timers.TimerCollection[$Key].EndTime.ToString("yyyy-MM-dd HH:mm:ss.fffffffZ");
                    "ElapsedSeconds" = $Global:Session.Logging.Timers.TimerCollection[$Key].ElapsedTime.TotalSeconds.ToString();
                });
            }
            Return $ReturnValue;
    };
#endregion Timers

#region Config
Add-Member `
    -InputObject $Global:Session.Logging `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Config" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.Logging.Config `
    -TypeName "System.Boolean" `
    -NotePropertyName "IsSavedToDatabase" `
    -NotePropertyValue $null;
Add-Member `
    -InputObject $Global:Session.Logging.Config `
    -TypeName "System.String" `
    -NotePropertyName "DatabaseType" `
    -NotePropertyValue $null;
Add-Member `
    -InputObject $Global:Session.Logging.Config `
    -TypeName "String" `
    -NotePropertyName "DatabaseConnectionName" `
    -NotePropertyValue $null;
Add-Member `
    -InputObject $Global:Session.Logging.Config `
    -TypeName "Int32" `
    -NotePropertyName "RetentionDays" `
    -NotePropertyValue $Config.RetentionDays;
Add-Member `
    -InputObject $Global:Session.Logging.Config `
    -TypeName "String[]" `
    -NotePropertyName "EmailRecipients" `
    -NotePropertyValue $Config.EmailRecipients;
Add-Member `
    -InputObject $Global:Session.Logging.Config `
    -TypeName "String" `
    -NotePropertyName "SMTPConnectionName" `
    -NotePropertyValue $Config.SMTPConnectionName;
Add-Member `
    -InputObject $Global:Session.Logging.Config `
    -Name "SetDatabaseConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [String] $ConnectionName
        )
        $Global:Session.Logging.Config.DatabaseConnectionName = $ConnectionName;
        [PSCustomObject] $Connection = $Global:Session.Connections.Get($Global:Session.Logging.Config.DatabaseConnectionName);
        [String] $DatabaseType = $Connection.Type;
        $Global:Session.Logging.Config.DatabaseType = $DatabaseType
        . ([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), $Global:Session.Logging.Config.DatabaseType, "Data.ps1"));
    }
Add-Member `
    -InputObject $Global:Session.Logging.Config `
    -Name "Save" `
    -MemberType "ScriptMethod" `
    -Value {
        ConvertTo-Json -InputObject @{
            "RetentionDays" = $Global:Session.Logging.Config.RetentionDays
            "EmailRecipients" = $Global:Session.Logging.Config.EmailRecipients
            "SMTPConnectionName" = $Global:Session.Logging.Config.SMTPConnectionName
        } | Set-Content -Path $Global:Session.Logging.ConfigFilePath;
    };
#endregion Config

#region Methods
Add-Member `
    -InputObject $Global:Session.Logging `
    -Name "GetNextLogFile" `
    -MemberType "ScriptMethod" `
    -Value {
            [OutputType([Collections.Hashtable])]
            Param
            (
                [Parameter(Mandatory=$false)]
                [ValidateSet("Information", "Warning", "Error", "Debug", "Fatal")]
                [String] $Level,

                [Parameter(Mandatory=$false)]
                [String] $DataFileExtension
            )
            $Global:Session.Logging.LastLogFileNumber ++;
            $DataFileExtension = ([String]::IsNullOrEmpty($DataFileExtension) ? "txt" : $DataFileExtension);
            [String] $FileNumber = $Global:Session.Logging.LastLogFileNumber.ToString().PadLeft(3, "0");
            Return [Collections.Hashtable]@{
                "Name" = [String]::Format(
                        $Global:Session.Logging.LogFileNameTemplate,
                        $FileNumber,
                        $Level.ToUpper()
                    );
                "Path" = [String]::Format(
                        $Global:Session.Logging.LogFilePathTemplate,
                        $FileNumber,
                        $Level.ToUpper()
                    );
                "DataPath" = [IO.Path]::ChangeExtension(
                        [String]::Format(
                                $Global:Session.Logging.LogFilePathTemplate,
                                $FileNumber,
                                [String]::Format("{0}_DATA", $Level.ToUpper())
                            ),
                        $DataFileExtension
                    );
            };
    };
Add-Member `
    -InputObject $Global:Session.Logging `
    -Name "WriteEntry" `
    -MemberType "ScriptMethod" `
    -Value {
            Param
            (
                [Parameter(Mandatory=$false)]
                [ValidateSet("Information", "Warning", "Error", "Debug", "Fatal")]
                [String] $Level,

                [Parameter(Mandatory=$true)]
                [String] $Text,

                [Parameter(Mandatory=$true)]
                [String[]] $SupplementalFilePaths
            )
            $Global:Session.Logging.LastEntryNumber ++;
            [DateTime] $EntryTime = [DateTime]::UtcNow;
            [void] $Global:Session.Logging.Entries.Add(@{
                "Number" = $Global:Session.Logging.LastEntryNumber;
                "EntryTime" = $EntryTime;
                "Level" = $Level;
                "Text" = $Text;
                "SupplementalFilePath" = $SupplementalFilePaths;
            });
            [String] $LogLine = [String]::Format("{0}`t{1}`t{2}",
                $EntryTime.ToString("yyyy-MM-dd HH:mm:ss.fffffffZ"),
                $Level.PadRight(11).ToUpper(),
                $Text
            );
            If ([IO.File]::Exists($Global:Session.Logging.CurrentLogFilePath))
            {
                Add-Content -Path $Global:Session.Logging.CurrentLogFilePath -Value $LogLine;
            }
            If ($Global:Session.Logging.OutputToHost)
            {
                Switch ($Level)
                {
                    "Information" { Write-Host -Object $LogLine -ForegroundColor Green; }
                    "Warning" { Write-Host -Object $LogLine -ForegroundColor Yellow; }
                    "Error" { Write-Host -Object $LogLine -ForegroundColor Red; }
                    "Debug" { Write-Host -Object $LogLine -ForegroundColor Blue; }
                    "Fatal" { Write-Host -Object $LogLine -ForegroundColor Red -BackgroundColor White; }
                }
            }
            If ($Global:Session.Logging.LevelCounts)
            {
                Switch ($Level.ToUpper())
                {
                    "INFORMATION" { $Global:Session.Logging.LevelCounts.Information ++; }
                    "WARNING" { $Global:Session.Logging.LevelCounts.Warning ++; }
                    "ERROR" { $Global:Session.Logging.LevelCounts.Error ++; }
                    "DEBUG" { $Global:Session.Logging.LevelCounts.Debug ++; }
                    "FATAL" { $Global:Session.Logging.LevelCounts.Fatal ++; }
                }
            }
    };
Add-Member `
    -InputObject $Global:Session.Logging `
    -Name "WriteEntryWithData" `
    -MemberType "ScriptMethod" `
    -Value {
            Param
            (
                [Parameter(Mandatory=$false)]
                [ValidateSet("Information", "Warning", "Error", "Debug", "Fatal")]
                [String] $Level,

                [Parameter(Mandatory=$true)]
                [String] $Text,

                [Parameter(Mandatory=$true)]
                [String] $AdditionalData,

                [Parameter(Mandatory=$false)]
                [String] $DataFileExtension
            )
            [Collections.Hashtable] $File = $Global:Session.Logging.GetNextLogFile($Level, $DataFileExtension);
            [void] [IO.File]::WriteAllText($File.DataPath, $AdditionalData);
            [void] $Global:Session.Logging.WriteEntry($Level, [String]::Format("({0}) {1}", $File.Name, $Text), @( $File.DataPath ));
        };
Add-Member `
    -InputObject $Global:Session.Logging `
    -Name "WriteException" `
    -MemberType "ScriptMethod" `
    -Value {
            Param
            (
                [Parameter(Mandatory=$true)]
                [Exception] $Exception
            )
            [Collections.Hashtable] $ExceptionFile = $Global:Session.Logging.GetNextLogFile("Error");
            [void] [IO.File]::WriteAllText($ExceptionFile.Path, $Exception.ToString());
            [void] $Global:Session.Logging.WriteEntry("Error", "(" + $ExceptionFile.Name + ") " + $Exception.Message, @( $ExceptionFile.Path ));
    };
Add-Member `
    -InputObject $Global:Session.Logging `
    -Name "WriteExceptionWithData" `
    -MemberType "ScriptMethod" `
    -Value {
            Param
            (
                [Parameter(Mandatory=$true)]
                [Exception] $Exception,

                [Parameter(Mandatory=$true)]
                [String] $AdditionalData,

                [Parameter(Mandatory=$false)]
                [String] $DataFileExtension
            )
            [Collections.Hashtable] $File = $Global:Session.Logging.GetNextLogFile("Error", $DataFileExtension);
            [void] [IO.File]::WriteAllText($File.Path, $Exception.ToString());
            [void] [IO.File]::WriteAllText($File.DataPath, $AdditionalData);
            [void] $Global:Session.Logging.WriteEntry("Error", [String]::Format("({0}) {1}", $File.Name, $Exception.Message), @( $File.Path, $File.DataPath ));
    };
Add-Member `
    -InputObject $Global:Session.Logging `
    -Name "WriteVariableSet" `
    -MemberType "ScriptMethod" `
    -Value {
            Param
            (
                [Parameter(Mandatory=$true)]
                [String] $Name,

                [Parameter(Mandatory=$true)]
                [Object] $Value
            )
            [void] $Global:Session.Logging.WriteEntry("Information", [String]::Format("Variable Set {0} = {1}", $Name, $Value), $null);
    };
Add-Member `
    -InputObject $Global:Session.Logging `
    -Name "Close" `
    -MemberType "ScriptMethod" `
    -Value {
        If ([IO.File]::Exists($Global:Session.Logging.CurrentLogFilePath))
        {
            [void] $Global:Session.Logging.WriteEntry("Information", "Timer data written to " + $Global:Session.Logging.Timers.TimersFilePath);
            $Global:Session.Logging.CloseLogTime = [DateTime]::UtcNow;
            $Global:Session.Logging.ElapsedLogTime = $Global:Session.Logging.CloseLogTime - $Global:Session.Logging.OpenLogTime;
            [void] $Global:Session.Logging.Timers.AddWithTimes("Total Log Time", $Global:Session.Logging.OpenLogTime, $Global:Session.Logging.CloseLogTime);
            [void] $Global:Session.Logging.Timers.WriteTimersFile();
            [void] $Global:Session.Logging.WriteEntry("Information", ("Total Log Time (Minutes): " + $Global:Session.Logging.ElapsedLogTime.TotalMinutes.ToString()), $null);
            [void] $Global:Session.Logging.WriteEntry("Information", "Closing Log", $null);
            [System.Collections.Specialized.OrderedDictionary] $LogObject = ([ordered]@{
                "Log" = [ordered]@{
                    "LogGUID" = $Global:Session.Logging.LogGUID;
                    "OpenLogTime" = $Global:Session.Logging.OpenLogTime;
                    "CloseLogTime" = $Global:Session.Logging.CloseLogTime;
                    "Project" = $Global:Session.Project;
                    "Script" = $Global:Session.Script;
                    "ScriptFilePath" = $Global:Session.ScriptFilePath;
                    "Host" = $Global:Session.Host;
                };
                "Variables" = $Global:Session.Variables.Dictionary;
                "Timers" = $Global:Session.Logging.Timers.GetTimersSimplified();
                "Entries" = $Global:Session.Logging.Entries;
            })
            [String] $LogJSON = ConvertTo-Json -Depth 100 -InputObject $LogObject;
            Set-Content -Path $Global:Session.Logging.JSONFilePath -Value $LogJSON;
            If ($Global:Session.Logging.Config.IsSavedToDatabase)
            {
                [void] $Global:Session.Logging.Data.SaveToDatabase($LogJSON);
            }
        }
    };
Add-Member `
    -InputObject $Global:Session.Logging `
    -Name "ClearLogs" `
    -MemberType "ScriptMethod" `
    -Value {
        If ($Global:Session.Logging.Config.RetentionDays -ne 0)
        {
            [DateTime] $DeleteOlderThan = [DateTime]::UtcNow.AddDays(-$Global:Session.Logging.Config.RetentionDays);
            ForEach ($File In (Get-ChildItem -Path $Global:Session.Logging.DirectoryPath -Filter "*.*"))
            {
                If ($File.Name.Length -ge 15)
                {
                    [String] $FileTimestamp = $File.Name.Substring(0, 15);
                    [DateTime] $FileNameTime = [DateTime]::MaxValue;
                    [DateTime] $ResultDateTime = [DateTime]::MaxValue;
                    If ([DateTime]::TryParseExact(
                        $FileTimestamp, "yyyyMMdd_HHmmss",
                        [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None,
                        [ref]$ResultDateTime))
                    {
                        $FileNameTime = $ResultDateTime;
                    }
                    If ($FileNameTime -lt $DeleteOlderThan)
                    {
                        [void] $File.Delete();
                    }
                }
            }
            If ($Global:Session.Logging.Config.IsSavedToDatabase)
            {
                [void] $Global:Session.Logging.Data.ClearDatabaseLogs();
            }
        }
    };
Add-Member `
    -InputObject $Global:Session.Logging `
    -Name "Send" `
    -MemberType "ScriptMethod" `
    -Value {
        If ([IO.File]::Exists($Global:Session.Logging.CurrentLogFilePath))
        {
            [System.Net.Mail.SmtpClient] $SmtpClient = Get-SMTPConnection -Name ($Global:Session.Logging.Config.SMTPConnectionName);
            [System.Net.Mail.MailMessage] $MailMessage = [System.Net.Mail.MailMessage]::new();
            $MailMessage.From = $SmtpClient.Credentials.UserName;
            ForEach ($EmailRecipient In $Global:Session.Logging.Config.EmailRecipients)
            {
                [void] $MailMessage.To.Add($EmailRecipient);
            }
            $MailMessage.Subject = "$Name Logging Alert";
            [String] $Body = "Logging Alert for $Name";
            If ($Global:Session.Logging.LevelCounts)
            {
                $Body += "`n`nENTRY LEVEL COUNTS";
                $Body += ("`nInformation: " + $Global:Session.Logging.LevelCounts.Information.ToString());
                $Body += ("`nWarning: " + $Global:Session.Logging.LevelCounts.Warning.ToString());
                $Body += ("`nError: " + $Global:Session.Logging.LevelCounts.Error.ToString());
                $Body += ("`nDebug: " + $Global:Session.Logging.LevelCounts.Debug.ToString());
                $Body += ("`nFatal: " + $Global:Session.Logging.LevelCounts.Fatal.ToString());
            }
            $Body += ("`n`nLog File Attached: " + [IO.Path]::GetFileName($Global:Session.Logging.CurrentLogFilePath));
            $MailMessage.Body = $Body;
            [void] $MailMessage.Attachments.Add($Global:Session.Logging.CurrentLogFilePath);
            [void] $SmtpClient.Send($MailMessage);
        }
    };
Add-Member `
    -InputObject $Global:Session.Logging `
    -Name "TimedExecute" `
    -MemberType "ScriptMethod" `
    -Value {
        [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [ScriptBlock] $ScriptBlock
        )
        [void] $Global:Session.Logging.WriteEntry("Information", [String]::Format("Executing {0}", $Name));
        [void] $Global:Session.Logging.Timers.Add($Name);
        [void] $Global:Session.Logging.Timers.Start($Name);
        [void] $ScriptBlock.Invoke();
        [void] $Global:Session.Logging.Timers.Stop($Name);
    };
#endregion Methods

$Global:Session.Logging.OpenLogTime = [DateTime]::UtcNow;
Set-Content -Path $Global:Session.Logging.CurrentLogFilePath -Value "Time`tLevel`tMessage";

If (![String]::IsNullOrEmpty($Config.DatabaseConnectionName))
{
    $Global:Session.Logging.Config.IsSavedToDatabase = $true;
    [void] $Global:Session.Logging.Config.SetDatabaseConnection($Config.DatabaseConnectionName);
    [void] $Global:Session.Logging.Data.VerifyDatabase();
}
Else
{
    $Global:Session.Logging.Config.IsSavedToDatabase = $false;
}
[void] $Global:Session.Logging.WriteEntry("Information", "Opening Log", $null);
