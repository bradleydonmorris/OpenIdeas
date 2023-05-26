#This script creates methods to manage logs
# that are stored in the Logs directory
# which should be specified in the ".jobs-config.json".

If (![IO.Directory]::Exists($Global:Job.Directories.LogsRoot))
{
    [void] [IO.Directory]::CreateDirectory($Global:Job.Directories.LogsRoot);
}
[String] $DirectoryPath = [IO.Path]::Combine($Global:Job.Directories.LogsRoot, $Global:Job.Collection, $Global:Job.Script);
[String] $ConfigFilePath = [IO.Path]::Combine($DirectoryPath, ".config.json");
If (![IO.Directory]::Exists($DirectoryPath))
{
    [void] [IO.Directory]::CreateDirectory($DirectoryPath);
}
If (![IO.File]::Exists($ConfigFilePath))
{
    ConvertTo-Json -InputObject @{
        "RetentionDays" = $Global:Job.LoggingDefaults.RetentionDays
        "EmailRecipients" = $Global:Job.LoggingDefaults.EmailRecipients
        "SMTPConnectionName" = $Global:Job.LoggingDefaults.SMTPConnectionName
    } | Set-Content -Path $ConfigFilePath;
}
$Config = ConvertFrom-Json -InputObject (Get-Content -Path $ConfigFilePath -Raw) -Depth 20;
Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Logging" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "System.DateTime" `
    -NotePropertyName "OpenLogTime" `
    -NotePropertyValue ([DateTime]::MinValue);
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "System.DateTime" `
    -NotePropertyName "CloseLogTime" `
    -NotePropertyValue ([DateTime]::MinValue);
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "System.TimeSpan" `
    -NotePropertyName "ElapsedLogTime" `
    -NotePropertyValue ([DateTime]::MinValue);
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Config" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "String" `
    -NotePropertyName "DirectoryPath" `
    -NotePropertyValue $DirectoryPath;
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "String" `
    -NotePropertyName "ConfigFilePath" `
    -NotePropertyValue $ConfigFilePath;
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "String" `
    -NotePropertyName "LogFileTimestamp" `
    -NotePropertyValue ([DateTime]::UtcNow.ToString("yyyyMMdd_HHmmss"));
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "String" `
    -NotePropertyName "LogFileNameTemplate" `
    -NotePropertyValue ($Global:Job.Logging.LogFileTimestamp + ".{0}.{1}.txt");
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "String" `
    -NotePropertyName "LogFilePathTemplate" `
    -NotePropertyValue ([IO.Path]::Combine($Global:Job.Logging.DirectoryPath, ($Global:Job.Logging.LogFileTimestamp + ".{0}.{1}.txt")));
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "Int32" `
    -NotePropertyName "LastLogFileNumber" `
    -NotePropertyValue (0);
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "String" `
    -NotePropertyName "CurrentLogFilePath" `
    -NotePropertyValue ([IO.Path]::Combine(
        $Global:Job.Logging.DirectoryPath, 
        [String]::Format(
            $Global:Job.Logging.LogFilePathTemplate,
            "000",
            "LOG"
        )
    ));
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "String" `
    -NotePropertyName "JSONFilePath" `
    -NotePropertyValue ([IO.Path]::Combine(
        $Global:Job.Logging.DirectoryPath,
        [String]::Format(
            "{0}.json",
            $Global:Job.Logging.LogFileTimestamp
        )
    ));
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "Int32" `
    -NotePropertyName "LastEntryNumber" `
    -NotePropertyValue (0);
Add-Member `
    -InputObject $Global:Job.Logging.Config `
    -TypeName "Int32" `
    -NotePropertyName "RetentionDays" `
    -NotePropertyValue $Config.RetentionDays;
Add-Member `
    -InputObject $Global:Job.Logging.Config `
    -TypeName "String[]" `
    -NotePropertyName "EmailRecipients" `
    -NotePropertyValue $Config.EmailRecipients;
Add-Member `
    -InputObject $Global:Job.Logging.Config `
    -TypeName "String" `
    -NotePropertyName "SMTPConnectionName" `
    -NotePropertyValue $Config.SMTPConnectionName;
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "LevelCounts" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Logging.LevelCounts `
    -TypeName "Int32" `
    -NotePropertyName "Information" `
    -NotePropertyValue 0;
Add-Member `
    -InputObject $Global:Job.Logging.LevelCounts `
    -TypeName "Int32" `
    -NotePropertyName "Warning" `
    -NotePropertyValue 0;
