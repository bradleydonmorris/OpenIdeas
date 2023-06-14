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

$Global:Session.SSHTunnel.SetKeyAuthTunnelConnection(
    $null, #Name - Name of the Connection file
    $null, #SSHServerAddress - SSH Server Address
    22, #SSHServerPost - SSH Server Port
    $null, #UserName - SSH User Name
    $null, #KeyFilePath - SSH Private Key File
    $null, #KeyFilePassphrase - SSH Key File Pashphrase
    $null, #LocalAddress - Local address for tunnel. This will be what is used in a Postgre Connection
    $null, #LocalPort - Local port for tunnel. This will be what is used in a Postgre Connection
    $null, #RemoteAddress - The actual PostgreSQL server name
    $null, #RemotePort - The actual PostgreSQL server port

    #Comments
    "This is for tunneling the datamanagement_read account on GoldPlus. The local PostgreSQL connection info will be stored in a separatePostgreSQL Connection file."
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

[void] $Global:Session.SSHTunnel.CreateKeyAuthTunnel("GoldPlusTunnel-SSH");
$Global:Session.PostgreSQL.GetRecords(
    "GoldPlusTunnel-PostgreSQL-datamanagment_read", #ConnectionName - Connection file name
    "SELECT code, name FROM public.t_language WHERE code = @Code", #CommandText - SQL command, use "@" prefix for parameters
    @{ "Code" = "en"; }, #Parameters - The name can be prefixed with "@" or not. The code checks for this
    @( "code", "name" ) #Fields - The fileds to return in the array.
                         #          If all fields should be returned, then use @("*").
);
[void] $Global:Session.SSHTunnel.DestroyTunnel();
