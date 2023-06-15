BEGIN
	DECLARE @ReturnValue [varchar](100)
	DECLARE @DaysText [varchar](100)
	SET @DaysText =
		CASE
			WHEN
			(
				@Monday = 1
				AND @Tuesday = 1
				AND @Wednesday = 1
				AND @Thursday = 1
				AND @Friday = 1
				AND @Saturday = 1
				AND @Sunday = 1
			)
				THEN 'Everyday'
			WHEN
			(
				@Monday = 1
				AND @Tuesday = 1
				AND @Wednesday = 1
				AND @Thursday = 1
				AND @Friday = 1
				AND @Saturday = 0
				AND @Sunday = 0
			)
				THEN 'Weekdays'
			WHEN
			(
				@Monday = 0
				AND @Tuesday = 0
				AND @Wednesday = 0
				AND @Thursday = 0
				AND @Friday = 0
				AND @Saturday = 1
				AND @Sunday = 1
			)
				THEN 'Weekends'
			WHEN
			(
				@Monday = 1
				OR @Tuesday = 1
				OR @Wednesday = 1
				OR @Thursday = 1
				OR @Friday = 1
				OR @Saturday = 1
				OR @Sunday = 1
			)
				THEN CONCAT
				(
					IIF(@Monday = 1, 'Mon, ', ''),
					IIF(@Tuesday = 1, 'Tue, ', ''),
					IIF(@Wednesday = 1, 'Wed, ', ''),
					IIF(@Thursday = 1, 'Thu, ', ''),
					IIF(@Friday = 1, 'Fri, ', ''),
					IIF(@Saturday = 1, 'Sat, ', ''),
					IIF(@Sunday = 1, 'Sun, ', '')
				)
			ELSE ''
		END
	SET @DaysText = LTRIM(RTRIM(@DaysText))
	SET @DaysText =IIF(RIGHT(@DaysText, 1) = ',', LEFT(@DaysText, (LEN(@DaysText) - 1)), @DaysText)
	DECLARE @RangeText [varchar](100)
	SET @RangeText =
		CASE
			WHEN
			(
				@RangeStartTime IS NOT NULL
				AND @RangeEndTime IS NOT NULL
			)
				THEN CONCAT
				(
					'between ',
					FORMAT
					(
						(
							(@RangeStartTime AT TIME ZONE 'UTC')
							AT TIME ZONE 'Central Standard Time'
						),
						'HH:mm'
					),
					' and ' ,
					FORMAT
					(
						(
							(@RangeEndTime AT TIME ZONE 'UTC')
							AT TIME ZONE 'Central Standard Time'
						),
						'HH:mm'
					),
					' Central Time'
				)
			ELSE NULL
		END
	SET @ReturnValue =
		CONCAT
		(
			CASE
				WHEN @Interval = 'None'
					THEN 'Does not repeat'
				WHEN @Interval = 'Daily'
					THEN CONCAT
					(
						CASE
							WHEN @Weekday = 1
								THEN 'Every weekday'
							WHEN @Weekday = 0
								THEN 'Everyday'
						END,
						IIF(@StartTime IS NOT NULL,
							CONCAT
							(
								' at ',
								FORMAT
								(
									(
										(@StartTime AT TIME ZONE 'UTC')
										AT TIME ZONE 'Central Standard Time'
									),
									'HH:mm'
								),
								' Central'
							),
							''
						)
					)
				WHEN @Interval = 'Minutely'
					THEN CONCAT
					(
						'On ',
						@DaysText,
						', every ',
						@Frequency,
						' minutes',
						IIF(@RangeText IS NOT NULL, CONCAT(', ', @RangeText), '')
					)
				WHEN @Interval = 'Hourly'
					THEN CONCAT
					(
						'On ',
						@DaysText,
						', every ',
						CASE
							WHEN @Frequency = 1
								THEN 'hour'
							ELSE CONCAT(@Frequency, ' hours')
						END,
						IIF(@RangeText IS NOT NULL, CONCAT(', ', @RangeText), '')
					)
				WHEN @Interval = 'Weekly'
					THEN CONCAT
					(
						'On ',
						@DaysText,
						IIF(@StartTime IS NOT NULL,
							CONCAT
							(
								' at ',
								FORMAT
								(
									(
										(@StartTime AT TIME ZONE 'UTC')
										AT TIME ZONE 'Central Standard Time'
									),
									'HH:mm'
								),
								' Central'
							),
							''
						)
					)
				WHEN @Interval = 'Biweekly'
					THEN CONCAT
					(
						'Every 2 weeks, on ',
						@DaysText,
						IIF(@StartTime IS NOT NULL,
							CONCAT
							(
								' at ',
								FORMAT
								(
									(
										(@StartTime AT TIME ZONE 'UTC')
										AT TIME ZONE 'Central Standard Time'
									),
									'HH:mm'
								),
								' Central'
							),
							''
						)
					)
				WHEN @Interval = 'Monthly'
					THEN CONCAT
					(
						'On the ',
						IIF(@DayOfMonth > 0,
							CASE
								WHEN @DayOfMonth IN (1, 21, 31)
									THEN CONCAT(@DayOfMonth, 'st')
								WHEN @DayOfMonth IN (2, 22)
									THEN CONCAT(@DayOfMonth, 'nd')
								WHEN @DayOfMonth IN (3, 23)
									THEN CONCAT(@DayOfMonth, 'rd')
								ELSE CONCAT(@DayOfMonth, 'th')
							END,
							LOWER(@WeekOfMonth)
						),
						' ',
						IIF(@DayOfWeek = 'Day', 'day', @DayOfWeek),
						' of the month',
						IIF(@StartTime IS NOT NULL,
							CONCAT
							(
								' at ',
								FORMAT
								(
									(
										(@StartTime AT TIME ZONE 'UTC')
										AT TIME ZONE 'Central Standard Time'
									),
									'HH:mm'
								),
								' Central'
							),
							''
						)
					)
			END,
			'.',
			IIF(@EndTime IS NOT NULL,
				CONCAT
				(
					' Runs till ',
					FORMAT
					(
						(
							(@EndTime AT TIME ZONE 'UTC')
							AT TIME ZONE 'Central Standard Time'
						),
						'yyyy-MM-dd HH:mm'
					),
					' Central'
				),
				' Runs indefinately'
			)
		)
	RETURN @ReturnValue
END
