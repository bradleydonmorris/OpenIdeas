[void] $Global:Session.LoadModule("Connections");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "SQLServerLocalDB" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
    -TypeName "System.String" `
    -NotePropertyName "MasterConnectionName" `
    -NotePropertyValue "LocalDB-master";

#region Connection Methods
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
    -Name "SetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,
    
            [Parameter(Mandatory=$false)]
            [String] $Comments,
            
            [Parameter(Mandatory=$true)]
            [Boolean] $IsPersisted,
    
            [Parameter(Mandatory=$true)]
            [String] $DatabaseFilePath
        )
        $Global:Session.Connections.Set(
            $Name,
            [PSCustomObject]@{
                "Type" = "SQLServerLocalDB";
                "DatabaseFilePath" = $DatabaseFilePath;
                "Comments" = $Comments;
            },
            $IsPersisted
        );
    };
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
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
    -InputObject $Global:Session.SQLServerLocalDB `
    -Name "GetConnectionString" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [String] $ReturnValue = $null;
        If ($Name -eq $Global:Session.SQLServerLocalDB.MasterConnectionName)
        {
            $ReturnValue = "Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=master;Integrated Security=True;";
        }
        Else
        {
            [PSCustomObject] $Connection = $Global:Session.Connections.Get($Name);
            $ReturnValue = [String]::Format(
                "Data Source=(LocalDB)\MSSQLLocalDB;AttachDbFilename={0};Integrated Security=True;",
                $Connection.DatabaseFilePath
            );
        }
        Return $ReturnValue;
    };
#endregion Connection Methods

#region Base Methods
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
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
        [Exception] $Exception = $null;
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServerLocalDB.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
            $Command.CommandTimeout = 0;
            $Command.CommandType = [Data.CommandType]::Text;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If ($Name.StartsWith("@"))
                    { $Name = $Name.Substring(1)}
                If ($Parameters[$ParameterKey] -isnot [System.Xml.XmlElement])
                {
                    [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
                }
                Else
                {
                    [System.Data.SqlTypes.SqlXml] $SqlXml = [System.Data.SqlTypes.SqlXml]::new([System.Xml.XmlNodeReader]::new($Parameters[$ParameterKey]));
                    [void] $Command.Parameters.AddWithValue($Name, (
                        $SqlXml.IsNull ?  
                            [System.DBNull]::Value :
                            $SqlXml
                    ));
                }
            }
            [void] $Command.ExecuteNonQuery();
        }
        Catch
        {
            $Exception = $_.Exception;
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
        If ($Exception)
        {
            Throw $Exception;
        }
    }
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
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
        [Exception] $Exception = $null;
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
        [Data.SqlClient.SqlDataReader] $DataReader = $null;
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServerLocalDB.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
            $Command.CommandTimeout = 0;
            $Command.CommandType = [Data.CommandType]::Text;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If ($Name.StartsWith("@"))
                    { $Name = $Name.Substring(1)}
                If ($Parameters[$ParameterKey] -isnot [System.Xml.XmlElement])
                {
                    [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
                }
                Else
                {
                    [System.Data.SqlTypes.SqlXml] $SqlXml = [System.Data.SqlTypes.SqlXml]::new([System.Xml.XmlNodeReader]::new($Parameters[$ParameterKey]));
                    [void] $Command.Parameters.AddWithValue($Name, (
                        $SqlXml.IsNull ?  
                            [System.DBNull]::Value :
                            $SqlXml
                    ));
                }
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
                    [Object] $Value = $DataReader.GetValue($DataReader.GetOrdinal($Field));
                    Add-Member `
                        -InputObject $Record `
                        -TypeName ($Value.GetType().Name) `
                        -NotePropertyName $Field `
                        -NotePropertyValue $Value;
                }
                [void] $ReturnValue.Add([PSObject]$Record);
            }
        }
        Catch
        {
            $Exception = $_.Exception;
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
        If ($Exception)
        {
            Throw $Exception;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
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
        [Exception] $Exception = $null;
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServerLocalDB.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
            $Command.CommandTimeout = 0;
            $Command.CommandType = [Data.CommandType]::Text;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If ($Name.StartsWith("@"))
                    { $Name = $Name.Substring(1)}
                If ($Parameters[$ParameterKey] -isnot [System.Xml.XmlElement])
                {
                    [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
                }
                Else
                {
                    [System.Data.SqlTypes.SqlXml] $SqlXml = [System.Data.SqlTypes.SqlXml]::new([System.Xml.XmlNodeReader]::new($Parameters[$ParameterKey]));
                    [void] $Command.Parameters.AddWithValue($Name, (
                        $SqlXml.IsNull ?  
                            [System.DBNull]::Value :
                            $SqlXml
                    ));
                }
            }
            $ReturnValue = $Command.ExecuteScalar();
            If ($ReturnValue -is [System.DBNull])
            {
                $ReturnValue = $null;
            }
        }
        Catch
        {
            $Exception = $_.Exception;
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
        If ($Exception)
        {
            Throw $Exception;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
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
        [Exception] $Exception = $null;
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
		[String] $CommandText = [String]::Format("[{0}].[{1}]", $Schema, $Procedure);
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServerLocalDB.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
            $Command.CommandType = [Data.CommandType]::StoredProcedure;
            $Command.CommandTimeout = 0;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If ($Name.StartsWith("@"))
                    { $Name = $Name.Substring(1)}
                If ($Parameters[$ParameterKey] -isnot [System.Xml.XmlElement])
                {
                    [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
                }
                Else
                {
                    [System.Data.SqlTypes.SqlXml] $SqlXml = [System.Data.SqlTypes.SqlXml]::new([System.Xml.XmlNodeReader]::new($Parameters[$ParameterKey]));
                    [void] $Command.Parameters.AddWithValue($Name, (
                        $SqlXml.IsNull ?  
                            [System.DBNull]::Value :
                            $SqlXml
                    ));
                }
            }
            [void] $Command.ExecuteNonQuery();
        }
        Catch
        {
            $Exception = $_.Exception;
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
        If ($Exception)
        {
            Throw $Exception;
        }
    }
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
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
            [Collections.Generic.List[String]] $Fields
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [Exception] $Exception = $null;
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
        [Data.SqlClient.SqlDataReader] $DataReader = $null;
		[String] $CommandText = [String]::Format("[{0}].[{1}]", $Schema, $Procedure);
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServerLocalDB.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
            $Command.CommandTimeout = 0;
            $Command.CommandType = [Data.CommandType]::StoredProcedure;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If ($Name.StartsWith("@"))
                    { $Name = $Name.Substring(1)}
                If ($Parameters[$ParameterKey] -isnot [System.Xml.XmlElement])
                {
                    [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
                }
                Else
                {
                    [System.Data.SqlTypes.SqlXml] $SqlXml = [System.Data.SqlTypes.SqlXml]::new([System.Xml.XmlNodeReader]::new($Parameters[$ParameterKey]));
                    [void] $Command.Parameters.AddWithValue($Name, (
                        $SqlXml.IsNull ?  
                            [System.DBNull]::Value :
                            $SqlXml
                    ));
                }
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
                    [Object] $Value = $DataReader.GetValue($DataReader.GetOrdinal($Field));
                    Add-Member `
                        -InputObject $Record `
                        -TypeName ($Value.GetType().Name) `
                        -NotePropertyName $Field `
                        -NotePropertyValue $Value;
                }
                [void] $ReturnValue.Add([PSObject]$Record);
            }
        }
        Catch
        {
            $Exception = $_.Exception;
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
        If ($Exception)
        {
            Throw $Exception;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
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
        [Exception] $Exception = $null;
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
		[String] $CommandText = [String]::Format("[{0}].[{1}]", $Schema, $Procedure);
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServerLocalDB.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
            $Command.CommandTimeout = 0;
            $Command.CommandType = [Data.CommandType]::StoredProcedure;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If ($Name.StartsWith("@"))
                    { $Name = $Name.Substring(1)}
                If ($Parameters[$ParameterKey] -isnot [System.Xml.XmlElement])
                {
                    [void] $Command.Parameters.AddWithValue($Name, $Parameters[$ParameterKey]);
                }
                Else
                {
                    [System.Data.SqlTypes.SqlXml] $SqlXml = [System.Data.SqlTypes.SqlXml]::new([System.Xml.XmlNodeReader]::new($Parameters[$ParameterKey]));
                    [void] $Command.Parameters.AddWithValue($Name, (
                        $SqlXml.IsNull ?  
                            [System.DBNull]::Value :
                            $SqlXml
                    ));
                }
            }
            $ReturnValue = $Command.ExecuteScalar();
            If ($ReturnValue -is [System.DBNull])
            {
                $ReturnValue = $null;
            }
        }
        Catch
        {
            $Exception = $_.Exception;
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
        If ($Exception)
        {
            Throw $Exception;
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
    -Name "ExecuteMultipleCommands" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [Collections.Generic.List[String]] $CommandTexts
        )
        [Exception] $Exception = $null;
        [Data.SqlClient.SqlConnection] $Connection = $null;
        [Data.SqlClient.SqlCommand] $Command = $null;
        Try
        {
            $Connection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServerLocalDB.GetConnectionString($ConnectionName));
            $Connection.Open();
            ForEach ($CommandText In $CommandTexts)
            {
                $Command = [Data.SqlClient.SqlCommand]::new($CommandText, $Connection);
                $Command.CommandTimeout = 0;
                $Command.CommandType = [Data.CommandType]::Text;
                [void] $Command.ExecuteNonQuery();
            }
        }
        Catch
        {
            $Exception = $_.Exception;
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
        If ($Exception)
        {
            Throw $Exception;
        }
    }
#endregion Base Methods

Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
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
    -InputObject $Global:Session.SQLServerLocalDB `
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
        [Object] $ScalarValue = $Global:Session.SQLServerLocalDB.GetScalar(
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
    -InputObject $Global:Session.SQLServerLocalDB `
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
        [Object] $ScalarValue = $Global:Session.SQLServerLocalDB.GetScalar(
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
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
    -Name "CreateSchemaIfNotFound" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $SchemaName,

            [Parameter(Mandatory=$true)]
            [String] $CommandText,
    
            [Parameter(Mandatory=$false)]
            [Collections.Hashtable] $Parameters
        )
        $CommandText = $CommandText.Replace("`$(SchemaName)", $SchemaName)
        [void] $Global:Session.SQLServerLocalDB.Execute($ConnectionName, $CommandText, $Parameters);
    }
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
    -Name "DoesDatabaseExists" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [Boolean] $ReturnValue = $false;
        [PSCustomObject] $Connection = $Global:Session.SQLServerLocalDB.GetConnection($ConnectionName);
