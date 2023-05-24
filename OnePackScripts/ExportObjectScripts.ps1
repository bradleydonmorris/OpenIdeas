[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [String] $Instance,

    [Parameter(Mandatory=$true)]
    [String] $Database,

    [Parameter(Mandatory=$true)]
    [String] $OutputDirectoryPath
 )

Class SQLObjectInfo {
    [Int64] $CreateOrder;
    [Int64] $DropOrder;
    [Int32] $ObjectId;
    [String] $Schema;
    [String] $Name;
    [String] $SimpleType;
    [String] $Type;
    [String] $QualifiedName;
    [String] $Script;

    SQLObjectInfo (
        [Int64] $createOrder,
        [Int64] $dropOrder,
        [Int32] $objectId,
        [String] $schema,
        [String] $name,
        [String] $simpleType,
        [String] $type,
        [String] $qualifiedName
    )
    {
        $this.CreateOrder = $createOrder;
        $this.DropOrder = $dropOrder;
        $this.ObjectId = $objectId;
        $this.Schema = $schema;
        $this.Name = $name;
        $this.SimpleType = $simpleType;
        $this.Type = $type;
        $this.QualifiedName = $qualifiedName;
    }

}

Function Get-SQLDependencies()
{
    [OutputType([Collections.ArrayList])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Instance,

        [Parameter(Mandatory=$true)]
        [String] $Database,

        [Parameter(Mandatory=$false)]
        [String] $Schema,

        [Parameter(Mandatory=$false)]
        [String] $OverrideGetDependenciesFilePath,

        [Parameter(Mandatory=$false)]
        [Collections.Hashtable] $Parameters
    )
    [Collections.ArrayList] $ReturnValue = [Collections.ArrayList]::new();

    [String] $CommandText = @"
    DECLARE @ObjectRowCount [int] = 1
    DECLARE @LastUsedLevel [int] = 0
    DECLARE @ObjectDependency TABLE
    (
        [Id] [int] IDENTITY(1, 1) NOT NULL,
        [ObjectId] [int] NOT NULL,
        [Type] [nvarchar](60) NOT NULL,
        [Level] [int] NOT NULL
    )
    INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
        SELECT
            [tables].[object_id] AS [ObjectId],
            [tables].[type_desc] AS [Type],
            0 AS [Level]
            FROM [sys].[tables] WITH (NOLOCK)
                INNER JOIN [sys].[schemas] WITH (NOLOCK)
                    ON [tables].[schema_id] = [schemas].[schema_id]
                LEFT OUTER JOIN [sys].[foreign_keys] WITH (NOLOCK)
                    ON [tables].[object_id] = [foreign_keys].[parent_object_id]
            WHERE
                [schemas].[name] != N'sys'
                AND [tables].[is_ms_shipped] = 0
                AND [foreign_keys].[object_id] IS NULL
    SET @ObjectRowCount = 1
    WHILE @ObjectRowCount > 0
        BEGIN
            INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
                SELECT
                    [tables].[object_id] AS [ObjectId],
                    [tables].[type_desc] AS [Type],
                    ([@ObjectDependency].[Level] + 1) AS [Level]
                    FROM [sys].[tables] WITH (NOLOCK)
                        INNER JOIN [sys].[schemas] WITH (NOLOCK)
                            ON [tables].[schema_id] = [schemas].[schema_id]
                        INNER JOIN [sys].[foreign_keys] WITH (NOLOCK)
                            ON [tables].[object_id] = [foreign_keys].[parent_object_id]
                        INNER JOIN @ObjectDependency AS [@ObjectDependency]
                            ON [foreign_keys].[referenced_object_id] = [@ObjectDependency].[ObjectId]
                        LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency_Exists]
                            ON [tables].[object_id] = [@ObjectDependency_Exists].[ObjectId]
                    WHERE
                        [tables].[is_ms_shipped] = 0
                        AND [schemas].[name] != N'sys'
                        AND [tables].[is_ms_shipped] = 0
                        AND [@ObjectDependency_Exists].[ObjectId] IS NULL
            SET @ObjectRowCount = @@ROWCOUNT
            RAISERROR(N'Current Row Count: %i', 1, 1, @ObjectRowCount) WITH NOWAIT
        END
    SELECT @LastUsedLevel = MAX([Level])
        FROM @ObjectDependency
    INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
        SELECT
            [objects].[object_id] AS [ObjectId],
            [objects].[type_desc] AS [Type],
            (@LastUsedLevel + 1) AS [Level]
            FROM [sys].[objects] WITH (NOLOCK)
                INNER JOIN [sys].[schemas] WITH (NOLOCK)
                    ON [objects].[schema_id] = [schemas].[schema_id]
                LEFT OUTER JOIN
                (
                    SELECT
                        [sql_dependencies].[object_id],
                        COUNT(*) AS [Count]
                        FROM [sys].[sql_dependencies] WITH (NOLOCK)
                            LEFT OUTER JOIN [sys].[objects] WITH (NOLOCK)
                                ON [sql_dependencies].[referenced_major_id] = [objects].[object_id]
                        WHERE [objects].[type_desc] != N'USER_TABLE'
                        GROUP BY
                            [sql_dependencies].[object_id]
                ) AS [sql_dependencies]
                    ON [objects].[object_id] = [sql_dependencies].[object_id]
            WHERE
                ISNULL([sql_dependencies].[Count], 0) = 0
                AND [objects].[type_desc] IN
                (
                    N'SQL_STORED_PROCEDURE',
                    N'VIEW',
                    N'SQL_INLINE_TABLE_VALUED_FUNCTION',
                    N'SQL_TABLE_VALUED_FUNCTION',
                    N'SQL_SCALAR_FUNCTION'
                )
    SET @ObjectRowCount = 1
    WHILE @ObjectRowCount > 0
        BEGIN
            INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
                SELECT
                    [objects].[object_id] AS [ObjectId],
                    [objects].[type_desc] AS [Type],
                    ([@ObjectDependency].[Level] + 1) AS [Level]
                    FROM [sys].[objects] WITH (NOLOCK)
                        INNER JOIN [sys].[schemas] WITH (NOLOCK)
                            ON [objects].[schema_id] = [schemas].[schema_id]
                        INNER JOIN [sys].[sql_dependencies] WITH (NOLOCK)
                            ON [sql_dependencies].[object_id] = [objects].[object_id]
                        INNER JOIN @ObjectDependency AS [@ObjectDependency]
                            ON [sql_dependencies].[referenced_major_id] = [@ObjectDependency].[ObjectId]
                        LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency_Exists]
                            ON [objects].[object_id] = [@ObjectDependency_Exists].[ObjectId]
                    WHERE
                        [objects].[is_ms_shipped] = 0
                        AND [@ObjectDependency_Exists].[ObjectId] IS NULL
            SET @ObjectRowCount = @@ROWCOUNT
            RAISERROR(N'Current Row Count: %i', 1, 1, @ObjectRowCount) WITH NOWAIT
        END
    INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
        SELECT
            [objects].[object_id] AS [ObjectId],
            [objects].[type_desc] AS [Type],
            CASE
                WHEN [objects].[type_desc] = N'USER_TABLE'
                    THEN 0
                ELSE (@LastUsedLevel + 1)
            END AS [Level]
            FROM [sys].[objects] WITH (NOLOCK)
                INNER JOIN [sys].[schemas] WITH (NOLOCK)
                    ON [objects].[schema_id] = [schemas].[schema_id]
                LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency]
                    ON [objects].[object_id] = [@ObjectDependency].[ObjectId]
            WHERE
                [@ObjectDependency].[ObjectId] IS NULL
                AND [objects].[is_ms_shipped] = 0
                AND [objects].[type_desc] IN
                (
                    N'SQL_INLINE_TABLE_VALUED_FUNCTION',
                    N'SQL_SCALAR_FUNCTION',
                    N'SQL_STORED_PROCEDURE',
                    N'SQL_TABLE_VALUED_FUNCTION',
                    N'USER_TABLE',
                    N'VIEW'
                )
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY 
                CASE
                    WHEN [objects].[type_desc] = N'USER_TABLE' THEN 0
                    ELSE 1
                END ASC,
                [@ObjectDependency].[Level] ASC,
                CASE
                    WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN 3
                    WHEN [objects].[type_desc] = N'VIEW' THEN 2
                    WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN 1
                    WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN 1
                    WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN 1
                    WHEN [objects].[type_desc] = N'USER_TABLE' THEN 0
                    ELSE (-1)
                END ASC,
                [schemas].[name] ASC,
                [objects].[name] ASC
        ) AS [CreateOrder],
        ROW_NUMBER() OVER (
            ORDER BY 
                CASE
                    WHEN [Type] = 'Table' THEN 0
                    ELSE 1
                END DESC,
                [@ObjectDependency].[Level] DESC,
                CASE
                    WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN 3
                    WHEN [objects].[type_desc] = N'VIEW' THEN 2
                    WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN 1
                    WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN 1
                    WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN 1
                    WHEN [objects].[type_desc] = N'USER_TABLE' THEN 0
                    ELSE (-1)
                END DESC,
                [schemas].[name] DESC,
                [objects].[name] DESC
        ) AS [DropOrder],
        [objects].[object_id] AS [ObjectId],
        [schemas].[name] AS [Schema],
        [objects].[name] AS [Name],
        CASE
            WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN N'Procedure'
            WHEN [objects].[type_desc] = N'VIEW' THEN N'View'
            WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN N'Function'
            WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN N'Function'
            WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN N'Function'
            WHEN [objects].[type_desc] = N'USER_TABLE' THEN N'Table'
            ELSE CONCAT(N'OTHER: ', [objects].[type_desc])
        END AS [SimpleType],
        [objects].[type_desc] AS [Type],
        CONCAT(QUOTENAME([schemas].[name]), N'.', QUOTENAME([objects].[name])) AS [QualifiedName]
        FROM
        (
            SELECT
                [@ObjectDependency].[ObjectId],
                MAX([@ObjectDependency].[Level]) AS [Level]
                FROM @ObjectDependency AS [@ObjectDependency]
                GROUP BY [@ObjectDependency].[ObjectId]
        ) AS [@ObjectDependency]
            INNER JOIN [sys].[objects] WITH (NOLOCK)
                ON [@ObjectDependency].[ObjectId] = [objects].[object_id]
            INNER JOIN [sys].[schemas] WITH (NOLOCK)
                ON [objects].[schema_id] = [schemas].[schema_id]
