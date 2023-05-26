BEGIN
	SELECT MAX([LastStartTime]) AS [LastStartTime]
		FROM
		(
			SELECT CAST('1900-01-01' AS [datetime2](7)) AS [LastStartTime]
			UNION ALL SELECT MAX([StartTime]) AS [LastStartTime]
				FROM [_SCHEMANAME_].[ActivityLog]
		) AS [ActivityLog]
END
