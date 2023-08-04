CREATE TABLE IF NOT EXISTS `Aggregate` (
    `AggregateId` INTEGER NOT NULL,
    `Name` TEXT NOT NULL,
    CONSTRAINT `PK_Aggregate` PRIMARY KEY (`AggregateId`)
);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Aggregate_AggregateId` ON `Aggregate`(`AggregateId` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Aggregate_Name` ON `Aggregate`(`Name` ASC);
INSERT INTO `Aggregate`(`Name`)
	VALUES
		('Average'),
		('Summation'),
		('Minimum'),
		('Maximum')
;

CREATE TABLE IF NOT EXISTS `UnitOfMeasure` (
    `UnitOfMeasureId` INTEGER NOT NULL,
    `Name` TEXT NOT NULL,
    CONSTRAINT `PK_UnitOfMeasure` PRIMARY KEY (`UnitOfMeasureId`)
);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_UnitOfMeasure_UnitOfMeasureId` ON `UnitOfMeasure`(`UnitOfMeasureId` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_UnitOfMeasure_Name` ON `UnitOfMeasure`(`Name` ASC);

CREATE TABLE IF NOT EXISTS `DataProvider` (
    `DataProviderId` INTEGER NOT NULL,
    `Name` TEXT NOT NULL,
    CONSTRAINT `PK_DataProvider` PRIMARY KEY (`DataProviderId`)
);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_DataProvider_DataProviderId` ON `DataProvider`(`DataProviderId` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_DataProvider_Name` ON `DataProvider`(`Name` ASC);

CREATE TABLE IF NOT EXISTS `Type` (
    `TypeId` INTEGER NOT NULL,
    `Name` TEXT NOT NULL,
    CONSTRAINT `PK_Type` PRIMARY KEY (`TypeId`)
);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Type_TypeId` ON `Type`(`TypeId` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Type_Name` ON `Type`(`Name` ASC);

