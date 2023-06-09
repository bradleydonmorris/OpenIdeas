INSERT INTO `$(Lookup)`(`Name`)
    SELECT
        `Source`.`Name`
        FROM
        (
            SELECT @Name AS `Name`
        ) AS `Source`
            LEFT OUTER JOIN `$(Lookup)` AS `Target`
                ON `Source`.`Name` = `Target`.`Name`
        WHERE `Target`.`$(Lookup)Id` IS NULL