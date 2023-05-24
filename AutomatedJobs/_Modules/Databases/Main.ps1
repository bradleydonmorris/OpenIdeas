#This script creates methods to manage generic database work

Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Databases" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Databases `
    -Name "ClearSQLServerTable" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $SQLConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($SQLConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand_Truncate = [Data.SqlClient.SqlCommand]::new("TRUNCATE TABLE [$Schema].[$Table]", $SqlConnection);
        [void] $SqlCommand_Truncate.ExecuteNonQuery();
        [void] $SqlCommand_Truncate.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases `
    -Name "GetSQLServerTableRowCount" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Int64])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath,
    
            [Parameter(Mandatory=$true)]
            [String] $SQLConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table
        )
        [Int64] $Results = (-1);
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($SQLConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand_RowCount = [Data.SqlClient.SqlCommand]::new("SELECT COUNT(*) FROM [$Schema].[$Table] WHERE [_SourceFilePath_] = @FilePath", $SqlConnection);
        [Data.SqlClient.SqlParameter] $SqlParameter_FilePath = $SqlCommand_RowCount.CreateParameter();
        $SqlParameter_FilePath.ParameterName = "@FilePath";
        $SqlParameter_FilePath.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_FilePath.Size = 400;
        $SqlParameter_FilePath.SqlValue = $FilePath;
        [void] $SqlCommand_RowCount.Parameters.Add($SqlParameter_FilePath);
        [Object] $ScalarObject = $SqlCommand_RowCount.ExecuteScalar();
        If (
            $ScalarObject -is [Int64] -or
            $ScalarObject -is [Int32] -or
            $ScalarObject -is [Int16] -or
            $ScalarObject -is [Byte]
        )
        {
            $Results = [Int64]$ScalarObject
        }
        [void] $SqlCommand_RowCount.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.Databases `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "FileImport" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Databases.FileImport `
    -Name "CSVToDataTable" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([System.Data.DataTable])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath,
    
            [Parameter(Mandatory=$true)]
            [String] $Delimiter
        )
        [System.Data.DataTable] $Results = [System.Data.DataTable]::new();
        [Collections.Hashtable] $BaseTypes = [Collections.Hashtable]::new()
        ForEach ($Type In @("System.Boolean", "System.Byte[]", "System.Byte", "System.Char", "System.Datetime", "System.Decimal", "System.Double", "System.Guid", "System.Int16", "System.Int32", "System.Int64", "System.Single", "System.UInt16", "System.UInt32", "System.UInt64"))
        {
            $BaseTypes[$Type] = $Type;
        }
        If ([String]::IsNullOrEmpty($Delimiter))
        {
            $Delimiter = ",";
        }
        [String[]] $IgnoredProperties = @("RowError", "RowState", "Table", "ItemArray", "HasErrors");
        ForEach ($Record In (Import-Csv -Path $FilePath -Delimiter $Delimiter))
        {
            $DataRow = $Results.NewRow();
            [Boolean] $IsDataRow = $Record.PSObject.TypeNames -like "*.DataRow*" -as [Boolean]
            ForEach ($Property in $Record.PSObject.Properties)
            {   
                If (
                    $IsDataRow -and
                    $IgnoredProperties -contains $Property.Name
                ) { Continue; }

                $IsBaseType = $BaseTypes.ContainsKey($Property.TypeNameOfValue)
                If (-not $Results.Columns.Contains($Property.Name))
                {   
                    [Data.DataColumn] $DataColumn = [Data.DataColumn]::new($Property.Name);
                    If ($IsBaseType)
                        { $DataColumn.DataType = $Property.TypeNameOfValue; }
                    Else
                        { $DataColumn.DataType = "System.Object"; }
                    $Results.Columns.Add($DataColumn);
                }                   
                If ($IsBaseType -and $Property.Value)
                    { $DataRow.Item($Property.Name) = $Property.Value; }
                ElseIf ($Property.Value)
                    { $DataRow.Item($Property.Name) = [PSObject]$Property.Value; }
                Else
                    { $DataRow.Item($Property.Name) = [DBNull]::Value; }
            }
            $Results.Rows.Add($DataRow)   
        }
        Return ,$Results;
    };
Add-Member `
    -InputObject $Global:Job.Databases.FileImport `
    -Name "CSVToSQLServerTable" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath,
    
            [Parameter(Mandatory=$true)]
            [String] $Delimiter,
    
            [Parameter(Mandatory=$true)]
            [String] $SQLConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table,
    
            [Parameter(Mandatory=$true)]
            [Int32] $BatchSize
        )
        [System.Data.DataTable] $DataTable = $Global:Job.Databases.FileImport.CSVToDataTable($FilePath, $Delimiter);
        [Data.DataColumn] $DataColumn = [Data.DataColumn]::new("_SourceFilePath_");
        $DataColumn.DataType = "System.String";
        $DataColumn.DefaultValue = $FilePath;
        $DataTable.Columns.Add($DataColumn);
        [void] $DataColumn.SetOrdinal(0);
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($SQLConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlBulkCopy] $SqlBulkCopy = [Data.SqlClient.SqlBulkCopy]::new($SqlConnection);
        $SqlBulkCopy.BatchSize = $BatchSize;
        $SqlBulkCopy.DestinationTableName = "[$Schema].[$Table]";
        $SqlBulkCopy.WriteToServer($DataTable);
        [void] $SqlBulkCopy.Close();
        [void] $SqlBulkCopy.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        [void] $DataTable.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.FileImport `
    -Name "GetCSVRowCount" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Int64])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath,
    
            [Parameter(Mandatory=$true)]
            [String] $Delimiter
        )
        [Int64] $Results = (-1);
        If ([String]::IsNullOrEmpty($Delimiter))
        {
            $Delimiter = ",";
        }
        $Results = (Import-Csv -Path $FilePath -Delimiter $Delimiter).Rows.Count;
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.Databases.FileImport `
    -Name "DeleteSQLServerTableFileRows" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath,
    
            [Parameter(Mandatory=$true)]
            [String] $SQLConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($SQLConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand_Delete = [Data.SqlClient.SqlCommand]::new("DELETE FROM [$Schema].[$Table] WHERE [_SourceFilePath_] = @FilePath", $SqlConnection);
        [Data.SqlClient.SqlParameter] $SqlParameter_FilePath = $SqlCommand_Delete.CreateParameter();
        $SqlParameter_FilePath.ParameterName = "@FilePath";
        $SqlParameter_FilePath.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_FilePath.Size = 400;
        $SqlParameter_FilePath.SqlValue = $FilePath;
        [void] $SqlCommand_Delete.Parameters.Add($SqlParameter_FilePath);
        [void] $SqlCommand_Delete.ExecuteNonQuery();
        [void] $SqlCommand_Delete.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.FileImport `
    -Name "GetSQLServerNewestFilePath" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $SQLConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table
        )
        [String] $Results = [String]::Empty;
        [Boolean] $HasDateTimeColumn = $Global:Job.Databases.GetSQLServerTableHasColumn($Global:Job.Config.DatabaseConnectionName, "TravelPort", "StagedFile", "_SourceFileDateTime_");
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($SQLConnectionName));
        [void] $SqlConnection.Open();
        [String] $CommandText = [String]::Empty;
        If ($HasDateTimeColumn)
        {
            $CommandText = @"
                SELECT [File].[_SourceFilePath_]
                    FROM
                    (
                        SELECT MAX([_SourceFileDateTime_]) AS [_SourceFileDateTime_]
                            FROM [$Schema].[$Table]
                    ) AS [MaximumFileDateTime]
                        INNER JOIN
                        (
                            SELECT DISTINCT
                                [_SourceFilePath_],
                                [_SourceFileDateTime_]
                                FROM [$Schema].[$Table]
                        ) AS [File]
                            ON [MaximumFileDateTime].[_SourceFileDateTime_] = [File].[_SourceFileDateTime_]
"@;
        }
        Else
        {
            $CommandText = "SELECT MAX([_SourceFilePath_]) AS [_SourceFilePath_] FROM [$Schema].[$Table]";
        }
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($CommandText, $SqlConnection);
        [Object] $ScalarObject = $SqlCommand.ExecuteScalar();
        If ($ScalarObject -is [String])
        {
            $Results = [String]$ScalarObject;
        }
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.Databases.FileImport `
    -Name "GetSQLServerNewestFileDateTime" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([DateTime])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $SQLConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table
        )
        [DateTime] $Results = [DateTime]::MinValue;
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($SQLConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("SELECT MAX([_SourceFileDateTime_]) AS [_SourceFileDateTime_] FROM [$Schema].[$Table]", $SqlConnection);
        [Object] $ScalarObject = $SqlCommand.ExecuteScalar();
        If ($ScalarObject -is [DateTime])
        {
            $Results = [DateTime]$ScalarObject;
        }
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.Databases `
    -Name "GetSQLServerTableHasColumn" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $SQLConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table,

            [Parameter(Mandatory=$true)]
            [String] $Column
        )
        [Boolean] $Results = $false;
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($SQLConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new(@"
            SELECT
                CASE
                    WHEN EXISTS
                    (
                        SELECT 1
                            FROM [sys].[columns]
                                INNER JOIN [sys].[objects]
                                    ON [columns].[object_id] = [objects].[object_id]
                                INNER JOIN [sys].[schemas]
                                    ON [objects].[schema_id] = [schemas].[schema_id]
                            WHERE
                                [columns].[name] = N'$Column'
                                AND [objects].[name] = N'$Table'
                                AND [schemas].[name] = N'$Schema'
                    )
                        THEN CONVERT([bit], 1, 0)
                    ELSE CONVERT([bit], 0, 0)
                END AS [HasSourceFilePath]
"@, $SqlConnection);
        [Object] $ScalarObject = $SqlCommand.ExecuteScalar();
        If ($ScalarObject -is [Boolean])
        {
            $Results = [Boolean]$ScalarObject;
        }
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.Databases `
    -Name "GetLargeSQLScalarValue" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Instance,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$true)]
            [String] $CommandText,
    
            [Parameter(Mandatory=$false)]
            [Collections.Hashtable] $Parameters
        )
        [String] $ReturnValue = $null;
        ForEach ($ParameterKey In $Parameters.Keys)
        {
            $CommandText = $CommandText.Replace("`$($ParameterKey)", $Parameters[$ParameterKey].ToString());
        }

        [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
        [void] $SqlConnection.Open();
    
        If (![String]::IsNullOrEmpty($CommandText.Trim()))
        {
            [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($CommandText, $SqlConnection);
            $SqlCommand.CommandType = [Data.CommandType]::Text
            $SqlCommand.CommandTimeout = 0;
            [Object] $ScalarObject = $SqlCommand.ExecuteScalar();
            If ($ScalarObject -is [String])
            {
                $ReturnValue = [String]$ScalarObject
            }
            [void] $SqlCommand.Dispose();
        }
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $ReturnValue;
    };
