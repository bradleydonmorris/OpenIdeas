SELECT
	`Weight`.`EntryGUID`,
	`Weight`.`EntryDate`,
	`Weight`.`EntryTime`,
	`Weight`.`Key`,
	`Weight`.`DataProvider`,
	`Weight`.`Type`,
	`Weight`.`CreationDate`,
	`Weight`.`StartDate`,
	`Weight`.`EndDate`,
	`Weight`.`UnitOfMeasure`,
	`Weight`.`Weight`
	FROM `Weight`
	ORDER BY
		`Weight`.`EntryDate` ASC,
		`Weight`.`EntryTime` ASC