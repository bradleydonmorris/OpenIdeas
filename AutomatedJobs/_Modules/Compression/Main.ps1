#This script creates methods to manage compression
# and decompressing files.

#These Modules require 7-Zip to be installed.
If (![IO.File]::Exists("C:\Program Files\7-Zip\7z.exe"))
{
    Throw [IO.FileNotFoundException]::new("C:\Program Files\7-Zip\7z.exe");
}
Else
{
    Add-Member `
        -InputObject $Global:Job `
        -TypeName "System.Management.Automation.PSObject" `
        -NotePropertyName "Compression" `
        -NotePropertyValue ([System.Management.Automation.PSObject]::new());
    Add-Member `
        -InputObject $Global:Job.Compression `
        -TypeName "String" `
        -NotePropertyName "ExecutablePath" `
        -NotePropertyValue "C:\Program Files\7-Zip\7z.exe";
    Add-Member `
        -InputObject $Global:Job.Compression `
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
                [String] $DecompressedDirecotyrPath
            )
            [String] $Results = [IO.Path]::Combine($DecompressedDirectoryPath, [IO.Path]::GetFileName($AssetPath));
            #[String] $ArgumentList = "e `"" + $CompressedFilePath + "`" -o`"$DecompressedDirectoryPath`" `"$AssetPath`" -y";
            #& ($Global:Job.Compression.ExecutablePath) $ArgumentList;
            Start-Process -RedirectStandardOutput "NUL" `
                -FilePath $Global:Job.Compression.ExecutablePath -ArgumentList @(
                    "e",
                    $CompressedFilePath,
                    "-o`"$DecompressedDirectoryPath`"",
                    "`"$AssetPath`"",
                    "-y"
                ) `
                -Wait `
                -NoNewWindow |
                    Out-Null;
            Return $Results;
        };
}
