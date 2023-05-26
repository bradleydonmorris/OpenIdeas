Class NamedSQLScript {
    [String] $Mode;
    [Int32] $Sequence;
    [String] $Type;
    [String] $Name;
    [String] $Script;

    NamedSQLScript (
        [String] $mode,
        [Int32] $sequence,
        [String] $type,
        [String] $name,
        [String] $script
    )
    {
        $this.Mode = $mode;
        $this.Sequence = $sequence;
        $this.Type = $type;
        $this.Name = $name;
        $this.Script = $script;
    }
}

Class SQLObjectInfo {
    [Int64] $CreateOrder;
    [Int64] $DropOrder;
    [String] $Schema;
    [String] $Name;
    [String] $SimpleType;
    [String] $Type;
    [String] $QualifiedName;
    [Object] $Details;
    [String] $ModuleBody;
    [String] $ModuleBodyFileRef;

    SQLObjectInfo (
        [Int64] $createOrder,
        [Int64] $dropOrder,
        [String] $schema,
        [String] $name,
        [String] $simpleType,
        [String] $type,
        [String] $qualifiedName
    )
    {
        $this.CreateOrder = $createOrder;
        $this.DropOrder = $dropOrder;
        $this.Schema = $schema;
        $this.Name = $name;
        $this.SimpleType = $simpleType;
        $this.Type = $type;
        $this.QualifiedName = $qualifiedName;
        $this.ModuleBody = "";
        $this.ModuleBodyFileRef = "";
    }
}

Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "ScriptSQLServerDatabase" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.ScriptSQLServerDatabase `
    -Name "GetObjectsByDependency" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Instance,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $OverrideGetDependenciesFilePath,
    
            [Parameter(Mandatory=$true)]
            [Collections.Hashtable] $Parameters,

            [Parameter(Mandatory=$true)]
            [Boolean] $IncludeDetails
        )
        [Collections.ArrayList] $ReturnValue = [Collections.ArrayList]::new();
    
        [String] $CommandText = [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "GetAllObjectDependencies.sql"));
        If (![String]::IsNullOrEmpty($OverrideGetDependenciesFilePath))
        {
            If (![IO.File]::Exists($OverrideGetDependenciesFilePath))
            {
                Throw [IO.FileNotFoundException]::new("File specified by `$OverrideGetDependenciesFilePath was not found.", $OverrideGetDependenciesFilePath)
            }
            $CommandText = [IO.File]::ReadAllText($OverrideGetDependenciesFilePath);
        }
        ElseIf (![String]::IsNullOrEmpty($Schema))
        {
            $CommandText = [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "GetSchemaObjectDependencies.sql"));
        }
        ForEach ($ParameterKey In $Parameters.Keys)
        {
            $CommandText = $CommandText.Replace("`$($ParameterKey)", $Parameters[$ParameterKey].ToString());
        }
        [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($CommandText, $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::Text
        $SqlCommand.CommandTimeout = 0;

        If (![String]::IsNullOrEmpty($Schema))
        {
            [Data.SqlClient.SqlParameter] $SqlParameter_Schema = $SqlCommand.CreateParameter();
            $SqlParameter_Schema.ParameterName = "@Schema";
            $SqlParameter_Schema.SqlDbType = [Data.SqlDbType]::NVarChar;
            $SqlParameter_Schema.Size = 128;
            $SqlParameter_Schema.SqlValue = $Schema;
            [void] $SqlCommand.Parameters.Add($SqlParameter_Schema);
        }

        [Data.SqlClient.SqlDataReader] $SqlDataReader =  $SqlCommand.ExecuteReader();
        While ($SqlDataReader.Read())
        {
            [SQLObjectInfo] $SQLObjectInfo = [SQLObjectInfo]::new(
                $SqlDataReader.GetInt64($SqlDataReader.GetOrdinal("CreateOrder")),
                $SqlDataReader.GetInt64($SqlDataReader.GetOrdinal("DropOrder")),
                $SqlDataReader.GetString($SqlDataReader.GetOrdinal("Schema")),
                $SqlDataReader.GetString($SqlDataReader.GetOrdinal("Name")),
                $SqlDataReader.GetString($SqlDataReader.GetOrdinal("SimpleType")),
                $SqlDataReader.GetString($SqlDataReader.GetOrdinal("Type")),
                $SqlDataReader.GetString($SqlDataReader.GetOrdinal("QualifiedName"))
            );
            If ($IncludeDetails)
            {
                Switch ($SQLObjectInfo.SimpleType)
                {
                    "Table" { $SQLObjectInfo.Details = $Global:Job.ScriptSQLServerDatabase.GetTableInfo($Instance, $Database, $SQLObjectInfo.Schema, $SQLObjectInfo.Name); }
                    "View" { $SQLObjectInfo.Details = $Global:Job.ScriptSQLServerDatabase.GetViewInfo($Instance, $Database, $SQLObjectInfo.Schema, $SQLObjectInfo.Name); }
                    "Function" { $SQLObjectInfo.Details = $Global:Job.ScriptSQLServerDatabase.GetFunctionInfo($Instance, $Database, $SQLObjectInfo.Schema, $SQLObjectInfo.Name); }
                    "Procedure" { $SQLObjectInfo.Details = $Global:Job.ScriptSQLServerDatabase.GetProcedureInfo($Instance, $Database, $SQLObjectInfo.Schema, $SQLObjectInfo.Name); }
                }
            }
            [void] $ReturnValue.Add($SQLObjectInfo);
        }
        [void] $SqlDataReader.Close();
        [void] $SqlDataReader.Dispose();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.ScriptSQLServerDatabase `
    -Name "GetTableInfo" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Object])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Instance,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Object] $ReturnValue = $null;
        [String] $CommandText = [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "GetTableJSON.sql"));
        [String] $Json = $null;
        [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($CommandText, $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::Text;
        $SqlCommand.CommandTimeout = 0;
    
        [Data.SqlClient.SqlParameter] $SqlParameter_Schema = $SqlCommand.CreateParameter();
        $SqlParameter_Schema.ParameterName = "@Schema";
        $SqlParameter_Schema.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_Schema.Size = 128;
        $SqlParameter_Schema.SqlValue = $Schema;
        [void] $SqlCommand.Parameters.Add($SqlParameter_Schema);

        [Data.SqlClient.SqlParameter] $SqlParameter_Name = $SqlCommand.CreateParameter();
        $SqlParameter_Name.ParameterName = "@Name";
        $SqlParameter_Name.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_Name.Size = 128;
        $SqlParameter_Name.SqlValue = $Name;
        [void] $SqlCommand.Parameters.Add($SqlParameter_Name);
    
        [Object] $ScalerValue = $SqlCommand.ExecuteScalar();
        If ($ScalerValue -is [String])
        {
            $Json = $ScalerValue;
        }
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();

        $ReturnValue = $Json | ConvertFrom-Json -Depth 100;
        [String] $CreateScript = [String]::Format("CREATE TABLE [{0}].[{1}]`r`n", $ReturnValue.Schema, $ReturnValue.Name);
        [Int32] $CurrentLoopIndex = 0;
        [Boolean] $HasPrimaryKey = $false;
        [Boolean] $HasForeignKeys = $false;
        If ($ReturnValue.PrimaryKey)
        {
            $HasPrimaryKey = $true;
        }
        If ($ReturnValue.ForeignKeys.Count -gt 0)
        {
            $HasForeignKeys = $true;
        }
        $CurrentLoopIndex = 0;
        $CreateScript += "(`r`n"
        ForEach ($Column In ($ReturnValue.Columns | Sort-Object -Property "Ordinal"))
        {
            $CurrentLoopIndex ++;
            $CreateScript += [String]::Format("`t[{0}] {1}", $Column.Name, $Column.CondensedType);
            If ($Column.IsIdentity)
            {
                $CreateScript += " IDENTITY(1, 1)";
            }
            If (![String]::IsNullOrEmpty($Column.Computation.Definition))
            {
                $CreateScript += [String]::Format("`r`n`t`tAS {0}", $Column.Computation.Definition);
            }
            Else
            {
                $CreateScript += [String]::Format(" {0}", ($Column.IsNullable ? "NULL" : "NOT NULL"));
            }
            If (![String]::IsNullOrEmpty($Column.Default.Definition))
            {
                $CreateScript += [String]::Format("`r`n`t`tCONSTRAINT [DF_{0}_{1}] DEFAULT {2}", $ReturnValue.Name, $Column.Name, $Column.Default.Definition);
            }
            If ($Column.IsRowGUID)
            {
                $CreateScript += " ROWGUIDCOL";
            }
            If (
                ($CurrentLoopIndex -lt $ReturnValue.Columns.Count) -or
                $HasPrimaryKey -or $HasForeignKeys
            )
            {
                $CreateScript += ",";
            }
            $CreateScript += "`r`n"
        }
        If ($HasPrimaryKey)
        {
            $CreateScript += [String]::Format("`tCONSTRAINT [{0}]`r`n", $ReturnValue.PrimaryKey.Name);
            $CreateScript += [String]::Format(
                "`t`tPRIMARY KEY{0}",
                ($ReturnValue.PrimaryKey.IsClustered ? " CLUSTERED" : "")
            );
            If ($ReturnValue.PrimaryKey.Columns -eq 1)
            {
                $CreateScript += [String]::Format(
                    " ([{0}] {1})`r`n",
                    $ReturnValue.PrimaryKey.Columns[0].Name,
                    ($ReturnValue.PrimaryKey.Columns[0].SortDirection -eq "Descending" ? "DESC" : "ASC")
                );
            }
            ElseIf ($ReturnValue.PrimaryKey.Columns.Count -gt 1)
            {
                $CreateScript += "`r`n`t`t(`r`n";
                $CurrentLoopIndex = 0;
                ForEach ($Column In ($ReturnValue.PrimaryKey.Columns | Sort-Object -Property "Ordinal"))
                {
                    $CreateScript += [String]::Format(
                        "`t`t`t[{0}] {1}",
                        $Column.Name,
                        ($Column.SortDirection -eq "Descending" ? "DESC" : "ASC")
                    );
                    If ($CurrentLoopIndex -lt $ReturnValue.PrimaryKey.Columns.Count)
                    {
                        $CreateScript += ",";
                    }
                    $CreateScript += "`r`n";
                }
                $CreateScript += "`t`t)`r`n";
    
            }
            $CreateScript += "`t`tWITH ( STATISTICS_NORECOMPUTE = OFF, ";
            $CreateScript += [String]::Format("FILLFACTOR = {0}, ", $ReturnValue.PrimaryKey.FillFactor);
            $CreateScript += [String]::Format("PAD_INDEX = {0}, ", ($ReturnValue.PrimaryKey.IsPadded ? "ON" : "OFF"));
            $CreateScript += [String]::Format("IGNORE_DUP_KEY = {0}, ", ($ReturnValue.PrimaryKey.IgnoreDuplicateKey ? "ON" : "OFF"));
            $CreateScript += [String]::Format("IGNORE_DUP_KEY = {0}, ", ($ReturnValue.PrimaryKey.IgnoreDuplicateKey ? "ON" : "OFF"));
            $CreateScript += [String]::Format("ALLOW_ROW_LOCKS = {0}, ", ($ReturnValue.PrimaryKey.AllowRowLocks ? "ON" : "OFF"));
            $CreateScript += [String]::Format("ALLOW_PAGE_LOCKS = {0} ", ($ReturnValue.PrimaryKey.AllowPageLocks ? "ON" : "OFF"));
            $CreateScript += ")`r`n";
            $CreateScript += [String]::Format("`t`tON [{0}]", $ReturnValue.PrimaryKey.FileGroup);
            If ($HasForeignKeys)
            {
                $CreateScript += ",";
            }
            $CreateScript += "`r`n"
        }
        If ($HasForeignKeys)
        {
            [Int32] $ForeignKeyCurrentLoopIndex = 0;
            ForEach ($ForeignKey In $ReturnValue.ForeignKeys)
            {
                $ForeignKeyCurrentLoopIndex ++;
                $CreateScript += [String]::Format("`tCONSTRAINT [{0}]`r`n", $ForeignKey.KeyName);
                $CreateScript += "`t`tFOREIGN KEY";
                If ($ForeignKey.Columns.Count -eq 1)
                {
                    $CreateScript += [String]::Format(" ([{0}])`r`n", $ForeignKey.Columns[0].ForeignColumn);
                }
                ElseIf ($ForeignKey.Columns.Count -gt 1)
                {
                    $CreateScript += "`r`n`t`t(`r`n";
                    $CurrentLoopIndex = 0;
                    ForEach ($Column In ($ForeignKey.Columns | Sort-Object -Property "Ordinal"))
                    {
                        $CreateScript += [String]::Format("`t`t`t[{0}]", $Column.ForeignColumn);
                        If ($CurrentLoopIndex -lt $ForeignKey.Columns.Count)
                        {
                            $CreateScript += ",";
                        }
                        $CreateScript += "`r`n";
                    }
                    $CreateScript += "`t`t)`r`n";
                }
                $CreateScript += [String]::Format("`t`tREFERENCES [{0}].[{1}]", $ForeignKey.ReferencedSchema, $ForeignKey.ReferencedTable);
                If ($ForeignKey.Columns.Count -eq 1)
                {
                    $CreateScript += [String]::Format(" ([{0}])", $ForeignKey.Columns[0].ReferencedColumn);
                }
                ElseIf ($ForeignKey.Columns.Count -gt 1)
                {
                    $CreateScript += "`r`n`t`t(`r`n";
                    $CurrentLoopIndex = 0;
                    ForEach ($Column In ($ForeignKey.Columns | Sort-Object -Property "Ordinal"))
                    {
                        $CreateScript += [String]::Format("`t`t`t[{0}]", $Column.ReferencedColumn);
                        If ($CurrentLoopIndex -lt $ForeignKey.Columns.Count)
                        {
                            $CreateScript += ",";
                        }
                        $CreateScript += "`r`n";
                    }
                    $CreateScript += "`t`t)";
                }
                If ($ForeignKeyCurrentLoopIndex -lt $ReturnValue.ForeignKeys.Count)
                {
                    $CreateScript += ",";
                }
                $CreateScript += "`r`n";
            }
        }
        $CreateScript += [String]::Format(") ON [{0}]", $ReturnValue.HeapFileGroupName);
        If (![String]::IsNullOrEmpty($ReturnValue.LobFileGroupName))
        {
            $CreateScript += [String]::Format(" TEXTIMAGE_ON [{0}]", $ReturnValue.LobFileGroupName);
        }
        ForEach ($Index In $ReturnValue.Indexes)
        {
            $CreateScript += [String]::Format(
                "`r`nCREATE{0}{1} INDEX [{2}]",
                ($Index.IsUnique ? " UNIQUE" : ""),
                ($Index.IsClustered ? " CLUSTERED" : " NONCLUSTERED"),
                $Index.Name
            );
            $CreateScript += [String]::Format("`tON [{0}].[{1}]", $ReturnValue.Schema, $ReturnValue.Name);
            If ($Index.Columns.Count -eq 1)
            {
                $CreateScript += [String]::Format(" ([{0}] {1})`r`n", $Index.Columns[0].Name, ($Index.Columns[0].SortDirection -eq "Descending" ? "DESC" : "ASC"));
            }
            ElseIf ($Index.Columns.Count -gt 1)
            {
                $CurrentLoopIndex = 0;
                $CreateScript += "`r`n`t(`r`n"
                ForEach ($Column In $Index.Columns)
                {
                    $CreateScript += [String]::Format("`t`t[{0}] {1}", $Column.Name, ($Column.SortDirection -eq "Descending" ? "DESC" : "ASC"));
                    $CurrentLoopIndex ++;
                    If ($CurrentLoopIndex -lt $Index.Columns.Count)
                    {
                        $CreateScript += ",";
                    }
                    $CreateScript += "`r`n";
                }
                $CreateScript += "`t)`r`n"
            }
            If ($Index.IncludeColumns.Count -eq 1)
            {
                $CreateScript += [String]::Format("`tINCLUDE ([{0}])`r`n", $Index.IncludeColumns[0].Name);
            }
            ElseIf  ($Index.IncludeColumns.Count -gt 1)
            {
                $CurrentLoopIndex = 0;
                $CreateScript += "`r`n`tINCLUDE`r`n`t(`r`n"
                ForEach ($Column In $Index.IncludeColumns)
                {
                    $CurrentLoopIndex ++;
                    $CreateScript += [String]::Format("`t`t[{0}]", $Column.Name);
                    If ($CurrentLoopIndex -lt $Index.IncludeColumns.Count)
                    {
                        $CreateScript += ",";
                    }
                    $CreateScript += "`r`n";
                }
                $CreateScript += "`t)`r`n"
            }
            $CreateScript += "`tWITH ( STATISTICS_NORECOMPUTE = OFF, ";
            $CreateScript += [String]::Format("FILLFACTOR = {0}, ", $Index.FillFactor);
            $CreateScript += [String]::Format("PAD_INDEX = {0}, ", ($Index.IsPadded ? "ON" : "OFF"));
            $CreateScript += [String]::Format("IGNORE_DUP_KEY = {0}, ", ($Index.IgnoreDuplicateKey ? "ON" : "OFF"));
            $CreateScript += [String]::Format("IGNORE_DUP_KEY = {0}, ", ($Index.IgnoreDuplicateKey ? "ON" : "OFF"));
            $CreateScript += [String]::Format("ALLOW_ROW_LOCKS = {0}, ", ($Index.AllowRowLocks ? "ON" : "OFF"));
            $CreateScript += [String]::Format("ALLOW_PAGE_LOCKS = {0} ", ($Index.AllowPageLocks ? "ON" : "OFF"));
            $CreateScript += ")`r`n";
            $CreateScript += [String]::Format("`tON [{0}]", $Index.FileGroup);
        }
        $ReturnValue.CreateScript = $CreateScript;
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.ScriptSQLServerDatabase `
    -Name "GetViewInfo" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Object])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Instance,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Object] $ReturnValue = $null;
        [String] $CommandText = [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "GetViewJSON.sql"));
        [String] $Json = $null;
        [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($CommandText, $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::Text;
        $SqlCommand.CommandTimeout = 0;
    
        [Data.SqlClient.SqlParameter] $SqlParameter_Schema = $SqlCommand.CreateParameter();
        $SqlParameter_Schema.ParameterName = "@Schema";
        $SqlParameter_Schema.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_Schema.Size = 128;
        $SqlParameter_Schema.SqlValue = $Schema;
        [void] $SqlCommand.Parameters.Add($SqlParameter_Schema);

        [Data.SqlClient.SqlParameter] $SqlParameter_Name = $SqlCommand.CreateParameter();
        $SqlParameter_Name.ParameterName = "@Name";
        $SqlParameter_Name.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_Name.Size = 128;
        $SqlParameter_Name.SqlValue = $Name;
        [void] $SqlCommand.Parameters.Add($SqlParameter_Name);
    
        [Object] $ScalerValue = $SqlCommand.ExecuteScalar();
        If ($ScalerValue -is [String])
        {
            $Json = $ScalerValue;
        }
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        $ReturnValue = $Json | ConvertFrom-Json -Depth 100;
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.ScriptSQLServerDatabase `
    -Name "GetFunctionInfo" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Object])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Instance,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Object] $ReturnValue = $null;
        [String] $CommandText = [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "GetFunctionJSON.sql"));
        [String] $Json = $null;
        [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($CommandText, $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::Text;
        $SqlCommand.CommandTimeout = 0;
    
        [Data.SqlClient.SqlParameter] $SqlParameter_Schema = $SqlCommand.CreateParameter();
        $SqlParameter_Schema.ParameterName = "@Schema";
        $SqlParameter_Schema.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_Schema.Size = 128;
        $SqlParameter_Schema.SqlValue = $Schema;
        [void] $SqlCommand.Parameters.Add($SqlParameter_Schema);

        [Data.SqlClient.SqlParameter] $SqlParameter_Name = $SqlCommand.CreateParameter();
        $SqlParameter_Name.ParameterName = "@Name";
        $SqlParameter_Name.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_Name.Size = 128;
        $SqlParameter_Name.SqlValue = $Name;
        [void] $SqlCommand.Parameters.Add($SqlParameter_Name);
    
        [Object] $ScalerValue = $SqlCommand.ExecuteScalar();
        If ($ScalerValue -is [String])
        {
            $Json = $ScalerValue;
        }
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        $ReturnValue = $Json | ConvertFrom-Json -Depth 100;
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.ScriptSQLServerDatabase `
    -Name "GetProcedureInfo" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Object])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Instance,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Object] $ReturnValue = $null;
        [String] $CommandText = [IO.File]::ReadAllText([IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "GetProcedureJSON.sql"));
        [String] $Json = $null;
        [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($CommandText, $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::Text;
        $SqlCommand.CommandTimeout = 0;
    
        [Data.SqlClient.SqlParameter] $SqlParameter_Schema = $SqlCommand.CreateParameter();
        $SqlParameter_Schema.ParameterName = "@Schema";
        $SqlParameter_Schema.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_Schema.Size = 128;
        $SqlParameter_Schema.SqlValue = $Schema;
        [void] $SqlCommand.Parameters.Add($SqlParameter_Schema);

        [Data.SqlClient.SqlParameter] $SqlParameter_Name = $SqlCommand.CreateParameter();
        $SqlParameter_Name.ParameterName = "@Name";
        $SqlParameter_Name.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_Name.Size = 128;
        $SqlParameter_Name.SqlValue = $Name;
        [void] $SqlCommand.Parameters.Add($SqlParameter_Name);
    
        [Object] $ScalerValue = $SqlCommand.ExecuteScalar();
        If ($ScalerValue -is [String])
        {
            $Json = $ScalerValue;
        }
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        $ReturnValue = $Json | ConvertFrom-Json -Depth 100;
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.ScriptSQLServerDatabase `
    -Name "GenerateScriptsByDependency" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Instance,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $OverrideGetDependenciesFilePath,
    
            [Parameter(Mandatory=$true)]
            [String] $OutputDirectoryPath,
    
            [Parameter(Mandatory=$true)]
            [Collections.Hashtable] $Parameters
        )
        $SQLObjectInfos = $Global:Job.ScriptSQLServerDatabase.GetObjectsByDependency(
            $SQLInstance,
            $Database,
            $Schema,
            $OverrideGetDependenciesFilePath,
            $Parameters,
            $true
        );
        [Int32] $PadLength = $SQLObjectInfos.Count.ToString().Length;
        [String] $JSONpOutputFilePath = [IO.Path]::Combine($OutputDirectoryPath, ("".PadLeft($PadLength, "0") + "-Objects.json"));
        [String] $DropOutputFilePath = [IO.Path]::Combine($OutputDirectoryPath, ("".PadLeft($PadLength, "0") + "-Drop.sql"));
        $SQLObjectInfos |
            Sort-Object -Property "CreateOrder" |
            ConvertTo-Json -Depth 100 |
            Out-File $JSONpOutputFilePath;
        ForEach ($SQLObjectInfo In ($SQLObjectInfos | Sort-Object -Property "CreateOrder"))
        {
            [String] $OutputFilePath = [IO.Path]::Combine(
                $OutputDirectoryPath,
                [String]::Format(
                    "{0}-{1}-{2}.sql",
                    $SQLObjectInfo.CreateOrder.ToString().PadLeft($PadLength, "0"),
                    $SQLObjectInfo.SimpleType,
                    $SQLObjectInfo.QualifiedName
                )
            );
            [void] [IO.File]::WriteAllText($OutputFilePath, $SQLObjectInfo.Details.CreateScript);
        }
        [void] [IO.File]::WriteAllText($DropOutputFilePath, "");
        ForEach ($SQLObjectInfo In ($SQLObjectInfos | Sort-Object -Property "DropOrder"))
        {
            [void] [IO.File]::AppendAllText($DropOutputFilePath, [String]::Format("{0}`r`n", $SQLObjectInfo.Details.DropScript));
        }
    }