CREATE TABLE IF NOT EXISTS `Reading` (
    `ReadingId` INTEGER NOT NULL,
    `DataProviderId` INTEGER NOT NULL,
    `UnitOfMeasureId` INTEGER NOT NULL,
    `TypeId` INTEGER NOT NULL,
    `ReadingGUID` TEXT NOT NULL,
    `Key` TEXT NOT NULL,
    `CreationDate` TEXT NOT NULL,
    `StartDate` TEXT NOT NULL,
    `EndDate` TEXT NOT NULL,
    `Value` NUMERIC NULL,
	`EntryDate` INTEGER NOT NULL,
	`EntryTime` INTEGER NOT NULL,
    CONSTRAINT `PK_Reading` PRIMARY KEY (`ReadingId`),
    CONSTRAINT `FK_Reading_DataProvider` FOREIGN KEY(`DataProviderId`) REFERENCES `DataProvider`(`DataProviderId`),
    CONSTRAINT `FK_Reading_UnitOfMeasure` FOREIGN KEY(`UnitOfMeasureId`) REFERENCES `UnitOfMeasure`(`UnitOfMeasureId`),
    CONSTRAINT `FK_Reading_Type` FOREIGN KEY(`TypeId`) REFERENCES `Type`(`TypeId`)
);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Reading_ReadingId` ON `Reading`(`ReadingId` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Reading_ReadingGUID` ON `Reading`(`ReadingGUID` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Reading_Key` ON `Reading`(`Key` ASC);
CREATE INDEX IF NOT EXISTS `IX_Reading_DataProviderId` ON `Reading`(`DataProviderId` ASC);
CREATE INDEX IF NOT EXISTS `IX_Reading_UnitOfMeasureId` ON `Reading`(`UnitOfMeasureId` ASC);
CREATE INDEX IF NOT EXISTS `IX_Reading_TypeId` ON `Reading`(`TypeId` ASC);
CREATE INDEX IF NOT EXISTS `IX_Reading_EntryDateEntryTime` ON `Reading`(`EntryDate` ASC, `EntryTime` ASC);

CREATE TABLE IF NOT EXISTS `Correlation` (
    `CorrelationId` INTEGER NOT NULL,
    `DataProviderId` INTEGER NOT NULL,
    `TypeId` INTEGER NOT NULL,
    `CorrelationGUID` TEXT NOT NULL,
    `Key` TEXT NOT NULL,
    `CreationDate` TEXT NOT NULL,
    `StartDate` TEXT NOT NULL,
    `EndDate` TEXT NOT NULL,
	`EntryDate` INTEGER NOT NULL,
	`EntryTime` INTEGER NOT NULL,
    CONSTRAINT `PK_Correlation` PRIMARY KEY (`CorrelationId`),
    CONSTRAINT `FK_Correlation_DataProvider` FOREIGN KEY(`DataProviderId`) REFERENCES `DataProvider`(`DataProviderId`),
    CONSTRAINT `FK_Correlation_Type` FOREIGN KEY(`TypeId`) REFERENCES `Type`(`TypeId`)
);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Correlation_CorrelationId` ON `Correlation`(`CorrelationId` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Correlation_CorrelationGUID` ON `Correlation`(`CorrelationGUID` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Correlation_Key` ON `Correlation`(`Key` ASC);
CREATE INDEX IF NOT EXISTS `IX_Correlation_DataProviderId` ON `Correlation`(`DataProviderId` ASC);
CREATE INDEX IF NOT EXISTS `IX_Correlation_TypeId` ON `Correlation`(`TypeId` ASC);
CREATE INDEX IF NOT EXISTS `IX_Correlation_EntryDateEntryTime` ON `Correlation`(`EntryDate` ASC, `EntryTime` ASC);

CREATE TABLE IF NOT EXISTS `CorrelationReading` (
    `CorrelationReadingId` INTEGER NOT NULL,
    `CorrelationId` INTEGER NOT NULL,
    `ReadingId` INTEGER NOT NULL,
    CONSTRAINT `PK_CorrelationReading` PRIMARY KEY (`CorrelationReadingId`),
    CONSTRAINT `FK_CorrelationReading_Correlation` FOREIGN KEY(`CorrelationId`) REFERENCES `Correlation`(`CorrelationId`),
    CONSTRAINT `FK_CorrelationReading_Reading` FOREIGN KEY(`ReadingId`) REFERENCES `Reading`(`ReadingId`)
);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_CorrelationReading_CorrelationReadingId` ON `CorrelationReading`(`CorrelationReadingId` ASC);
CREATE INDEX IF NOT EXISTS `IX_CorrelationReading_CorrelationId` ON `CorrelationReading`(`CorrelationId` ASC);
CREATE INDEX IF NOT EXISTS `IX_CorrelationReading_ReadingId` ON `CorrelationReading`(`ReadingId` ASC);

CREATE TABLE IF NOT EXISTS `Workout` (
    `WorkoutId` INTEGER NOT NULL,
    `DataProviderId` INTEGER NOT NULL,
    `UnitOfMeasureId` INTEGER NOT NULL,
    `TypeId` INTEGER NOT NULL,
    `WorkoutGUID` TEXT NOT NULL,
    `Key` TEXT NOT NULL,
    `CreationDate` TEXT NOT NULL,
    `StartDate` TEXT NOT NULL,
    `EndDate` TEXT NOT NULL,
    `Duration` NUMERIC NULL,
	`EntryDate` INTEGER NOT NULL,
	`EntryTime` INTEGER NOT NULL,
    CONSTRAINT `PK_Workout` PRIMARY KEY (`WorkoutId`),
    CONSTRAINT `FK_Workout_DataProvider` FOREIGN KEY(`DataProviderId`) REFERENCES `DataProvider`(`DataProviderId`),
    CONSTRAINT `FK_Workout_UnitOfMeasure` FOREIGN KEY(`UnitOfMeasureId`) REFERENCES `UnitOfMeasure`(`UnitOfMeasureId`),
    CONSTRAINT `FK_Workout_Type` FOREIGN KEY(`TypeId`) REFERENCES `Type`(`TypeId`)
);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Workout_WorkoutId` ON `Workout`(`WorkoutId` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Workout_WorkoutGUID` ON `Workout`(`WorkoutGUID` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_Workout_Key` ON `Workout`(`Key` ASC);
CREATE INDEX IF NOT EXISTS `IX_Workout_DataProviderId` ON `Workout`(`DataProviderId` ASC);
CREATE INDEX IF NOT EXISTS `IX_Workout_UnitOfMeasureId` ON `Workout`(`UnitOfMeasureId` ASC);
CREATE INDEX IF NOT EXISTS `IX_Workout_TypeId` ON `Workout`(`TypeId` ASC);
CREATE INDEX IF NOT EXISTS `IX_Workout_EntryDateEntryTime` ON `Workout`(`EntryDate` ASC, `EntryTime` ASC);

CREATE TABLE IF NOT EXISTS `WorkoutStatistic` (
    `WorkoutStatisticId` INTEGER NOT NULL,
    `WorkoutId` INTEGER NOT NULL,
    `UnitOfMeasureId` INTEGER NOT NULL,
    `TypeId` INTEGER NOT NULL,
    `AggregateId` INTEGER NOT NULL,
    `WorkoutStatisticGUID` TEXT NOT NULL,
    `Key` TEXT NOT NULL,
    `StartDate` TEXT NOT NULL,
    `EndDate` TEXT NOT NULL,
    `Value` NUMERIC NULL,
	`EntryDate` INTEGER NOT NULL,
	`EntryTime` INTEGER NOT NULL,
    CONSTRAINT `PK_WorkoutStatistic` PRIMARY KEY (`WorkoutStatisticId`),
    CONSTRAINT `FK_WorkoutStatistic_Workout` FOREIGN KEY(`WorkoutId`) REFERENCES `Workout`(`WorkoutId`),
    CONSTRAINT `FK_WorkoutStatistic_UnitOfMeasure` FOREIGN KEY(`UnitOfMeasureId`) REFERENCES `UnitOfMeasure`(`UnitOfMeasureId`),
    CONSTRAINT `FK_WorkoutStatistic_Type` FOREIGN KEY(`TypeId`) REFERENCES `Type`(`TypeId`),
    CONSTRAINT `FK_WorkoutStatistic_Aggregate` FOREIGN KEY(`AggregateId`) REFERENCES `Aggregate`(`AggregateId`)
);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_WorkoutStatistic_WorkoutStatisticId` ON `WorkoutStatistic`(`WorkoutStatisticId` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_WorkoutStatistic_WorkoutStatisticGUID` ON `WorkoutStatistic`(`WorkoutStatisticGUID` ASC);
CREATE UNIQUE INDEX IF NOT EXISTS `UX_WorkoutStatistic_Key` ON `WorkoutStatistic`(`Key` ASC);
CREATE INDEX IF NOT EXISTS `IX_WorkoutStatistic_WorkoutId` ON `WorkoutStatistic`(`WorkoutId` ASC);
CREATE INDEX IF NOT EXISTS `IX_WorkoutStatistic_UnitOfMeasureId` ON `WorkoutStatistic`(`UnitOfMeasureId` ASC);
CREATE INDEX IF NOT EXISTS `IX_WorkoutStatistic_TypeId` ON `WorkoutStatistic`(`TypeId` ASC);
CREATE INDEX IF NOT EXISTS `IX_WorkoutStatistic_AggregateId` ON `WorkoutStatistic`(`AggregateId` ASC);
CREATE INDEX IF NOT EXISTS `IX_WorkoutStatistic_EntryDateEntryTime` ON `WorkoutStatistic`(`EntryDate` ASC, `EntryTime` ASC);










DROP VIEW IF EXISTS `BloodPressure`;
CREATE VIEW `BloodPressure`
AS
	SELECT
		`Correlation`.`CorrelationGUID` AS `EntryGUID`,
		`Correlation`.`EntryDate`,
		`Correlation`.`EntryTime`,
		`Correlation`.`Key`,
		`DataProvider_Correlation`.`Name` AS `DataProvider`,
		`Type_Correlation`.`Name` AS `Type`,
		`Correlation`.`CreationDate`,
		`Correlation`.`StartDate`,
		`Correlation`.`EndDate`,
		`Systolic`.`UnitOfMeasure`,
		`Systolic`.`Value` AS `Systolic`,
		`Diastolic`.`Value` AS `Diastolic`
		FROM
		(
			SELECT
				`Correlation`.`CorrelationId`
				FROM
				(
					SELECT
						`Correlation`.`TypeId`,
						`Correlation`.`EntryDate`,
						MIN(`Correlation`.`EntryTime`) AS `EntryTime`
						FROM `Correlation`
						GROUP BY
							`Correlation`.`TypeId`,
							`Correlation`.`EntryDate`
				) AS `Correlation_FirstOfDay`
					INNER JOIN `Correlation`
						ON
							`Correlation_FirstOfDay`.`TypeId` = `Correlation`.`TypeId`
							AND `Correlation_FirstOfDay`.`EntryDate` = `Correlation`.`EntryDate`
							AND `Correlation_FirstOfDay`.`EntryTime` = `Correlation`.`EntryTime`
		) AS `Correlation_FirstOfDay`
			INNER JOIN `Correlation`
				ON `Correlation_FirstOfDay`.`CorrelationId` = `Correlation`.`CorrelationId`
			INNER JOIN `DataProvider` AS `DataProvider_Correlation`
				ON `Correlation`.`DataProviderId` = `DataProvider_Correlation`.`DataProviderId` COLLATE NOCASE
			INNER JOIN `Type` AS `Type_Correlation`
				ON `Correlation`.`TypeId` = `Type_Correlation`.`TypeId`
			INNER JOIN
			(
				SELECT
					`CorrelationReading`.`CorrelationId`,
					`UnitOfMeasure`.`Name` AS `UnitOfMeasure`,
					`Reading`.`Value`
					FROM `CorrelationReading`
						INNER JOIN `Reading`
							ON `CorrelationReading`.`ReadingId` = `Reading`.`ReadingId`
						INNER JOIN `UnitOfMeasure`
							ON `Reading`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `Reading`.`TypeId` = `Type`.`TypeId`
					WHERE `Type`.`Name` = 'HKQuantityTypeIdentifierBloodPressureSystolic'
			) AS `Systolic`
				ON `Correlation`.`CorrelationId` = `Systolic`.`CorrelationId`
			INNER JOIN
			(
				SELECT
					`CorrelationReading`.`CorrelationId`,
					`Reading`.`Value`
					FROM `CorrelationReading`
						INNER JOIN `Reading`
							ON `CorrelationReading`.`ReadingId` = `Reading`.`ReadingId`
						INNER JOIN `Type`
							ON `Reading`.`TypeId` = `Type`.`TypeId`
					WHERE `Type`.`Name` = 'HKQuantityTypeIdentifierBloodPressureDiastolic'
			) AS `Diastolic`
				ON `Correlation`.`CorrelationId` = `Diastolic`.`CorrelationId`
		WHERE `Type_Correlation`.`Name` = 'HKCorrelationTypeIdentifierBloodPressure'
;
DROP VIEW IF EXISTS `Weight`;
CREATE VIEW `Weight`
AS
	SELECT
		`Reading`.`ReadingGUID` AS `EntryGUID`,
		`Reading`.`EntryDate`,
		`Reading`.`EntryTime`,
		`Reading`.`Key`,
		`DataProvider`.`Name` AS `DataProvider`,
		`Type`.`Name` AS `Type`,
		`Reading`.`CreationDate`,
		`Reading`.`StartDate`,
		`Reading`.`EndDate`,
		`UnitOfMeasure`.`Name` AS `UnitOfMeasure`,
		`Reading`.`Value` AS `Weight`
		FROM
		(
			SELECT
				`Reading`.`ReadingId`
				FROM
				(
					SELECT
						`Reading`.`TypeId`,
						`Reading`.`EntryDate`,
						MIN(`Reading`.`EntryTime`) AS `EntryTime`
						FROM `Reading`
						GROUP BY
							`Reading`.`TypeId`,
							`Reading`.`EntryDate`
				) AS `Reading_FirstOfDay`
					INNER JOIN `Reading`
						ON
							`Reading_FirstOfDay`.`TypeId` = `Reading`.`TypeId`
							AND `Reading_FirstOfDay`.`EntryDate` = `Reading`.`EntryDate`
							AND `Reading_FirstOfDay`.`EntryTime` = `Reading`.`EntryTime`
		) AS `Reading_FirstOfDay`
			INNER JOIN `Reading`
				ON `Reading_FirstOfDay`.`ReadingId` = `Reading`.`ReadingId`
			INNER JOIN `DataProvider`
				ON `Reading`.`DataProviderId` = `DataProvider`.`DataProviderId` COLLATE NOCASE
			INNER JOIN `UnitOfMeasure`
				ON `Reading`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
			INNER JOIN `Type`
				ON `Reading`.`TypeId` = `Type`.`TypeId`
		WHERE `Type`.`Name` = 'HKQuantityTypeIdentifierBodyMass'
;

DROP VIEW IF EXISTS `WorkoutWalk`;
CREATE VIEW `WorkoutWalk`
AS
	SELECT
		`Workout`.`WorkoutGUID` AS `EntryGUID`,
		`Workout`.`EntryDate`,
		`Workout`.`EntryTime`,
		`Workout`.`Key`,
		`DataProvider`.`Name` AS `DataProvider`,
		`Type`.`Name` AS `Type`,
		`Workout`.`CreationDate`,
		`Workout`.`StartDate`,
		`Workout`.`EndDate`,
		`Distance`.`DistanceUnitOfMeasure`,
		`Distance`.`Distance`,
		`BasalEnergyBurned`.`BasalEnergyBurnedUnitOfMeasure`,
		`BasalEnergyBurned`.`BasalEnergyBurned`,
		`ActiveEnergyBurned`.`ActiveEnergyBurnedUnitOfMeasure`,
		`ActiveEnergyBurned`.`ActiveEnergyBurned`,
		`HeartRateMaximum`.`HeartRateMaximumUnitOfMeasure`,
		`HeartRateMaximum`.`HeartRateMaximum`,
		`HeartRateMinimum`.`HeartRateMinimumUnitOfMeasure`,
		`HeartRateMinimum`.`HeartRateMinimum`	
		FROM `Workout`
			INNER JOIN `DataProvider`
				ON `Workout`.`DataProviderId` = `DataProvider`.`DataProviderId` COLLATE NOCASE
			INNER JOIN `Type`
				ON `Workout`.`TypeId` = `Type`.`TypeId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `DistanceUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `Distance`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierDistanceWalkingRunning'
						AND `Aggregate`.`Name` = 'Summation'
			) AS `Distance`
				ON `Workout`.`WorkoutId` = `Distance`.`WorkoutId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `BasalEnergyBurnedUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `BasalEnergyBurned`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierBasalEnergyBurned'
						AND `Aggregate`.`Name` = 'Summation'
			) AS `BasalEnergyBurned`
				ON `Workout`.`WorkoutId` = `BasalEnergyBurned`.`WorkoutId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `ActiveEnergyBurnedUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `ActiveEnergyBurned`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierActiveEnergyBurned'
						AND `Aggregate`.`Name` = 'Summation'
			) AS `ActiveEnergyBurned`
				ON `Workout`.`WorkoutId` = `ActiveEnergyBurned`.`WorkoutId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `HeartRateAverageUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `HeartRateAverage`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierHeartRate'
						AND `Aggregate`.`Name` = 'Average'
			) AS `HeartRateAverage`
				ON `Workout`.`WorkoutId` = `HeartRateAverage`.`WorkoutId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `HeartRateMaximumUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `HeartRateMaximum`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierHeartRate'
						AND `Aggregate`.`Name` = 'Maximum'
			) AS `HeartRateMaximum`
				ON `Workout`.`WorkoutId` = `HeartRateMaximum`.`WorkoutId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `HeartRateMinimumUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `HeartRateMinimum`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierHeartRate'
						AND `Aggregate`.`Name` = 'Minimum'
			) AS `HeartRateMinimum`
				ON `Workout`.`WorkoutId` = `HeartRateMinimum`.`WorkoutId`
		WHERE `Type`.`Name` = 'HKWorkoutActivityTypeWalking'
