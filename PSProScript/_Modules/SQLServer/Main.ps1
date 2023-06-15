[void] $Global:Session.LoadModule("Connections");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "SQLServer" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

#region Connection Methods
Add-Member `
    -InputObject $Global:Session.SQLServer `
    -Name "SetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,
    
            [Parameter(Mandatory=$true)]
            [String] $Instance,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$true)]
            [Boolean] $IntegratedSecurity,

            [Parameter(Mandatory=$true)]
            [String] $UserName,
    
            [Parameter(Mandatory=$true)]
            [String] $Password,
    
            [Parameter(Mandatory=$false)]
            [String] $Comments,
            
            [Parameter(Mandatory=$true)]
            [Boolean] $IsPersisted
        )
        $Global:Session.Connections.Set(
            $Name,
            [PSCustomObject]@{
                "Instance" = $Instance;
                "Database" = $Database;
                "IntegratedSecurity" = $IntegratedSecurity.ToString();
                "UserName" = $UserName;
                "Password" = $Password;
                "Comments" = $Comments;
            },
            $IsPersisted
        );
    };
Add-Member `
    -InputObject $Global:Session.SQLServer `
    -Name "GetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSCustomObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        Return $Global:Session.Connections.Get($Name);
    };
Add-Member `
    -InputObject $Global:Session.SQLServer `
    -Name "GetConnectionString" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        $Connection = $Global:Session.SQLServer.GetConnection($Name);
        Return [String]::Format(
            "Server={0};Database={1};{2};Workstation ID={3};Application Name={4};",
            $Connection.Instance,
            $Connection.Database,
            (
                ($Connection.IntegratedSecurity -eq "True") ?
                    "Trusted_Connection=True" :
                    [String]::Format("User ID={0};Password={1}",
                        $Connection.UserName,
                        $Connection.Password
                    )
            ),
            [System.Net.Dns]::GetHostName(),
            [String]::Format("{0}/{1}",
                $Global:Session.Project,
                $Global:Session.Script
            )
        );
    };
#endregion Connection Methods

#region Base Methods
Add-Member `
    -InputObject $Global:Session.SQLServer `
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
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServer.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
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
    }
Add-Member `
    -InputObject $Global:Session.SQLServer `
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
            [Collections.ArrayList] $Fields
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
        [Data.SqlClient.SqlDataReader] $DataReader = $null;
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServer.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
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
                {
                    [void] $DataReader.Close();
                }
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
    -InputObject $Global:Session.SQLServer `
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
            [Collections.Hashtable] $Parameters
        )
        [Object] $ReturnValue = $null;
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServer.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
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
Add-Member `
    -InputObject $Global:Session.SQLServer `
    -Name "ProcExecute" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $Schema,

            [Parameter(Mandatory=$true)]
            [String] $Procedure,
    
            [Parameter(Mandatory=$false)]
            [Collections.Hashtable] $Parameters
        )
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
		[String] $CommandText = [String]::Format("[{0}].[{1}]", $Schema, $Procedure);
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServer.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
            $Command.CommandType = [Data.CommandType]::StoredProcedure;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If ($Name.StartsWith("@"))
                    { $Name = $Name.Substring(1)}
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
    }
Add-Member `
    -InputObject $Global:Session.SQLServer `
    -Name "ProcGetRecords" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.Generic.List[PSObject]])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

             [Parameter(Mandatory=$true)]
            [String] $Schema,

            [Parameter(Mandatory=$true)]
            [String] $Procedure,

            [Parameter(Mandatory=$true)]
            [Collections.Hashtable] $Parameters,

            [Parameter(Mandatory=$true)]
            [Collections.ArrayList] $Fields
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
        [Data.SqlClient.SqlDataReader] $DataReader = $null;
		[String] $CommandText = [String]::Format("[{0}].[{1}]", $Schema, $Procedure);
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServer.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
            $Command.CommandType = [Data.CommandType]::StoredProcedure;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If ($Name.StartsWith("@"))
                    { $Name = $Name.Substring(1)}
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
                {
                    [void] $DataReader.Close();
                }
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
    -InputObject $Global:Session.SQLServer `
    -Name "ProcGetScalar" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Object])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $Schema,

            [Parameter(Mandatory=$true)]
            [String] $Procedure,

            [Parameter(Mandatory=$true)]
            [Collections.Hashtable] $Parameters
        )
        [Object] $ReturnValue = $null;
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
		[String] $CommandText = [String]::Format("[{0}].[{1}]", $Schema, $Procedure);
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServer.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
            $Command.CommandType = [Data.CommandType]::StoredProcedure;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If ($Name.StartsWith("@"))
                    { $Name = $Name.Substring(1)}
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
    -InputObject $Global:Session.SQLServer `
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
        $Global:Session.PostgreSQL.Execute(
            $ConnectionName,
            [String]::Format("TRUNCATE TABLE [{0}].[{1}]", $Schema, $Table)
        );
    };
Add-Member `
    -InputObject $Global:Session.SQLServer `
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
                                "[{0}] = @Param{1}" :
                                " AND [{0}] = @Param{1}"
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
        [Object] $ScalarValue = $Global:Session.SQLServer.GetScalar(
            $ConnectionName,
            [String]::Format("SELECT COUNT_BIG(*) FROM [{0}].[{1}]{2}",
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
    -InputObject $Global:Session.SQLServer `
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
        [Object] $ScalarValue = $Global:Session.SQLServer.GetScalar(
            $ConnectionName,
            (
                "SELECT 1 FROM [sys].[schemas]`r`n" +
                "INNER JOIN [sys].[objects] ON [schemas].[schema_id] = [objects].[schema_id]`r`n" +
                "INNER JOIN  [sys].[columns] ON [objects].[object_id] = [columns].[object_id]`r`n" +
                "WHERE [schemas].[name] = @Schema AND [objects].[name] = @Table AND [columns].[name] = @Column"
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
