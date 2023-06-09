[void] $Global:Session.LoadModule("SQLServer");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "SQLServerFileImport" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.SQLServerFileImport `
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
        [System.Data.DataTable] $ReturnValue = [System.Data.DataTable]::new();
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
            $DataRow = $ReturnValue.NewRow();
            [Boolean] $IsDataRow = $Record.PSObject.TypeNames -like "*.DataRow*" -as [Boolean]
            ForEach ($Property in $Record.PSObject.Properties)
            {   
                If (
                    $IsDataRow -and
                    $IgnoredProperties -contains $Property.Name
                ) { Continue; }

                $IsBaseType = $BaseTypes.ContainsKey($Property.TypeNameOfValue)
                If (-not $ReturnValue.Columns.Contains($Property.Name))
                {   
                    [Data.DataColumn] $DataColumn = [Data.DataColumn]::new($Property.Name);
                    If ($IsBaseType)
                        { $DataColumn.DataType = $Property.TypeNameOfValue; }
                    Else
                        { $DataColumn.DataType = "System.Object"; }
                    $ReturnValue.Columns.Add($DataColumn);
                }                   
                If ($IsBaseType -and $Property.Value)
                    { $DataRow.Item($Property.Name) = $Property.Value; }
                ElseIf ($Property.Value)
                    { $DataRow.Item($Property.Name) = [PSObject]$Property.Value; }
                Else
                    { $DataRow.Item($Property.Name) = [DBNull]::Value; }
            }
            $ReturnValue.Rows.Add($DataRow)   
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.SQLServerFileImport `
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
        [Int64] $ReturnValue = (-1);
        If ([String]::IsNullOrEmpty($Delimiter))
        {
            $Delimiter = ",";
        }
        $ReturnValue = (Import-Csv -Path $FilePath -Delimiter $Delimiter).Rows.Count;
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.SQLServerFileImport `
    -Name "ImportCSV" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Schema,
    
            [Parameter(Mandatory=$true)]
            [String] $Table,
    
            [Parameter(Mandatory=$true)]
            [String] $FilePath,
    
            [Parameter(Mandatory=$true)]
            [String] $Delimiter,

            [Parameter(Mandatory=$true)]
            [Int32] $BatchSize,

            [Parameter(Mandatory=$true)]
            [Collections.Generic.List[PSObject]] $AdditionalDataItems
                <#
                    Array of 
                        @{
                            "Ordinal" = 0;
                            "Name" = "COLUMNNAME";
                            "DataType" = "System.String or other simple type";
                            "Value" = "VALUE"
                        }
                #>
        )
        [System.Data.DataTable] $DataTable = $Global:Session.SQLServerFileImport.CSVToDataTable($FilePath, $Delimiter);
        If ($AdditionalDataItems)
        {
            If ($AdditionalDataItems.Count -gt 0)
            {
                ForEach ($Item In $AdditionalDataItems)
                {
                    [Data.DataColumn] $DataColumn = [Data.DataColumn]::new($Item.Name);
                    [Type]::GetType($Item.DataType);
                    $DataColumn.DefaultValue = $Item.Value;
                    $DataTable.Columns.Add($DataColumn);
                    [void] $DataColumn.SetOrdinal([Int32]$Item.Ordinal);
                }
            }
        }
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Session.SQLServer.GetConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlBulkCopy] $SqlBulkCopy = [Data.SqlClient.SqlBulkCopy]::new($SqlConnection);
        $SqlBulkCopy.BatchSize = $BatchSize;
        $SqlBulkCopy.DestinationTableName = [String]::Format("[{0}].[{1}]", $Schema, $Table);
        $SqlBulkCopy.WriteToServer($DataTable);
        [void] $SqlBulkCopy.Close();
        [void] $SqlBulkCopy.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        [void] $DataTable.Dispose();
    };
