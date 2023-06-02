If (!$Global:Job.NuGet.IsPackageInstalled("Microsoft.Data.Sqlite"))
{
    [void] $Global:Job.NuGet.InstallPackage("Microsoft.Data.Sqlite");
}
$Global:Job.NuGet.AddAssembly("Stub.System.Data.Sqlite.Core.NetFramework.1.0.117.0\lib\net451\System.Data.Sqlite.dll");

Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Sqlite" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Sqlite `
    -Name "CreateDatabase" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $DatabasePath,

            [Parameter(Mandatory=$true)]
            [String] $ScriptFilePath
        )
        [Data.Sqlite.SqliteConnection] $SqliteConnection = [Data.Sqlite.SqliteConnection]::new([String]::Format("Data Source={0}", $DatabasePath));
        $SqliteConnection.Open();
        [String] $CommandText = [IO.File]::ReadAllText($ScriptFilePath);
        [Data.Sqlite.SqliteCommand] $SqliteCommand = [Data.Sqlite.SqliteCommand]::new($CommandText, $SqliteConnection);
        $SqliteCommand.CommandType = [Data.CommandType]::Text;
        Try
        {
            [void] $SqliteCommand.ExecuteNonQuery();
        }
        Finally {}
        [void] $SqliteCommand.Dispose();
        [void] $SqliteConnection.Close();
        [void] $SqliteConnection.Dispose();
    }
Add-Member `
    -InputObject $Global:Job.Sqlite `
    -Name "GetRecords" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $DatabasePath,

            [Parameter(Mandatory=$true)]
            [String] $ScriptFilePath,

            [Parameter(Mandatory=$true)]
            [Collections.Hashtable] $Parameters,

            [Parameter(Mandatory=$true)]
            [Collections.ArrayList] $Fields
        )
        [Collections.ArrayList] $ReturnValue = [Collections.ArrayList]::new();
        [Data.Sqlite.SqliteConnection] $SqliteConnection = [Data.Sqlite.SqliteConnection]::new([String]::Format("Data Source={0}", $DatabasePath));
        $SqliteConnection.Open();
        [String] $CommandText = [IO.File]::ReadAllText($ScriptFilePath);
        [Data.Sqlite.SqliteCommand] $SqliteCommand = [Data.Sqlite.SqliteCommand]::new($CommandText, $SqliteConnection);
        $SqliteCommand.CommandType = [Data.CommandType]::Text;
        Try
        {
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If (!$Name.StartsWith("@"))
                    { $Name = "@" + $Name}
                [void] $SqliteCommand.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
            }
            [Data.Sqlite.SqliteDataReader] $SqliteDataReader = $SqliteCommand.ExecuteReader();
            While ($SqliteDataReader.Read())
            {
                [Collections.Hashtable] $Record = [Collections.Hashtable]::new();
                ForEach ($Field In $Fields)
                {
                    [void] $Record.Add(
                        $Field,
                        $SqliteDataReader.GetValue($SqliteDataReader.GetOrdinal($Field))
                    );
                }
                [void] $ReturnValue.Add($Record);
            }
            [void] $SqliteDataReader.Close();
            [void] $SqliteDataReader.Dispose();
        }
        Finally {}
        [void] $SqliteCommand.Dispose();
        [void] $SqliteConnection.Close();
        [void] $SqliteConnection.Dispose();
        Return $ReturnValue;
    }