Function Get-DateDouble()
{
    Param
    (
        [DateTime] $DateTime
    )
    [Double] $ReturnDouble = 0;
    if (![Double]::TryParse($DateTime.ToString("yyyyMMdd"), [ref] $ReturnDouble))
    {
        throw [ArgumentException]::new("Unable to pasre date to Double/Double.");
    }
    return $ReturnDouble;
}

Function Get-TimeDouble()
{
    Param
    (
        [DateTime] $DateTime
    )
    [Double] $ReturnDouble = 0;
	[TimeSpan] $TimeSpan = ($DateTime - ([DateTime]::new($DateTime.Year, $DateTime.Month, $DateTime.Day, 0, 0, 0, 0, $DateTime.Kind)));
    if (![Double]::TryParse(("0." + $TimeSpan.TotalMilliseconds.ToString("0000000")), [ref] $ReturnDouble))
    {
        throw [ArgumentException]::new("Unable to pasre date to Double/Double.");
    }
    return $ReturnDouble;
}

Function Get-DateTimeDouble()
{
    Param
    (
        [DateTime] $DateTime
    )
    [Double] $ReturnDouble = 0;
    [Double] $DateDouble = 0;
    if (![Double]::TryParse($DateTime.ToString("yyyyMMdd"), [ref] $DateDouble))
    {
        throw [ArgumentException]::new("Unable to pasre date to Double/Double.");
    }
	[TimeSpan] $TimeSpan = ($DateTime - ([DateTime]::new($DateTime.Year, $DateTime.Month, $DateTime.Day, 0, 0, 0, 0, $DateTime.Kind)));
    if (![Double]::TryParse(($DateDouble.ToString("00000000") + "." + $TimeSpan.TotalMilliseconds.ToString("0000000")), [ref] $ReturnDouble))
    {
        throw [ArgumentException]::new("Unable to pasre date to Double/Double.");
    }
    return $ReturnDouble;
}

Function Get-ElapsedTime()
{
	Param
	(
        [System.DateTime] $BeginTime,
        [System.DateTime] $EndTime
	)
    [System.Object] $ReturnValue = ConvertFrom-Json -InputObject "{ BeginTime:null, EndTime:null, BeginTicks:null, EndTicks:null, Ticks:null,  DecimalSeconds:null, Formatted:null }";
    [System.TimeSpan] $TimeSpan = [System.TimeSpan]::new($EndTime.Ticks - $BeginTime.Ticks);
    $ReturnValue.DecimalSeconds = $TimeSpan.TotalSeconds;
    $ReturnValue.BeginTime = $BeginTime;
    $ReturnValue.EndTime = $EndTime;
    $ReturnValue.BeginTicks = $BeginTime.Ticks;
    $ReturnValue.EndTicks = $EndTime.Ticks;
    $ReturnValue.Ticks = $TimeSpan.Ticks;
    [System.Double] $DecimalSecondsRemaining = $ReturnValue.DecimalSeconds;
    [System.Int32] $Days = [Int32][System.Math]::Floor($DecimalSecondsRemaining / 86400);
    $DecimalSecondsRemaining -= ($Days * 86400);
    [System.Int32] $Hours = [Int32][System.Math]::Floor($DecimalSecondsRemaining / 3600);
    $DecimalSecondsRemaining -= ($Hours * 3600);
    [System.Int32] $Minutes = [Int32][System.Math]::Floor($DecimalSecondsRemaining / 60);
    $DecimalSecondsRemaining -= ($Minutes * 60);
    [System.String] $ReturnValue.Formatted = "{@Hours}:{@Minutes}:{@Seconds}";
    If ($Days -gt 0)
    {
	    $ReturnValue.Formatted = "{@Days}d " + $ReturnValue.Formatted;
	    $ReturnValue.Formatted = $ReturnValue.Formatted.Replace("{@Days}", $Days.ToString());
    }
    $ReturnValue.Formatted = $ReturnValue.Formatted.Replace("{@Hours}", $Hours.ToString().PadLeft(2, '0'));
    $ReturnValue.Formatted = $ReturnValue.Formatted.Replace("{@Minutes}", $Minutes.ToString().PadLeft(2, '0'));
    $ReturnValue.Formatted = $ReturnValue.Formatted.Replace("{@Seconds}", $DecimalSecondsRemaining.ToString("0.0000000").PadLeft(10, '0'));
    Return $ReturnValue;
}


