Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "SQLServerDatabases" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.SQLServerDatabases `
    -Name "GetConnection" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [String] $Result = $null;
        $Values = $Global:Job.Connections.Get($Name);
        If ($Values.AuthType -eq "UserNameAndPassword")
        {
            $Result = "Server=tcp:" + $Values.Instance + ";" +
                "Database=" + $Values.Database + ";" +
                "User ID=" + $Values.UserName + ";" +
                "Password=" + $Values.Password + ";";
        }
        If ($Values.AuthType -eq "Integrated")
        {
            $Result = "Server=tcp:" + $Values.Instance + ";" +
                "Database=" + $Values.Database + ";" +
                "Trusted_Connection=True;";
        }
        Return $Result;
    };
Add-Member `
    -InputObject $Global:Job.SQLServerDatabases `
    -Name "GetConnectionString" `
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
            [String] $UserName,
    
            [Parameter(Mandatory=$true)]
            [String] $Password,
    
            [Parameter(Mandatory=$true)]
            [String] $WorkstationName,
    
            [Parameter(Mandatory=$true)]
            [String] $ApplicationName
        )
        $WorkstationName = (
            ![String]::IsNullOrEmpty($WorkstationName) ?
                $WorkstationName :
                [System.Net.Dns]::GetHostName()
        );
        $ApplicationName = (
            ![String]::IsNullOrEmpty($ApplicationName) ?
                $ApplicationName :
                [String]::Format("{0}/{1}",
                    $Global:Job.Collection,
                    $Global:Job.Script
                )
        );
        [String] $Authentication = (
            [String]::IsNullOrEmpty($UserName) ?
                "Trusted_Connection=True" :
                [String]::Format("User ID={0};Password={1}",
                    $UserName,
                    $Password
                )
        );
        Return [String]::Format(
            "Server={0};Database={1};{2};Workstation ID={3}Application Name={4}",
            $Instance,
            $Database,
            $Authentication,
            $WorkstationName,
            $ApplicationName
        );
    };
Add-Member `
    -InputObject $Global:Job.SQLServerDatabases `
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
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Databases.GetConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("TRUNCATE TABLE [$Schema].[$Table]", $SqlConnection);
        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.SQLServerDatabases `
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
        [Int64] $ReturnValue = (-1);
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
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.SQLServerDatabases.GetConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new(
            [String]::Format("SELECT COUNT_BIG(*) FROM [{0}].[{1}]{2}",
                $Schema,
                $Table,
                $WhereClause # May be an empty string if $Filters is null or empty
            ),
            $SqlConnection
        );
        ForEach ($ParameterKey In $Parameters.Keys)
        {
            [void] $SqlCommand.Parameters.AddWithValue($ParameterKey, $Parameters[$ParameterKey]);
        }
        [Object] $ScalarObject = $SqlCommand.ExecuteScalar();
        If (
            $ScalarObject -is [Int64] -or
            $ScalarObject -is [Int32] -or
            $ScalarObject -is [Int16] -or
            $ScalarObject -is [Byte]
        )
        {
            $ReturnValue = [Int64]$ScalarObject
        }
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.SQLServerDatabases `
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
        [Boolean] $Results = $false;
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.SQLServerDatabases.GetConnection($ConnectionName));
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
                                [columns].[name] = @Column
                                AND [objects].[name] = @Table
                                AND [schemas].[name] = @Schema
                    )
                        THEN CONVERT([bit], 1, 0)
                    ELSE CONVERT([bit], 0, 0)
                END AS [HasSourceFilePath]
"@, $SqlConnection);
        ForEach ($ParameterKey In @{
                                    "@Schema" = $Schema;
                                    "@Table" = $Table;
                                    "@Column" = $Column;
                                    }
        )
        {
            [void] $SqlCommand.Parameters.AddWithValue($ParameterKey, $Parameters[$ParameterKey]);
        }
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
    -InputObject $Global:Job.SQLServerDatabases `
    -Name "GetLargeSQLScalarValue" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Object])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Database,
    
            [Parameter(Mandatory=$true)]
            [String] $CommandText,
    
            [Parameter(Mandatory=$false)]
            [Collections.Hashtable] $Parameters
        )
        [Object] $ReturnValue = $null;
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.SQLServerDatabases.GetConnection($ConnectionName));
        [void] $SqlConnection.Open();
    
        If (![String]::IsNullOrEmpty($CommandText.Trim()))
        {
            [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($CommandText, $SqlConnection);
            $SqlCommand.CommandType = [Data.CommandType]::Text
            $SqlCommand.CommandTimeout = 0;
            ForEach ($ParameterKey In $Parameters)
            {
                [void] $SqlCommand.Parameters.AddWithValue($ParameterKey, $Parameters[$ParameterKey]);
            }
            $ReturnValue = $SqlCommand.ExecuteScalar();
            [void] $SqlCommand.Dispose();
        }
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Job.SQLServerDatabases `
    -Name "ExecuteScript" `
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
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.SQLServerDatabases.GetConnection($ConnectionName));
        [void] $SqlConnection.Open();
        If (![String]::IsNullOrEmpty($CommandText.Trim()))
        {
            [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($CommandText, $SqlConnection);
            $SqlCommand.CommandType = [Data.CommandType]::Text
            $SqlCommand.CommandTimeout = 0;
            ForEach ($ParameterKey In $Parameters)
            {
                [void] $SqlCommand.Parameters.AddWithValue($ParameterKey, $Parameters[$ParameterKey]);
            }
            [void] $SqlCommand.ExecuteNonQuery();
            [void] $SqlCommand.Dispose();
        }
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
