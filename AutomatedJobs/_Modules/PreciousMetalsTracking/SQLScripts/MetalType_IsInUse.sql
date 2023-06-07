SELECT COUNT(*) AS `Count`
	FROM `Item`
		INNER JOIN `MetalType`
			ON `Item`.`MetalTypeId` = `MetalType`.`MetalTypeId`
	WHERE `MetalType`.`Name` = @Name
