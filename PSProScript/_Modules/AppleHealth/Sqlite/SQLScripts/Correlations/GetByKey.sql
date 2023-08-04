SELECT
    `Correlation`.`CorrelationGUID`,
    `Correlation`.`Key`,
    `DataProvider`.`Name` AS `DataProvider`,
    `Type`.`Name` AS `Type`,
    `Correlation`.`CreationDate`,
    `Correlation`.`StartDate`,
    `Correlation`.`EndDate`,
    `Correlation`.`EntryDate`,
    `Correlation`.`EntryTime`
    FROM `Correlation`
        INNER JOIN `DataProvider`
            ON `Correlation`.`DataProviderId` = `DataProvider`.`DataProviderId` COLLATE NOCASE
        INNER JOIN `Type`
            ON `Correlation`.`TypeId` = `Type`.`TypeId` COLLATE NOCASE
    WHERE `Correlation`.`Key` = @Key COLLATE NOCASE
