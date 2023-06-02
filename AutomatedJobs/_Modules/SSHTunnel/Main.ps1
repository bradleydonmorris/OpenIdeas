[void] $Global:Job.NuGet.InstallPackageIfMissing("SSH.NET")
[void] $Global:Job.NuGet.AddAssembly("Renci.SshNet", "SSH.NET.2020.0.2\lib\net40\Renci.SshNet.dll");
Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "SSHTunnel" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.SSHTunnel `
    -NotePropertyName "Internals" `
    -NotePropertyValue ([Collections.Hashtable]::new());
Add-Member `
    -InputObject $Global:Job.SSHTunnel `
    -Name "CreateKeyAuthTunnel" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $SSHServerAddress,

            [Parameter(Mandatory=$true)]
            [Int32] $SSHServerPort,

            [Parameter(Mandatory=$true)]
            [String] $UserName,

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
        $Global:Job.SSHTunnel.Internals = [Collections.Hashtable]::new();
        $Global:Job.SSHTunnel.Internals.Clear();
        If (![String]::IsNullOrEmpty($KeyFilePassphrase))
        {
            [void] $Global:Job.SSHTunnel.Internals.Add(
                "PrivateKeyFile",
                [Renci.SshNet.PrivateKeyFile]::new($KeyFilePath, $KeyFilePassphrase)
            );
        }
        Else
        {
            [void] $Global:Job.SSHTunnel.Internals.Add(
                "PrivateKeyFile",
                [Renci.SshNet.PrivateKeyFile]::new($KeyFilePath)
            );
        }
        If ($Global:Job.SSHTunnel.Internals.ContainsKey("PrivateKeyFile"))
        {
            [void] $Global:Job.SSHTunnel.Internals.Add(
                "ConnectionInfo",
                [Renci.SshNet.PrivateKeyConnectionInfo]::new(
                    $SSHServerAddress,
                    $SSHServerPort,
                    $UserName,
                    $Global:Job.SSHTunnel.Internals["PrivateKeyFile"]
                )
            );
        }
        If ($Global:Job.SSHTunnel.Internals.ContainsKey("ConnectionInfo"))
        {
            [void] $Global:Job.SSHTunnel.Internals.Add(
                "SshClient",
                [Renci.SshNet.SshClient]::new($Global:Job.SSHTunnel.Internals["ConnectionInfo"])
            );
        }
        If ($Global:Job.SSHTunnel.Internals.ContainsKey("SshClient"))
        {
            [void] $Global:Job.SSHTunnel.Internals["SshClient"].Connect();
            If ($Global:Job.SSHTunnel.Internals["SshClient"].IsConnected)
            {
                [void] $Global:Job.SSHTunnel.Internals.Add(
                    "ForwardedPortLocal",
                    [Renci.SshNet.ForwardedPortLocal]::new(
                        $LocalAddress,
                        $LocalPort,
                        $RemoteAddress,
                        $RemotePort
                    )
                );
                [void] $Global:Job.SSHTunnel.Internals["SshClient"].AddForwardedPort($Global:Job.SSHTunnel.Internals["ForwardedPortLocal"]);
                [void] $Global:Job.SSHTunnel.Internals["ForwardedPortLocal"].Start();
            }
        }
    }
Add-Member `
    -InputObject $Global:Job.SSHTunnel `
    -Name "IsTunnelEstablished" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        [Boolean] $ReturnValue = $false;
        If ($Global:Job.SSHTunnel.Internals.ContainsKey("SshClient"))
        {
            If ($Global:Job.SSHTunnel.Internals["SshClient"].IsConnected)
            {
                If ($Global:Job.SSHTunnel.Internals.ContainsKey("ForwardedPortLocal"))
                {
                    If ($Global:Job.SSHTunnel.Internals["ForwardedPortLocal"].IsStarted)
                    {
                        $ReturnValue = $true;
                    }
                }
            }
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.SSHTunnel `
    -Name "DestroyTunnel" `
    -MemberType "ScriptMethod" `
    -Value {
        If ($Global:Job.SSHTunnel.Internals.ContainsKey("ForwardedPortLocal"))
        {
            If ($Global:Job.SSHTunnel.Internals["ForwardedPortLocal"].IsStarted)
            {
                $Global:Job.SSHTunnel.Internals["ForwardedPortLocal"].Stop();
            }
            $Global:Job.SSHTunnel.Internals["ForwardedPortLocal"].Dispose();
            [void] $Global:Job.SSHTunnel.Internals.Remove("ForwardedPortLocal");
        }
        If ($Global:Job.SSHTunnel.Internals.ContainsKey("SshClient"))
        {
            If ($Global:Job.SSHTunnel.Internals["SshClient"].IsConnected)
            {
                $Global:Job.SSHTunnel.Internals["SshClient"].Disconnect();
            }
            $Global:Job.SSHTunnel.Internals["SshClient"].Dispose();
            [void] $Global:Job.SSHTunnel.Internals.Remove("SshClient");
        }
        If ($Global:Job.SSHTunnel.Internals.ContainsKey("ConnectionInfo"))
        {
            $Global:Job.SSHTunnel.Internals["ConnectionInfo"].Dispose();
            [void] $Global:Job.SSHTunnel.Internals.Remove("ConnectionInfo");
        }
        If ($Global:Job.SSHTunnel.Internals.ContainsKey("PrivateKeyFile"))
        {
            $Global:Job.SSHTunnel.Internals["PrivateKeyFile"].Dispose();
            [void] $Global:Job.SSHTunnel.Internals.Remove("PrivateKeyFile");
        }
        $Global:Job.SSHTunnel.Internals.Clear();
        $Global:Job.SSHTunnel.Internals = [Collections.Hashtable]::new();
    }

