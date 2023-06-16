[void] $Global:Session.LoadModule("Connections");

[void] $Global:Session.NuGet.InstallPackageIfMissing("SSH.NET")
[void] $Global:Session.NuGet.AddAssembly("Renci.SshNet", "SSH.NET.2020.0.2\lib\net40\Renci.SshNet.dll");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "SSHTunnel" `
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
            [String] $SSHServerAddress,

            [Parameter(Mandatory=$true)]
            [Int32] $SSHServerPort,

            [Parameter(Mandatory=$true)]
            [String] $UserName,

            [Parameter(Mandatory=$true)]
            [String] $Password,

            [Parameter(Mandatory=$true)]
            [String] $KeyFilePath,

            [Parameter(Mandatory=$true)]
            [String] $KeyFilePassphrase,

            [Parameter(Mandatory=$true)]
            [String] $LocalAddress,

            [Parameter(Mandatory=$true)]
            [Int32] $LocalPort,

            [Parameter(Mandatory=$true)]
            [String] $RemoteAddress,

            [Parameter(Mandatory=$true)]
            [Int32] $RemotePort
        )
        If ($AuthType -eq "Password")
        {
            $Global:Session.Connections.Set(
                $Name,
                [PSCustomObject]@{
                    "SSHServerAddress" = $SSHServerAddress;
                    "SSHServerPort" = $SSHServerPort;
                    "UserName" = $UserName;
                    "Password" = $Password;
                    "LocalAddress" = $LocalAddress;
                    "LocalPort" = $LocalPort;
                    "RemoteAddress" = $RemoteAddress;
                    "RemotePort" = $RemotePort;
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
                    "SSHServerAddress" = $SSHServerAddress;
                    "SSHServerPort" = $SSHServerPort;
                    "UserName" = $UserName;
                    "KeyFilePath" = $KeyFilePath;
                    "KeyFilePassphrase" = $KeyFilePassphrase;
                    "LocalAddress" = $LocalAddress;
                    "LocalPort" = $LocalPort;
                    "RemoteAddress" = $RemoteAddress;
                    "RemotePort" = $RemotePort;
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
    -InputObject $Global:Session.SSHTunnel `
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
#endregion Connection Methods

