[void] $Global:Job.NuGet.InstallPackageVersionIfMissing("Npgsql", "5.0.0");
[void] $Global:Job.NuGet.AddAssembly("Npgsql", "Npgsql.5.0.0\lib\net5.0\Npgsql.dll");

Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "PostgreSQL" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.PostgreSQL `
    -Name "GetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        $Values = $Global:Job.Connections.Get($Name);
        Return [String]::Format(
            "Server={0};Port={1};Database={2};User ID={3};Password={4};",
            $Values.Server,
            $Values.Port,
            $Values.Database,
            $Values.UserName,
            $Values.Password
        );
    };
Add-Member `
    -InputObject $Global:Job.PostgreSQL `
    -Name "SetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,
    
            [Parameter(Mandatory=$true)]
            [String] $Server,
    
            [Parameter(Mandatory=$true)]
            [Int32] $Port,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$false)]
            [String] $UserName,
    
            [Parameter(Mandatory=$false)]
            [String] $Password,
    
            [Parameter(Mandatory=$false)]
            [String] $Comments
        )
        $Global:Job.Connections.Set(
            $Name,
            [PSCustomObject]@{
                "Server" = $Server;
                "Port" = $Port;
                "Database" = $Database;
                "UserName" = $UserName;
                "Password" = $Password;
                "Comments" = $Comments;
            }
        );
    };
Add-Member `
    -InputObject $Global:Job.PostgreSQL `
    -Name "GetRecords" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $CommandText,

            [Parameter(Mandatory=$true)]
            [Collections.Hashtable] $Parameters,

            [Parameter(Mandatory=$true)]
            [Collections.ArrayList] $Fields
        )
        [Collections.ArrayList] $ReturnValue = [Collections.ArrayList]::new();
        [Npgsql.NpgsqlConnection] $NpgsqlConnection = $null;
        [Npgsql.NpgsqlCommand] $NpgsqlCommand = $null;
        [Npgsql.NpgsqlDataReader] $NpgsqlDataReader = $null;
        Try
        {
            $NpgsqlConnection = [Npgsql.NpgsqlConnection]::new($Global:Job.PostgreSQL.GetConnection($ConnectionName));
            $NpgsqlConnection.Open();
            $NpgsqlCommand = [Npgsql.NpgsqlCommand]::new($CommandText, $NpgsqlConnection);
            $NpgsqlCommand.CommandType = [Data.CommandType]::Text;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If (!$Name.StartsWith("@"))
                    { $Name = "@" + $Name}
                [void] $NpgsqlCommand.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
            }
            $NpgsqlDataReader = $NpgsqlCommand.ExecuteReader();
            If ($Fields.Contains("*"))
            {
                $Fields.Clear();
                For ($FieldIndex = 0; $FieldIndex -lt $NpgsqlDataReader.FieldCount; $FieldIndex ++)
                {
                    [void] $Fields.Add($NpgsqlDataReader.GetName($FieldIndex));
                }
            }
            While ($NpgsqlDataReader.Read())
            {
                [Collections.Hashtable] $Record = [Collections.Hashtable]::new();
                ForEach ($Field In $Fields)
                {
                    [void] $Record.Add(
                        $Field,
                        $NpgsqlDataReader.GetValue($NpgsqlDataReader.GetOrdinal($Field))
                    );
                }
                [void] $ReturnValue.Add($Record);
            }
        }
        Finally
        {
            If ($NpgsqlDataReader)
            {
                If (!$NpgsqlDataReader.IsClosed)
                    { [void] $NpgsqlDataReader.Close(); }
                [void] $NpgsqlDataReader.Dispose();
            }
            If ($NpgsqlCommand)
                { [void] $NpgsqlCommand.Dispose(); }
            If ($NpgsqlConnection)
            {
                If (!$NpgsqlConnection.State -ne [Data.ConnectionState]::Closed)
                    { [void] $NpgsqlDataReader.Close(); }
                [void] $NpgsqlDataReader.Dispose();
            }
        }
        Return $ReturnValue;
    }
