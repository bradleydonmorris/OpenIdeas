SELECT
    `WorkoutStatistic`.`WorkoutStatisticGUID`,
    `WorkoutStatistic`.`Key`,
    `Workout`.`WorkoutGUID`,
    `UnitOfMeasure`.`Name` AS `UnitOfMeasure`,
    `Type`.`Name` AS `Type`,
    `Aggregate`.`Name` AS `Aggregate`,
    `WorkoutStatistic`.`StartDate`,
    `WorkoutStatistic`.`EndDate`,
    `WorkoutStatistic`.`Value`,
    `WorkoutStatistic`.`EntryDate`,
    `WorkoutStatistic`.`EntryTime`
    FROM `WorkoutStatistic`
        INNER JOIN `Workout`
            ON `WorkoutStatistic`.`WorkoutId` = `Workout`.`WorkoutId` COLLATE NOCASE
        INNER JOIN `UnitOfMeasure`
            ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId` COLLATE NOCASE
        INNER JOIN `Type`
            ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId` COLLATE NOCASE
        INNER JOIN `Aggregate`
            ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId` COLLATE NOCASE
    WHERE `WorkoutStatistic`.`WorkoutStatisticGUID` = @WorkoutStatisticGUID COLLATE NOCASE
