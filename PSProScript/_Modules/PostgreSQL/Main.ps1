[void] $Global:Session.LoadModule("Connections");

[void] $Global:Session.NuGet.InstallPackageVersionIfMissing("Npgsql", "5.0.0");
[void] $Global:Session.NuGet.AddAssembly("Npgsql", "Npgsql.5.0.0\lib\net5.0\Npgsql.dll");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "PostgreSQL" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

#region Connection Methods
Add-Member `
    -InputObject $Global:Session.PostgreSQL `
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
            [String] $Comments,
            
            [Parameter(Mandatory=$true)]
            [Boolean] $IsPersisted
        )
        $Global:Session.Connections.Set(
            $Name,
            [PSCustomObject]@{
                "Server" = $Server;
                "Port" = $Port;
                "Database" = $Database;
                "UserName" = $UserName;
                "Password" = $Password;
                "Comments" = $Comments;
            },
            $IsPersisted
        );
    };
Add-Member `
    -InputObject $Global:Session.PostgreSQL `
    -Name "GetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        Return $Global:Session.Connections.Get($Name);
    };
Add-Member `
    -InputObject $Global:Session.PostgreSQL `
    -Name "GetConnectionString" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        $Connection = $Global:Session.PostgreSQL.GetConnection($Name);
        Return [String]::Format(
            "Server={0};Port={1};Database={2};User ID={3};Password={4};",
            $Connection.Server,
            $Connection.Port,
            $Connection.Database,
            $Connection.UserName,
            $Connection.Password
        );
    };
#endregion Connection Methods

#region Base Methods
Add-Member `
    -InputObject $Global:Session.PostgreSQL `
    -Name "Execute" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $CommandText,
    
            [Parameter(Mandatory=$false)]
            [Collections.Hashtable] $Parameters
        )
        [Npgsql.NpgsqlConnection] $Connection = $null;
        [Npgsql.NpgsqlCommand] $Command = $null;
        Try
        {
            $Connection = [Npgsql.NpgsqlConnection]::new($Global:Session.PostgreSQL.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Npgsql.NpgsqlCommand]::new($CommandText, $Connection);
            $Command.CommandType = [Data.CommandType]::Text;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If (!$Name.StartsWith("@"))
                    { $Name = "@" + $Name}
                [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
            }
            [void] $Command.ExecuteNonQuery();
        }
        Finally
        {
            If ($Command)
                { [void] $Command.Dispose(); }
            If ($Connection)
            {
                If (!$Connection.State -ne [Data.ConnectionState]::Closed)
                    { [void] $Connection.Close(); }
                [void] $Connection.Dispose();
            }
        }
    };
