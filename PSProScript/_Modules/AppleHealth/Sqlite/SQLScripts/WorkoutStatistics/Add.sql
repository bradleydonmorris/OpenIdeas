BEGIN TRANSACTION;
INSERT INTO `WorkoutStatistic`(`WorkoutId`, `UnitOfMeasureId`, `TypeId`, `AggregateId`, `WorkoutStatisticGUID`, `Key`, `StartDate`, `EndDate`, `Value`, `EntryDate`, `EntryTime`)
    SELECT
    	`Workout`.`WorkoutId`,
        `UnitOfMeasure`.`UnitOfMeasureId`,
        `Type`.`TypeId`,
        `Aggregate`.`AggregateId`,
        `Source`.`WorkoutStatisticGUID`,
        `Source`.`Key`,
        `Source`.`StartDate`,
        `Source`.`EndDate`,
        `Source`.`Value`,
        `Source`.`EntryDate`,
        `Source`.`EntryTime`
        FROM
        (
            SELECT
                @WorkoutStatisticGUID AS `WorkoutStatisticGUID`,
                @WorkoutGUID AS `WorkoutGUID`,
                @UnitOfMeasure AS `UnitOfMeasure`,
                @Type AS `Type`,
                @Aggregate AS `Aggregate`,
                @Key AS `Key`,
                @StartDate AS `StartDate`,
                @EndDate AS `EndDate`,
                @Value AS `Value`,
                @EntryDate AS `EntryDate`,
                @EntryTime AS `EntryTime`
        ) AS `Source`
        	INNER JOIN `Workout`
        		ON `Source`.`WorkoutGUID` = `Workout`.`WorkoutGUID` COLLATE NOCASE
        	INNER JOIN `UnitOfMeasure`
        		ON `Source`.`UnitOfMeasure` = `UnitOfMeasure`.`Name` COLLATE NOCASE
        	INNER JOIN `Type`
        		ON `Source`.`Type` = `Type`.`Name` COLLATE NOCASE
        	INNER JOIN `Aggregate`
        		ON `Source`.`Aggregate` = `Aggregate`.`Name` COLLATE NOCASE
            LEFT OUTER JOIN `WorkoutStatistic` AS `Target`
                ON `Source`.`Key` = `Target`.`Key` COLLATE NOCASE
        WHERE `Target`.`WorkoutStatisticId` IS NULL
;
END TRANSACTION;