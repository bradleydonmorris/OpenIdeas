[void] $Global:Session.LoadModule("Utilities");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "GnuPG" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.GnuPG `
    -TypeName "String" `
    -NotePropertyName "ExecutablePath" `
    -NotePropertyValue "C:\Program Files (x86)\GnuPG\bin\gpg.exe";
Add-Member `
    -InputObject $Global:Session.GnuPG `
    -Name "GetPublicKeys" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $HomeDirectory
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [Collections.Generic.List[String]] $Arguments = [Collections.Generic.List[String]]::new();
        [void] $Arguments.Add("--list-keys");
        If (![String]::IsNullOrEmpty($HomeDirectory))
        {
            [void] $Arguments.Add("--homedir");
            [void] $Arguments.Add([String]::Format("`"{0}`"", $HomeDirectory));
        }
        [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
        $ProcessStartInfo.FileName = $Global:Session.GnuPG.ExecutablePath;
        $ProcessStartInfo.RedirectStandardError = $true
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
        $ProcessStartInfo.Arguments = [String]::Join(" ", $Arguments);
        [System.Diagnostics.Process] $Process = [System.Diagnostics.Process]::new()
        $Process.StartInfo = $ProcessStartInfo;
        [void] $Process.Start();
        [void] $Process.WaitForExit();
        [Boolean] $NextLineShouldBeFingureprint = $false;
        [Int32] $CurrentObjectIndex = (-1);
        ForEach ($Line In ($Process.StandardOutput.ReadToEnd() -split "`r`n"))
        {
            If ($Line.StartsWith("pub"))
            {
                $CurrentObjectIndex ++;
                [void] $ReturnValue.Add([PSObject]::new());
                $Line = $Line.Replace("  ", " ").Replace("  ", " ");
                [String[]] $Elements = $Line -split " ";
                Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                    -NotePropertyName "KeyType" -NotePropertyValue "Public";
                If ($Elements.Count -ge 1)
                {
                    Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                        -NotePropertyName "Algorithm" -NotePropertyValue $Elements[1];
                }
                If ($Elements.Count -ge 2)
                {
                    [DateTime] $IssueDate = [DateTime]::MinValue;
                    If ([DateTime]::TryParseExact(
                        $Elements[2], "yyyy-MM-dd",
                        [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None,
                        [ref]$IssueDate))
                    {
                        Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                            -NotePropertyName "IssueDate" -NotePropertyValue $IssueDate;
                    }
                }
                If ($Elements.Count -ge 5)
                {
                    [DateTime] $ExpiryDate = [DateTime]::MinValue;
                    If ([DateTime]::TryParseExact(
                        $Elements[5].Replace("]", ""), "yyyy-MM-dd",
                        [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None,
                        [ref]$ExpiryDate))
                    {
                        Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                            -NotePropertyName "ExpiryDate" -NotePropertyValue $ExpiryDate;
                    }
                }
                $NextLineShouldBeFingureprint = $true;
            }
            ElseIf ($Line.StartsWith("uid"))
            {
                [String] $Validity = $Global:Session.Utilities.SubstringBetween($Line, "[", "]").Trim();
                [String] $Comment = $Global:Session.Utilities.SubstringBetween($Line, "(", ")").Trim();
                [String] $EmailAddress = $Global:Session.Utilities.SubstringBetween($Line, "<", ">").Trim();
                [String] $Name = $null;
                If ($Line.Contains("]") -and $Line.Contains("("))
                {
                    $Name = $Global:Session.Utilities.SubstringBetween($Line, "]", "(").Trim();
                }
                ElseIf ($Line.Contains("]") -and $Line.Contains("<"))
                {
                    $Name = $Global:Session.Utilities.SubstringBetween($Line, "]", "<").Trim();
                }
                Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                    -NotePropertyName "Name" -NotePropertyValue $Name;
                Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                    -NotePropertyName "EmailAddress" -NotePropertyValue $EmailAddress;
                Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                    -NotePropertyName "Comment" -NotePropertyValue $Comment;
                Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                    -NotePropertyName "Validity" -NotePropertyValue $Validity;
            }
            Else
            {
                If ($NextLineShouldBeFingureprint)
                {
                    Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                        -NotePropertyName "Fingerprint" -NotePropertyValue $Line.Trim();
                    $NextLineShouldBeFingureprint = $false;
                }
            }
        }
        [void] $Process.Dispose();
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.GnuPG `
    -Name "GetPrivateKeys" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $HomeDirectory
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [Collections.Generic.List[String]] $Arguments = [Collections.Generic.List[String]]::new();
        [void] $Arguments.Add("--list-secret-keys");
        If (![String]::IsNullOrEmpty($HomeDirectory))
        {
            [void] $Arguments.Add("--homedir");
            [void] $Arguments.Add([String]::Format("`"{0}`"", $HomeDirectory));
        }
        [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
        $ProcessStartInfo.FileName = $Global:Session.GnuPG.ExecutablePath;
        $ProcessStartInfo.RedirectStandardError = $true
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
        $ProcessStartInfo.Arguments = [String]::Join(" ", $Arguments);
        [System.Diagnostics.Process] $Process = [System.Diagnostics.Process]::new()
        $Process.StartInfo = $ProcessStartInfo;
        [void] $Process.Start();
        [void] $Process.WaitForExit();
        [Boolean] $NextLineShouldBeFingureprint = $false;
        [Int32] $CurrentObjectIndex = (-1);
        ForEach ($Line In ($Process.StandardOutput.ReadToEnd() -split "`r`n"))
        {
            If ($Line.StartsWith("sec"))
            {
                $CurrentObjectIndex ++;
                [void] $ReturnValue.Add([PSObject]::new());
                $Line = $Line.Replace("  ", " ").Replace("  ", " ");
                [String[]] $Elements = $Line -split " ";
                Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                    -NotePropertyName "KeyType" -NotePropertyValue "Private";
                If ($Elements.Count -ge 1)
                {
                    Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                        -NotePropertyName "Algorithm" -NotePropertyValue $Elements[1];
                }
                If ($Elements.Count -ge 2)
                {
                    [DateTime] $IssueDate = [DateTime]::MinValue;
                    If ([DateTime]::TryParseExact(
                        $Elements[2], "yyyy-MM-dd",
                        [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None,
                        [ref]$IssueDate))
                    {
                        Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                            -NotePropertyName "IssueDate" -NotePropertyValue $IssueDate;
                    }
                }
                If ($Elements.Count -ge 5)
                {
                    [DateTime] $ExpiryDate = [DateTime]::MinValue;
                    If ([DateTime]::TryParseExact(
                        $Elements[5].Replace("]", ""), "yyyy-MM-dd",
                        [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None,
                        [ref]$ExpiryDate))
                    {
                        Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                            -NotePropertyName "ExpiryDate" -NotePropertyValue $ExpiryDate;
                    }
                }
                $NextLineShouldBeFingureprint = $true;
            }
            ElseIf ($Line.StartsWith("uid"))
            {
                [String] $Validity = $Global:Session.Utilities.SubstringBetween($Line, "[", "]").Trim();
                [String] $Comment = $Global:Session.Utilities.SubstringBetween($Line, "(", ")").Trim();
                [String] $EmailAddress = $Global:Session.Utilities.SubstringBetween($Line, "<", ">").Trim();
                [String] $Name = $null;
                If ($Line.Contains("]") -and $Line.Contains("("))
                {
                    $Name = $Global:Session.Utilities.SubstringBetween($Line, "]", "(").Trim();
                }
                ElseIf ($Line.Contains("]") -and $Line.Contains("<"))
                {
                    $Name = $Global:Session.Utilities.SubstringBetween($Line, "]", "<").Trim();
                }
                Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                    -NotePropertyName "Name" -NotePropertyValue $Name;
                Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                    -NotePropertyName "EmailAddress" -NotePropertyValue $EmailAddress;
                Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                    -NotePropertyName "Comment" -NotePropertyValue $Comment;
                Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                    -NotePropertyName "Validity" -NotePropertyValue $Validity;
            }
            Else
            {
                If ($NextLineShouldBeFingureprint)
                {
                    Add-Member -InputObject $ReturnValue[$CurrentObjectIndex] -TypeName "System.String" `
                        -NotePropertyName "Fingerprint" -NotePropertyValue $Line.Trim();
                    $NextLineShouldBeFingureprint = $false;
                }
            }
        }
        [void] $Process.Dispose();
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.GnuPG `
    -Name "GetKeys" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $HomeDirectory
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [Collections.Generic.List[PSObject]] $PrivateResults = $Global:Session.GnuPG.GetPrivateKeys($HomeDirectory);
        [Collections.Generic.List[PSObject]] $PublicResults = $Global:Session.GnuPG.GetPublicKeys($HomeDirectory);
        ForEach ($Key In $PrivateResults)
        {
            [void] $ReturnValue.Add($Key);
        }
        ForEach ($Key In $PublicResults)
        {
            [void] $ReturnValue.Add($Key);
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.GnuPG `
    -Name "AddPrivateKey" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath,

            [Parameter(Mandatory=$true)]
            [String] $Passphrase,

            [Parameter(Mandatory=$true)]
            [String] $HomeDirectory
        )
        If ([String]::IsNullOrEmpty($FilePath))
        {
            Throw [System.ArgumentException]::new("FilePath");
        }
        [Collections.Generic.List[String]] $Arguments = [Collections.Generic.List[String]]::new();
        [void] $Arguments.Add("--allow-secret-key-import");
        If (![String]::IsNullOrEmpty($Passphrase))
        {
            [void] $Arguments.Add("--pinentry-mode=loopback");
            [void] $Arguments.Add("--passphrase");
            [void] $Arguments.Add([String]::Format("`"{0}`"", $Passphrase));
        }
        If (![String]::IsNullOrEmpty($HomeDirectory))
        {
            [void] $Arguments.Add("--homedir");
            [void] $Arguments.Add([String]::Format("`"{0}`"", $HomeDirectory));
        }
        [void] $Arguments.Add("--import");
        [void] $Arguments.Add([String]::Format("`"{0}`"", $FilePath));
        [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
        $ProcessStartInfo.FileName = $Global:Session.GnuPG.ExecutablePath
        $ProcessStartInfo.RedirectStandardError = $true
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
        $ProcessStartInfo.Arguments = [String]::Join(" ", $Arguments);
        [System.Diagnostics.Process] $Process = [System.Diagnostics.Process]::new()
        $Process.StartInfo = $ProcessStartInfo;
        [void] $Process.Start();
        [void] $Process.WaitForExit();
        [void] $Process.Dispose();
    };
Add-Member `
    -InputObject $Global:Session.GnuPG `
    -Name "AddPublicKey" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath,

            [Parameter(Mandatory=$true)]
            [String] $HomeDirectory
        )
        If ([String]::IsNullOrEmpty($FilePath))
        {
            Throw [System.ArgumentException]::new("FilePath");
        }
        [Collections.Generic.List[String]] $Arguments = [Collections.Generic.List[String]]::new();
        If (![String]::IsNullOrEmpty($HomeDirectory))
        {
            [void] $Arguments.Add("--homedir");
            [void] $Arguments.Add([String]::Format("`"{0}`"", $HomeDirectory));
        }
        [void] $Arguments.Add("--import");
        [void] $Arguments.Add([String]::Format("`"{0}`"", $FilePath));
        [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
        $ProcessStartInfo.FileName = $Global:Session.GnuPG.ExecutablePath
        $ProcessStartInfo.RedirectStandardError = $true
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
        $ProcessStartInfo.Arguments = [String]::Join(" ", $Arguments);
        [System.Diagnostics.Process] $Process = [System.Diagnostics.Process]::new()
        $Process.StartInfo = $ProcessStartInfo;
        [void] $Process.Start()
        [void] $Process.WaitForExit()
        [void] $Process.Dispose();
    };
Add-Member `
    -InputObject $Global:Session.GnuPG `
    -Name "RemovePrivateKey" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Fingerprint,

            [Parameter(Mandatory=$true)]
            [String] $HomeDirectory
        )
        [Collections.Generic.List[String]] $Arguments = [Collections.Generic.List[String]]::new();
        If (![String]::IsNullOrEmpty($HomeDirectory))
        {
            [void] $Arguments.Add("--homedir");
            [void] $Arguments.Add([String]::Format("`"{0}`"", $HomeDirectory));
        }
        [void] $Arguments.Add("--batch");
        [void] $Arguments.Add("--yes");
        [void] $Arguments.Add("--quiet");
        [void] $Arguments.Add("--delete-secret-key");
        [void] $Arguments.Add($Fingerprint);
        [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
        $ProcessStartInfo.FileName = $Global:Session.GnuPG.ExecutablePath
        $ProcessStartInfo.RedirectStandardError = $true
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
        $ProcessStartInfo.Arguments = [String]::Join(" ", $Arguments);
        [System.Diagnostics.Process] $Process = [System.Diagnostics.Process]::new()
        $Process.StartInfo = $ProcessStartInfo;
        [void] $Process.Start();
        [void] $Process.WaitForExit();
        [void] $Process.Dispose();
    };
Add-Member `
    -InputObject $Global:Session.GnuPG `
    -Name "RemovePublicKey" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Fingerprint,

            [Parameter(Mandatory=$true)]
            [String] $HomeDirectory
        )
        [Collections.Generic.List[String]] $Arguments = [Collections.Generic.List[String]]::new();
        If (![String]::IsNullOrEmpty($HomeDirectory))
        {
            [void] $Arguments.Add("--homedir");
            [void] $Arguments.Add([String]::Format("`"{0}`"", $HomeDirectory));
        }
        [void] $Arguments.Add("--batch");
        [void] $Arguments.Add("--yes");
        [void] $Arguments.Add("--quiet");
        [void] $Arguments.Add("--delete-key");
        [void] $Arguments.Add($Fingerprint);
        [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
        $ProcessStartInfo.FileName = $Global:Session.GnuPG.ExecutablePath
        $ProcessStartInfo.RedirectStandardError = $true
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
        $ProcessStartInfo.Arguments = [String]::Join(" ", $Arguments);
        [System.Diagnostics.Process] $Process = [System.Diagnostics.Process]::new()
        $Process.StartInfo = $ProcessStartInfo;
        [void] $Process.Start();
        [void] $Process.WaitForExit();
        [String] $ErrorOutput = $Process.StandardError.ReadToEnd()
        If ($ErrorOutput.Contains("gpg: there is a secret key for public key"))
        {
            Throw [System.Exception]::new("Private key exsits for public key. Must delete private key first.")
        }
        [void] $Process.Dispose();
    };
