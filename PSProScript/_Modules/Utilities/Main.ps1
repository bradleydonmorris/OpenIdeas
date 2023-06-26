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
