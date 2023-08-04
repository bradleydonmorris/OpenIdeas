[void] $Global:Session.LoadModule("SQLServer");

Add-Member `
    -InputObject $Global:Session.DatesAndTimes `
    -Name "DateTimeOffsetStringToDateTimeUTC" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([DateTime])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Text
        )
        [DateTime] $ReturnValue = [DateTime]::MinValue;
        [DateTimeOffset] $Result = [DateTimeOffset]::MinValue;
        If ([DateTimeOffset]::TryParse($Text, [ref]$Result))
        {
            $ReturnValue = $Result.ToUniversalTime().DateTime;
        }
        Return $ReturnValue
    };
Add-Member `
    -InputObject $Global:Session.DatesAndTimes `
    -Name "DateTimeOffsetStringToDateTimeUTCString" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Text
        )
        [String] $ReturnValue = [String]::Empty;
        [DateTime] $Result = $Global:Session.DatesAndTimes.DateTimeOffsetStringToDateTimeUTC($Text);
        If ($Result -ne [DateTimeOffset]::MinValue)
        {
            $ReturnValue = $Result.ToString("yyyy-MM-dd HH:mm:ss.fffffff");
        }
        Return $ReturnValue
    };
Add-Member `
    -InputObject $Global:Session.DatesAndTimes `
    -Name "SplitIntFromDateTime" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSCustomObject])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [DateTime] $DateTime
        )
        [PSCustomObject] $ReturnValue = [PSCustomObject]@{
            "Date" = [Int64]0;
            "Time" = [Int64]0;
        };
        [Int64] $ParsedDate = 0;
        [Int64] $ParsedTime = 0;
        If (
            [Int64]::TryParse($DateTime.ToString("yyyyMMdd"), [ref]$ParsedDate) -and
            [Int64]::TryParse($DateTime.ToString("HHmmss"), [ref]$ParsedTime)
        )
        {
            $ReturnValue.Date = $ParsedDate;
            $ReturnValue.Time = $ParsedTime;
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.DatesAndTimes `
    -Name "DateTimeUTCFromSplitInt" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([DateTime])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [Int64] $Date,

            [Parameter(Mandatory=$true)]
            [Int64] $Time
        )
        [DateTime] $ReturnValue = [DateTime]::MinValue;
        [DateTime] $ParsedDateTime = [DateTime]::MinValue;
        [String] $DateTimeString = [String]::Format(
                "{0}{1}",
                $Date.ToString(),
                $Time.ToString("000000")
        );
        $DateTimeString = $DateTimeString.Insert(4, "-").Insert(7, "-").Insert(10, " ").Insert(13, ":").Insert(16, ":");
        If ([DateTime]::TryParse($DateTimeString, [ref]$ParsedDateTime))
        {
            $ReturnValue = $ParsedDateTime;
        }
        $ReturnValue = [DateTime]::SpecifyKind($ReturnValue, [DateTimeKind]::Utc);
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.DatesAndTimes `
    -Name "ParseFileNameTime" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([DateTime])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $FilePath,
    
            [Parameter(Mandatory=$false)]
            [String] $DateTimeFormatString,
    
            [Parameter(Mandatory=$false)]
            [Int32] $DateTimeStartPosition
        )
        [DateTime] $ReturnValue = [DateTime]::MinValue;
        [String] $FileName = [IO.Path]::GetFileName($FilePath);
        If ($FileName.Length -ge ($DateTimeStartPosition + $DateTimeFormatString.Length))
        {
            [String] $FileDateStamp = $FileName.Substring($DateTimeStartPosition, $DateTimeFormatString.Length);
            [DateTime] $ResultDateTime = [DateTime]::MinValue;
            If ([DateTime]::TryParseExact(
                $FileDateStamp, $DateTimeFormatString,
                [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None,
                [ref]$ResultDateTime))
            {
                $ReturnValue = $ResultDateTime;
            }
        }
        Else
        {
            $ReturnValue = [DateTime]::MinValue;
        }
        Return $ReturnValue
    };
