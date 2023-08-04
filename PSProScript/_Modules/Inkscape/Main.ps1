Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Inkscape" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

Add-Member `
    -InputObject $Global:Session.Inkscape `
    -TypeName "System.String" `
    -NotePropertyName "ExecutablePath" `
    -NotePropertyValue "C:\Program Files\Inkscape\bin\inkscape.exe";

Add-Member `
    -InputObject $Global:Session.Inkscape `
    -Name "SVGToPNG" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [String] $SVGFilePath,
            [String] $PNGFilePath,
            [Int32] $ExportWidth
        )
        [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
        $ProcessStartInfo.WorkingDirectory = [IO.Path]::GetDirectoryName($Global:Session.Inkscape.ExecutablePath);
        $ProcessStartInfo.FileName = "C:\Program Files\Inkscape\bin\inkscape";
        $ProcessStartInfo.RedirectStandardError = $true;
        $ProcessStartInfo.RedirectStandardOutput = $true;
        # $ProcessStartInfo.RedirectStandardInput = $true;
        #$ProcessStartInfo.UseShellExecute = $true;
        $ProcessStartInfo.Arguments = @(
            "--batch-process",
            "--export-background-opacity=0",
            [String]::Format("--export-width={0}", $ExportWidth),
            "-export-type=png",
            [String]::Format("--export-filename=`"{0}`"", $PNGFilePath),
            [String]::Format("`"{0}`"", $SVGFilePath)
        );
        [System.Diagnostics.Process] $Process = [System.Diagnostics.Process]::new();
        $Process.StartInfo = $ProcessStartInfo;
        Write-Host ($ProcessStartInfo.FileName)
        Write-Host ($ProcessStartInfo.Arguments)
        [void] $Process.Start();
        $Process.WaitForExit(5000);
        $Process.StandardOutput.ReadToEnd();
        $Process.StandardError.ReadToEnd();
    }
