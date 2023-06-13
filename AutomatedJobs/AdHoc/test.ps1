. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1"));
$Global:Job.LoadModule("Compression7Zip");
#$Global:Job.Compression7Zip.GetAssets("C:\keys\test.zip");
$Global:Job.Compression7Zip.ExtractAsset("C:\keys\test.zip", "keys\temp.rsa", "C:\keys\trash");

# #[OutputType([Collections.Generic.List[PSObject]])]

# [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
# [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
# $ProcessStartInfo.FileName = "C:\Program Files\7-Zip\7z.exe"
# $ProcessStartInfo.RedirectStandardError = $true
# $ProcessStartInfo.RedirectStandardOutput = $true
# $ProcessStartInfo.UseShellExecute = $false
# $ProcessStartInfo.Arguments = @(
#     "l",
#     "`"C:\keys\test.zip`"",
#     "-y"
# );
# [System.Diagnostics.Process] $Process = [System.Diagnostics.Process]::new()
# $Process.StartInfo = $ProcessStartInfo
# $Process.Start() | Out-Null
# $Process.WaitForExit()
# $StandardOutput = $Process.StandardOutput.ReadToEnd()
# [Boolean] $InList = $false;
# ForEach ($Line In ($StandardOutput -split "`r`n"))
# {
#     If ($Line -eq "------------------- ----- ------------ ------------  ------------------------")
#     {
#         If ($InList)
#         {
#             $InList = $false;
#         }
#         Else
#         {
#             $InList = $true;
#         }
#     }
#     If (
#         $InList -and
#         $Line -ne "------------------- ----- ------------ ------------  ------------------------")
#     {
#         [PSObject] $Asset = [PSObject]::new();
#         Add-Member `
#             -InputObject $Asset `
#             -TypeName "System.String" `
#             -NotePropertyName "Path" `
#             -NotePropertyValue $Line.SubString(53);
#         Add-Member `
#             -InputObject $Asset `
#             -TypeName "System.Nullable[System.DateTime]" `
#             -NotePropertyName "FileTime" `
#             -NotePropertyValue ([DateTime]::Parse($Line.Substring(0, 19)));
#         Add-Member `
#             -InputObject $Asset `
#             -TypeName "System.Nullable[System.Int64]" `
#             -NotePropertyName "Size" `
#             -NotePropertyValue ([Int64]::Parse($Line.Substring(26).Substring(0, 12)));
#         Add-Member `
#             -InputObject $Asset `
#             -TypeName "System.Boolean" `
#             -NotePropertyName "IsDirectory" `
#             -NotePropertyValue ($Line.SubString(20, 1) -eq "D");
#         Add-Member `
#             -InputObject $Asset `
#             -TypeName "System.Boolean" `
#             -NotePropertyName "IsReadOnly" `
#             -NotePropertyValue ($Line.SubString(21, 1) -eq "R");
#         Add-Member `
#             -InputObject $Asset `
#             -TypeName "System.Boolean" `
#             -NotePropertyName "IsHidden" `
#             -NotePropertyValue ($Line.SubString(22, 1) -eq "H");
#             Add-Member `
#             -InputObject $Asset `
#             -TypeName "System.Boolean" `
#             -NotePropertyName "IsSystem" `
#             -NotePropertyValue ($Line.SubString(23, 1) -eq "S");
#         Add-Member `
#             -InputObject $Asset `
#             -TypeName "System.Boolean" `
#             -NotePropertyName "IsArchived" `
#             -NotePropertyValue ($Line.SubString(24, 1) -eq "A");
#         [void] $ReturnValue.Add($Asset);
#     }
# }
# [void] $Process.Dispose();

# #Clear-Host;
# #$StandardOutput
# $ReturnValue

# #Remove-Variable -Name "Asset";



<#

"C:\Program Files\7-Zip\7z.exe" e "C:\keys\test.zip" -o"C:\keys\trash" "keys\temp.rsa" -y

#>