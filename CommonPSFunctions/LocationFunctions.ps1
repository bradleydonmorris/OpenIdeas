Function Get-SexagesimalAngle()
{
    Param
    (
        [Decimal] $DecimalDegrees
    )
    [Object] $ReturnValue = ConvertFrom-Json -InputObject @"
        {
			IsNegative: false,
            Degrees: 0,
            Minutes: 0,
            Seconds: 0,
            Milliseconds: 0,
            DD: 0.0,
            DMS: ""
        }
"@;
	$ReturnValue.DD = $DecimalDegrees;
	If ($DecimalDegrees -lt 0)
	{
		$ReturnValue.IsNegative = $true;
	}
	Else
	{
		$ReturnValue.IsNegative = $false;
	}
	while ($DecimalDegrees -lt -180.0)
	{
		$DecimalDegrees += 360.0;
	}
	while ($DecimalDegrees -gt 180.0)
	{
		$DecimalDegrees -= 360.0;
	}

	$DecimalDegrees = [Math]::Abs($DecimalDegrees);

	$ReturnValue.Degrees = [Int32][Math]::Floor($DecimalDegrees);
	$delta = $DecimalDegrees - $ReturnValue.Degrees;

	$seconds = [Int32][Math]::Floor(3600.0 * $delta);
	$ReturnValue.Seconds = $seconds % 60;
	$ReturnValue.Minutes = [Int32][Math]::Floor($seconds / 60.0);
	$delta = $delta * 3600.0 - $seconds;

	$ReturnValue.Milliseconds = [Int32](1000.0 * $delta);

	$ReturnValue.DMS = [String]::Format("{0}° {1:00}' {2:00}.{3:000}`"",
		$ReturnValue.Degrees,
		$ReturnValue.Minutes,
		$ReturnValue.Seconds,
		$ReturnValue.Milliseconds);

	Return $ReturnValue;
}

Function Get-LatLongConversions()
{
    Param
    (
        [Decimal] $LatitudeDecimalDegrees,
		[Decimal] $LongitudeDecimalDegrees
    )
    [Object] $ReturnValue = ConvertFrom-Json -InputObject @"
        {
			Latitude: {
				IsNegative: false,
				Degrees: 0,
				Minutes: 0,
				Seconds: 0,
				Milliseconds: 0,
				DD: 0.0,
				DMS: "",
				CardinalDirection: null
			},
            Longitude: {
				IsNegative: false,
				Degrees: 0,
				Minutes: 0,
				Seconds: 0,
				Milliseconds: 0,
				DD: 0.0,
				DMS: "",
				CardinalDirection: null
			}
        }
"@;
	$Lat = Get-SexagesimalAngle -DecimalDegrees $LatitudeDecimalDegrees;
	$ReturnValue.Latitude.IsNegative = $Lat.IsNegative;
	$ReturnValue.Latitude.Degrees = $Lat.Degrees;
	$ReturnValue.Latitude.Minutes = $Lat.Minutes;
	$ReturnValue.Latitude.Seconds = $Lat.Seconds;
	$ReturnValue.Latitude.Milliseconds = $Lat.Milliseconds;
	$ReturnValue.Latitude.DD = $Lat.DD;
	If ($Lat.IsNegative)
	{
		$ReturnValue.Latitude.CardinalDirection = "S";
	}
	Else
	{
		$ReturnValue.Latitude.CardinalDirection = "N";
	}
	$ReturnValue.Latitude.DMS = [String]::Format("{0}° {1:00}' {2:00}.{3:000}`" {4}",
		$ReturnValue.Latitude.Degrees,
		$ReturnValue.Latitude.Minutes,
		$ReturnValue.Latitude.Seconds,
		$ReturnValue.Latitude.Milliseconds,
		$ReturnValue.Latitude.CardinalDirection);

	$Long = Get-SexagesimalAngle -DecimalDegrees $LongitudeDecimalDegrees;
	$ReturnValue.Longitude.IsNegative = $Long.IsNegative;
	$ReturnValue.Longitude.Degrees = $Long.Degrees;
	$ReturnValue.Longitude.Minutes = $Long.Minutes;
	$ReturnValue.Longitude.Seconds = $Long.Seconds;
	$ReturnValue.Longitude.Milliseconds = $Long.Milliseconds;
	$ReturnValue.Longitude.DD = $Long.DD;
	If ($Long.IsNegative)
	{
		$ReturnValue.Longitude.CardinalDirection = "W";
	}
	Else
	{
		$ReturnValue.Longitude.CardinalDirection = "E";
	}
	$ReturnValue.Longitude.DMS = [String]::Format("{0}° {1:00}' {2:00}.{3:000}`" {4}",
		$ReturnValue.Longitude.Degrees,
		$ReturnValue.Longitude.Minutes,
		$ReturnValue.Longitude.Seconds,
		$ReturnValue.Longitude.Milliseconds,
		$ReturnValue.Longitude.CardinalDirection);

	Return $ReturnValue;
}