Add-Member `
    -InputObject $Global:Job.Logging.LevelCounts `
    -TypeName "Int32" `
    -NotePropertyName "Error" `
    -NotePropertyValue 0;
Add-Member `
    -InputObject $Global:Job.Logging.LevelCounts `
    -TypeName "Int32" `
    -NotePropertyName "Debug" `
    -NotePropertyValue 0;
Add-Member `
    -InputObject $Global:Job.Logging.LevelCounts `
    -TypeName "Int32" `
    -NotePropertyName "Fatal" `
    -NotePropertyValue 0;
    Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "System.Collections.ArrayList" `
    -NotePropertyName "Entries" `
    -NotePropertyValue ([System.Collections.ArrayList]::new());
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "System.Collections.Hashtable" `
    -NotePropertyName "Variables" `
    -NotePropertyValue ([System.Collections.Hashtable]::new());
Add-Member `
    -InputObject $Global:Job.Logging `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Timers" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

#region Timers
Add-Member `
    -InputObject $Global:Job.Logging.Timers `
    -TypeName "System.Collections.Hashtable" `
    -NotePropertyName "TimerCollection" `
    -NotePropertyValue ([Collections.Hashtable]::new());
Add-Member `
    -InputObject $Global:Job.Logging.Timers `
    -TypeName "System.Collections.ArrayList" `
    -NotePropertyName "TimerOrder" `
    -NotePropertyValue ([Collections.ArrayList]::new());
Add-Member `
    -InputObject $Global:Job.Logging.Timers `
    -TypeName "String" `
    -NotePropertyName "TimersFilePath" `
    -NotePropertyValue ([IO.Path]::Combine(
        $Global:Job.Logging.DirectoryPath, 
        [String]::Format(
            $Global:Job.Logging.LogFilePathTemplate,
            "000",
            "TIMERS"
        )
    ));
Add-Member `
    -InputObject $Global:Job.Logging.Timers `
    -Name "Add" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$false)]
            [String] $Name
        )
        If ($Global:Job.Logging.Timers.TimerCollection.ContainsKey($Name))
        {
            Throw [Exception]::new("Timer $Name already exists.");
        }
        Else
        {
            [void] $Global:Job.Logging.Timers.TimerOrder.Add($Name);
            [void] $Global:Job.Logging.Timers.TimerCollection.Add($Name, @{
                "BeginTime" = [DateTime]::UtcNow;
                "EndTime" = [DateTime]::MinValue;
                "ElapsedTime" = [TimeSpan]::MinValue;
                "State" = "Not Started";
            });
        }
    };
Add-Member `
    -InputObject $Global:Job.Logging.Timers `
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
        If ($Global:Job.Logging.Timers.TimerCollection.ContainsKey($Name))
        {
            Throw [Exception]::new("Timer $Name already exists.");
        }
        Else
        {
            [void] $Global:Job.Logging.Timers.TimerOrder.Add($Name);
            [void] $Global:Job.Logging.Timers.TimerCollection.Add($Name, @{
                "BeginTime" = $BeginTime;
                "EndTime" = $EndTime;
                "ElapsedTime" = ($EndTime - $BeginTime);
                "State" = "Stopped";
            });
        }
    };
Add-Member `
    -InputObject $Global:Job.Logging.Timers `
    -Name "Start" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$false)]
            [String] $Name
        )
        If (!$Global:Job.Logging.Timers.TimerCollection.ContainsKey($Name))
        {
            Throw [Exception]::new("Timer $Name not found.");
        }
        ElseIf ($Global:Job.Logging.Timers.TimerCollection[$Name].State -eq "Started")
        {
            Throw [Exception]::new("Timer $Name already started.");
        }
        ElseIf ($Global:Job.Logging.Timers.TimerCollection[$Name].State -eq "Stopped")
        {
            Throw [Exception]::new("Timer $Name already stopped.");
        }
        Else
        {
            $Global:Job.Logging.Timers.TimerCollection[$Name].BeginTime = [DateTime]::UtcNow;
            $Global:Job.Logging.Timers.TimerCollection[$Name].EndTime = [DateTime]::MinValue;
            $Global:Job.Logging.Timers.TimerCollection[$Name].ElapsedTime = [TimeSpan]::MinValue;
            $Global:Job.Logging.Timers.TimerCollection[$Name].State = "Started";
        }
    };
