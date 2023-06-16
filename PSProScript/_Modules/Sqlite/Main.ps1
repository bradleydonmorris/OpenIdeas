[void] $Global:Session.LoadModule("Connections");

[void] $Global:Session.NuGet.InstallPackageIfMissing("System.Data.Sqlite");
[void] $Global:Session.NuGet.AddAssembly("System.Data.Sqlite", "Stub.System.Data.Sqlite.Core.NetFramework.1.0.117.0\lib\net451\System.Data.Sqlite.dll");

Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Sqlite" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

#region Connection Methods
Add-Member `
    -InputObject $Global:Session.Sqlite `
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
    
            [Parameter(Mandatory=$false)]
            [String] $FilePath
        )
        $Global:Session.Connections.Set(
            $Name,
            [PSCustomObject]@{
                "FilePath" = $FilePath;
                "Comments" = $Comments;
            },
            $IsPersisted
        );
    };
Add-Member `
    -InputObject $Global:Session.Sqlite `
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
    -InputObject $Global:Session.Sqlite `
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
        If (![IO.File]::Exists($Connection.FilePath))
        {
            Throw [System.IO.FileNotFoundException]::new("Database File not found", $Connection.FilePath);
        }
        Return [String]::Format("Data Source={0}", $Connection.FilePath);
    };
#endregion Connection Methods

#region Base Methods
Add-Member `
    -InputObject $Global:Session.Sqlite `
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
        [Data.Sqlite.SqliteConnection] $Connection = $null;
        [Data.Sqlite.SqliteCommand] $Command = $null;
        Try
        {
            $Connection = [Data.Sqlite.SqliteConnection]::new($Global:Session.Sqlite.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.Sqlite.SqliteCommand]::new($CommandText, $Connection);
            $Command.CommandType = [Data.CommandType]::Text;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If (!$Name.StartsWith("@"))
                    { $Name = "@" + $Name}
                [void] $Command.Parameters.AddWithValue($Name, $Global:Session.Sqlite.ConvertToDBValue($Parameters[$ParameterKey]));
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
    -InputObject $Global:Session.Sqlite `
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
            [Collections.Generic.List[String]] $Fields,

            [Parameter(Mandatory=$true)]
            [Collections.Hashtable] $FieldConversion
        )
        [Collections.Generic.List[PSObject]] $ReturnValue = [Collections.Generic.List[PSObject]]::new();
        [Data.Sqlite.SqliteConnection] $Connection = $null;
        [Data.Sqlite.SqliteCommand] $Command = $null;
        [Data.Sqlite.SqliteDataReader] $DataReader = $null;
        $FieldConversion = (($FieldConversion -ne $null) ? $FieldConversion : [Collections.Hashtable]::new());
        Try
        {
            $Connection = [Data.Sqlite.SqliteConnection]::new($Global:Session.Sqlite.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.Sqlite.SqliteCommand]::new($CommandText, $Connection);
            $Command.CommandType = [Data.CommandType]::Text;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If (!$Name.StartsWith("@"))
                    { $Name = "@" + $Name}
                [void] $Command.Parameters.AddWithValue($Name, $Global:Session.Sqlite.ConvertToDBValue($Parameters[$ParameterKey]));
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
                    [Object] $Value = (
                        $FieldConversion.ContainsKey($Field) ?
                            $Global:Session.Sqlite.ConvertFromDBValue(
                                $DataReader.GetValue($DataReader.GetOrdinal($Field)),
                                $FieldConversion[$Field]
                            ) :
                            $DataReader.GetValue($DataReader.GetOrdinal($Field))
                    );
                    Add-Member `
                        -InputObject $Record `
                        -TypeName ($Value.GetType().Name) `
                        -NotePropertyName $Field `
                        -NotePropertyValue $Value;
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
    -InputObject $Global:Session.Sqlite `
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
        [Data.Sqlite.SqliteConnection] $Connection = $null;
        [Data.Sqlite.SqliteCommand] $Command = $null;
        Try
        {
            $Connection = [Data.Sqlite.SqliteConnection]::new($Global:Session.Sqlite.GetConnectionString($ConnectionName));
            $Connection.Open();
            $Command = [Data.Sqlite.SqliteCommand]::new($CommandText, $Connection);
            $Command.CommandType = [Data.CommandType]::Text;
            ForEach ($ParameterKey In $Parameters.Keys)
            {
                [String] $Name = $ParameterKey;
                If (!$Name.StartsWith("@"))
                    { $Name = "@" + $Name}
                [void] $Command.Parameters.AddWithValue($Name, $Global:Session.Sqlite.ConvertToDBValue($Parameters[$ParameterKey]));
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
    -InputObject $Global:Session.Sqlite `
    -Name "ClearTable" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Table
        )
        [void] $Global:Session.Sqlite.Execute($ConnectionName, [String]::Format("DELETE FROM ``{0}``", $Table));
    };