Function Get-ISOWeek()
{
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [DateTime] $Date
    )
    [System.Collections.Generic.Dictionary[[String], [Object]]] $ReturnValue = [System.Collections.Generic.Dictionary[[String], [Object]]]::new()
    [System.Globalization.Calendar] $Calendar = [System.Globalization.CultureInfo]::InvariantCulture.Calendar
    [Int32] $DaysToMonday = 0;
    [Int32] $DaysToThursday = 0;
    Switch ($Date.DayOfWeek)
    {
        "Monday" { $DaysToMonday = 0; $DaysToThursday = 3; }
        "Tuesday" { $DaysToMonday = (-1); $DaysToThursday = 2; }
        "Wednesday" { $DaysToMonday = (-2); $DaysToThursday = 1; }
        "Thursday" { $DaysToMonday = (-3); $DaysToThursday = 0; }
        "Friday" { $DaysToMonday = (-4); $DaysToThursday = (-1); }
        "Saturday" { $DaysToMonday = (-5); $DaysToThursday = (-2); }
        "Sunday" { $DaysToMonday = (-6); $DaysToThursday = (-3); }
    }
    [DateTime] $Monday = $Date.AddDays($DaysToMonday);
    [DateTime] $Thursday = $Date.AddDays($DaysToThursday);
    [Int32] $WeekNumber = $Calendar.GetWeekOfYear($Thursday, [System.Globalization.CalendarWeekRule]::FirstFourDayWeek, [DayOfWeek]::Monday);
    [Int32] $Year = $Date.Year;
    If ($Date.Month -eq 1 -and $WeekNumber -gt 50)
    {
        $Year -= 1;
    }
    $ReturnValue["Date"] = $Date;
    $ReturnValue["WeekBegin"] = $Monday;
    $ReturnValue["Thursday"] = $Thursday;
    $ReturnValue["Number"] = $WeekNumber;
    $ReturnValue["Year"] = $Year;
    $ReturnValue["Name"] = [String]::Format("{0}-W{1}", $Year, $WeekNumber.ToString().PadLeft(2, "0"))
    Return $ReturnValue;
}

