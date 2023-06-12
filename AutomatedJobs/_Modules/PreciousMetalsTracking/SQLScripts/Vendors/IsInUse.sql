SELECT IFNULL(SUM(`VendorUse`.`Count`), 0) AS `Count`
	FROM `Vendor`
		INNER JOIN
		(
			SELECT `ItemVendor`.`VendorId`, COUNT(*) AS `Count`
				FROM `ItemVendor`
			UNION ALL SELECT `Transaction`.`VendorId`, COUNT(*) AS `Count`
				FROM `Transaction`
		) AS `VendorUse`
			ON `Vendor`.`VendorId` = `VendorUse`.`VendorId` 
	WHERE
		`Vendor`.`Name` = @Name COLLATE NOCASE
