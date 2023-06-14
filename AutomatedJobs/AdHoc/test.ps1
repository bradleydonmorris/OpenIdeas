. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1"));
$Global:Job.LoadModule("SQLServer");
$Global:Job.LoadModule("Compression7Zip");
#$Global:Job.Compression7Zip.GetAssets("C:\keys\test.zip");
#$Global:Job.Compression7Zip.ExtractAsset("C:\keys\test.zip", "keys\temp.rsa", "C:\keys\trash");


#$Global:Job.Connections.Get("FOXLocalActiveDirectory");

# [void] $Global:Job.SQLServer.SetConnection(
#     "ActiveDirectoryDatabase",
#     "TUL-IT-WL-19",
#     "Integrations",
#     $true,
#     $null,
#     $null,
#     "Connection for ActiveDirectory Schema in Integrations database",
#     $true
# );
$Global:Job.SQLServer.GetConnection("ActiveDirectoryDatabase");
$Global:Job.SQLServer.GetConnectionString("ActiveDirectoryDatabase");


# [NamedConnection] $NamedConnection = [NamedConnection]::new("FOXLocalActiveDirectory", "Connection for ActiveDirectory LDAP");
# [void] $NamedConnection.Set("Test", "Asdf");
# $NamedConnection

