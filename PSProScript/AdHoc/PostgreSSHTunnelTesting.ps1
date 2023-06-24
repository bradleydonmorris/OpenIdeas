. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "SSHTunnel",
    "PostgreSQL"
);

# [void] $Global:Session.NuGet.InstallPackageIfMissing("SSH.NET")
# [void] $Global:Session.NuGet.AddAssembly("Renci.SshNet", "SSH.NET.2020.0.2\lib\net40\Renci.SshNet.dll");
# [void] $Global:Session.NuGet.InstallPackageVersionIfMissing("Npgsql", "5.0.0");
# [void] $Global:Session.NuGet.AddAssembly("Npgsql", "Npgsql.5.0.0\lib\net5.0\Npgsql.dll");

<#
#MAKE SURE THE CONNECTION FILES EXISTS
#Some of these values are set to $null here, so they don't get stored in GitHub.
#Set the values prior to running these method, then change them back to $null.

#If using a Key for authentication
    $Global:Session.SSHTunnel.SetConnection(
        $null, #Name - Name of the Connection file
        "KeyFile", #AuthType - for Key authentication
        $null, #SSHServerAddress - SSH Server Address
        22, #SSHServerPost - SSH Server Port
        $null, #UserName - SSH User Name
        $null, #Password - Since using Key authentication, this argument is ignored
        $null, #KeyFilePath - SSH Private Key File
        $null, #KeyFilePassphrase - SSH Key File Pashphrase
        $null, #LocalAddress - Local address for tunnel. This will be what is used in a Postgre Connection
        $null, #LocalPort - Local port for tunnel. This will be what is used in a Postgre Connection
        $null, #RemoteAddress - The actual PostgreSQL server name
        $null, #RemotePort - The actual PostgreSQL server port

        #Comments
        "This is for tunneling the datamanagement_read account on GoldPlus. The local PostgreSQL connection info will be stored in a separatePostgreSQL Connection file.",

        $true #IsPersisted - Set to true to store the connection on the file system
    )

#If using a Password for authentication
    $Global:Session.SSHTunnel.SetConnection(
        $null, #Name - Name of the Connection file
        "Password", #AuthType - for Key authentication
        $null, #SSHServerAddress - SSH Server Address
        22, #SSHServerPost - SSH Server Port
        $null, #UserName - SSH User Name
        $null, #Password - SSH Password
        $null, #KeyFilePath - Since using Key authentication, this argument is ignored
        $null, #KeyFilePassphrase - Since using Key authentication, this argument is ignored
        $null, #LocalAddress - Local address for tunnel. This will be what is used in a Postgre Connection
        $null, #LocalPort - Local port for tunnel. This will be what is used in a Postgre Connection
        $null, #RemoteAddress - The actual PostgreSQL server name
        $null, #RemotePort - The actual PostgreSQL server port

        #Comments
        "This is for tunneling the datamanagement_read account on GoldPlus. The local PostgreSQL connection info will be stored in a separatePostgreSQL Connection file.",

        $true #IsPersisted - Set to true to store the connection on the file system
    )

$Global:Session.PostgreSQL.SetConnection(
    "GoldPlusTunnel-PostgreSQL-datamanagment_read", #Name - Name of the Connection file
    "localhost", #Server - PostgreSQL server address. In this case it's the local address, as this will be done through an SSH Tunnel.
    15432, #Port - PostgreSQL server port. In this case it's the local port, as this will be done through an SSH Tunnel.
    $null, #Database - PostgreSQL database
    $null, #UserName - PostgreSQL user name
    $null, #Password - PostgreSQL password

    #Comment
    "This is for tunneling the datamanagement_read account on GoldPlus. The actual server and port should be stored in the separate SSH Tunnel Connection file."
);
#>

<#
If error is "Invalid private key file.",
    try to load the key file in PuttyGen.
    Then export to OpenSSH
        Conversions > Export OpenSSH key
        (not the "force new file format" option)
#>
#[System.Security.Cryptography.HMACRIPEMD160] $r;

[void] $Global:Session.SSHTunnel.CreateTunnel("GoldPlusTunnel-SSH");
$Global:Session.PostgreSQL.GetRecords(
    "GoldPlusTunnel-PostgreSQL-datamanagment_read",
    "SELECT person_id, first_name, last_name FROM public.t_person WHERE person_id = @PersonId;",
    @{ "@PersonId" = 10000001969 },
    @( "person_id", "first_name", "last_name" )
);