"@;
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
        $CommandText = @"
        DECLARE @SchemaName [sys].[sysname] = N'`$(SchemaName)'
        DECLARE @ObjectRowCount [int] = 1
        DECLARE @LastUsedLevel [int] = 0
        DECLARE @ObjectDependency TABLE
        (
            [Id] [int] IDENTITY(1, 1) NOT NULL,
            [ObjectId] [int] NOT NULL,
            [Type] [nvarchar](60) NOT NULL,
            [Level] [int] NOT NULL
        )
        INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
            SELECT
                [tables].[object_id] AS [ObjectId],
                [tables].[type_desc] AS [Type],
                0 AS [Level]
                FROM [sys].[tables] WITH (NOLOCK)
                    INNER JOIN [sys].[schemas] WITH (NOLOCK)
                        ON [tables].[schema_id] = [schemas].[schema_id]
                    LEFT OUTER JOIN [sys].[foreign_keys] WITH (NOLOCK)
                        ON [tables].[object_id] = [foreign_keys].[parent_object_id]
                WHERE
                    [schemas].[name] = @SchemaName
                    AND [tables].[is_ms_shipped] = 0
                    AND [foreign_keys].[object_id] IS NULL
        SET @ObjectRowCount = 1
        WHILE @ObjectRowCount > 0
            BEGIN
                INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
                    SELECT
                        [tables].[object_id] AS [ObjectId],
                        [tables].[type_desc] AS [Type],
                        ([@ObjectDependency].[Level] + 1) AS [Level]
                        FROM [sys].[tables] WITH (NOLOCK)
                            INNER JOIN [sys].[schemas] WITH (NOLOCK)
                                ON [tables].[schema_id] = [schemas].[schema_id]
                            INNER JOIN [sys].[foreign_keys] WITH (NOLOCK)
                                ON [tables].[object_id] = [foreign_keys].[parent_object_id]
                            INNER JOIN @ObjectDependency AS [@ObjectDependency]
                                ON [foreign_keys].[referenced_object_id] = [@ObjectDependency].[ObjectId]
                            LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency_Exists]
                                ON [tables].[object_id] = [@ObjectDependency_Exists].[ObjectId]
                        WHERE
                            [tables].[is_ms_shipped] = 0
                            AND [schemas].[name] = @SchemaName
                            AND [tables].[is_ms_shipped] = 0
                            AND [@ObjectDependency_Exists].[ObjectId] IS NULL
                SET @ObjectRowCount = @@ROWCOUNT
                RAISERROR(N'Current Row Count: %i', 1, 1, @ObjectRowCount) WITH NOWAIT
            END
        SELECT @LastUsedLevel = MAX([Level])
            FROM @ObjectDependency
        INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
            SELECT
                [objects].[object_id] AS [ObjectId],
                [objects].[type_desc] AS [Type],
                (@LastUsedLevel + 1) AS [Level]
                FROM [sys].[objects] WITH (NOLOCK)
                    INNER JOIN [sys].[schemas] WITH (NOLOCK)
                        ON [objects].[schema_id] = [schemas].[schema_id]
                    LEFT OUTER JOIN
                    (
                        SELECT
                            [sql_dependencies].[object_id],
                            COUNT(*) AS [Count]
                            FROM [sys].[sql_dependencies] WITH (NOLOCK)
                                LEFT OUTER JOIN [sys].[objects]
                                    ON [sql_dependencies].[referenced_major_id] = [objects].[object_id]
                            WHERE [objects].[type_desc] != N'USER_TABLE'
                            GROUP BY
                                [sql_dependencies].[object_id]
                    ) AS [sql_dependencies]
                        ON [objects].[object_id] = [sql_dependencies].[object_id]
                WHERE
                    ISNULL([sql_dependencies].[Count], 0) = 0
                    AND [schemas].[name] = @SchemaName
                    AND [objects].[type_desc] IN
                    (
                        N'SQL_STORED_PROCEDURE',
                        N'VIEW',
                        N'SQL_INLINE_TABLE_VALUED_FUNCTION',
                        N'SQL_TABLE_VALUED_FUNCTION',
                        N'SQL_SCALAR_FUNCTION'
                    )
        SET @ObjectRowCount = 1
        WHILE @ObjectRowCount > 0
            BEGIN
                INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
                    SELECT
                        [objects].[object_id] AS [ObjectId],
                        [objects].[type_desc] AS [Type],
                        ([@ObjectDependency].[Level] + 1) AS [Level]
                        FROM [sys].[objects] WITH (NOLOCK)
                            INNER JOIN [sys].[schemas] WITH (NOLOCK)
                                ON [objects].[schema_id] = [schemas].[schema_id]
                            INNER JOIN [sys].[sql_dependencies] WITH (NOLOCK)
                                ON [sql_dependencies].[object_id] = [objects].[object_id]
                            INNER JOIN @ObjectDependency AS [@ObjectDependency]
                                ON [sql_dependencies].[referenced_major_id] = [@ObjectDependency].[ObjectId]
                            LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency_Exists]
                                ON [objects].[object_id] = [@ObjectDependency_Exists].[ObjectId]
                        WHERE
                            [objects].[is_ms_shipped] = 0
                            AND [schemas].[name] = @SchemaName
                            AND [@ObjectDependency_Exists].[ObjectId] IS NULL
                SET @ObjectRowCount = @@ROWCOUNT
                RAISERROR(N'Current Row Count: %i', 1, 1, @ObjectRowCount) WITH NOWAIT
            END
        INSERT INTO @ObjectDependency([ObjectId], [Type], [Level])
            SELECT
                [objects].[object_id] AS [ObjectId],
                [objects].[type_desc] AS [Type],
                CASE
                    WHEN [objects].[type_desc] = N'USER_TABLE'
                        THEN 0
                    ELSE (@LastUsedLevel + 1)
                END AS [Level]
                FROM [sys].[objects] WITH (NOLOCK)
                    INNER JOIN [sys].[schemas] WITH (NOLOCK)
                        ON [objects].[schema_id] = [schemas].[schema_id]
                    LEFT OUTER JOIN @ObjectDependency AS [@ObjectDependency]
                        ON [objects].[object_id] = [@ObjectDependency].[ObjectId]
                WHERE
                    [@ObjectDependency].[ObjectId] IS NULL
                    AND [objects].[is_ms_shipped] = 0
                    AND [schemas].[name] = @SchemaName
                    AND [objects].[type_desc] IN
                    (
                        N'SQL_INLINE_TABLE_VALUED_FUNCTION',
                        N'SQL_SCALAR_FUNCTION',
                        N'SQL_STORED_PROCEDURE',
                        N'SQL_TABLE_VALUED_FUNCTION',
                        N'USER_TABLE',
                        N'VIEW'
                    )
        SELECT
            ROW_NUMBER() OVER (
                ORDER BY 
                    CASE
                        WHEN [objects].[type_desc] = N'USER_TABLE' THEN 0
                        ELSE 1
                    END ASC,
                    [@ObjectDependency].[Level] ASC,
                    CASE
                        WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN 3
                        WHEN [objects].[type_desc] = N'VIEW' THEN 2
                        WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN 1
                        WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN 1
                        WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN 1
                        WHEN [objects].[type_desc] = N'USER_TABLE' THEN 0
                        ELSE (-1)
                    END ASC,
                    [schemas].[name] ASC,
                    [objects].[name] ASC
            ) AS [CreateOrder],
            ROW_NUMBER() OVER (
                ORDER BY 
                    CASE
                        WHEN [Type] = 'Table' THEN 0
                        ELSE 1
                    END DESC,
                    [@ObjectDependency].[Level] DESC,
                    CASE
                        WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN 3
                        WHEN [objects].[type_desc] = N'VIEW' THEN 2
                        WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN 1
                        WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN 1
                        WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN 1
                        WHEN [objects].[type_desc] = N'USER_TABLE' THEN 0
                        ELSE (-1)
                    END DESC,
                    [schemas].[name] DESC,
                    [objects].[name] DESC
            ) AS [DropOrder],
            [objects].[object_id] AS [ObjectId],
            [schemas].[name] AS [Schema],
            [objects].[name] AS [Name],
            CASE
                WHEN [objects].[type_desc] = N'SQL_STORED_PROCEDURE' THEN N'Procedure'
                WHEN [objects].[type_desc] = N'VIEW' THEN N'View'
                WHEN [objects].[type_desc] = N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN N'Function'
                WHEN [objects].[type_desc] = N'SQL_TABLE_VALUED_FUNCTION' THEN N'Function'
                WHEN [objects].[type_desc] = N'SQL_SCALAR_FUNCTION' THEN N'Function'
                WHEN [objects].[type_desc] = N'USER_TABLE' THEN N'Table'
                ELSE CONCAT(N'OTHER: ', [objects].[type_desc])
            END AS [SimpleType],
            [objects].[type_desc] AS [Type],
            CONCAT(QUOTENAME([schemas].[name]), N'.', QUOTENAME([objects].[name])) AS [QualifiedName]
            FROM
            (
                SELECT
                    [@ObjectDependency].[ObjectId],
                    MAX([@ObjectDependency].[Level]) AS [Level]
                    FROM @ObjectDependency AS [@ObjectDependency]
                    GROUP BY [@ObjectDependency].[ObjectId]
            ) AS [@ObjectDependency]
                INNER JOIN [sys].[objects] WITH (NOLOCK)
                    ON [@ObjectDependency].[ObjectId] = [objects].[object_id]
                INNER JOIN [sys].[schemas] WITH (NOLOCK)
                    ON [objects].[schema_id] = [schemas].[schema_id]
            WHERE [schemas].[name] = @SchemaName
