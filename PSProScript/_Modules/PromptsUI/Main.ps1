Add-Member `
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "PromptsUI" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.PromptsUI `
    -Name "GetStringPrompt" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [String] $Name,
            [String] $Description,
            [String] $Default
        )
        [PSObject] $ReturnValue = [PSObject]::new();
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Type" -NotePropertyValue "String";
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Name" -NotePropertyValue $Name;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Description" -NotePropertyValue $Description;
        Add-Member -InputObject $ReturnValue -TypeName "System.String" -NotePropertyName "Default" -NotePropertyValue $Default;
        Add-Member -InputObject $ReturnValue -TypeName "System.Windows.Forms.Control" -NotePropertyName "PromptControl" -NotePropertyValue $null;
        Return $ReturnValue;
    }