Add-Member `
    -InputObject $Global:Job.Logging.Timers `
    -Name "Stop" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$false)]
            [String] $Name
        )
        If (!$Global:Job.Logging.Timers.TimerCollection.ContainsKey($Name))
        {
            Throw [Exception]::new("Timer $Name not found.");
        }
        ElseIf ($Global:Job.Logging.Timers.TimerCollection[$Name].State -eq "Created")
        {
            Throw [Exception]::new("Timer $Name not started.");
        }
        ElseIf ($Global:Job.Logging.Timers.TimerCollection[$Name].State -eq "Stopped")
        {
            Throw [Exception]::new("Timer $Name already stopped.");
        }
        Else
        {
            $Global:Job.Logging.Timers.TimerCollection[$Name].EndTime = [DateTime]::UtcNow;
            $Global:Job.Logging.Timers.TimerCollection[$Name].ElapsedTime = (
                $Global:Job.Logging.Timers.TimerCollection[$Name].EndTime -
                $Global:Job.Logging.Timers.TimerCollection[$Name].BeginTime
            );
            $Global:Job.Logging.Timers.TimerCollection[$Name].State = "Stopped";
        }
    };
Add-Member `
    -InputObject $Global:Job.Logging.Timers `
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
        If (!$Global:Job.Logging.Timers.TimerCollection.ContainsKey($Name))
        {
            Throw [Exception]::new("Timer $Name not found.");
        }
        Else
        {
            $Results = $Global:Job.Logging.Timers.TimerCollection[$Name];
        }
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.Logging.Timers `
    -Name "WriteTimersFile" `
    -MemberType "ScriptMethod" `
    -Value {
            [Int32] $MaximumNameLength = 0;
            ForEach($Key In $Global:Job.Logging.Timers.TimerCollection.Keys)
            {
                If ($Key.Length -gt $MaximumNameLength)
                {
                    $MaximumNameLength = $Key.Length;
                }
            }
            Set-Content -Path $Global:Job.Logging.Timers.TimersFilePath `
                -Value (
                    "Name".PadRight($MaximumNameLength) + 
                    "  " + "Begin Time".PadRight(28) +
                    "  " + "End Time".PadRight(28) +
                    "  " + "Elapsed Seconds"
                );
            ForEach($Key In $Global:Job.Logging.Timers.TimerCollection.Keys)
            {
                Add-Content -Path $Global:Job.Logging.Timers.TimersFilePath `
                    -Value (
                        $Key.PadRight($MaximumNameLength) + 
                        "  " + $Global:Job.Logging.Timers.TimerCollection[$Key].BeginTime.ToString("yyyy-MM-dd HH:mm:ss.fffffffZ") +
                        "  " + $Global:Job.Logging.Timers.TimerCollection[$Key].EndTime.ToString("yyyy-MM-dd HH:mm:ss.fffffffZ") +
                        "  " + $Global:Job.Logging.Timers.TimerCollection[$Key].ElapsedTime.TotalSeconds.ToString("N10")
                    );
            }
    };
Add-Member `
    -InputObject $Global:Job.Logging.Timers `
    -Name "GetTimersSimplified" `
    -MemberType "ScriptMethod" `
    -Value {
            [OutputType([Collections.ArrayList])]
            [Collections.ArrayList] $ReturnValue = [Collections.ArrayList]::new();
            #ForEach ($Key In $Global:Job.Logging.Timers.TimerCollection.Keys)
            ForEach ($Key In $Global:Job.Logging.Timers.TimerOrder)
            {
                [void] $ReturnValue.Add(@{
                    "Sequence" = ($Global:Job.Logging.Timers.TimerOrder.IndexOf($Key) + 1);
                    "Name" = $Key;
                    "BeginTime" = $Global:Job.Logging.Timers.TimerCollection[$Key].BeginTime.ToString("yyyy-MM-dd HH:mm:ss.fffffffZ");
                    "EndTime" = $Global:Job.Logging.Timers.TimerCollection[$Key].EndTime.ToString("yyyy-MM-dd HH:mm:ss.fffffffZ");
                    "ElapsedSeconds" = $Global:Job.Logging.Timers.TimerCollection[$Key].ElapsedTime.TotalSeconds.ToString("N10");
                });
            }
            Return $ReturnValue;
    };
#endregion Timers

Add-Member `
    -InputObject $Global:Job.Logging.Config `
    -Name "Save" `
    -MemberType "ScriptMethod" `
    -Value {
        ConvertTo-Json -InputObject @{
            "RetentionDays" = $Global:Job.Logging.Config.RetentionDays
            "EmailRecipients" = $Global:Job.Logging.Config.EmailRecipients
            "SMTPConnectionName" = $Global:Job.Logging.Config.SMTPConnectionName
        } | Set-Content -Path $Global:Job.Logging.ConfigFilePath;
    };
Add-Member `
    -InputObject $Global:Job.Logging `
    -Name "WriteEntry" `
    -MemberType "ScriptMethod" `
    -Value {
            Param
            (
                [Parameter(Mandatory=$false)]
                [ValidateSet("Information", "Warning", "Error", "Debug", "Fatal")]
                [String] $Level,

                [Parameter(Mandatory=$true)]
                [String] $Text
            )
            $Global:Job.Logging.LastEntryNumber ++;
            [void] $Global:Job.Logging.Entries.Add(@{
                "Number" = $Global:Job.Logging.LastEntryNumber;
                "Level" = $Level;
                "Text" = $Text;
            });
            If ([IO.File]::Exists($Global:Job.Logging.CurrentLogFilePath))
            {
                Add-Content -Path $Global:Job.Logging.CurrentLogFilePath -Value ([DateTime]::UtcNow.ToString("yyyy-MM-dd HH:mm:ss.fffffffZ") + "`t" + $Level.PadRight(11).ToUpper() + "`t" + $Text);
            }
            If ($Global:Job.Logging.LevelCounts)
            {
                Switch ($Level.ToUpper())
                {
                    "INFORMATION" { $Global:Job.Logging.LevelCounts.Information ++; }
                    "WARNING" { $Global:Job.Logging.LevelCounts.Warning ++; }
                    "ERROR" { $Global:Job.Logging.LevelCounts.Error ++; }
                    "DEBUG" { $Global:Job.Logging.LevelCounts.Debug ++; }
                    "FATAL" { $Global:Job.Logging.LevelCounts.Fatal ++; }
                }
            }
    };
Add-Member `
    -InputObject $Global:Job.Logging `
    -Name "GetNextLogFile" `
    -MemberType "ScriptMethod" `
    -Value {
            [OutputType([Collections.Hashtable])]
            Param
            (
                [Parameter(Mandatory=$true)]
                [Exception] $Exception
            )
            $Global:Job.Logging.LastLogFileNumber ++;
            [String] $FileNumber = $Global:Job.Logging.LastLogFileNumber.ToString().PadLeft(3, "0");
            Return [Collections.Hashtable]@{
                "Name" = [String]::Format(
                        $Global:Job.Logging.LogFileNameTemplate,
                        $FileNumber,
                        "EXCEPTION"
                    );
                "Path" = [String]::Format(
                        $Global:Job.Logging.LogFilePathTemplate,
                        $FileNumber,
                        "EXCEPTION"
                    );
                "DataPath" = [String]::Format(
                        $Global:Job.Logging.LogFilePathTemplate,
                        $FileNumber,
                        "EXCEPTION_DATA"
                    );
            };
    };
Add-Member `
    -InputObject $Global:Job.Logging `
    -Name "WriteException" `
    -MemberType "ScriptMethod" `
    -Value {
            Param
            (
                [Parameter(Mandatory=$true)]
                [Exception] $Exception
            )
            [Collections.Hashtable] $ExceptionFile = $Global:Job.Logging.GetNextLogFile();
            [IO.File]::WriteAllText($ExceptionFile.Path, $Exception.ToString());
            $Global:Job.Logging.WriteEntry("Error", "(" + $ExceptionFile.Name + ") " + $Exception.Message);
    };
Add-Member `
    -InputObject $Global:Job.Logging `
    -Name "WriteExceptionWithData" `
    -MemberType "ScriptMethod" `
    -Value {
            Param
            (
                [Parameter(Mandatory=$true)]
                [Exception] $Exception,

                [Parameter(Mandatory=$true)]
                [String] $AdditionalData
            )
            [Collections.Hashtable] $ExceptionFile = $Global:Job.Logging.GetNextLogFile();
            [IO.File]::WriteAllText($ExceptionFile.Path, $Exception.ToString());
            [IO.File]::WriteAllText($ExceptionFile.DataPath, $AdditionalData);
            $Global:Job.Logging.WriteEntry("Error", "(" + $ExceptionFile.Name + ") " + $Exception.Message);
    };
Add-Member `
    -InputObject $Global:Job.Logging `
    -Name "WriteVariables" `
    -MemberType "ScriptMethod" `
    -Value {
            Param
            (
                [Parameter(Mandatory=$false)]
                [String] $SetName,
        
                [Parameter(Mandatory=$true)]
                [Collections.Hashtable] $Variables
            )
            $SetName = ([String]::IsNullOrEmpty($SetName)) ? "Variables" : $SetName;
            [void] $Global:Job.Logging.Variables.Add($SetName, $Variables);
            ForEach ($Key In $Variables.Keys)
            {
                $Global:Job.Logging.WriteEntry("Information", ($SetName + ": " + $Key + " = " + $Variables[$Key]))
            }
    };
Add-Member `
    -InputObject $Global:Job.Logging `
    -Name "Close" `
    -MemberType "ScriptMethod" `
    -Value {
        If ([IO.File]::Exists($Global:Job.Logging.CurrentLogFilePath))
        {
            $Global:Job.Logging.WriteEntry("Information", "Timer data written to " + $Global:Job.Logging.Timers.TimersFilePath);
            $Global:Job.Logging.CloseLogTime = [DateTime]::UtcNow;
            $Global:Job.Logging.ElapsedLogTime = $Global:Job.Logging.CloseLogTime - $Global:Job.Logging.OpenLogTime;
            $Global:Job.Logging.Timers.AddWithTimes("Total Log Time", $Global:Job.Logging.OpenLogTime, $Global:Job.Logging.CloseLogTime);
            $Global:Job.Logging.Timers.WriteTimersFile();
            $Global:Job.Logging.WriteEntry("Information", ("Total Log Time (Minutes): " + $Global:Job.Logging.ElapsedLogTime.TotalMinutes.ToString()));
            $Global:Job.Logging.WriteEntry("Information", "Closing Log");
            Set-Content -Path $Global:Job.Logging.JSONFilePath `
                -Value (ConvertTo-Json -Depth 100 -InputObject (@{
                    "Variables" = $Global:Job.Logging.Variables;
                    "Timers" = $Global:Job.Logging.Timers.GetTimersSimplified();
                    "Entries" = $Global:Job.Logging.Entries;
                }));
        }
    };
