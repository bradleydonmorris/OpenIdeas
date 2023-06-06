INSERT INTO `MetalType`(`Name`)
    SELECT
        `Source`.`Name`
        FROM
        (
            SELECT
                @Name AS `Name`
        ) AS `Source`
            LEFT OUTER JOIN `MetalType` AS `Target`
                ON `Source`.`Name` = `Target`.`Name`
        WHERE `Target`.`MetalTypeId` IS NULL