Write-Host ($Connection.DatabaseFilePath)
        [Object] $ScalarValue = $Global:Session.SQLServerLocalDB.GetScalar(
            $Global:Session.SQLServerLocalDB.MasterConnectionName,
            "SELECT 1 FROM [sys].[databases] WHERE [name] = @DatabaseFilePath",
            @{ "@DatabaseFilePath" = $Connection.DatabaseFilePath; }
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
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
    -Name "DetachDatabase" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [PSCustomObject] $Connection = $Global:Session.SQLServerLocalDB.GetConnection($ConnectionName);
        If ($Global:Session.SQLServerLocalDB.DoesDatabaseExists($Connection.DatabaseFilePath))
        {
            [void] $Global:Session.SQLServerLocalDB.ExecuteMultipleCommands(
                $Global:Session.SQLServerLocalDB.MasterConnectionName,
                @(
                    [String]::Format("ALTER DATABASE [{0}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE", $Connection.DatabaseFilePath.ToUpper()),
                    [String]::Format("EXEC [master].[dbo].[sp_detach_db] @dbname = N'{0}', @skipchecks = 'false'", $Connection.DatabaseFilePath.ToUpper())
                )
            );
        }
    }
Add-Member `
    -InputObject $Global:Session.SQLServerLocalDB `
    -Name "CreateDatabaseIfNotExists" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        If (!$Global:Session.SQLServerLocalDB.DoesDatabaseExists($ConnectionName))
        {
            [PSCustomObject] $Connection = $Global:Session.SQLServerLocalDB.GetConnection($ConnectionName);
            [String] $PrimaryFilePath = $Connection.DatabaseFilePath;
            [String] $LogFilePath = [IO.Path]::ChangeExtension($PrimaryFilePath, ".ldf");
            [String] $PrimaryFileName = [String]::Format("{0}_Primary", [IO.Path]::GetFileNameWithoutExtension($PrimaryFilePath));
            [String] $LogFileName = [String]::Format("{0}_Log", [IO.Path]::GetFileNameWithoutExtension($LogFilePath));
            [String] $CommandText = [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "CreateDatabase.sql"));
            $CommandText = $CommandText.Replace("`$(PrimaryFilePath)", $PrimaryFilePath);
            $CommandText = $CommandText.Replace("`$(PrimaryFileName)", $PrimaryFileName);
            $CommandText = $CommandText.Replace("`$(LogFilePath)", $LogFilePath);
            $CommandText = $CommandText.Replace("`$(LogFileName)", $LogFileName);
            [void] $Global:Session.SQLServerLocalDB.Execute(
                $Global:Session.SQLServerLocalDB.MasterConnectionName,
                $CommandText,
                $null);
            }
    }