Add-Member `
    -InputObject $Global:Session.SSHTunnel `
    -NotePropertyName "Internals" `
    -NotePropertyValue ([Collections.Hashtable]::new());

Add-Member `
    -InputObject $Global:Session.SSHTunnel `
    -Name "CreateTunnel" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        $Global:Session.SSHTunnel.Internals = [Collections.Hashtable]::new();
        $Global:Session.SSHTunnel.Internals.Clear();

        $Connection = $Global:Session.SSHTunnel.GetConnection($ConnectionName);
        If ($Connection.AuthType -eq "KeyFile")
        {
            If (![String]::IsNullOrEmpty($Connection.KeyFilePassphrase))
            {
                [void] $Global:Session.SSHTunnel.Internals.Add(
                    "PrivateKeyFile",
                    [Renci.SshNet.PrivateKeyFile]::new($Connection.KeyFilePath, $Connection.KeyFilePassphrase)
                );
            }
            Else
            {
                [void] $Global:Session.SSHTunnel.Internals.Add(
                    "PrivateKeyFile",
                    [Renci.SshNet.PrivateKeyFile]::new($Connection.KeyFilePath)
                );
            }
            If ($Global:Session.SSHTunnel.Internals.ContainsKey("PrivateKeyFile"))
            {
                [void] $Global:Session.SSHTunnel.Internals.Add(
                    "ConnectionInfo",
                    [Renci.SshNet.PrivateKeyConnectionInfo]::new(
                        $Connection.SSHServerAddress,
                        [Int32]$Connection.SSHServerPort,
                        $Connection.UserName,
                        $Global:Session.SSHTunnel.Internals["PrivateKeyFile"]
                    )
                );
            }
        }
        ElseIf ($Connection.AuthType -eq "Password")
        {
            [void] $Global:Session.SSHTunnel.Internals.Add(
                "ConnectionInfo",
                [Renci.SshNet.PasswordConnectionInfo]::new(
                    $Connection.SSHServerAddress,
                    [Int32]$Connection.SSHServerPort,
                    $Connection.UserName,
                    $Connection.Password
                )
            );
        }
        If ($Global:Session.SSHTunnel.Internals.ContainsKey("ConnectionInfo"))
        {
            [void] $Global:Session.SSHTunnel.Internals.Add(
                "SshClient",
                [Renci.SshNet.SshClient]::new($Global:Session.SSHTunnel.Internals["ConnectionInfo"])
            );
        }
        If ($Global:Session.SSHTunnel.Internals.ContainsKey("SshClient"))
        {
            [void] $Global:Session.SSHTunnel.Internals["SshClient"].Connect();
            If ($Global:Session.SSHTunnel.Internals["SshClient"].IsConnected)
            {
                [void] $Global:Session.SSHTunnel.Internals.Add(
                    "ForwardedPortLocal",
                    [Renci.SshNet.ForwardedPortLocal]::new(
                        $Connection.LocalAddress,
                        $Connection.LocalPort,
                        $Connection.RemoteAddress,
                        $Connection.RemotePort
                    )
                );
                [void] $Global:Session.SSHTunnel.Internals["SshClient"].AddForwardedPort($Global:Session.SSHTunnel.Internals["ForwardedPortLocal"]);
                [void] $Global:Session.SSHTunnel.Internals["ForwardedPortLocal"].Start();
            }
        }
    }
Add-Member `
    -InputObject $Global:Session.SSHTunnel `
    -Name "IsTunnelEstablished" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        [Boolean] $ReturnValue = $false;
        If ($Global:Session.SSHTunnel.Internals.ContainsKey("SshClient"))
        {
            If ($Global:Session.SSHTunnel.Internals["SshClient"].IsConnected)
            {
                If ($Global:Session.SSHTunnel.Internals.ContainsKey("ForwardedPortLocal"))
                {
                    If ($Global:Session.SSHTunnel.Internals["ForwardedPortLocal"].IsStarted)
                    {
                        $ReturnValue = $true;
                    }
                }
            }
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.SSHTunnel `
    -Name "DestroyTunnel" `
    -MemberType "ScriptMethod" `
    -Value {
        If ($Global:Session.SSHTunnel.Internals.ContainsKey("ForwardedPortLocal"))
        {
            If ($Global:Session.SSHTunnel.Internals["ForwardedPortLocal"].IsStarted)
            {
                $Global:Session.SSHTunnel.Internals["ForwardedPortLocal"].Stop();
            }
            $Global:Session.SSHTunnel.Internals["ForwardedPortLocal"].Dispose();
            [void] $Global:Session.SSHTunnel.Internals.Remove("ForwardedPortLocal");
        }
        If ($Global:Session.SSHTunnel.Internals.ContainsKey("SshClient"))
        {
            If ($Global:Session.SSHTunnel.Internals["SshClient"].IsConnected)
            {
                $Global:Session.SSHTunnel.Internals["SshClient"].Disconnect();
            }
            $Global:Session.SSHTunnel.Internals["SshClient"].Dispose();
            [void] $Global:Session.SSHTunnel.Internals.Remove("SshClient");
        }
        If ($Global:Session.SSHTunnel.Internals.ContainsKey("ConnectionInfo"))
        {
            $Global:Session.SSHTunnel.Internals["ConnectionInfo"].Dispose();
            [void] $Global:Session.SSHTunnel.Internals.Remove("ConnectionInfo");
        }
        If ($Global:Session.SSHTunnel.Internals.ContainsKey("PrivateKeyFile"))
        {
            $Global:Session.SSHTunnel.Internals["PrivateKeyFile"].Dispose();
            [void] $Global:Session.SSHTunnel.Internals.Remove("PrivateKeyFile");
        }
        $Global:Session.SSHTunnel.Internals.Clear();
        $Global:Session.SSHTunnel.Internals = [Collections.Hashtable]::new();
    }
