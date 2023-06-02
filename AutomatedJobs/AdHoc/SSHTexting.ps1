. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "SSHTunnel"
);

[void] $Global:Job.NuGet.InstallPackageIfMissing("SSH.NET")
[void] $Global:Job.NuGet.AddAssembly("Renci.SshNet", "SSH.NET.2020.0.2\lib\net40\Renci.SshNet.dll");
[void] $Global:Job.NuGet.InstallPackageVersionIfMissing("Npgsql", "5.0.0");
[void] $Global:Job.NuGet.AddAssembly("Npgsql", "Npgsql.5.0.0\lib\net5.0\Npgsql.dll");

<#
If error is "Invalid private key file.",
    try to load the key file in PuttyGen.
    Then ecport to OpenSSH
        Conversions > Export OpenSSH key
        (not the "force new file format" option)
#>
[String] $SSHServerAddress = "ec2-50-18-210-155.us-west-1.compute.amazonaws.com";
[Int32] $SSHServerPort = 22
[String] $UserName = "bmorris";
[String] $KeyFilePath = "C:\Users\bmorris\.ssh\rsa_auth_bmorris.temp.openssh";
[String] $KeyFilePassphrase = $null;
[String] $LocalAddress = "127.0.0.1";
[Int32] $LocalPort = 15432;
[String] $RemoteAddress = "tigoldplusdb15.ceayxqg8ja64.us-west-1.rds.amazonaws.com";
[Int32] $RemotePort = 5432

$Global:Job.SSHTunnel.CreateKeyAuthTunnel(
    $SSHServerAddress, $SSHServerPort,
    $UserName, $KeyFilePath, $KeyFilePassphrase,
    $LocalAddress, $LocalPort,
    $RemoteAddress, $RemotePort
);
If ($Global:Job.SSHTunnel.IsTunnelEstablished())
{

    [String] $PostgreDatabase = "just_share_it";
    [String] $PostgreUserName = ;
    [String] $PostgrePassword = ;
    [String] $ConnectionString = (
        [String]::Format("Server={0};", $LocalAddress) +
        [String]::Format("Port={0};", $LocalPort) +
        [String]::Format("Database={0};", $PostgreDatabase) + 
        [String]::Format("User Id={0};", $PostgreUserName) +
        [String]::Format("Password={0};", $PostgrePassword)
    );
    [Npgsql.NpgsqlConnection] $NpgsqlConnection = [Npgsql.NpgsqlConnection]::new($ConnectionString);
    Try
    {
        [void] $NpgsqlConnection.Open();
        [Npgsql.NpgsqlCommand] $NpgsqlCommand = [Npgsql.NpgsqlCommand]::new("SELECT code, name FROM public.t_language", $NpgsqlConnection);
        $NpgsqlCommand.CommandType = [Data.CommandType]::Text;
        [Npgsql.NpgsqlDataReader] $NpgsqlDataReader = $NpgsqlCommand.ExecuteReader();
        While ($NpgsqlDataReader.Read())
        {
            Write-Host -Object ([String]::Format(
                "{0}, {1}",
                $NpgsqlDataReader.GetString($NpgsqlDataReader.GetOrdinal("code")),
                $NpgsqlDataReader.GetString($NpgsqlDataReader.GetOrdinal("name"))
            ));
        }
    }
    Finally {}
    If ($NpgsqlConnection.State -ne [Data.ConnectionState]::Closed)
        { [void] $NpgsqlConnection.Close(); }
    [void] $NpgsqlConnection.Dispose();
}
[void] $Global:Job.SSHTunnel.DestroyTunnel();

# [Renci.SshNet.PrivateKeyFile] $PrivateKeyFile = $null;
# [Renci.SshNet.PrivateKeyConnectionInfo] $PrivateKeyConnectionInfo = $null;
# [Renci.SshNet.PrivateKeyFile] $PrivateKeyFile = $null;
# If ([String]::IsNullOrEmpty($KeyFilePassphrase))
# {
#     $PrivateKeyFile = [Renci.SshNet.PrivateKeyFile]::new($KeyFilePath);
# }
# Else
# {
#     $PrivateKeyFile = [Renci.SshNet.PrivateKeyFile]::new($KeyFilePath, $KeyFilePassphrase);
# }
# If ($PrivateKeyFile)
# {
#     [Renci.SshNet.PrivateKeyConnectionInfo] $PrivateKeyConnectionInfo = [Renci.SshNet.PrivateKeyConnectionInfo]::new($SSHServerAddress, $SSHServerPort, $UserName, $PrivateKeyFile);
# }
# [Renci.SshNet.SshClient] $SshClient = [Renci.SshNet.SshClient]::new($PrivateKeyConnectionInfo);
# [void] $SshClient.Connect();
# If ($SshClient.IsConnected)
# {
    
#     [Renci.SshNet.ForwardedPortLocal] $ForwardedPortLocal = [Renci.SshNet.ForwardedPortLocal]::new($LocalAddress, $LocalPort, $RemoteAddress, $RemotePort);
#     [void] $SshClient.AddForwardedPort($ForwardedPortLocal);
#     [void] $ForwardedPortLocal.Start();
#     If ($ForwardedPortLocal.IsStarted)
#     {
#         [String] $ConnectionString = (
#             [String]::Format("Server={0};", $LocalAddress) +
#             [String]::Format("Port={0};", $LocalPort) +
#             "Database=just_share_it;" +
#             "User Id=datamanagment_read;" +
#             "Password=IA7Vus4bRq17!A6Agjv#;"
#         );
#         [Npgsql.NpgsqlConnection] $NpgsqlConnection = [Npgsql.NpgsqlConnection]::new($ConnectionString);
#         Try
#         {
#             [void] $NpgsqlConnection.Open();
#             [Npgsql.NpgsqlCommand] $NpgsqlCommand = [Npgsql.NpgsqlCommand]::new("SELECT code, name FROM public.t_language", $NpgsqlConnection);
#             $NpgsqlCommand.CommandType = [Data.CommandType]::Text;
#             [Npgsql.NpgsqlDataReader] $NpgsqlDataReader = $NpgsqlCommand.ExecuteReader();
#             While ($NpgsqlDataReader.Read())
#             {
#                 Write-Host -Object ([String]::Format(
#                     "{0}, {1}",
#                     $NpgsqlDataReader.GetString($NpgsqlDataReader.GetOrdinal("code")),
#                     $NpgsqlDataReader.GetString($NpgsqlDataReader.GetOrdinal("name"))
#                 ));
#             }
#         }
#         Finally {}
#         If ($NpgsqlConnection.State -ne [Data.ConnectionState]::Closed)
#             { [void] $NpgsqlConnection.Close(); }
#         [void] $NpgsqlConnection.Dispose();
#         [void] $ForwardedPortLocal.Stop();
#     }
#     [void] $ForwardedPortLocal.Dispose();
#     [void] $SshClient.Disconnect();
# }
# [void] $SshClient.Dispose();
# [void] $PrivateKeyConnectionInfo.Dispose();
# [void] $PrivateKeyFile.Dispose();

# #ssh -i "C:\Users\bmorris\.ssh\rsa_auth_bmorris.id_rsa" bmorris@ec2-50-18-210-155.us-west-1.compute.amazonaws.com
# #PrivateKeyConnectionInfo(string host, int port, string username, params PrivateKeyFile[] keyFiles)
