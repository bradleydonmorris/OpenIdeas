. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1"));
#$Global:Session.LoadModule("SQLServer");
#$Global:Session.LoadModule("Compression7Zip");
$Global:Session.LoadModule("GoogleAPI");

#$Global:Session.Connections.Get("GoogleAPI");
#$Global:Session.GoogleAPI.GetConnection("GoogleAPI");
#$Global:Session.GoogleAPI.GetRefreshedToken("GoogleAPI");
$Global:Session.GoogleAPI.GetUsers("GoogleAPI", $true);
#$Global:Session.GoogleAPI.GetGroups("GoogleAPI", $true);
#$tii = $Global:Session.GoogleAPI.GetOrgUnits("GoogleAPI");
#$tii

#$Global:Session.LoadModule("ActiveDirectorySQLDatabase");
#$Global:Session.Compression7Zip.GetAssets("C:\keys\test.zip");
#$Global:Session.Compression7Zip.ExtractAsset("C:\keys\test.zip", "keys\temp.rsa", "C:\keys\trash");


#$Global:Session.Connections.Get("FOXLocalActiveDirectory");

# [void] $Global:Session.SQLServer.SetConnection(
#     "ActiveDirectoryDatabase",
#     "TUL-IT-WL-19",
#     "Integrations",
#     $true,
#     $null,
#     $null,
#     "Connection for ActiveDirectory Schema in Integrations database",
#     $true
# );
#$Global:Session.SQLServer.GetConnection("ActiveDirectoryDatabase");

# $Global:Session.SQLServer.GetConnectionString("ActiveDirectoryDatabase");
# $Global:Session.ActiveDirectorySQLDatabase.GetUserLastWhenChangedTime("ActiveDirectoryDatabase");

# [NamedConnection] $NamedConnection = [NamedConnection]::new("FOXLocalActiveDirectory", "Connection for ActiveDirectory LDAP");
# [void] $NamedConnection.Set("Test", "Asdf");
# $NamedConnection

