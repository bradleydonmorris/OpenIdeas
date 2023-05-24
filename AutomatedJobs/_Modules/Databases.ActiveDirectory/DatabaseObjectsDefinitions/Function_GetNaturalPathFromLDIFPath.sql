BEGIN
	--This function is required because the version of SQL in use does not support STRING_SPLIT with ordinal output
	--And have to use the hack method of STRING_AGG due to being on older version of SQL Server.
	DECLARE @ReturnValue [nvarchar](400)
	DECLARE @LDIFComponent TABLE
	(
		[Id] [int] IDENTITY(1, 1) NOT NULL,
		[LDAPValue] [nvarchar](400) NOT NULL,
		[ComponentType] [nvarchar](400) NOT NULL,
		[ComponentName] [nvarchar](400) NOT NULL
	)
	INSERT INTO @LDIFComponent([LDAPValue], [ComponentType], [ComponentName])
		SELECT
			[value] AS [LDAPValue],
			CASE LEFT([value], (CHARINDEX(N'=', [value]) - 1))
				WHEN N'DC' THEN N'Domain Component'
				WHEN N'DN' THEN N'Distinguished Name'
				WHEN N'OU' THEN N'Organizational Unit'
				WHEN N'CN' THEN N'Common Name'
			END AS [ComponentType],
			RIGHT([value], (LEN([value]) - CHARINDEX(N'=', [value]))) AS [ComponentName]
			FROM STRING_SPLIT(@LDIFPath, ',')
	SELECT @ReturnValue =
		CONCAT
		(
			LEFT([Domain].[Domain], (LEN([Domain].[Domain]) - 1)),
			N'\',
			LEFT([Path].[Path], (LEN([Path].[Path]) - 1))
		)
		FROM
		(
			SELECT
			(
				SELECT CONCAT([ComponentName], N'.')
					FROM @LDIFComponent
					WHERE [ComponentType] = N'Domain Component'
					ORDER BY [Id] ASC
					FOR XML PATH('')
			) AS [Domain]
		) AS [Domain]
			CROSS JOIN
			(
				SELECT
				(
					SELECT CONCAT([ComponentName], N'\')
						FROM @LDIFComponent
						WHERE [ComponentType] != N'Domain Component'
						ORDER BY [Id] DESC
						FOR XML PATH('')
				) AS [Path]
			) AS [Path]
	RETURN @ReturnValue
END
