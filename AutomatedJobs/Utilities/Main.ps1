Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Utilities" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Utilities `
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
        [DateTime] $Results = [DateTime]::MinValue;
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
                $Results = $ResultDateTime;
            }
        }
        Else
        {
            $Results = [DateTime]::MinValue;
        }
        Return $Results
    };