Add-Member `
    -InputObject $Global:Session.Sqlite `
    -Name "GetTableRowCount" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Int64])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

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
                        "{0}``{1}`` = @Param{2}{3}",
                        (
                            ($FilterIndex -eq 0) ?    
                                "" :
                                " AND "
                        ),
                        $FilterKey,
                        $FilterIndex,
                        (
                            ($Filters[$FilterKey] -is [String]) ?
                                " COLLATE NOCASE" :
                                ""
                        )
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
            [String]::Format("SELECT COUNT(*) FROM ``{0}``{1}",
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
    -InputObject $Global:Session.Sqlite `
    -Name "DoesTableHaveColumn" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,
    
            [Parameter(Mandatory=$true)]
            [String] $Table,

            [Parameter(Mandatory=$true)]
            [String] $Column
        )
        [Boolean] $ReturnValue = $false;
        [Object] $ScalarValue = $Global:Session.Sqlite.GetScalar(
            $ConnectionName,
            (
                "SELECT 1 AS HasColumn`r`n" +
                "FROM sqlite_master`r`n" +
                "LEFT OUTER JOIN pragma_table_info((sqlite_master.name)) AS pragma_table_info ON sqlite_master.name <> pragma_table_info.name`r`n" +
                "WHERE sqlite_master.name = @Table AND pragma_table_info.name = @Column"
            ),
            @{
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
    -InputObject $Global:Session.Sqlite `
    -Name "ConvertToDBValue" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Object])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Object] $Value
        )
        [Object] $ReturnValue = $null;
        Switch ($Value.GetType().Name)
        {
            {($_ -eq "Guid") -or ($_ -eq "System.Guid")}
                { $ReturnValue = $Value.ToString("N"); }
            {($_ -eq "DateTime") -or ($_ -eq "System.DateTime")}
                { $ReturnValue = $Value.ToString("yyyy-MM-dd HH:mm:ss.fffffff"); }
            Default { $ReturnValue = $Value; }
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.Sqlite `
    -Name "ConvertFromDBValue" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Object])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Object] $Value,

            [Parameter(Mandatory=$true)]
            [String] $Type
        )
        [Object] $ReturnValue = $null;
        Switch ($Type)
        {
            {($_ -eq "Guid") -or ($_ -eq "System.Guid")}
                { $ReturnValue = [Guid]::Parse($Value); }
            {($_ -eq "DateTime") -or ($_ -eq "System.DateTime")}
                { $ReturnValue = [DateTime]::Parse($Value); }
            {($_ -eq "Int64") -or ($_ -eq "System.Int64")}
                { $ReturnValue = [Int64]$Value; }
            {($_ -eq "String") -or ($_ -eq "System.String")}
                { $ReturnValue = [String]$Value; }
            {($_ -eq "Double") -or ($_ -eq "System.Double")}
                { $ReturnValue = [Double]$Value; }
            Default { $ReturnValue = $Value; }
        }
        Return $ReturnValue;
    }
Add-Member `
    -InputObject $Global:Session.Sqlite `
    -Name "CreateIfNotFound" `
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
        $ConnectionValues = $Global:Session.Connections.Get($ConnectionName);
        If (![IO.File]::Exists($ConnectionValues.FilePath))
        {
            [Data.Sqlite.SqliteConnection] $Connection = $null;
            [Data.Sqlite.SqliteCommand] $Command = $null;
            Try
            {
                $Connection = [Data.Sqlite.SqliteConnection]::new($Global:Session.Sqlite.GetConnectionString($ConnectionName));
                $Connection.Open();
                $Command = [Data.Sqlite.SqliteCommand]::new($CommandText, $Connection);
                $Command.CommandType = [Data.CommandType]::Text;
                ForEach ($ParameterKey In $Parameters.Keys)
                {
                    [String] $Name = $ParameterKey;
                    If (!$Name.StartsWith("@"))
                        { $Name = "@" + $Name}
                    [void] $Command.Parameters.AddWithValue($Name, $Global:Session.Sqlite.ConvertToDBValue($Parameters[$ParameterKey]));
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
    }