Add-Member `
    -InputObject $Global:Session.PostgreSQL `
    -Name "GetRecords" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $CommandText,

            [Parameter(Mandatory=$true)]
            [Collections.Hashtable] $Parameters,

            [Parameter(Mandatory=$true)]
            [Collections.Generic.List[String]] $Fields
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [Npgsql.NpgsqlConnection] $Connection = $null;
        [Npgsql.NpgsqlCommand] $Command = $null;
        [Npgsql.NpgsqlDataReader] $DataReader = $null;
        Try
        {
            $Connection = [Npgsql.NpgsqlConnection]::new($Global:Session.PostgreSQL.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Npgsql.NpgsqlCommand]::new($CommandText, $Connection);
            $Command.CommandType = [Data.CommandType]::Text;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If (!$Name.StartsWith("@"))
                    { $Name = "@" + $Name}
                [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
            }
            $DataReader = $Command.ExecuteReader();
            If ($Fields.Contains("*"))
            {
                [void] $Fields.Clear();
                For ($FieldIndex = 0; $FieldIndex -lt $DataReader.FieldCount; $FieldIndex ++)
                {
                    [void] $Fields.Add($DataReader.GetName($FieldIndex));
                }
            }
            While ($DataReader.Read())
            {
                [PSObject] $Record = [PSObject]::new();
                ForEach ($Field In $Fields)
                {
                    Add-Member `
                        -InputObject $Record `
                        -TypeName ($Value.GetType().Name) `
                        -NotePropertyName $Field `
                        -NotePropertyValue $DataReader.GetValue($DataReader.GetOrdinal($Field));
                }
                [void] $ReturnValue.Add([PSObject]$Record);
            }
        }
        Finally
        {
            If ($DataReader)
            {
                If (!$DataReader.IsClosed)
                    { [void] $DataReader.Close(); }
                [void] $DataReader.Dispose();
            }
            If ($Command)
                { [void] $Command.Dispose(); }
            If ($Connection)
            {
                If (!$Connection.State -ne [Data.ConnectionState]::Closed)
                    { [void] $Connection.Close(); }
                [void] $Connection.Dispose();
            }
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.PostgreSQL `
    -Name "GetScalar" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Object])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $CommandText,

            [Parameter(Mandatory=$true)]
            [Collections.Hashtable] $Parameters,

            [Parameter(Mandatory=$true)]
            [Collections.Generic.List[String]] $Fields
        )
        [Object] $ReturnValue = $null;
        [Npgsql.NpgsqlConnection] $Connection = $null;
        [Npgsql.NpgsqlCommand] $Command = $null;
        Try
        {
            $Connection = [Npgsql.NpgsqlConnection]::new($Global:Session.PostgreSQL.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Npgsql.NpgsqlCommand]::new($CommandText, $Connection);
            $Command.CommandType = [Data.CommandType]::Text;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If (!$Name.StartsWith("@"))
                    { $Name = "@" + $Name}
                [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
            }
            $ReturnValue = $Command.ExecuteScalar();
            If ($ReturnValue -is [System.DBNull])
            {
                $ReturnValue = $null;
            }
        }
        Finally
        {
            If ($Command)
                { [void] $Command.Dispose(); }
            If ($Connection)
            {
                If (!$Connection.State -ne [Data.ConnectionState]::Closed)
                    { [void] $Connection.Close(); }
                [void] $Connection.Dispose();
            }
        }
        Return $ReturnValue;
    }
#endregion Base Methods

Add-Member `
    -InputObject $Global:Session.PostgreSQL `
    -Name "ClearTable" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table
        )
        [void] $Global:Session.PostgreSQL.Execute(
            $ConnectionName,
            [String]::Format("TRUNCATE TABLE {0}.{1}", $Schema, $Table)
        );
    };
Add-Member `
    -InputObject $Global:Session.PostgreSQL `
    -Name "GetTableRowCount" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Int64])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table,

            [Parameter(Mandatory=$true)]
            [Collections.Hashtable] $Filters
        )
        [Int64] $ReturnValue = 0;
        [String] $WhereClause = "";
        [Collections.Hashtable] $Parameters = [Collections.Hashtable]::new();
        If ($Filters)
        {
            If ($Filters.Count -gt 0)
            {
                $WhereClause = " WHERE ";
                [Int32] $FilterIndex = 0;
                ForEach ($FilterKey In $Filters.Keys)
                {
                    $WhereClause += [String]::Format(
                        (
                            ($FilterIndex -eq 0) ?    
                                "{0} = @Param{1}" :
                                " AND {0} = @Param{1}"
                        ),
                        $FilterKey,
                        $FilterIndex
                    );
                    [void] $Parameters.Add(
                        [String]::Format("@Param{0}", $FilterIndex),
                        $Filters[$FilterKey]
                    );
                }
            }
        }
        [Object] $ScalarValue = $Global:Session.Sqlite.GetScalar(
            $ConnectionName,
            [String]::Format("SELECT COUNT(*) FROM {0}.{1}{2}",
                $Schema,
                $Table,
                $WhereClause # May be an empty string if $Filters is null or empty
            ),
            $Parameters
        );
        If (
            $ScalarValue -is [Int64] -or
            $ScalarValue -is [Int32] -or
            $ScalarValue -is [Int16] -or
            $ScalarValue -is [Byte]
        )
        {
            $ReturnValue = [Int64]$ScalarValue;
        }
        Return $ReturnValue
    };
Add-Member `
    -InputObject $Global:Session.PostgreSQL `
    -Name "DoesTableHaveColumn" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table,

            [Parameter(Mandatory=$true)]
            [String] $Column
        )
        [Boolean] $ReturnValue = $false;
        [Object] $ScalarValue = $Global:Session.PostgreSQL.GetScalar(
            $ConnectionName,
            (
                "SELECT 1 AS HasColumn FROM pg_namespace`r`n" +
                "INNER JOIN pg_class ON pg_namespace.oid = pg_class.relnamespace`r`n" +
                "INNER JOIN pg_attribute ON pg_class.oid = pg_attribute.attrelid`r`n" +
                "WHERE pg_namespace.nspname = @Schema AND pg_class.relname = @Table AND pg_attribute.attname = @Column"
            ),
            @{
                "@Schema" = $Schema;
                "@Table" = $Table;
                "@Column" = $Column;
            }
        );
        If (
            $ScalarValue -is [Int64] -or
            $ScalarValue -is [Int32] -or
            $ScalarValue -is [Int16] -or
            $ScalarValue -is [Byte]
        )
        {
            If (([Int64]$ScalarValue) -eq 1)
            {
                $ReturnValue = $true;
            }
        }
        Return $ReturnValue
    };
