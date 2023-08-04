Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Variables" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.Variables `
    -NotePropertyName "Dictionary" `
    -NotePropertyValue ([System.Collections.Generic.Dictionary[[String], [Object]]]::new());
Add-Member `
    -InputObject $Global:Session.Variables `
    -Name "Set" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name,

            [Parameter(Mandatory=$true)]
            [Object] $Value
        )
        If ($Global:Session.Variables.Dictionary.ContainsKey($Name))
        {
            [void] $Global:Session.Variables.Dictionary.Remove($Name);
        }
        [void] $Global:Session.Variables.Dictionary.Add($Name, $Value);
        [void] $Global:Session.Logging.WriteVariableSet($Name, $Value);
    };
Add-Member `
    -InputObject $Global:Session.Variables `
    -Name "Get" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Object])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        [Object] $ReturnValue = $null;
        If ($Global:Session.Variables.Dictionary.ContainsKey($Name))
        {
            $ReturnValue = $Global:Session.Variables.Dictionary[$Name];
        }
        Return $ReturnValue;
    };
Add-Member `
    -InputObject $Global:Session.Variables `
    -Name "Remove" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Name
        )
        If ($Global:Session.Variables.Dictionary.ContainsKey($Name))
        {
            [void] $Global:Session.Variables.Dictionary.Remove($Name);
        }
    };
