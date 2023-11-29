. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "NuGet",
    "SQLServer"
);
$Global:Session.NuGet.InstallPackageIfMissing("Microsoft.Data.SqlClient");
$Global:Session.NuGet.InstallPackageIfMissing("Microsoft.SqlServer.SqlManagementObjects");
[void] $Global:Session.NuGet.AddAssembly("Microsoft.Data.SqlClient", "Microsoft.Data.SqlClient.5.1.2\runtimes\win\lib\netstandard2.1\Microsoft.Data.SqlClient.dll");

[void] $Global:Session.NuGet.AddAssembly("Microsoft.SqlServer.ConnectionInfo", "Microsoft.SqlServer.SqlManagementObjects.170.18.0\lib\netstandard2.0\Microsoft.SqlServer.ConnectionInfo.dll");
[void] $Global:Session.NuGet.AddAssembly("Microsoft.SqlServer.Smo", "Microsoft.SqlServer.SqlManagementObjects.170.18.0\lib\netstandard2.0\Microsoft.SqlServer.Smo.dll");

[String] $ConnectionName = "LegacyAdHoc";
# $Global:Session.SQLServer.SetConnection($ConnectionName, $null, $false,
#        "tsd-sql02-aws.fox.local", "master", $true, $null, $null
# );
$Global:Session.SQLServer.SetConnection($ConnectionName, $null, $false,
       "localhost", "master", $true, $null, $null
);
$Global:Session.SQLServer.GetRecords($ConnectionName, "SELECT @@SPID AS [SPID]", $null);

[Microsoft.SqlServer.Management.Common.SqlConnectionInfo] $SqlConnectionInfo  = [Microsoft.SqlServer.Management.Common.SqlConnectionInfo]::new()
#$SqlConnectionInfo.ConnectionString = $Global:Session.SQLServer.GetConnectionString($ConnectionName)
$SqlConnectionInfo.ServerName = "localhost";
$SqlConnectionInfo.UseIntegratedSecurity = $true;
$SqlConnectionInfo.ApplicationName = [String]::Format("PS:{0}/{1}",
       $Global:Session.Project,
       $Global:Session.Script
);
$SqlConnectionInfo.WorkstationId = [System.Net.Dns]::GetHostName();
$SqlConnectionInfo.TrustServerCertificate = $true;
$SqlConnectionInfo.ConnectionString;

# $svr = new-object ('Microsoft.SQLServer.Management.SMO.Server') "localhost"
# $svr.GetSqlServerVersionName()
[Microsoft.SqlServer.Management.Common.ServerConnection] $ServerConnection = [Microsoft.SqlServer.Management.Common.ServerConnection]::new($SqlConnectionInfo);
$ServerConnection.LoginSecure = $true;
$ServerConnection.NetworkProtocol = [Microsoft.SqlServer.Management.Common.NetworkProtocol]::TcpIp;
[Microsoft.SqlServer.Management.Smo.Server] $Server = [Microsoft.SqlServer.Management.Smo.Server]::new($ServerConnection);

$Server
#$ServerConnection.IsOpen


#$SqlConnection.Open();

# [String] $ConnectionString = [String]::Format(
#             "Server={0};Database={1};Trusted_Connection=True;Workstation ID={2};Application Name=`"PS:{3}`";",
#             "tsd-sql02-aws.fox.local",
#             "Legacy",
#             [System.Net.Dns]::GetHostName(),
#             [String]::Format("{0}/{1}",
#                 $Global:Session.Project,
#                 $Global:Session.Script
#             )
#         );
# [Microsoft.Data.SqlClient.SqlConnection] $SqlConnection = [Microsoft.Data.SqlClient.SqlConnection]::new($ConnectionString);
# $SqlConnection.Open();
#[Microsoft.SqlServer.Management.Common.ServerConnection] $ServerConnection = [Microsoft.SqlServer.Management.Common.ServerConnection]::new($SqlConnection);

#[void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlManagementObjects");
#[Microsoft.SqlServer.SqlManagementObjects]
#[Microsoft.SqlServer.Smo.Server] $Server = [Microsoft.SqlServer.Smo.Server]::new($ServerConnection);

#$Server
# ["Legacy"] | gm

# $serverInstance = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $ServerName
# $IncludeTypes = @("Tables","StoredProcedures","Views","UserDefinedFunctions", "Triggers") #object you want do backup. 
# $ExcludeSchemas = @("sys","Information_Schema")
# $so = new-object ('Microsoft.SqlServer.Management.Smo.ScriptingOptions')

<#
$dbs=$serverInstance.Databases #you can change this variable for a query for filter yours databases.
foreach ($db in $dbs)
{
       $dbname = "$db".replace("[","").replace("]","")
       $dbpath = "$path"+ "\"+"$dbname" + "\"
    if ( !(Test-Path $dbpath))
           {$null=new-item -type directory -name "$dbname"-path "$path"}
 
       foreach ($Type in $IncludeTypes)
       {
              $objpath = "$dbpath" + "$Type" + "\"
         if ( !(Test-Path $objpath))
           {$null=new-item -type directory -name "$Type"-path "$dbpath"}
              foreach ($objs in $db.$Type)
              {
                     If ($ExcludeSchemas -notcontains $objs.Schema ) 
                      {
                           $ObjName = "$objs".replace("[","").replace("]","")                  
                           $OutFile = "$objpath" + "$ObjName" + ".sql"
                           $objs.Script($so)+"GO" | out-File $OutFile
                      }
              }
       }     
}
#>