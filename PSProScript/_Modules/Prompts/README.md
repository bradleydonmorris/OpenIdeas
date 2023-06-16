# Prompts
## Allows interation with the user.

- ### `Method` PressEnter
    Causes a wait for the user to press ENTER.
- ### StringResponse `[method]`
    Returns: `System.String`  
    Requests a string response from the user.  
    - PromptText `System.String`  
        The text to show the user

    - Default `System.String`  
        The value to return if the user presses ENTER

- ### BooleanResponse `[method]`
    Returns: `System.Boolean`  
    Requests a yes or no response from the user.  
    - PromptText `System.String`  
        The text to show the user

    - Default `System.Boolean`  
        The value to return if the user presses ENTER

- ### `Method` DisplayHashTable
    Displays the contents of a name/value pair collection  
    - SetName `System.String`  
        Can be null. The name to give the values that are to be displayed

    - MaximumLineLength `System.Int64`  
        The maximum length to use when establishing the lines. Defaults to 180

    - Values `System.Collections.Specialized.OrderedDictionary`  
        The name/values to display

- ### OutputHashTableToText `[method]`
    Returns: `System.String`  
    Generates the text output for a hash table.  
    - SetName `System.String`  
        Can be null. The name to give the values that are to be displayed

    - MaximumLineLength `System.Int64`  
        The maximum length to use when establishing the lines. Defaults to 180

    - Values `System.Collections.Specialized.OrderedDictionary`  
        The name/values to output

- ### ShowMenu `[method]`
    Returns: `System.String`  
    Displays a menu for a user to choose from.  
    - MaximumLineLength `System.Int64`  
        The maximum length to use when establishing the lines. Defaults to 180

    - Options `System.Collections.Generic.List[System.Management.Automation.PSObject]`  
        An array of options to display

