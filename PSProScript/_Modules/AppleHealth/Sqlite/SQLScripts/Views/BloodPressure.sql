SELECT
	`BloodPressure`.`EntryGUID`,
	`BloodPressure`.`EntryDate`,
	`BloodPressure`.`EntryTime`,
	`BloodPressure`.`Key`,
	`BloodPressure`.`DataProvider`,
	`BloodPressure`.`Type`,
	`BloodPressure`.`CreationDate`,
	`BloodPressure`.`StartDate`,
	`BloodPressure`.`EndDate`,
	`BloodPressure`."UnitOfMeasure",
	`BloodPressure`.`Systolic`,
	`BloodPressure`.`Diastolic`
	FROM `BloodPressure`
	ORDER BY
		`BloodPressure`.`EntryDate` ASC,
		`BloodPressure`.`EntryTime` ASC