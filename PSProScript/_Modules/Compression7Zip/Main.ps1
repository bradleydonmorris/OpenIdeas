If (![IO.File]::Exists($Global:Session.Compression7Zip.ExecutablePath))
{
    Throw [IO.FileNotFoundException]::new($Global:Session.Compression7Zip.ExecutablePath);
}
Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Compression7Zip" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.Compression7Zip `
    -TypeName "String" `
    -NotePropertyName "ExecutablePath" `
    -NotePropertyValue "C:\Program Files\7-Zip\7z.exe";
Add-Member `
    -InputObject $Global:Session.Compression7Zip `
    -Name "GetAssets" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $CompressedFilePath
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
        $ProcessStartInfo.FileName = $Global:Session.Compression7Zip.ExecutablePath
        $ProcessStartInfo.RedirectStandardError = $true
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
        $ProcessStartInfo.Arguments = @(
            "l",
            "`"$CompressedFilePath`"",
            "-y"
        );
        [System.Diagnostics.Process] $Process = [System.Diagnostics.Process]::new()
        $Process.StartInfo = $ProcessStartInfo
        [void] $Process.Start()
        [void] $Process.WaitForExit()
        [Boolean] $InList = $false;
        ForEach ($Line In ($Process.StandardOutput.ReadToEnd() -split "`r`n"))
        {
            If ($Line -eq "------------------- ----- ------------ ------------  ------------------------")
            {
                If ($InList)
                {
                    $InList = $false;
                }
                Else
                {
                    $InList = $true;
                }
            }
            If (
                $InList -and
                $Line -ne "------------------- ----- ------------ ------------  ------------------------")
            {
                [PSObject] $Asset = [PSObject]::new();
                Add-Member `
                    -InputObject $Asset `
                    -TypeName "System.String" `
                    -NotePropertyName "Path" `
                    -NotePropertyValue $Line.SubString(53);
                Add-Member `
                    -InputObject $Asset `
                    -TypeName "System.Nullable[System.DateTime]" `
                    -NotePropertyName "FileTime" `
                    -NotePropertyValue ([DateTime]::Parse($Line.Substring(0, 19)));
                Add-Member `
                    -InputObject $Asset `
                    -TypeName "System.Nullable[System.Int64]" `
                    -NotePropertyName "Size" `
                    -NotePropertyValue ([Int64]::Parse($Line.Substring(26).Substring(0, 12)));
                Add-Member `
                    -InputObject $Asset `
                    -TypeName "System.Boolean" `
                    -NotePropertyName "IsDirectory" `
                    -NotePropertyValue ($Line.SubString(20, 1) -eq "D");
                Add-Member `
                    -InputObject $Asset `
                    -TypeName "System.Boolean" `
                    -NotePropertyName "IsReadOnly" `
                    -NotePropertyValue ($Line.SubString(21, 1) -eq "R");
                Add-Member `
                    -InputObject $Asset `
                    -TypeName "System.Boolean" `
                    -NotePropertyName "IsHidden" `
                    -NotePropertyValue ($Line.SubString(22, 1) -eq "H");
                Add-Member `
                    -InputObject $Asset `
                    -TypeName "System.Boolean" `
                    -NotePropertyName "IsSystem" `
                    -NotePropertyValue ($Line.SubString(23, 1) -eq "S");
                Add-Member `
                    -InputObject $Asset `
                    -TypeName "System.Boolean" `
                    -NotePropertyName "IsArchived" `
                    -NotePropertyValue ($Line.SubString(24, 1) -eq "A");
                [void] $ReturnValue.Add($Asset);
            }
        }
        [void] $Process.Dispose();
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.Compression7Zip `
    -Name "ExtractAsset" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $CompressedFilePath,

            [Parameter(Mandatory=$true)]
            [String] $AssetPath,

            [Parameter(Mandatory=$true)]
            [String] $OutputDirectoryPath
        )
        [String] $ReturnValue = [IO.Path]::Combine($DecompressedDirectoryPath, [IO.Path]::GetFileName($AssetPath));
        If (![IO.Directory]::Exists($OutputDirectoryPath))
        {
            [void] [IO.Directory]::CreateDirectory($OutputDirectoryPath);
        }
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
        $ProcessStartInfo.FileName = "C:\Program Files\7-Zip\7z.exe"
        $ProcessStartInfo.RedirectStandardError = $true
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
        $ProcessStartInfo.Arguments = @(
            "e",
            "`"$CompressedFilePath`"",
            "-o`"$OutputDirectoryPath`"",
            "`"$AssetPath`"",
            "-y"
        );
        [System.Diagnostics.Process] $Process = [System.Diagnostics.Process]::new()
        $Process.StartInfo = $ProcessStartInfo
        [void] $Process.Start()
        [void] $Process.WaitForExit()
        [String] $Output = $Process.StandardOutput.ReadToEnd();
        [void] $Process.Dispose();
        If ($Output.Contains("No files to process"))
        {
            Throw [System.Exception]::new([String]::Format("Asset `"{0}`" not found.", $AssetPath));
        }
        ElseIf (!$Output.Contains("Everything is Ok"))
        {
            [String] $ErrorFilePath = [IO.Path]::Combine($OutputDirectoryPath, [String]::Format("Error_{0}.txt", [DateTime]::UtcNow.ToString("yyyyMMddHHmmssfffffff")));
            [void] [IO.File]::WriteAllText(
                $ErrorFilePath,
                $Output
            );
            Throw [System.Exception]::new([String]::Format("Errors encountered. Please review {0}", $ErrorFilePath));
        }
        Return $ReturnValue;
    };