Function Get-DateDimension()
{
    Param
    (
        
        [Parameter(Mandatory=$true)]
        [DateTime] $Date
    )
	[System.Collections.Generic.Dictionary[[String], [Object]]] $ReturnValue = [System.Collections.Generic.Dictionary[[String], [Object]]]::new()

	#Date
	$ReturnValue["Date"] = $Date;
	$ReturnValue["DateKey"] = [Int32]$Date.ToString("yyyyMMdd");
	$ReturnValue["DateNumber"] = [Int32]$Date.ToString("yyyyMMdd");
	$ReturnValue["DateName"] = $Date.ToString("yyyy-MM-dd");

	#Year
	[DateTime] $Year = [DateTime]::new($Date.Year, 1, 1).Date;
	$ReturnValue["Year"] = $Year
	$ReturnValue["YearKey"] = [Int32]$Year.ToString("yyyyMMdd");
	$ReturnValue["YearNumber"] = $Year.Year;
	$ReturnValue["YearName"] = [String]::Format("CY{0}", $Year.Year)

	#Semester
	[DateTime] $Semester = [DateTime]::MinValue;
	[Int32] $SemesterNumber = 0;
	Switch ($Date.Month)
	{
		{$_ -in 1..6}
		{
			$Semester = [DateTime]::new($Date.Year, 1, 1).Date;
			$SemesterNumber = 1;
		}
		{$_ -in 7..12}
		{
			$Semester = [DateTime]::new($Date.Year, 7, 1).Date;
			$SemesterNumber = 2;
		}
	}
	$ReturnValue["Semester"] = $Semester
	$ReturnValue["SemesterKey"] = [Int32]$Semester.ToString("yyyyMMdd");
	$ReturnValue["SemesterNumber"] = $SemesterNumber;
	$ReturnValue["SemesterName"] = [String]::Format("CY{0}-S{1}", $Semester.Year, $SemesterNumber)

	#Trimester
	[DateTime] $Trimester = [DateTime]::MinValue;
	[Int32] $TrimesterNumber = 0;
	Switch ($Date.Month)
	{
		{$_ -in 1..4}
		{
			$Trimester = [DateTime]::new($Date.Year, 1, 1).Date;
			$TrimesterNumber = 1;
		}
		{$_ -in 5..8}
		{
			$Trimester = [DateTime]::new($Date.Year, 5, 1).Date;
			$TrimesterNumber = 2;
		}
		{$_ -in 9..12}
		{
			$Trimester = [DateTime]::new($Date.Year, 9, 1).Date;
			$TrimesterNumber = 3;
		}
	}
	$ReturnValue["Trimester"] = $Trimester
	$ReturnValue["TrimesterKey"] = [Int32]$Trimester.ToString("yyyyMMdd");
	$ReturnValue["TrimesterNumber"] = $TrimesterNumber;
	$ReturnValue["TrimesterName"] = [String]::Format("CY{0}-T{1}", $Trimester.Year, $TrimesterNumber)

	#Quarter
	[DateTime] $Quarter = [DateTime]::MinValue;
	[Int32] $QuarterNumber = 0;
	Switch ($Date.Month)
	{
		{$_ -in 1..3}
		{
			$Quarter = [DateTime]::new($Date.Year, 1, 1).Date;
			$QuarterNumber = 1;
		}
		{$_ -in 4..6}
		{
			$Quarter = [DateTime]::new($Date.Year, 4, 1).Date;
			$QuarterNumber = 2;
		}
		{$_ -in 7..9}
		{
			$Quarter = [DateTime]::new($Date.Year, 7, 1).Date;
			$QuarterNumber = 3;
		}
		{$_ -in 10..12}
		{
			$Quarter = [DateTime]::new($Date.Year, 10, 1).Date;
			$QuarterNumber = 4;
		}
	}
	$ReturnValue["Quarter"] = $Quarter
	$ReturnValue["QuarterKey"] = [Int32]$Quarter.ToString("yyyyMMdd");
	$ReturnValue["QuarterNumber"] = $QuarterNumber;
	$ReturnValue["QuarterName"] = [String]::Format("CY{0}-Q{1}", $Quarter.Year, $QuarterNumber)

	#Month
	[DateTime] $Month = [DateTime]::new($Date.Year, $Date.Month, 1).Date;
	[Int32] $MonthNumber = $Month.Month;
	$ReturnValue["Month"] = $Month
	$ReturnValue["MonthKey"] = [Int32]$Month.ToString("yyyyMMdd");
	$ReturnValue["MonthNumber"] = $MonthNumber;
	$ReturnValue["MonthName"] = $Month.ToString("yyyy-MM (MMMM)");

	#ISO Week
	$ISOWeek = Get-ISOWeek -Date $Date;
	$ReturnValue["ISOWeek"] = $ISOWeek["WeekBegin"];
	$ReturnValue["ISOWeekKey"] = [Int32]$ISOWeek["WeekBegin"].ToString("yyyyMMdd");
	$ReturnValue["ISOWeekNumber"] = $ISOWeek["Number"];
	$ReturnValue["ISOWeekName"] = $ISOWeek["Name"];

	#Ancillary
	$ReturnValue["DayOfWeekNumber"] = [Int32]$Date.DayOfWeek;
	$ReturnValue["DayOfMonthNumber"] = $Date.Day;
	$ReturnValue["DayOfYearNumber"] = $Date.DayOfYear;
	$ReturnValue["DayOfWeekName"] = $Date.ToString("dddd");
	$ReturnValue["DayOfMonthName"] = $ReturnValue["DayOfMonthNumber"].ToString("00");
	$ReturnValue["DayOfYearName"] = $ReturnValue["DayOfYearNumber"].ToString("000");

	$ReturnValue
}

