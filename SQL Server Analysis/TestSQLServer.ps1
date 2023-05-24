Param
(
    [Parameter(Mandatory=$true)]
    [String] $SQLServerInstance
)

[Collections.Hashtable] $Results = [Collections.Hashtable]::new();
[String] $ConnectionString = "Server=tcp:$SQLServerInstance;Database=master;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
[String] $CommanText = @"
SELECT
    @@SERVERNAME AS [@@SERVERNAME],
	DB_NAME() AS [DB_NAME()],
    USER_NAME() AS [USER_NAME()],
    SUSER_SNAME() AS [SUSER_SNAME()],
	HOST_NAME() AS [HOST_NAME()],
	APP_NAME() AS [APPNAME()]
"@
[Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
[void] $SqlConnection.Open();
[Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($CommanText, $SqlConnection);
$SqlCommand.CommandType = [Data.CommandType]::Text
$SqlCommand.CommandTimeout = 0;
[Data.SqlClient.SqlDataReader] $SqlDataReader = $SqlCommand.ExecuteReader();
While ($SqlDataReader.Read())
{
    $Results = [Collections.Hashtable]::new();
    For ($Index = 0; $Index -lt $SqlDataReader.FieldCount; $Index ++)
    {
        [void] $Results.Add(
            $SqlDataReader.GetName($Index),
            $SqlDataReader.GetValue($Index)
        );
    }
}
[void] $SqlDataReader.Close();
[void] $SqlDataReader.Dispose();
[void] $SqlCommand.Dispose();
[void] $SqlConnection.Close();
[void] $SqlConnection.Dispose();
$Results;
