UPDATE `Item`
    SET
        `MetalTypeId` = `MetalType`.`MetalTypeId`,
        `Name` = `Source`.`Name`,
        `Purity` = `Source`.`Purity`,
        `Ounces` = `Source`.`Ounces`
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
	WHERE `Item`.`ItemGUID` = `Source`.`ItemGUID`  