Function Get-DegreesToRadians()
{
	[OutputType([Decimal])]
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [Decimal] $Degress
    )
    Return [Math]::PI * $Degress / 180;
}

Function Get-RadiansToDegrees()
{
	[OutputType([Decimal])]
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [Decimal] $Radians
    )
    Return 180 * $Radians / [Math]::PI;
}

Function Get-DistanceMeters()
{
	[OutputType([Decimal])]
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [Decimal] $Latitude1,

        [Parameter()]
        [Decimal] $Longitude1,

        [Parameter()]
        [Decimal] $Latitude2,

        [Parameter()]
        [Decimal] $Longitude2
    )
    [Int32] $EarthRadiusKM = 6371;
    [Decimal] $LatitudeRadians = Get-DegreesToRadians -Degress ($Latitude2 - $Latitude1);
    [Decimal] $LongitudeRadians = Get-DegreesToRadians -Degress ($Longitude2 - $Longitude1);

    [Decimal] $Latitude1Radians = Get-DegreesToRadians -Degress $Latitude1;
    [Decimal] $Latitude2Radians = Get-DegreesToRadians -Degress $Latitude2;
    
    [Decimal] $a = [Math]::Sin($LatitudeRadians/2) * [Math]::Sin($LatitudeRadians/2) +
        [Math]::Sin($LongitudeRadians/2) * [Math]::Sin($LongitudeRadians/2) * [Math]::Cos($Latitude1Radians) * [Math]::Cos($Latitude2Radians); 
    [Decimal] $c = 2 * [Math]::Atan2([Math]::Sqrt($a), [Math]::Sqrt(1-$a)); 
    Return ($EarthRadiusKM * 1000) * $c;
}

Function Get-Bearing()
{
	[OutputType([Decimal])]
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [Decimal] $Latitude1,

        [Parameter()]
        [Decimal] $Longitude1,

        [Parameter()]
        [Decimal] $Latitude2,

        [Parameter()]
        [Decimal] $Longitude2
    )
    [Decimal] $Latitude1Radians = Get-DegreesToRadians -Degress $Latitude1;
    [Decimal] $Longitude1Radians = Get-DegreesToRadians -Degress $Longitude1;
    [Decimal] $Latitude2Radians = Get-DegreesToRadians -Degress $Latitude2;
    [Decimal] $Longitude2Radians = Get-DegreesToRadians -Degress $Longitude2;
	[Decimal] $X = (
		[Math]::Cos($Latitude2Radians) *
		[Math]::Sin($Latitude1Radians) -
		[Math]::Sin($Latitude2Radians) *
		[Math]::Cos($Latitude1Radians) *
		[Math]::Cos($Longitude1Radians - $Longitude2Radians)
	);
    [Decimal] $Y = [Math]::Sin($Longitude1Radians - $Longitude2Radians) * [Math]::Cos($Latitude1Radians);
	Return (Get-RadiansToDegrees -Radians (([Math]::Atan2($y, $x) + [Math]::PI * 2) % ([Math]::PI * 2)));
}

Function Get-ReverseAzimuth()
{
	[OutputType([Decimal])]
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [Decimal] $Degress
    )
    Return ( $Degress -lt 180 ? ($Degress + 180) : ($Degress - 180) );
}

Function Format-USNG()
{
	[OutputType([String])]
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline=$true)]
        [String] $Value,

		[Parameter(ValueFromPipeline=$true)]
        [switch] $AsHTML
	)
	[String] $ReturnValue = $null;
    [String[]] $USNGElements = $Value -split " ";
	If ($AsHTML.IsPresent)
	{
		$ReturnValue = [String]::Format(
			"{0}&nbsp;{1}&nbsp;{2}<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{3}",
			$USNGElements[0],
			$USNGElements[1],
			$USNGElements[2],
			$USNGElements[3]
		);
	}
	Else
	{
		$ReturnValue = [String]::Format(
			"{0} {1} {2}`n       {3}",
			$USNGElements[0],
			$USNGElements[1],
			$USNGElements[2],
			$USNGElements[3]
		);
	}
	Return $ReturnValue;
}