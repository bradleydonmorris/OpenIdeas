BEGIN TRANSACTION;
DELETE FROM `WorkoutStatistic`
    WHERE `WorkoutStatistic`.`WorkoutStatisticGUID` = @WorkoutStatisticGUID COLLATE NOCASE
;
END TRANSACTION;
