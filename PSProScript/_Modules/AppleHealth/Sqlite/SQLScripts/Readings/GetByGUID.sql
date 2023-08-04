SELECT
    `DataProvider`.`Name` AS `DataProvider`,
    `UnitOfMeasure`.`Name` AS `UnitOfMeasure`,
    `Type`.`Name` AS `Type`,
    `Reading`.`ReadingGUID`,
    `Reading`.`Key`,
    `Reading`.`CreationDate`,
    `Reading`.`StartDate`,
    `Reading`.`EndDate`,
    `Reading`.`Value`,
    `Reading`.`EntryDate`,
    `Reading`.`EntryTime`
    FROM `Reading`
        INNER JOIN `DataProvider`
            ON `Reading`.`DataProviderId` = `DataProvider`.`DataProviderId` COLLATE NOCASE
        INNER JOIN `UnitOfMeasure`
            ON `Reading`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId` COLLATE NOCASE
        INNER JOIN `Type`
            ON `Reading`.`TypeId` = `Type`.`TypeId` COLLATE NOCASE
    WHERE `Reading`.`ReadingGUID` = @ReadingGUID COLLATE NOCASE
