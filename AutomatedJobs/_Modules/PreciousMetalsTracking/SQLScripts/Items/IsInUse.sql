SELECT IFNULL(SUM(`ItemUse`.`Count`), 0) AS `Count`
	FROM `Item`
		INNER JOIN
		(
			SELECT `ItemTransaction`.`ItemId`, COUNT(*) AS `Count`
				FROM `ItemTransaction`
			UNION ALL SELECT `ItemVendor`.`ItemId`, COUNT(*) AS `Count`
				FROM `ItemVendor`
		) AS `ItemUse`
			ON `Item`.`ItemId` = `ItemUse`.`ItemId` 
	WHERE
		`Item`.`Name` = @Name COLLATE NOCASE
