INSERT INTO `Item`(`MetalTypeId`, `ItemGUID`, `Name`, `Purity`, `Ounces`)
    SELECT
    	`MetalType`.`MetalTypeId`,
        `Source`.`ItemGUID`,
        `Source`.`Name`,
        `Source`.`Purity`,
        `Source`.`Ounces`
        FROM
        (
            SELECT
                @ItemGUID AS `ItemGUID`,
                @MetalType AS `MetalType`,
                @Name AS `Name`,
                @Purity AS `Purity`,
                @Ounces AS `Ounces`
        ) AS `Source`
        	INNER JOIN `MetalType`
        		ON `Source`.`MetalType` = `MetalType`.`Name` COLLATE NOCASE
            LEFT OUTER JOIN `Item` AS `Target`
                ON `Source`.`Name` = `Target`.`Name` COLLATE NOCASE
        WHERE `Target`.`ItemId` IS NULL
