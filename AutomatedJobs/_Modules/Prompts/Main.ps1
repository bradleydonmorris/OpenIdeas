Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Prompts" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Prompts `
    -Name "StringResponse" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $PromptText,
        
            [Parameter(Mandatory=$true)]
            [String] $Default
        )
        [String] $Result = $null;
        [String] $Response = $null;
        If ([String]::IsNullOrEmpty($Default))
            { $Response = Read-Host -Prompt $PromptText; }
        Else
        {
            $Response = Read-Host -Prompt ("$PromptText [Default: " + $Default + "]");
            If ([String]::IsNullOrEmpty($Response))
                { $Response = $Default; }
        }
        $Result = $Response;
        Return $Result;
    };
Add-Member `
    -InputObject $Global:Job.Prompts `
    -Name "BooleanResponse" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $PromptText,
        
            [Parameter(Mandatory=$true)]
            [Boolean] $Default
        )
        [Boolean] $Result = $false;
        [String] $Response = Read-Host -Prompt "$PromptText [Options: (Y)es, (T)rue, 1, (N)o, (F)alse, 0] [Default: $Default]";
        If ([String]::IsNullOrEmpty($Response))
            { $Result = $Default; }
        ElseIf (@("Y", "YES", "T", "TRUE", "1").Contains($Response.ToUpper()))
            { $Result = $true; }
        Else
            { $Result = $false; }
        Return $Result;
    };
Add-Member `
    -InputObject $Global:Job.Prompts `
    -Name "DisplayHashTable" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$false)]
            [String] $SetName,

            [Parameter(Mandatory=$false)]
            [Int32] $MaximumLineLength = 0,

            [Parameter(Mandatory=$true)]
            [Collections.Specialized.OrderedDictionary] $Values
        )
        Write-Host -Object ($Global:Job.Prompts.OutputHashTableToText($SetName, $MaximumLineLength, $Values));
    };
Add-Member `
    -InputObject $Global:Job.Prompts `
    -Name "OutputHashTableToText" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([String])]
        Param
        (
            [Parameter(Mandatory=$false)]
            [String] $SetName,

            [Parameter(Mandatory=$false)]
            [Int32] $MaximumLineLength = 0,

            [Parameter(Mandatory=$true)]
            [Collections.Specialized.OrderedDictionary] $Values
        )
        [String] $ReturnValue = $null;
        $SetName = ([String]::IsNullOrEmpty($SetName)) ? "" : $SetName;
        $MaximumLineLength = (($MaximumLineLength -eq 0) ? 180 : $MaximumLineLength);
        [Int32] $MaximumNameLength = 3
        ForEach ($Key In $Values.Keys)
        {
            If ($Key.Length -gt $MaximumNameLength)
            {
                $MaximumNameLength = $Key.Length;
            }
        }
        $MaximumNameLength += 5;
        [Int32] $MaximumValueLength = (($MaximumLineLength - $MaximumNameLength) - 1);
        $ReturnValue = ([String]::Format("***{0}", $SetName).PadRight($MaximumLineLength, "*") + "`r`n");
        $ReturnValue += ("*".PadRight($MaximumLineLength - 1) + "*`r`n");
        $ReturnValue += (
            "* Name".PadRight($MaximumNameLength, " ") + 
            "Value".PadRight($MaximumValueLength, " ") +
            "*`r`n"
        );
        $ReturnValue += (
            "* -".PadRight(($MaximumNameLength - 1), "-") + 
            " -".PadRight($MaximumValueLength, "-") +
            " *`r`n"
        );
        ForEach ($Key In $Values.Keys)
        {
            [String] $ValueText = $null;
            If ($Values[$Key] -isnot [Boolean])
            {
                $ValueText = $Values[$Key].ToString();
            }
            Else
            {
                $ValueText = $Values[$Key] ? "Yes" : "No";
            }
            $ReturnValue += (
                [String]::Format("* {0}", $Key).PadRight($MaximumNameLength, " ") +
                [String]::Format("{0}", $ValueText).PadRight($MaximumValueLength, " ") +
                "*`r`n"
            );
        }
        $ReturnValue += ("*".PadRight($MaximumLineLength - 1) + "*`r`n");
        $ReturnValue += ("".PadRight($MaximumLineLength, "*"));
        Return $ReturnValue;
    };