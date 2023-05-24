#This script creates methods to manage logs
# that are stored in the Logs directory
# which should be specified in the ".jobs-config.json".

#These Modules require Posh-SSH
# On newer Windows machines, SSH is built in.
# However, this script is not written to take advantage of that yet.

If (-not (Get-Module -ListAvailable -Name "Posh-SSH"))
{
    Install-Module -Name Posh-SSH
} 
If (-not (Get-Module -Name "Posh-SSH"))
{
    Import-Module -Name "Posh-SSH"
} 

If (![IO.Directory]::Exists($Global:Job.Directories.ConnectionsRoot))
{
    [void] [IO.Directory]::CreateDirectory($Global:Job.Directories.ConnectionsRoot);
}
Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "SFTP" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.SFTP `
    -Name "GetSession" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([SSH.SftpSession])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [SSH.SftpSession] $Result = $null;
        $Values = $Global:Job.Connections.Get($ConnectionName);
        Get-SSHTrustedHost | Remove-SSHTrustedHost | Out-Null;
        If ($Values.AuthType -eq "UserNameAndPassword")
        {
            [System.Security.SecureString] $SecurePassword = ConvertTo-SecureString -String ($Values.Password) -AsPlainText -Force;
            [System.Management.Automation.PSCredential] $Credential = [System.Management.Automation.PSCredential]::new($Values.UserName, $SecurePassword);
            $Result = New-SFTPSession -ComputerName $Values.HostName -Port $Values.Port -Credential $Credential -AcceptKey;
        }
        If ($Values.AuthType -eq "KeyFile")
        {
            If (![IO.File]::Exists($Values.KeyFile))
            {
                Throw [System.IO.FileNotFoundException]::new("Key File not found", $Values.KeyFile);
            }
            $Result = New-SFTPSession -ComputerName $Values.HostName -Port $Values.Port -KeyFile $Values.KeyFile -AcceptKey;
        }
        Return $Result;
    }
Add-Member `
    -InputObject $Global:Job.SFTP `
    -Name "GetFileList" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $RemotePath,
    
            [Parameter(Mandatory=$false)]
            [String] $DateTimeFormatString,
    
            [Parameter(Mandatory=$false)]
            [Int32] $DateTimeStartPosition
        )
        [Collections.ArrayList] $Results = [Collections.ArrayList]::new();
        [SSH.SftpSession] $Session = $Global:Job.SFTP.GetSession($ConnectionName);
        $Files = Get-SFTPChildItem -SFTPSession $Session -Path $RemotePath;
        If ([String]::IsNullOrEmpty($DateTimeFormatString))
        {
            ForEach ($SftpFile In $Files)
            {
                [void] $Results.Add([PSCustomObject]@{
                    FileNameTime = $null;
                    FilePath = $SftpFile.FullName;
                    FileName = $SftpFile.Name;
                    Length = $SftpFile.Length;
                    LastWriteTimeUtc = $SftpFile.LastWriteTimeUtc;
                    LastAccessTimeUtc = $SftpFile.LastAccessTimeUtc;
                });
            }
        }
        Else
        {
            ForEach ($SftpFile In $Files)
            {
                [DateTime] $FileNameTime = [DateTime]::MinValue;
                If ($SftpFile.Name.Length -ge ($DateTimeStartPosition + $DateTimeFormatString.Length))
                {
                    [String] $FileDateStamp = $SftpFile.Name.Substring($DateTimeStartPosition, $DateTimeFormatString.Length);
                    [DateTime] $ResultDateTime = [DateTime]::MinValue;
                    If ([DateTime]::TryParseExact(
                                                    $FileDateStamp, $DateTimeFormatString,
                                                    [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None,
                                                    [ref]$ResultDateTime))
                    {
                        $FileNameTime = $ResultDateTime;
                    }
                }
                Else
                {
                    $FileNameTime = [DateTime]::MinValue;
                }
                [void] $Results.Add([PSCustomObject]@{
                    FileNameTime = ($FileNameTime -eq [DateTime]::MinValue) ? $null : $FileNameTime;
                    FilePath = $SftpFile.FullName;
                    FileName = $SftpFile.Name;
                    Length = $SftpFile.Length;
                    LastWriteTimeUtc = $SftpFile.LastWriteTimeUtc;
                    LastAccessTimeUtc = $SftpFile.LastAccessTimeUtc;
                });
            }
        }
        Remove-SFTPSession -SFTPSession $Session | Out-Null;
        Return $Results
    };
Add-Member `
    -InputObject $Global:Job.SFTP `
    -Name "GetFile" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $RemoteFilePath,
    
            [Parameter(Mandatory=$true)]
            [String] $LocalDirectoryPath,
    
            [Parameter(Mandatory=$true)]
            [Boolean] $Overwrite
        )
        If (
            [IO.File]::Exists([IO.Path]::Combine($LocalDirectoryPath, [IO.Path]::GetFileName($RemoteFilePath))) -and
            -not $Overwrite
        )
        {
            Throw [System.IO.IOException]::new("File Already Exists.");
        }
        [SSH.SftpSession] $Session = $Global:Job.SFTP.GetSession($ConnectionName);
        If ($Overwrite)
        {
            Get-SFTPItem -SFTPSession $Session -Path $RemoteFilePath -Destination $LocalDirectoryPath -Force;
        }
        Else
        {
            Get-SFTPItem -SFTPSession $Session -Path $RemoteFilePath -Destination $LocalDirectoryPath;
        }
        Remove-SFTPSession -SFTPSession $Session | Out-Null;
    };
Add-Member `
    -InputObject $Global:Job.SFTP `
    -Name "GetFilesNewerThan" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $RemotePath,
    
            [Parameter(Mandatory=$true)]
            [String] $LocalDirectoryPath,
    
            [Parameter(Mandatory=$true)]
            [String] $DateTimeFormatString,
    
            [Parameter(Mandatory=$true)]
            [Int32] $DateTimeStartPosition,

            [Parameter(Mandatory=$true)]
            [DateTime] $NewerThan,
    
            [Parameter(Mandatory=$true)]
            [Boolean] $Overwrite
        )
        [Collections.ArrayList] $Results = [Collections.ArrayList]::new();
        [SSH.SftpSession] $Session = $Global:Job.SFTP.GetSession($ConnectionName);
        $Files = Get-SFTPChildItem -SFTPSession $Session -Path $RemotePath -File;
        ForEach ($SftpFile In $Files)
        {
            [String] $LocalFilePath = [IO.Path]::Combine($LocalDirectoryPath, $SftpFile.Name);
            [Boolean] $AlreadyExists = [IO.File]::Exists($LocalFilePath);
            [DateTime] $FileNameTime = [DateTime]::MinValue;
            [Boolean] $IsFileNameTimeParsed = $false;
            [Boolean] $IsNewer = $false;
            If ($SftpFile.Name.Length -ge ($DateTimeStartPosition + $DateTimeFormatString.Length))
            {
                [String] $FileDateStamp = $SftpFile.Name.Substring($DateTimeStartPosition, $DateTimeFormatString.Length);
                [DateTime] $ResultDateTime = [DateTime]::MinValue;
                If ([DateTime]::TryParseExact(
                                                $FileDateStamp, $DateTimeFormatString,
                                                [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None,
                                                [ref]$ResultDateTime))
                {
                    $FileNameTime = $ResultDateTime;
                    $IsFileNameTimeParsed = $true;
                    $IsNewer = ($NewerThan -lt $FileNameTime);
                }
            }
            If ($IsNewer)
            {
                [void] $Results.Add([PSCustomObject]@{
                    RemoteFilePath = $SftpFile.FullName;
                    FileName = $SftpFile.Name;
                    Length = $SftpFile.Length;
                    LastWriteTimeUtc = $SftpFile.LastWriteTimeUtc;
                    LastAccessTimeUtc = $SftpFile.LastAccessTimeUtc;
                    LocalFilePath = $LocalFilePath;
                    FileNameTime = $FileNameTime;
                    IsFileNameTimeParsed = $IsFileNameTimeParsed;
                    IsNewer = $IsNewer;
                    AlreadyExists = $AlreadyExists;
                });
            }
        }
        ForEach ($SFTPFile In $Results)
        {
            If ($SFTPFile.IsNewer)
            {
                If ($SFTPFile.AlreadyExists -and $Overwrite)
                {
                    Get-SFTPItem -SFTPSession $Session -Path $SFTPFile.RemoteFilePath -Destination $LocalDirectoryPath -Force;
                }
                Else
                {
                    Get-SFTPItem -SFTPSession $Session -Path $SFTPFile.RemoteFilePath -Destination $LocalDirectoryPath;
                }
            }
        }
        Remove-SFTPSession -SFTPSession $Session | Out-Null;
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.SFTP `
    -Name "WriteFile" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $RemoteDirectoryPath,
    
            [Parameter(Mandatory=$true)]
            [String] $LocalFilePath
        )
        [SSH.SftpSession] $Session = $Global:Job.SFTP.GetSession($ConnectionName);
        Set-SFTPItem -SFTPSession $Session -Destination $RemoteDirectoryPath -Path $LocalFilePath;
        Remove-SFTPSession -SFTPSession $Session | Out-Null;
    };
