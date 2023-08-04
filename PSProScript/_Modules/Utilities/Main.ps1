Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Utilities" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.Utilities `
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
Add-Member `
    -InputObject $Global:Session.Utilities `
    -Name "SubstringBetween" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Text,
    
            [Parameter(Mandatory=$false)]
            [String] $BeginToken,
    
            [Parameter(Mandatory=$false)]
            [String] $EndToken
        )
        [String] $ReturnValue = $null;
        If (
            $Text.Contains($BeginToken) -and
            $Text.Contains($EndToken)
        )
        {
            [Int32] $TokenBeginPosition = $Text.IndexOf($BeginToken);
            [Int32] $TokenEndPosition = $Text.IndexOf($EndToken, $TokenBeginPosition);
            $TokenBeginPosition += 1;
            $ReturnValue = $Text.Substring($TokenBeginPosition, ($TokenEndPosition - $TokenBeginPosition));
        }
        Return $ReturnValue
    };
Add-Member `
    -InputObject $Global:Session.Utilities `
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
    -InputObject $Global:Session.Utilities `
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
        [DateTime] $Result = $Global:Session.Utilities.DateTimeOffsetStringToDateTimeUTC($Text);
        If ($Result -ne [DateTimeOffset]::MinValue)
        {
            $ReturnValue = $Result.ToString("yyyy-MM-dd HH:mm:ss.fffffff");
        }
        Return $ReturnValue
    };
Add-Member `
    -InputObject $Global:Session.Utilities `
    -Name "HashString" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Text
        )
        Return (([System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Text))|ForEach-Object ToString X2) -join '');
    };
Add-Member `
    -InputObject $Global:Session.Utilities `
    -Name "DoubleFromString" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Double])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Text
        )
        [Double] $ReturnValue = 0;
        [Double] $ParsedValue = 0;
        If ([Double]::TryParse($Text, [ref]$ParsedValue))
        {
            $ReturnValue = $ParsedValue;
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.Utilities `
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
    -InputObject $Global:Session.Utilities `
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
