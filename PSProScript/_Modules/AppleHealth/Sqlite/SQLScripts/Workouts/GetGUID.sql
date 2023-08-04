SELECT `Workout`.`WorkoutGUID`
    FROM `Workout`
    WHERE `Workout`.`Key` = @Key COLLATE NOCASE