"@;
        $CommandText = $CommandText.Replace("`$(SchemaName)", $Schema);
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
    [Data.SqlClient.SqlDataReader] $SqlDataReader =  $SqlCommand.ExecuteReader();
    While ($SqlDataReader.Read())
    {
        [void] $ReturnValue.Add([SQLObjectInfo]::new(
            $SqlDataReader.GetInt64($SqlDataReader.GetOrdinal("CreateOrder")),
            $SqlDataReader.GetInt64($SqlDataReader.GetOrdinal("DropOrder")),
            $SqlDataReader.GetInt32($SqlDataReader.GetOrdinal("ObjectId")),
            $SqlDataReader.GetString($SqlDataReader.GetOrdinal("Schema")),
            $SqlDataReader.GetString($SqlDataReader.GetOrdinal("Name")),
            $SqlDataReader.GetString($SqlDataReader.GetOrdinal("SimpleType")),
            $SqlDataReader.GetString($SqlDataReader.GetOrdinal("Type")),
            $SqlDataReader.GetString($SqlDataReader.GetOrdinal("QualifiedName"))
        ));
    }
    [void] $SqlDataReader.Close();
    [void] $SqlDataReader.Dispose();
    [void] $SqlCommand.Dispose();
    [void] $SqlConnection.Close();
    [void] $SqlConnection.Dispose();
    Return $ReturnValue;
}

