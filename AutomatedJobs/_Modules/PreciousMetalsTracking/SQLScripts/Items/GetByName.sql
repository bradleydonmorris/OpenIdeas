SELECT
    `Item`.`ItemGUID`,
    `MetalType`.`Name` AS `MetalType`,
    `Item`.`Name`,
    `Item`.`Purity`,
    `Item`.`Ounces`
    FROM `Item`
        INNER JOIN `MetalType`
            ON `Item`.`MetalTypeId` = `MetalType`.`MetalTypeId` COLLATE NOCASE
    WHERE `Item`.`Name` = @ItemName COLLATE NOCASE
