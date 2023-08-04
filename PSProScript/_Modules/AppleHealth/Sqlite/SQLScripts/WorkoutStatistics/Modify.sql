BEGIN TRANSACTION;
UPDATE `WorkoutStatistic`
    SET
    	`WorkoutId` = `Workout`.`WorkoutId`,
        `UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`,
        `TypeId` = `Type`.`TypeId`,
        `AggregateId` = `Aggregate`.`AggregateId`,
        `WorkoutStatisticGUID` = `Source`.`WorkoutStatisticGUID`,
        `Key` = `Source`.`Key`,
        `StartDate` = `Source`.`StartDate`,
        `EndDate` = `Source`.`EndDate`,
        `Value` = `Source`.`Value`,
        `EntryDate` = `Source`.`EntryDate`,
        `EntryTime` = `Source`.`EntryTime`
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
	WHERE `WorkoutStatistic`.`WorkoutStatisticGUID` = `Source`.`WorkoutStatisticGUID`
;
END TRANSACTION;