Function Get-TimeDimension()
{
    Param
    (
        
        [Parameter(Mandatory=$true)]
        [DateTime] $Time
    )
	[System.Collections.Generic.Dictionary[[String], [Object]]] $ReturnValue = [System.Collections.Generic.Dictionary[[String], [Object]]]::new()

	#Time
	$Time = [DateTime]::new(1, 1, 1, $Time.Hour, $Time.Minute, $Time.Second, 0);
	$ReturnValue["Time"] = $Time;
	$ReturnValue["TimeKey"] = [Int32]$Time.ToString("HHmmss");
	$ReturnValue["TimeNumber"] = [Int32]$Time.ToString("HHmmss");
	$ReturnValue["TimeName"] = $Time.ToString("HH:mm:ss");

	#Hour
	[DateTime] $Hour = [DateTime]::new(1, 1, 1, $Time.Hour, 0, 0)
	$ReturnValue["Hour"] = $Hour;
	$ReturnValue["HourKey"] = [Int32]$Hour.ToString("HHmmss");
	$ReturnValue["HourNumber"] = $Hour.Hour;
	$ReturnValue["HourName"] = $Hour.ToString("HH:mm:ss");

	#Half Hour
	[DateTime] $HalfHour = [DateTime]::MinValue;
	[Int32] $HalfHourNumber = 0;
	Switch ($Time.Minute)
	{
		{$_ -in 0..29}
		{
			$HalfHour = [DateTime]::new(1900, 1, 1, $Time.Hour, 0, 0);
			$HalfHourNumber = 1;
		}
		{$_ -in 30..59}
		{
			$HalfHour = [DateTime]::new(1900, 1, 1, $Time.Hour, 30, 0);
			$HalfHourNumber = 2;
		}
	}
	$ReturnValue["HalfHour"] = $HalfHour.ToString("HH:mm:ss");
	$ReturnValue["HalfHourKey"] = [Int32]$HalfHour.ToString("HHmmss");
	$ReturnValue["HalfHourNumber"] = $HalfHourNumber;
	$ReturnValue["HalfHourName"] = $HalfHour.ToString("HH:mm:ss");

	#Quarter Hour
	[DateTime] $QuarterHour = [DateTime]::MinValue;
	[Int32] $QuarterHourNumber = 0;
	Switch ($Time.Minute)
	{
		{$_ -in 0..14}
		{
			$QuarterHour = [DateTime]::new(1900, 1, 1, $Time.Hour, 0, 0);
			$QuarterHourNumber = 1;
		}
		{$_ -in 15..29}
		{
			$QuarterHour = [DateTime]::new(1900, 1, 1, $Time.Hour, 15, 0);
			$QuarterHourNumber = 2;
		}
		{$_ -in 30..44}
		{
			$QuarterHour = [DateTime]::new(1900, 1, 1, $Time.Hour, 30, 0);
			$QuarterHourNumber= 3;
		}
		{$_ -in 45..59}
		{
			$QuarterHour = [DateTime]::new(1900, 1, 1, $Time.Hour, 45, 0);
			$QuarterHourNumber = 4;
		}
	}
	$ReturnValue["QuarterHour"] = $QuarterHour.ToString("HH:mm:ss");
	$ReturnValue["QuarterHourKey"] = [Int32]$QuarterHour.ToString("HHmmss");
	$ReturnValue["QuarterHourNumber"] = $QuarterHourNumber;
	$ReturnValue["QuarterHourName"] = $QuarterHour.ToString("HH:mm:ss");

	#Minute
	[DateTime] $Minute = [DateTime]::new(1900, 1, 1, $Time.Hour, $Time.Minute, 0);
	$ReturnValue["Minute"] = $Minute.ToString("HH:mm:ss");
	$ReturnValue["MinuteKey"] = [Int32]$Minute.ToString("HHmmss");
	$ReturnValue["MinuteNumber"] = $Minute.Minute;
	$ReturnValue["MinuteName"] = $Minute.ToString("HH:mm:ss");

	#Time Of Day
	[DateTime] $TimeOfDay = [DateTime]::MinValue;
	[Int32] $TimeOfDayNumber = 0;
	[String] $TimeOfDayName = [String]::Empty;
	Switch ($Time.Hour)
	{
		{$_ -in 0..4}
		{
			$TimeOfDay = [DateTime]::new(1900, 1, 1, 0, 0, 0);
			$TimeOfDayNumber = 1;
			$TimeOfDayName = "Night";
		}
		{$_ -in 5..11}
		{
			$TimeOfDay = [DateTime]::new(1900, 1, 1, 5, 0, 0);
			$TimeOfDayNumber = 2;
			$TimeOfDayName = "Morning";
		}
		{$_ -in 12..17}
		{
			$TimeOfDay = [DateTime]::new(1900, 1, 1, 12, 0, 0);
			$TimeOfDayNumber = 3;
			$TimeOfDayName = "Afternoon";
		}
		{$_ -in 18..23}
		{
			$TimeOfDay = [DateTime]::new(1900, 1, 1, 18, 0, 0);
			$TimeOfDayNumber = 4;
			$TimeOfDayName = "Evening";
		}
	}
	$ReturnValue["TimeOfDay"] = $TimeOfDay.ToString("HH:mm:ss");
	$ReturnValue["TimeOfDayKey"] = [Int32]$TimeOfDay.ToString("HHmmss");
	$ReturnValue["TimeOfDayNumber"] = $TimeOfDayNumber;
	$ReturnValue["TimeOfDayName"] = $TimeOfDayName;

	#Sub Time Of Day
	[DateTime] $SubTimeOfDay = [DateTime]::MinValue;
	[Int32] $SubTimeOfDayNumber = 0;
	[String] $SubTimeOfDayName = [String]::Empty;
	Switch ($Time.Hour)
	{
		{$_ -in 0..4}
		{
			$SubTimeOfDay = [DateTime]::new(1900, 1, 1, 0, 0, 0);
			$SubTimeOfDayNumber = 1;
			$SubTimeOfDayName = "Night";
		}
		{$_ -in 5..9}
		{
			$SubTimeOfDay = [DateTime]::new(1900, 1, 1, 5, 0, 0);
			$SubTimeOfDayNumber = 2;
			$SubTimeOfDayName = "Early Morning";
		}
		{$_ -in 10..11}
		{
			$SubTimeOfDay = [DateTime]::new(1900, 1, 1, 10, 0, 0);
			$SubTimeOfDayNumber = 3;
			$SubTimeOfDayName = "Late Morning";
		}
		{$_ -in 12..14}
		{
			$SubTimeOfDay = [DateTime]::new(1900, 1, 1, 12, 0, 0);
			$SubTimeOfDayNumber = 4;
			$SubTimeOfDayName = "Early Afternoon";
		}
		{$_ -in 15..17}
		{
			$SubTimeOfDay = [DateTime]::new(1900, 1, 1, 15, 0, 0);
			$SubTimeOfDayNumber = 5;
			$SubTimeOfDayName = "Late Afternoon";
		}
		{$_ -in 18..20}
		{
			$SubTimeOfDay = [DateTime]::new(1900, 1, 1, 18, 0, 0);
			$SubTimeOfDayNumber = 6;
			$SubTimeOfDayName = "Early Evening";
		}
		{$_ -in 20..23}
		{
			$SubTimeOfDay = [DateTime]::new(1900, 1, 1, 20, 0, 0);
			$SubTimeOfDayNumber = 7;
			$SubTimeOfDayName = "Late Evening";
		}
	}
	$ReturnValue["SubTimeOfDay"] = $SubTimeOfDay.ToString("HH:mm:ss");
	$ReturnValue["SubTimeOfDayKey"] = [Int32]$SubTimeOfDay.ToString("HHmmss");
	$ReturnValue["SubTimeOfDayNumber"] = $SubTimeOfDayNumber;
	$ReturnValue["SubTimeOfDayName"] = $SubTimeOfDayName;

	$ReturnValue
}