[void] $Global:Session.SSHTunnel.DestroyTunnel();
#[PSCustomObject] $Connection = $Global:Session.SSHTunnel.GetConnection("GoldPlusTunnel-SSH");
# [System.Diagnostics.ProcessStartInfo] $ProcessStartInfo = [System.Diagnostics.ProcessStartInfo]::new();
# $ProcessStartInfo.FileName = "ssh"
# $ProcessStartInfo.RedirectStandardError = $true;
# $ProcessStartInfo.RedirectStandardOutput = $true;
# $ProcessStartInfo.RedirectStandardInput = $true;
# $ProcessStartInfo.UseShellExecute = $false;
# $ProcessStartInfo.Arguments = @(
#     [String]::Format(
#         "`"ssh://{0}@{1}:{2}`"",
#         $Connection.UserName,
#         $Connection.SSHServerAddress,
#         $Connection.SSHServerPort
#     ),
#     "-i",
#     [String]::Format(
#         "`"{0}`"",
#         $Connection.KeyFilePath
#     ),
#     "-L",
#     [String]::Format(
#         "{0}:{1}:{2}:{3}",
#         $Connection.LocalAddress,
#         $Connection.LocalPort,
#         $Connection.RemoteAddress,
#         $Connection.RemotePort
#     )
# );
# [System.Diagnostics.Process] $Process = [System.Diagnostics.Process]::new()
# $Process.StartInfo = $ProcessStartInfo
# [void] $Process.Start();



#Read-Host -Prompt "ASDFASDFASDF"
# [void] $Process.StandardInput.WriteLine("logout")
# [void] $Process.Dispose();


# [String] $ConnectionName = "GoldPlusTunnel-PostgreSQL-datamanagment_read";

# $Global:Session.PostgreSQL.GetRecords(
#     "GoldPlusTunnel-PostgreSQL-datamanagment_read",
#     "SELECT person_id, first_name, last_name FROM public.t_person WHERE person_id = @PersonId;",
#     @{ "@PersonId" = 10000001969 },
#     @( "person_id", "first_name", "last_name" )
# );


# [String] $ConnectionString = $Global:Session.PostgreSQL.GetConnectionString($ConnectionName);
# [Npgsql.NpgsqlConnection] $Connection = $null;
# [Npgsql.NpgsqlCommand] $Command = $null;
# [Npgsql.NpgsqlDataReader] $DataReader = $null;
# $Connection = [Npgsql.NpgsqlConnection]::new($ConnectionString);
# $Connection.Open();
# $Command = [Npgsql.NpgsqlCommand]::new($CommandText, $Connection);
# $Command.CommandType = [Data.CommandType]::Text;
# ForEach ($ParameterKey In $Parameters.Keys)
# {
#     [String] $Name = $ParameterKey;
#     If (!$Name.StartsWith("@"))
#         { $Name = "@" + $Name}
#     [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
# }
# $DataReader = $Command.ExecuteReader();
# While ($DataReader.Read())
# {
#     Write-Host ([String]::Format("{0} === {1}",
#         "person_id",
#         $DataReader.GetInt64($DataReader.GetOrdinal("person_id")).ToString()
#     ))
#     Write-Host ([String]::Format("{0} === {1}",
#         "first_name",
#         $DataReader.GetString($DataReader.GetOrdinal("first_name")).ToString()
#     ))
#     Write-Host ([String]::Format("{0} === {1}",
#         "last_name",
#         $DataReader.GetString($DataReader.GetOrdinal("last_name")).ToString()
#     ))
# }
# If ($DataReader)
# {
#     If (!$DataReader.IsClosed)
#         { [void] $DataReader.Close(); }
#     [void] $DataReader.Dispose();
# }
# If ($Command)
#     { [void] $Command.Dispose(); }
# If ($Connection)
# {
#     If (!$Connection.State -ne [Data.ConnectionState]::Closed)
#         { [void] $Connection.Close(); }
#     [void] $Connection.Dispose();
# }





#  $Global:Session.PostgreSQL.GetRecords(
#      "GoldPlusTunnel-PostgreSQL-datamanagment_read", #ConnectionName - Connection file name
#      "SELECT code, name FROM public.t_language WHERE code = @Code", #CommandText - SQL command, use "@" prefix for parameters
#      @{ "Code" = "en"; }, #Parameters - The name can be prefixed with "@" or not. The code checks for this
#      @( "code", "name" ) #Fields - The fileds to return in the array.
#                           #          If all fields should be returned, then use @("*").
# );
# # [void] $Global:Session.SSHTunnel.DestroyTunnel();