Add-Member `
    -InputObject $Global:Job.ScriptSQLServerDatabase `
    -Name "CreateScriptFromJSON" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $JSONFilePath,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $HeapFileGroup,
    
            [Parameter(Mandatory=$true)]
            [String] $LobFileGroup,
    
            [Parameter(Mandatory=$true)]
            [String] $IndexFileGroup
        )
        [String] $RetrunValue = "";
        If (![IO.File]::Exists($JSONFilePath))
        {
            Throw [IO.FileNotFoundException]::new("File specified by `$JSONFilePath was not found.", $JSONFilePath)
        }
        $ObjectInfos = ConvertFrom-Json -InputObject ([IO.File]::ReadAllText($JSONFilePath));
        [String] $DirectoryPath = [IO.Path]::GetDirectoryName($JSONFilePath);
        ForEach ($ObjectInfo In ($ObjectInfos | Sort-Object -Property "CreateOrder"))
        {
            [String] $Script = $null;
            $ObjectInfo.Schema = $Schema
            Switch ($ObjectInfo.SimpleType)
            {
                "Table"
                {
                    If ($ObjectInfo.HeapFileGroupName -eq "_HEAPFILEGROUP_")
                    {
                        $ObjectInfo.HeapFileGroupName = $HeapFileGroup;
                    }
                    If ($ObjectInfo.LobFileGroupName -eq "_LOBFILEGROUP_")
                    {
                        $ObjectInfo.LobFileGroupName = $LobFileGroup;
                    }
                    If ($ObjectInfo.LobFileGroupName -eq "_INDEXFILEGROUP_")
                    {
                        $ObjectInfo.HeapFileGroupName = $LobFileGroup;
                    }
                    ForEach ($Index In $ObjectInfo.Indexes)
                    {
                        If ($Index.FileGroup -eq "_INDEXFILEGROUP_")
                        {
                            $Index.FileGroup = $IndexFileGroup;
                        }
                    }
                    $Script = $Global:Job.ScriptSQLServerDatabase.GenerateTableScript($ObjectInfo);
                }
                "View"
                {
                    $Script = $Global:Job.ScriptSQLServerDatabase.GenerateViewScript(
                        $ObjectInfo,
                        [IO.Path]::Combine($DirectoryPath, $ObjectInfo.ModuleBodyFileRef)
                    );
                }
                "Function"
                {
                    $Script = $Global:Job.ScriptSQLServerDatabase.GenerateFunctionScript(
                        $ObjectInfo,
                        [IO.Path]::Combine($DirectoryPath, $ObjectInfo.ModuleBodyFileRef)
                    );
                }
                "Procedure"
                {
                    $Script = $Global:Job.ScriptSQLServerDatabase.GenerateProcedureScript(
                        $ObjectInfo,
                        [IO.Path]::Combine($DirectoryPath, $ObjectInfo.ModuleBodyFileRef)
                    );
                }
            }
            If (![String]::IsNullOrEmpty($Script))
            {
                $RetrunValue += "`r`nGO`r`n" + $Script + "`r`nGO`r`n"
            }
        }
        Return $RetrunValue;
    }
