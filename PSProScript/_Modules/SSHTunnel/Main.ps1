[void] $Global:Session.LoadModule("Connections");

# [void] $Global:Session.NuGet.InstallPackageIfMissing("SSH.NET")
# [void] $Global:Session.NuGet.AddAssembly("Renci.SshNet", "SSH.NET.2020.0.2\lib\net40\Renci.SshNet.dll");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "SSHTunnel" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

#region Connection Methods
Add-Member `
    -InputObject $Global:Session.SSHTunnel `
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
                    "Type" = "SSHTunnel";
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
                    "Type" = "SSHTunnel";
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
        If ($ReturnValue.AuthType -ne "KeyFile")
        {
            Throw [System.NotImplementedException]::new("Onle KeyFile Auth Type is currently supported");
        }
        If ($ReturnValue.AuthType -eq "KeyFile")
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
    -NotePropertyName "ActiveSSHProcess" `
    -NotePropertyValue ([System.Diagnostics.Process]::new());

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
        [PSCustomObject] $Connection = $Global:Session.SSHTunnel.GetConnection($ConnectionName);
        [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
        $ProcessStartInfo.FileName = "ssh"
        $ProcessStartInfo.RedirectStandardError = $true;
        $ProcessStartInfo.RedirectStandardOutput = $true;
        $ProcessStartInfo.RedirectStandardInput = $true;
        $ProcessStartInfo.UseShellExecute = $false;
        $ProcessStartInfo.Arguments = @(
            [String]::Format(
                "`"ssh://{0}@{1}:{2}`"",
                $Connection.UserName,
                $Connection.SSHServerAddress,
                $Connection.SSHServerPort
            ),
            "-i",
            [String]::Format(
                "`"{0}`"",
                $Connection.KeyFilePath
            ),
            "-L",
            [String]::Format(
                "{0}:{1}:{2}:{3}",
                $Connection.LocalAddress,
                $Connection.LocalPort,
                $Connection.RemoteAddress,
                $Connection.RemotePort
            )
        );
        $Global:Session.SSHTunnel.ActiveSSHProcess = [System.Diagnostics.Process]::new()
        $Global:Session.SSHTunnel.ActiveSSHProcess.StartInfo = $ProcessStartInfo
        [void] $Global:Session.SSHTunnel.ActiveSSHProcess.Start();
    }
Add-Member `
    -InputObject $Global:Session.SSHTunnel `
    -Name "DestroyTunnel" `
    -MemberType "ScriptMethod" `
    -Value {
        If ($Global:Session.SSHTunnel.ActiveSSHProcess.ProcessName -eq "ssh")
        {
            [void] $Global:Session.SSHTunnel.ActiveSSHProcess.StandardInput.WriteLine("logout")
            [void] $Global:Session.SSHTunnel.ActiveSSHProcess.Dispose();
        }
    }