Function Get-SQLTableCreate()
{
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Instance,

        [Parameter(Mandatory=$true)]
        [String] $Database,

        [Parameter(Mandatory=$true)]
        [Int32] $ObjectId
    )
    [String] $ReturnValue = $null;
    [String] $CommandText = @"
    SELECT CONVERT([Nvarchar](MAX),
    (
        SELECT
        [filegroups].[name] AS [HeapFileGroupName],
        [filegroups_LOB].[name] AS [LobFileGroupName],
        [schemas].[name] AS [Schema],
        [tables].[name] AS [Name],
        JSON_QUERY((
            SELECT
                COLUMNPROPERTY([columns].[object_id], [columns].[name], 'ordinal') AS [Ordinal],
                IIF
                (
                    [columns].[is_identity] = 1,
                        CONCAT([tables].[name], N'Id'),
                        [columns].[name]
                ) AS [Name],
                (
                    CASE
                        WHEN [types_User].[name] IS NOT NULL
                            THEN
                            (
                                N'['
                                + [schemas_UserType].[name]
                                + N'].['
                                + [types_User].[name]
                                + N']'
                            )
                        ELSE
                        (
                            N'['
                            + [types_System].[name]
                            + N']'
                        )
                    END
                    +
                    CASE
                        WHEN
                        (
                            [types_System].[name] = N'image'
                            OR [types_System].[name] = N'text'
                            OR [types_System].[name] = N'uniqueidentifier'
                            OR [types_System].[name] = N'date'
                            OR [types_System].[name] = N'tinyint'
                            OR [types_System].[name] = N'smallint'
                            OR [types_System].[name] = N'int'
                            OR [types_System].[name] = N'smalldatetime'
                            OR [types_System].[name] = N'datetime'
                            OR [types_System].[name] = N'money'
                            OR [types_System].[name] = N'smallmoney'
                            OR [types_System].[name] = N'real'
                            OR [types_System].[name] = N'float'
                            OR [types_System].[name] = N'sql_variant'
                            OR [types_System].[name] = N'text'
                            OR [types_System].[name] = N'bit'
                            OR [types_System].[name] = N'bigint'
                            OR [types_System].[name] = N'hierarchyid'
                            OR [types_System].[name] = N'geometry'
                            OR [types_System].[name] = N'geography'
                            OR [types_System].[name] = N'timestamp'
                            OR [types_System].[name] = N'xml'
                            OR
                            (
                                [types_System].[name] = N'nvarchar'
                                AND [types_User].[name] = N'sysname'
                                AND [schemas_UserType].[name] = N'sys'
                            )
                        )
                            THEN ''
                        WHEN
                        (
                            [types_System].[name] = N'varbinary'
                            OR [types_System].[name] = N'varchar'
                            OR [types_System].[name] = N'binary'
                            OR [types_System].[name] = N'char'
                            OR [types_System].[name] = N'nvarchar'
                            OR [types_System].[name] = N'nchar'
                        )
                            THEN
                            (
                                CASE
                                    WHEN CONVERT([int], COLUMNPROPERTY([tables].[object_id], [columns].[name], 'CharMaxLen'), 0) = (-1)
                                        THEN '(MAX)'
                                    ELSE
                                    (
                                        '('
                                        + CONVERT([varchar](11), CONVERT([int], COLUMNPROPERTY([tables].[object_id], [columns].[name], 'CharMaxLen'), 0), 0)
                                        + ')'
                                    )
                                END
                            )
                        WHEN
                        (
                            [types_System].[name] = N'time'
                            OR [types_System].[name] = N'datetime2'
                            OR [types_System].[name] = N'datetimeoffset'
                        )
                            THEN
                            (
                                '('
                                + CONVERT([varchar](11), ODBCSCALE([types_System].[system_type_id], [columns].[scale]))
                                + ')'
                            )
                        WHEN
                        (
                            [types_System].[name] = N'decimal'
                            OR [types_System].[name] = N'numeric'
                        )
                            THEN
                            (
                                '('
                                + CONVERT([varchar](11), [columns].[precision], 0)
                                + ', '
                                + CONVERT([varchar](11), ODBCSCALE([types_System].[system_type_id], [columns].[scale]), 0)
                                + ')'
                            )
                    END
                ) AS [CondensedType],
                CASE
                    WHEN [types_User].[name] IS NOT NULL
                        THEN CONCAT
                        (
                            [schemas_UserType].[name],
                            + N'.'
                            + [types_User].[name]
                        )
                    ELSE [types_System].[name]
                END AS [Type],
                CASE
                    WHEN
                    (
                        [schemas_UserType].[name] = N'sys'
                        AND [types_User].[name] = N'sysname'
                    )
                        THEN NULL
                    WHEN
                    (
                        [types_System].[name] = N'varbinary'
                        OR [types_System].[name] = N'varchar'
                        OR [types_System].[name] = N'binary'
                        OR [types_System].[name] = N'char'
                        OR [types_System].[name] = N'nvarchar'
                        OR [types_System].[name] = N'nchar'
                    )
                        THEN CONVERT([int], COLUMNPROPERTY([columns].[object_id], [columns].[name], 'CharMaxLen'), 0)
                    WHEN
                    (
                        [types_System].[name] = N'time'
                        OR [types_System].[name] = N'datetime2'
                        OR [types_System].[name] = N'datetimeoffset'
                    )
                        THEN ODBCSCALE([types_System].[system_type_id], [columns].[scale])
                END AS [TypeLength],
                CASE
                    WHEN
                    (
                        [types_System].[name] = N'decimal'
                        OR [types_System].[name] = N'numeric'
                    )
                        THEN [columns].[precision]
                    ELSE NULL
                END AS [TypePrecision],
                CASE
                    WHEN
                    (
                        [types_System].[name] = N'decimal'
                        OR [types_System].[name] = N'numeric'
                    )
                        THEN ODBCSCALE([types_System].[system_type_id], [columns].[scale])
                    ELSE NULL
                END AS [TypeScale],
                [columns].[is_nullable] AS [IsNullable],
                [columns].[is_identity] AS [IsIdentity],
                [columns].[is_rowguidcol] AS [IsRowGUID],
                JSON_QUERY((
                    SELECT
                        [default_constraints].[definition] AS [Definition]
                        FROM [sys].[default_constraints] WITH (NOLOCK)
                        WHERE [default_constraints].[object_id] = [columns].[default_object_id]
                        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                )) AS [Default],
                JSON_QUERY((
                    SELECT
                        [computed_columns].[definition] AS [Definition]
                        FROM [sys].[computed_columns] WITH (NOLOCK)
                        WHERE
                            [computed_columns].[object_id] = [tables].[object_id]
                            AND [computed_columns].[column_id] = [columns].[column_id]
                        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                )) AS [Computation]
                FROM [sys].[columns] WITH (NOLOCK)
                    INNER JOIN [sys].[types] AS [types_System] WITH (NOLOCK)
                        ON
                            [columns].[system_type_id] = [types_System].[user_type_id]
                            AND [types_System].[system_type_id] = [types_System].[user_type_id]
                    LEFT OUTER JOIN [sys].[types] AS [types_User] WITH (NOLOCK)
                        ON
                            [columns].[user_type_id] = [types_User].[user_type_id]
                            AND [types_User].[system_type_id] != [types_User].[user_type_id]
                    LEFT OUTER JOIN [sys].[schemas] AS [schemas_UserType] WITH (NOLOCK)
                        ON [types_User].[schema_id] = [schemas_UserType].[schema_id]
                WHERE [columns].[object_id] = [tables].[object_id]
                ORDER BY [Ordinal] ASC
                FOR JSON PATH
        )) AS [Columns],
        JSON_QUERY((
            SELECT
                [key_constraints].[name] AS [Name],
                [filegroups].[name] AS [FileGroup],
                IIF([indexes].[type_desc] = N'CLUSTERED', CAST(1 AS [bit]), CAST(0 AS [bit])) AS [IsClustered],
                [indexes].[is_unique] AS [IsUnique],
                [indexes].[ignore_dup_key] AS [IgnoreDuplicateKey],
                [indexes].[allow_row_locks] AS [AllowRowLocks],
                [indexes].[allow_page_locks] AS [AllowPageLocks],
                [indexes].[is_padded] AS [IsPadded],
                [indexes].[fill_factor] AS [FillFactor],
                JSON_QUERY((
                    SELECT
						[index_columns].[key_ordinal] AS [Ordinal],
                        [columns].[name] AS [Name],
                        CASE
                            WHEN [index_columns].[is_descending_key] = 1
                                THEN N'Descending'
                            ELSE N'Ascending'
                        END AS [SortDirection]
                        FROM [sys].[index_columns] WITH (NOLOCK)
                            INNER JOIN [sys].[columns] WITH (NOLOCK)
                                ON
                                    [index_columns].[object_id] = [columns].[object_id]
                                    AND [index_columns].[column_id] = [columns].[column_id]
                        WHERE
                            [index_columns].[object_id] = [indexes].[object_id]
                            AND [index_columns].[index_id] = [indexes].[index_id]
                            AND [index_columns].[is_included_column] = 0
                        ORDER BY [Ordinal] ASC
                        FOR JSON PATH
                )) AS [Columns]
                FROM [sys].[key_constraints] WITH (NOLOCK)
                    INNER JOIN [sys].[indexes] WITH (NOLOCK)
                        ON
                            [key_constraints].[parent_object_id] = [indexes].[object_id]
                            AND [key_constraints].[unique_index_id] = [indexes].[index_id]
                    INNER JOIN [sys].[filegroups] WITH (NOLOCK)
                        ON [indexes].[data_space_id] = [filegroups].[data_space_id]
                WHERE [key_constraints].[parent_object_id] = [tables].[object_id]
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS [PrimaryKey],
        JSON_QUERY((
            SELECT
                [schemas_Referenced].[name] AS [Schema],
                [schemas].[name] AS [KeySchema],
                [foreign_keys].[name] AS [KeyName],
                [schemas_Foreign].[name] AS [ForeignSchema],
                [objects_Foreign].[name] AS [ForiengTable],
                [schemas_Referenced].[name] AS [ReferencedSchema],
                [objects_Referenced].[name] AS [ReferencedTable],
                JSON_QUERY((
                    SELECT
                        ROW_NUMBER() OVER (ORDER BY [foreign_key_columns].[constraint_column_id]) AS [Ordinal],
                        [columns_Referenced].[name] AS [ForeignColumn],
                        [columns_Referenced].[name] AS [ReferencedColumn]
                        FROM [sys].[foreign_key_columns] WITH (NOLOCK)
                            INNER JOIN [sys].[columns] AS [columns_Foreign] WITH (NOLOCK)
                                ON
                                    [foreign_key_columns].[parent_object_id] = [columns_Foreign].[object_id]
                                    AND [foreign_key_columns].[parent_column_id] = [columns_Foreign].[column_id]
                            INNER JOIN [sys].[columns] AS [columns_Referenced] WITH (NOLOCK)
                                ON
                                    [foreign_key_columns].[referenced_object_id] = [columns_Referenced].[object_id]
                                    AND [foreign_key_columns].[referenced_column_id] = [columns_Referenced].[column_id]
                        WHERE [foreign_key_columns].[constraint_object_id] = [foreign_keys].[object_id]
                        ORDER BY [Ordinal] ASC
                        FOR JSON PATH
                )) AS [Columns]
                FROM [sys].[foreign_keys] WITH (NOLOCK)
                    INNER JOIN [sys].[schemas] WITH (NOLOCK)
                        ON [foreign_keys].[schema_id] = [schemas].[schema_id]
                    INNER JOIN [sys].[objects] AS [objects_Foreign] WITH (NOLOCK)
                        ON [foreign_keys].[parent_object_id] = [objects_Foreign].[object_id]
                    INNER JOIN [sys].[schemas] AS [schemas_Foreign] WITH (NOLOCK)
                        ON [objects_Foreign].[schema_id] = [schemas_Foreign].[schema_id]
                    INNER JOIN [sys].[objects] AS [objects_Referenced] WITH (NOLOCK)
                        ON [foreign_keys].[referenced_object_id] = [objects_Referenced].[object_id]
                    INNER JOIN [sys].[schemas] AS [schemas_Referenced] WITH (NOLOCK)
                        ON [objects_Referenced].[schema_id] = [schemas_Referenced].[schema_id]
                WHERE [foreign_keys].[parent_object_id] = [tables].[object_id]
                FOR JSON PATH
        )) AS [ForeignKeys],
        JSON_QUERY((
            SELECT
                CONCAT
                (
                    IIF
                    (
                        [indexes].[is_unique] = 1,
                            N'UX_',
                            N'IX_'
                    ),
                    [tables].[name],
                    N'_',
                    CASE
                        WHEN [indexes].[is_unique] = 0
                            THEN [Columns].[List]
                        WHEN
                        (
                            [indexes].[is_unique] = 1
                            AND [Uniques].[Count] = 1
                        )
                            THEN N'Key'
                        WHEN
                        (
                            [indexes].[is_unique] = 1
                            AND [Uniques].[Count] > 1
                        )
                            THEN CONCAT(N'Key', [UniqueSequence].[Sequence])
                    END
                ) AS [Name],
                [indexes].[is_unique] AS [IsUnique],
                [filegroups].[name] AS [FileGroup],
                [indexes].[ignore_dup_key] AS [IgnoreDuplicateKey],
                [indexes].[allow_row_locks] AS [AllowRowLocks],
                [indexes].[allow_page_locks] AS [AllowPageLocks],
                [indexes].[is_padded] AS [IsPadded],
                [indexes].[fill_factor] AS [FillFactor],
                JSON_QUERY((
                    SELECT
                        [columns].[name] AS [Name],
                        CASE
                            WHEN [index_columns].[is_descending_key] = 1
                                THEN N'Descending'
                            ELSE N'Ascending'
                        END AS [SortDirection]
                        FROM [sys].[index_columns] WITH (NOLOCK)
                            INNER JOIN [sys].[columns] WITH (NOLOCK)
                                ON
                                    [index_columns].[object_id] = [columns].[object_id]
                                    AND [index_columns].[column_id] = [columns].[column_id]
                        WHERE
                            [index_columns].[object_id] = [indexes].[object_id]
                            AND [index_columns].[index_id] = [indexes].[index_id]
                            AND [index_columns].[is_included_column] = 0
                        ORDER BY [index_columns].[key_ordinal] ASC
                        FOR JSON PATH
                )) AS [Columns],
                JSON_QUERY((
                    SELECT
                        [columns].[name] AS [Name]
                        FROM [sys].[index_columns] WITH (NOLOCK)
                            INNER JOIN [sys].[columns] WITH (NOLOCK)
                                ON
                                    [index_columns].[object_id] = [columns].[object_id]
                                    AND [index_columns].[column_id] = [columns].[column_id]
                        WHERE
                            [index_columns].[object_id] = [indexes].[object_id]
                            AND [index_columns].[index_id] = [indexes].[index_id]
                            AND [index_columns].[is_included_column] = 1
                        ORDER BY [index_columns].[key_ordinal] ASC
                        FOR JSON PATH
                )) AS [IncludeColumns]
                FROM [sys].[indexes] WITH (NOLOCK)
                    INNER JOIN [sys].[filegroups] WITH (NOLOCK)
                        ON [indexes].[data_space_id] = [filegroups].[data_space_id]
                    LEFT OUTER JOIN
                    (
                        SELECT
                            [indexes].[object_id],
                            [indexes].[index_id],
                            (
                                SELECT
                                    CONCAT([columns].[name], N'')
                                    FROM [sys].[index_columns] WITH (NOLOCK)
                                        INNER JOIN [sys].[columns] WITH (NOLOCK)
                                            ON
                                                [index_columns].[object_id] = [columns].[object_id]
                                                AND [index_columns].[column_id] = [columns].[column_id]
                                    WHERE
                                        [index_columns].[object_id] = [indexes].[object_id]
                                        AND [index_columns].[index_id] = [indexes].[index_id]
                                        AND [index_columns].[is_included_column] = 0
                                    ORDER BY [index_columns].[key_ordinal] ASC
                                    FOR XML PATH('')
                            ) AS [List]
                            FROM [sys].[indexes]
                    ) AS [Columns]
                        ON
                            [indexes].[object_id] = [Columns].[object_id]
                            AND [indexes].[index_id] = [Columns].[index_id]
                    LEFT OUTER JOIN
                    (
                        SELECT
                            [indexes].[object_id],
                            COUNT(*) AS [Count]
                            FROM [sys].[indexes] WITH (NOLOCK)
                            WHERE
                                [indexes].[is_unique] = 1
                                AND [indexes].[is_primary_key] = 0
                            GROUP BY [indexes].[object_id]
                    ) AS [Uniques]
                        ON [indexes].[object_id] = [Uniques].[object_id]
                    LEFT OUTER JOIN
                    (
                        SELECT
                            [indexes_Uqinues].[object_id],
                            [indexes_Uqinues].[index_id],
                            ROW_NUMBER() OVER
                            (
                                PARTITION BY [indexes_Uqinues].[object_id]
                                ORDER BY
                                    [indexes_Uqinues].[object_id] ASC,
                                    [indexes_Uqinues].[index_id] ASC
                            ) AS [Sequence]
                            FROM [sys].[indexes] AS [indexes_Uqinues] WITH (NOLOCK)
                            WHERE
                                [indexes_Uqinues].[is_unique] = 1
                                AND [indexes_Uqinues].[is_primary_key] = 0
                    ) AS [UniqueSequence]
                        ON
                            [indexes].[object_id] = [UniqueSequence].[object_id]
                            AND [indexes].[index_id] = [UniqueSequence].[index_id]
                WHERE
                    [indexes].[object_id] = [tables].[object_id]
                    AND [indexes].[is_primary_key] = 0
                    AND [indexes].[type_desc] != N'HEAP'
                ORDER BY [indexes].[index_id] ASC
                FOR JSON PATH
        )) AS [Indexes]
        FROM [sys].[tables] WITH (NOLOCK)
            INNER JOIN [sys].[schemas] WITH (NOLOCK)
                ON [tables].[schema_id] = [schemas].[schema_id]
            INNER JOIN [sys].[indexes] WITH (NOLOCK)
                ON
                    [tables].[object_id] = [indexes].[object_id]
                    AND [indexes].[index_id] IN (0, 1)
            INNER JOIN [sys].[filegroups] WITH (NOLOCK)
                ON [indexes].[data_space_id] = [filegroups].[data_space_id]
            LEFT JOIN [sys].[filegroups] AS [filegroups_LOB] WITH (NOLOCK)
                ON [tables].[lob_data_space_id] = [filegroups_LOB].[data_space_id]
        WHERE [tables].[object_id] = @ObjectId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ), 0) AS [JSON]
"@;
    [String] $Json = $null;
    [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
    [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
    [void] $SqlConnection.Open();
    [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($CommandText, $SqlConnection);
    $SqlCommand.CommandType = [Data.CommandType]::Text;
    $SqlCommand.CommandTimeout = 0;

    [Data.SqlClient.SqlParameter] $SqlParameter_ObjectId = $SqlCommand.CreateParameter();
    $SqlParameter_ObjectId.ParameterName = "ObjectId";
    $SqlParameter_ObjectId.SqlDbType = [Data.SqlDbType]::Int;
    $SqlParameter_ObjectId.SqlValue = $ObjectId;
    [void] $SqlCommand.Parameters.Add($SqlParameter_ObjectId);

    [Object] $ScalerValue = $SqlCommand.ExecuteScalar();
    If ($ScalerValue -is [String])
    {
        $Json = $ScalerValue;
    }
    [void] $SqlCommand.Dispose();
    [void] $SqlConnection.Close();
    [void] $SqlConnection.Dispose();

    [Object] $TableInfo = $Json | ConvertFrom-Json -Depth 100;
    [String] $ReturnValue = [String]::Format("CREATE TABLE [{0}].[{1}]`r`n", $TableInfo.Schema, $TableInfo.Name);
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
            ($CurrentLoopIndex -lt $Columns.Count) -or
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
    $ReturnValue += [String]::Format(") ON [{0}]", $TableInfo.HeapFileGroupName);
    If (![String]::IsNullOrEmpty($TableInfo.LobFileGroup))
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

Function Get-SQLModuleCreate()
{
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Instance,

        [Parameter(Mandatory=$true)]
        [String] $Database,

        [Parameter(Mandatory=$true)]
        [Int32] $ObjectId
    )
    [String] $ReturnValue = $null;
    [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
    [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
    [void] $SqlConnection.Open();
    [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("SELECT [definition] FROM [sys].[sql_modules] WHERE [object_id] = @ObjectId", $SqlConnection);
    $SqlCommand.CommandType = [Data.CommandType]::Text;
    $SqlCommand.CommandTimeout = 0;

    [Data.SqlClient.SqlParameter] $SqlParameter_ObjectId = $SqlCommand.CreateParameter();
    $SqlParameter_ObjectId.ParameterName = "ObjectId";
    $SqlParameter_ObjectId.SqlDbType = [Data.SqlDbType]::Int;
    $SqlParameter_ObjectId.SqlValue = $ObjectId;
    [void] $SqlCommand.Parameters.Add($SqlParameter_ObjectId);

    [Object] $ScalerValue = $SqlCommand.ExecuteScalar();
    If ($ScalerValue -is [String])
    {
        $ReturnValue = $ScalerValue;
    }
    [void] $SqlCommand.Dispose();
    [void] $SqlConnection.Close();
    [void] $SqlConnection.Dispose();
    Return $ReturnValue;
}

<#
If ([IO.Directory]::Exists($OutputDirectoryPath))
{
    [void] [IO.Directory]::Delete($OutputDirectoryPath, $true);
}
[void] [IO.Directory]::CreateDirectory($OutputDirectoryPath);
[Int32] $PadLength = 3;
[SQLObjectInfo] $SQLObjectInfo = [SQLObjectInfo]::new(3, 3, 1876409954, "ActiveDirectory", "tempHeap", "Table", "USER_TABLE", "[ActiveDirectory].[tempHeap]");
[String] $OutputFilePath = [IO.Path]::Combine(
    $OutputDirectoryPath,
    [String]::Format(
        "{0}-{1}-{2}.sql",
        $SQLObjectInfo.CreateOrder.ToString().PadLeft($PadLength, "0"),
        $SQLObjectInfo.SimpleType,
        $SQLObjectInfo.QualifiedName
    )
);
[String] $Content = $null;
Switch ($SQLObjectInfo.SimpleType)
{
    "Table" { $Content = Get-SQLTableCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
    "View" { $Content = Get-SQLModuleCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
    "Procedure" { $Content = Get-SQLModuleCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
    "Function" { $Content = Get-SQLModuleCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
}
[void] [IO.File]::WriteAllText($OutputFilePath, $Content);
#>

If ([IO.Directory]::Exists($OutputDirectoryPath))
{
    [void] [IO.Directory]::Delete($OutputDirectoryPath, $true);
}
[void] [IO.Directory]::CreateDirectory($OutputDirectoryPath);

[Collections.ArrayList] $SQLObjectInfos = Get-SQLDependencies -Instance $Instance -Database $Database;
[Int32] $PadLength = ($SQLObjectInfos | Sort-Object -Property "CreateOrder" | Select-Object -Property "CreateOrder" -Last 1).CreateOrder.ToString().Length;
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
    [String] $Content = $null;
    Switch ($SQLObjectInfo.SimpleType)
    {
        "Table" { $Content = Get-SQLTableCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
        "View" { $Content = Get-SQLModuleCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
        "Procedure" { $Content = Get-SQLModuleCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
        "Function" { $Content = Get-SQLModuleCreate -Instance $Instance -Database $Database -ObjectId $SQLObjectInfo.ObjectId; }
    }
    [void] [IO.File]::WriteAllText($OutputFilePath, $Content);
}