;
DROP VIEW IF EXISTS `WorkoutHIIT`;
CREATE VIEW `WorkoutHIIT`
AS
	SELECT
		`Workout`.`WorkoutGUID` AS `EntryGUID`,
		`Workout`.`EntryDate`,
		`Workout`.`EntryTime`,
		`Workout`.`Key`,
		`DataProvider`.`Name` AS `DataProvider`,
		`Type`.`Name` AS `Type`,
		`Workout`.`CreationDate`,
		`Workout`.`StartDate`,
		`Workout`.`EndDate`,
		`Workout`.`Duration`,
		`Distance`.`DistanceUnitOfMeasure`,
		`Distance`.`Distance`,
		`BasalEnergyBurned`.`BasalEnergyBurnedUnitOfMeasure`,
		`BasalEnergyBurned`.`BasalEnergyBurned`,
		`ActiveEnergyBurned`.`ActiveEnergyBurnedUnitOfMeasure`,
		`ActiveEnergyBurned`.`ActiveEnergyBurned`,
		`HeartRateMaximum`.`HeartRateMaximumUnitOfMeasure`,
		`HeartRateMaximum`.`HeartRateMaximum`,
		`HeartRateMinimum`.`HeartRateMinimumUnitOfMeasure`,
		`HeartRateMinimum`.`HeartRateMinimum`	
		FROM `Workout`
			INNER JOIN `DataProvider`
				ON `Workout`.`DataProviderId` = `DataProvider`.`DataProviderId` COLLATE NOCASE
			INNER JOIN `Type`
				ON `Workout`.`TypeId` = `Type`.`TypeId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `DistanceUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `Distance`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierDistanceWalkingRunning'
						AND `Aggregate`.`Name` = 'Summation'
			) AS `Distance`
				ON `Workout`.`WorkoutId` = `Distance`.`WorkoutId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `BasalEnergyBurnedUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `BasalEnergyBurned`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierBasalEnergyBurned'
						AND `Aggregate`.`Name` = 'Summation'
			) AS `BasalEnergyBurned`
				ON `Workout`.`WorkoutId` = `BasalEnergyBurned`.`WorkoutId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `ActiveEnergyBurnedUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `ActiveEnergyBurned`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierActiveEnergyBurned'
						AND `Aggregate`.`Name` = 'Summation'
			) AS `ActiveEnergyBurned`
				ON `Workout`.`WorkoutId` = `ActiveEnergyBurned`.`WorkoutId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `HeartRateAverageUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `HeartRateAverage`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierHeartRate'
						AND `Aggregate`.`Name` = 'Average'
			) AS `HeartRateAverage`
				ON `Workout`.`WorkoutId` = `HeartRateAverage`.`WorkoutId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `HeartRateMaximumUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `HeartRateMaximum`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierHeartRate'
						AND `Aggregate`.`Name` = 'Maximum'
			) AS `HeartRateMaximum`
				ON `Workout`.`WorkoutId` = `HeartRateMaximum`.`WorkoutId`
			LEFT OUTER JOIN
			(
				SELECT
					`WorkoutStatistic`.`WorkoutId`,
					`UnitOfMeasure`.`Name` AS `HeartRateMinimumUnitOfMeasure`,
					`WorkoutStatistic`.`Value` AS `HeartRateMinimum`
					FROM `WorkoutStatistic`
						INNER JOIN `UnitOfMeasure`
							ON `WorkoutStatistic`.`UnitOfMeasureId` = `UnitOfMeasure`.`UnitOfMeasureId`
						INNER JOIN `Type`
							ON `WorkoutStatistic`.`TypeId` = `Type`.`TypeId`
						INNER JOIN `Aggregate`
							ON `WorkoutStatistic`.`AggregateId` = `Aggregate`.`AggregateId`
					WHERE
						`Type`.`Name` = 'HKQuantityTypeIdentifierHeartRate'
						AND `Aggregate`.`Name` = 'Minimum'
			) AS `HeartRateMinimum`
				ON `Workout`.`WorkoutId` = `HeartRateMinimum`.`WorkoutId`
		WHERE `Type`.`Name` = 'HKWorkoutActivityTypeHighIntensityIntervalTraining'
;
