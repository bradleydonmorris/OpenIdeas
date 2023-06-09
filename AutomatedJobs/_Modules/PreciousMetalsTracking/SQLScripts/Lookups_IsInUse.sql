SELECT `LookupUse`.`Count`
	FROM
	(
		SELECT
			'MetalType' AS `Lookup`,
			`MetalType`.`Name`,
			COUNT(*) AS `Count`
			FROM `Item`
				INNER JOIN `MetalType`
					ON `Item`.`MetalTypeId` = `MetalType`.`MetalTypeId`
			GROUP BY `MetalType`.`Name`
	) AS `LookupUse`
	WHERE
		`LookupUse`.`Lookup` = @Lookup
		`LookupUse`.`Name` = @Name