Add-Member `
    -InputObject $Global:Job.Logging `
    -Name "ClearLogs" `
    -MemberType "ScriptMethod" `
    -Value {
        If ($Global:Job.Logging.Config.RetentionDays -ne 0)
        {
            [DateTime] $DeleteOlderThan = [DateTime]::UtcNow.AddDays(-$Global:Job.Logging.Config.RetentionDays);
            ForEach ($File In (Get-ChildItem -Path "C:\JobsWorkspace\Logs\Informatica\Export" -Filter "*.*"))
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
                        $File.Delete();
                    }
                }
            }
        }
    };
Add-Member `
    -InputObject $Global:Job.Logging `
    -Name "Send" `
    -MemberType "ScriptMethod" `
    -Value {
        If ([IO.File]::Exists($Global:Job.Logging.CurrentLogFilePath))
        {
            [System.Net.Mail.SmtpClient] $SmtpClient = Get-SMTPConnection -Name ($Global:Job.Logging.Config.SMTPConnectionName);
            [System.Net.Mail.MailMessage] $MailMessage = [System.Net.Mail.MailMessage]::new();
            $MailMessage.From = $SmtpClient.Credentials.UserName;
            ForEach ($EmailRecipient In $Global:Job.Logging.Config.EmailRecipients)
            {
                [void] $MailMessage.To.Add($EmailRecipient);
            }
            $MailMessage.Subject = "$Name Logging Alert";
            [String] $Body = "Logging Alert for $Name";
            If ($Global:Job.Logging.LevelCounts)
            {
                $Body += "`n`nENTRY LEVEL COUNTS";
                $Body += ("`nInformation: " + $Global:Job.Logging.LevelCounts.Information.ToString());
                $Body += ("`nWarning: " + $Global:Job.Logging.LevelCounts.Warning.ToString());
                $Body += ("`nError: " + $Global:Job.Logging.LevelCounts.Error.ToString());
                $Body += ("`nDebug: " + $Global:Job.Logging.LevelCounts.Debug.ToString());
                $Body += ("`nFatal: " + $Global:Job.Logging.LevelCounts.Fatal.ToString());
            }
            $Body += ("`n`nLog File Attached: " + [IO.Path]::GetFileName($Global:Job.Logging.CurrentLogFilePath));
            $MailMessage.Body = $Body;
            [void] $MailMessage.Attachments.Add($Global:Job.Logging.CurrentLogFilePath);
            $SmtpClient.Send($MailMessage);
        }
    };
Add-Member `
    -InputObject $Global:Job.Logging `
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
    -InputObject $Global:Job.Logging `
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




Set-Content -Path $Global:Job.Logging.CurrentLogFilePath -Value ([DateTime]::UtcNow.ToString("yyyy-MM-dd HH:mm:ss.fffffffZ") + "`tINFORMATION`tOpening Log");
$Global:Job.Logging.OpenLogTime = [DateTime]::UtcNow;
