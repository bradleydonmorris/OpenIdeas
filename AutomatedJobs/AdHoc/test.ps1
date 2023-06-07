Function Damn-it()
{
    [OutputType([System.Collections.Generic.List[PSObject]])]
    Param
    (
        [Int32] $HowMany,

        [System.Collections.Generic.List[String]] $Fields
    )
    [System.Collections.Generic.List[PSObject]] $ReturnValue = [System.Collections.Generic.List[PSObject]]::new();
    For ($Index = 1; $Index -le $HowMany; $Index ++)
    {
        [PSObject] $Record = [PSObject]::new();
        ForEach ($Field In $Fields)
        {
            [Object] $Value = [String]::Format("{0}-{1}", $Field, $Index);
            Add-Member `
                -InputObject $Record `
                -TypeName ($Value.GetType().Name) `
                -NotePropertyName $Field `
                -NotePropertyValue $Value;
        }
        [void] $ReturnValue.Add([PSObject]$Record);
    }
    Return $ReturnValue;
}
$Result = Damn-it -HowMany 1 -Fields @( "Name", "Description", "Code");
ForEach ($Item In $Result)
{
    $Item.Name;
}