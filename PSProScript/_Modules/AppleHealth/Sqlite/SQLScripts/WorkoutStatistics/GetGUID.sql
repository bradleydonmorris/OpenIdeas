SELECT `WorkoutStatistic`.`WorkoutStatisticGUID`
    FROM `WorkoutStatistic`
    WHERE `WorkoutStatistic`.`Key` = @Key COLLATE NOCASE
