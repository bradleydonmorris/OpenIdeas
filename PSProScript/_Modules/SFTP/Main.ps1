[void] $Global:Session.LoadModule("Connections");

#This script creates methods to manage logs
# that are stored in the Logs directory
# which should be specified in the ".psps-config.json".

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

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "SFTP" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

#region Connection Methods
Add-Member `
    -InputObject $Global:Session.SFTP `
    -Name "SetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,
    
            [Parameter(Mandatory=$false)]
            [String] $Comments,
            
            [Parameter(Mandatory=$true)]
            [Boolean] $IsPersisted,
    
            [Parameter(Mandatory=$true)]
            [String] $AuthType, #Password Or KeyFile
    
            [Parameter(Mandatory=$true)]
            [String] $HostAddress,
    
            [Parameter(Mandatory=$true)]
            [Int32] $Port,
    
            [Parameter(Mandatory=$true)]
            [String] $UserName,
    
            [Parameter(Mandatory=$false)]
            [String] $Password,
    
            [Parameter(Mandatory=$false)]
            [String] $KeyFilePath
        )
        If ($AuthType -eq "Password")
        {
            $Global:Session.Connections.Set(
                $Name,
                [PSCustomObject]@{
                    "Type" = "SFTP";
                    "HostAddress" = $HostAddress;
                    "Port" = $Port;
                    "UserName" = $UserName;
                    "Password" = $Password;
                    "Comments" = $Comments;
                },
                $IsPersisted
            );
        }
        ElseIf ($AuthType -eq "KeyFile")
        {
            If (![IO.File]::Exists($KeyFilePath))
            {
                Throw [System.IO.FileNotFoundException]::new("Key File not found", $KeyFilePath);
            }
            $Global:Session.Connections.Set(
                $Name,
                [PSCustomObject]@{
                    "Type" = "SFTP";
                    "HostAddress" = $HostAddress;
                    "Port" = $Port;
                    "UserName" = $UserName;
                    "KeyFilePath" = $KeyFilePath;
                    "Comments" = $Comments;
                },
                $IsPersisted
            );
        }
        Else
        {
            Throw [System.ArgumentOutOfRangeException]::new("AuthType", "AuthType must be either UserNameAndPassword or KeyFile");
        }
    };
Add-Member `
    -InputObject $Global:Session.SFTP `
    -Name "GetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSCustomObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [PSCustomObject] $ReturnValue = $Global:Session.Connections.Get($Name);
        If ($ReturnValue.AuthType -eq "FileFile")
        {
            If (![IO.File]::Exists($ReturnValue.KeyFilePath))
            {
                $ReturnValue = $null;
                Throw [System.IO.FileNotFoundException]::new("Key File not found", $ReturnValue.KeyFilePath);
            }
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.SFTP `
    -Name "GetSession" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([SSH.SftpSession])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [SSH.SftpSession] $ReturnValue = $null;
        $Connection = $Global:Session.Connections.Get($Name);
        Get-SSHTrustedHost | Remove-SSHTrustedHost | Out-Null;
        If ($Connection.AuthType -eq "Password")
        {
            [System.Security.SecureString] $SecurePassword = ConvertTo-SecureString -String ($Connection.Password) -AsPlainText -Force;
            [System.Management.Automation.PSCredential] $Credential = [System.Management.Automation.PSCredential]::new($Connection.UserName, $SecurePassword);
            $ReturnValue = New-SFTPSession -ComputerName $Connection.HostAddress -Port $Connection.Port -Credential $Credential -AcceptKey;
        }
        If ($Connection.AuthType -eq "KeyFile")
        {
            If (![IO.File]::Exists($Connection.KeyFilePath))
            {
                Throw [System.IO.FileNotFoundException]::new("Key File not found", $Connection.KeyFilePath);
            }
            $ReturnValue = New-SFTPSession -ComputerName $Connection.HostAddress -Port $Connection.Port -KeyFile $Connection.KeyFilePath -AcceptKey;
        }
        Return $ReturnValue;
    }
#endregion Connection Methods

Add-Member `
    -InputObject $Global:Session.SFTP `
    -Name "GetFileList" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
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
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [SSH.SftpSession] $Session = $Global:Session.SFTP.GetSession($ConnectionName);
        $Files = Get-SFTPChildItem -SFTPSession $Session -Path $RemotePath;
        If ([String]::IsNullOrEmpty($DateTimeFormatString))
        {
            ForEach ($SftpFile In $Files)
            {
                [void] $ReturnValue.Add([PSCustomObject]@{
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
                [void] $ReturnValue.Add([PSCustomObject]@{
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
        Return $ReturnValue
    };
Add-Member `
    -InputObject $Global:Session.SFTP `
    -Name "GetFilesNewerThan" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
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
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [SSH.SftpSession] $Session = $Global:Session.SFTP.GetSession($ConnectionName);
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
                [void] $ReturnValue.Add([PSCustomObject]@{
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
        ForEach ($SFTPFile In $ReturnValue)
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
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.SFTP `
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
        [SSH.SftpSession] $Session = $Global:Session.SFTP.GetSession($ConnectionName);
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
    -InputObject $Global:Session.SFTP `
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
        [SSH.SftpSession] $Session = $Global:Session.SFTP.GetSession($ConnectionName);
        Set-SFTPItem -SFTPSession $Session -Destination $RemoteDirectoryPath -Path $LocalFilePath;
        Remove-SFTPSession -SFTPSession $Session | Out-Null;
    };