Add-Member `
    -InputObject $Global:Job.ScriptSQLServerDatabase `
    -Name "GenerateTableScript" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Object] $TableInfo
        )
        [Object] $ReturnValue = [String]::Format("CREATE TABLE [{0}].[{1}]`r`n", $TableInfo.Schema, $TableInfo.Name);
        [Int32] $CurrentLoopIndex = 0;
        [Boolean] $HasPrimaryKey = $false;
        [Boolean] $HasForeignKeys = $false;
        If ($TableInfo.PrimaryKey)
        {
            $HasPrimaryKey = $true;
        }
        If ($TableInfo.ForeignKeys.Count -gt 0)
        {
            $HasForeignKeys = $true;
        }
        $CurrentLoopIndex = 0;
        $ReturnValue += "(`r`n"
        ForEach ($Column In ($TableInfo.Columns | Sort-Object -Property "Ordinal"))
        {
            $CurrentLoopIndex ++;
            $ReturnValue += [String]::Format("`t[{0}] {1}", $Column.Name, $Column.CondensedType);
            If ($Column.IsIdentity)
            {
                $ReturnValue += " IDENTITY(1, 1)";
            }
            If (![String]::IsNullOrEmpty($Column.Computation.Definition))
            {
                $ReturnValue += [String]::Format("`r`n`t`tAS {0}", $Column.Computation.Definition);
            }
            Else
            {
                $ReturnValue += [String]::Format(" {0}", ($Column.IsNullable ? "NULL" : "NOT NULL"));
            }
            If (![String]::IsNullOrEmpty($Column.Default.Definition))
            {
                $ReturnValue += [String]::Format("`r`n`t`tCONSTRAINT [DF_{0}_{1}] DEFAULT {2}", $TableInfo.Name, $Column.Name, $Column.Default.Definition);
            }
            If ($Column.IsRowGUID)
            {
                $ReturnValue += " ROWGUIDCOL";
            }
            If (
                ($CurrentLoopIndex -lt $TableInfo.Columns.Count) -or
                $HasPrimaryKey -or $HasForeignKeys
            )
            {
                $ReturnValue += ",";
            }
            $ReturnValue += "`r`n"
        }
        If ($HasPrimaryKey)
        {
            $ReturnValue += [String]::Format("`tCONSTRAINT [{0}]`r`n", $TableInfo.PrimaryKey.Name);
            $ReturnValue += [String]::Format(
                "`t`tPRIMARY KEY{0}",
                ($TableInfo.PrimaryKey.IsClustered ? " CLUSTERED" : "")
            );
            If ($TableInfo.PrimaryKey.Columns -eq 1)
            {
                $ReturnValue += [String]::Format(
                    " ([{0}] {1})`r`n",
                    $TableInfo.PrimaryKey.Columns[0].Name,
                    ($TableInfo.PrimaryKey.Columns[0].SortDirection -eq "Descending" ? "DESC" : "ASC")
                );
            }
            ElseIf ($TableInfo.PrimaryKey.Columns.Count -gt 1)
            {
                $ReturnValue += "`r`n`t`t(`r`n";
                $CurrentLoopIndex = 0;
                ForEach ($Column In ($TableInfo.PrimaryKey.Columns | Sort-Object -Property "Ordinal"))
                {
                    $ReturnValue += [String]::Format(
                        "`t`t`t[{0}] {1}",
                        $Column.Name,
                        ($Column.SortDirection -eq "Descending" ? "DESC" : "ASC")
                    );
                    If ($CurrentLoopIndex -lt $TableInfo.PrimaryKey.Columns.Count)
                    {
                        $ReturnValue += ",";
                    }
                    $ReturnValue += "`r`n";
                }
                $ReturnValue += "`t`t)`r`n";
    
            }
            $ReturnValue += "`t`tWITH ( STATISTICS_NORECOMPUTE = OFF, ";
            $ReturnValue += [String]::Format("FILLFACTOR = {0}, ", $TableInfo.PrimaryKey.FillFactor);
            $ReturnValue += [String]::Format("PAD_INDEX = {0}, ", ($TableInfo.PrimaryKey.IsPadded ? "ON" : "OFF"));
            $ReturnValue += [String]::Format("IGNORE_DUP_KEY = {0}, ", ($TableInfo.PrimaryKey.IgnoreDuplicateKey ? "ON" : "OFF"));
            $ReturnValue += [String]::Format("IGNORE_DUP_KEY = {0}, ", ($TableInfo.PrimaryKey.IgnoreDuplicateKey ? "ON" : "OFF"));
            $ReturnValue += [String]::Format("ALLOW_ROW_LOCKS = {0}, ", ($TableInfo.PrimaryKey.AllowRowLocks ? "ON" : "OFF"));
            $ReturnValue += [String]::Format("ALLOW_PAGE_LOCKS = {0} ", ($TableInfo.PrimaryKey.AllowPageLocks ? "ON" : "OFF"));
            $ReturnValue += ")`r`n";
            $ReturnValue += [String]::Format("`t`tON [{0}]", $TableInfo.PrimaryKey.FileGroup);
            If ($HasForeignKeys)
            {
                $ReturnValue += ",";
            }
            $ReturnValue += "`r`n"
        }
        If ($HasForeignKeys)
        {
            [Int32] $ForeignKeyCurrentLoopIndex = 0;
            ForEach ($ForeignKey In $TableInfo.ForeignKeys)
            {
                $ForeignKeyCurrentLoopIndex ++;
                $ReturnValue += [String]::Format("`tCONSTRAINT [{0}]`r`n", $ForeignKey.KeyName);
                $ReturnValue += "`t`tFOREIGN KEY";
                If ($ForeignKey.Columns.Count -eq 1)
                {
                    $ReturnValue += [String]::Format(" ([{0}])`r`n", $ForeignKey.Columns[0].ForeignColumn);
                }
                ElseIf ($ForeignKey.Columns.Count -gt 1)
                {
                    $ReturnValue += "`r`n`t`t(`r`n";
                    $CurrentLoopIndex = 0;
                    ForEach ($Column In ($ForeignKey.Columns | Sort-Object -Property "Ordinal"))
                    {
                        $ReturnValue += [String]::Format("`t`t`t[{0}]", $Column.ForeignColumn);
                        If ($CurrentLoopIndex -lt $ForeignKey.Columns.Count)
                        {
                            $ReturnValue += ",";
                        }
                        $ReturnValue += "`r`n";
                    }
                    $ReturnValue += "`t`t)`r`n";
                }
                $ReturnValue += [String]::Format("`t`tREFERENCES [{0}].[{1}]", $ForeignKey.ReferencedSchema, $ForeignKey.ReferencedTable);
                If ($ForeignKey.Columns.Count -eq 1)
                {
                    $ReturnValue += [String]::Format(" ([{0}])", $ForeignKey.Columns[0].ReferencedColumn);
                }
                ElseIf ($ForeignKey.Columns.Count -gt 1)
                {
                    $ReturnValue += "`r`n`t`t(`r`n";
                    $CurrentLoopIndex = 0;
                    ForEach ($Column In ($ForeignKey.Columns | Sort-Object -Property "Ordinal"))
                    {
                        $ReturnValue += [String]::Format("`t`t`t[{0}]", $Column.ReferencedColumn);
                        If ($CurrentLoopIndex -lt $ForeignKey.Columns.Count)
                        {
                            $ReturnValue += ",";
                        }
                        $ReturnValue += "`r`n";
                    }
                    $ReturnValue += "`t`t)";
                }
                If ($ForeignKeyCurrentLoopIndex -lt $TableInfo.ForeignKeys.Count)
                {
                    $ReturnValue += ",";
                }
                $ReturnValue += "`r`n";
            }
        }
        $ReturnValue += [String]::Format(") ON [{0}]", ($HasPrimaryKey ? $TableInfo.PrimaryKey.FileGroup : $TableInfo.HeapFileGroupName));
        If (![String]::IsNullOrEmpty($TableInfo.LobFileGroupName))
        {
            $ReturnValue += [String]::Format(" TEXTIMAGE_ON [{0}]", $TableInfo.LobFileGroupName);
        }
        ForEach ($Index In $TableInfo.Indexes)
        {
            $ReturnValue += [String]::Format(
                "`r`nCREATE{0}{1} INDEX [{2}]",
                ($Index.IsUnique ? " UNIQUE" : ""),
                ($Index.IsClustered ? " CLUSTERED" : " NONCLUSTERED"),
                $Index.Name
            );
            $ReturnValue += [String]::Format("`tON [{0}].[{1}]", $TableInfo.Schema, $TableInfo.Name);
            If ($Index.Columns.Count -eq 1)
            {
                $ReturnValue += [String]::Format(" ([{0}] {1})`r`n", $Index.Columns[0].Name, ($Index.Columns[0].SortDirection -eq "Descending" ? "DESC" : "ASC"));
            }
            ElseIf ($Index.Columns.Count -gt 1)
            {
                $CurrentLoopIndex = 0;
                $ReturnValue += "`r`n`t(`r`n"
                ForEach ($Column In $Index.Columns)
                {
                    $ReturnValue += [String]::Format("`t`t[{0}] {1}", $Column.Name, ($Column.SortDirection -eq "Descending" ? "DESC" : "ASC"));
                    $CurrentLoopIndex ++;
                    If ($CurrentLoopIndex -lt $Index.Columns.Count)
                    {
                        $ReturnValue += ",";
                    }
                    $ReturnValue += "`r`n";
                }
                $ReturnValue += "`t)`r`n"
            }
            If ($Index.IncludeColumns.Count -eq 1)
            {
                $ReturnValue += [String]::Format("`tINCLUDE ([{0}])`r`n", $Index.IncludeColumns[0].Name);
            }
            ElseIf  ($Index.IncludeColumns.Count -gt 1)
            {
                $CurrentLoopIndex = 0;
                $ReturnValue += "`r`n`tINCLUDE`r`n`t(`r`n"
                ForEach ($Column In $Index.IncludeColumns)
                {
                    $CurrentLoopIndex ++;
                    $ReturnValue += [String]::Format("`t`t[{0}]", $Column.Name);
                    If ($CurrentLoopIndex -lt $Index.IncludeColumns.Count)
                    {
                        $ReturnValue += ",";
                    }
                    $ReturnValue += "`r`n";
                }
                $ReturnValue += "`t)`r`n"
            }
            $ReturnValue += "`tWITH ( STATISTICS_NORECOMPUTE = OFF, ";
            $ReturnValue += [String]::Format("FILLFACTOR = {0}, ", $Index.FillFactor);
            $ReturnValue += [String]::Format("PAD_INDEX = {0}, ", ($Index.IsPadded ? "ON" : "OFF"));
            $ReturnValue += [String]::Format("IGNORE_DUP_KEY = {0}, ", ($Index.IgnoreDuplicateKey ? "ON" : "OFF"));
            $ReturnValue += [String]::Format("IGNORE_DUP_KEY = {0}, ", ($Index.IgnoreDuplicateKey ? "ON" : "OFF"));
            $ReturnValue += [String]::Format("ALLOW_ROW_LOCKS = {0}, ", ($Index.AllowRowLocks ? "ON" : "OFF"));
            $ReturnValue += [String]::Format("ALLOW_PAGE_LOCKS = {0} ", ($Index.AllowPageLocks ? "ON" : "OFF"));
            $ReturnValue += ")`r`n";
            $ReturnValue += [String]::Format("`tON [{0}]", $Index.FileGroup);
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Job.ScriptSQLServerDatabase `
    -Name "GenerateViewScript" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Object] $ViewInfo,

            [Parameter(Mandatory=$true)]
            [String] $ModuleBodyFilePath
        )
        [String] $ReturnValue = [String]::Format("CREATE OR ALTER View [{0}].[{1}]`r`n", $ViewInfo.Schema, $ViewInfo.Name);
        $ReturnValue += "`r`nAS`r`n";
        $ReturnValue += [IO.File]::ReadAllText($ModuleBodyFilePath);
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.ScriptSQLServerDatabase `
    -Name "GenerateFunctionScript" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Object] $FunctionInfo,

            [Parameter(Mandatory=$true)]
            [String] $ModuleBodyFilePath
        )
        [String] $ReturnValue = [String]::Format("CREATE OR ALTER FUNCTION [{0}].[{1}]`r`n", $FunctionInfo.Schema, $FunctionInfo.Name);
        [Int32] $CurrentLoopIndex = 0;
        If ($FunctionInfo.Parameters.Count -gt 0)
        {
            $ReturnValue += "(`r`n";
            $CurrentLoopIndex = 0;
            ForEach ($Parameter In ($Parameters | Sort-Object -Property "Sequence"))
            {
                $CurrentLoopIndex ++;
                $ReturnValue += [String]::Format("`t{0} {1}", $Parameter.Name, $Parameter.CondensedType);
                If ($Parameter.IsOutput)
                {
                    $ReturnValue += " OUTPUT";
                }
                If ($CurrentLoopIndex -lt $FunctionInfo.Parameters.Count)
                {
                    $ReturnValue += ",";
                }
                $ReturnValue += "`r`n"
            }
            $ReturnValue += ")`r`n";
        }
        $ReturnValue += [String]::Format("RETURNS {0}", $FunctionInfo.Returns.CondensedType);
        $ReturnValue += "`r`nAS`r`n";
        $ReturnValue += [IO.File]::ReadAllText($ModuleBodyFilePath);
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.ScriptSQLServerDatabase `
    -Name "GenerateProcedureScript" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Object] $ProcedureInfo,

            [Parameter(Mandatory=$true)]
            [String] $ModuleBodyFilePath
        )
        [String] $ReturnValue = [String]::Format("CREATE OR ALTER PROCEDURE [{0}].[{1}]`r`n", $ProcedureInfo.Schema, $ProcedureInfo.Name);
        [Int32] $CurrentLoopIndex = 0;
        If ($ProcedureInfo.Parameters.Count -gt 0)
        {
            $ReturnValue += "(`r`n";
            $CurrentLoopIndex = 0;
            ForEach ($Parameter In ($ProcedureInfo.Parameters | Sort-Object -Property "Sequence"))
            {
                $CurrentLoopIndex ++;
                $ReturnValue += [String]::Format("`t{0} {1}", $Parameter.Name, $Parameter.CondensedType);
                If ($Parameter.IsOutput)
                {
                    $ReturnValue += " OUTPUT";
                }
                If ($CurrentLoopIndex -lt $ProcedureInfo.Parameters.Count)
                {
                    $ReturnValue += ",";
                }
                $ReturnValue += "`r`n"
            }
            $ReturnValue += ")`r`n";
        }
        $ReturnValue += "`r`nAS`r`n";
        $ReturnValue += [IO.File]::ReadAllText($ModuleBodyFilePath);
        Return $ReturnValue;
    }
