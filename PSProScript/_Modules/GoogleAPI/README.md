# GoogleAPI
## Enteracts with Google's API to manage user and group information.

- ### Requires [Connections](_Modules/Connections/README.md)  
- ### `Method` SetConnection
    Sets a GoogleAPI connection either in memory or persisted.  
    - Name `System.String`  
        Name of the Connection

    - Comments `System.String`  
        Comments for the Connection

    - IsPersisted `System.String`  
        True to store in file system.

    - ClientId `System.String`  
        

    - ProjectId `System.String`  
        

    - AuthURI `System.String`  
        

    - TokenURI `System.String`  
        

    - AuthProviderx509CertURI `System.String`  
        

    - ClientSecret `System.String`  
        

    - RedirectURI `System.String`  
        

    - Scopes `System.Collections.Generic.List[System.String]`  
        

    - RefreshToken `System.String`  
        

- ### GetConnection `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Gets a GoogleAPI connection either from memory or from file storage.  
    - Name `System.String`  
        Name of the Connection

- ### GetRefreshedToken `[method]`
    Returns: `System.String`  
    Returns the refresh token needed for API calls, and stores the token on the connection.  
    - ConnectionName `System.String`  
        Name of the Connection

- ### GetUsers `[method]`
    Returns: `System.Collections.Generic.List[System.Management.Automation.PSObject]`  
    Gets All Google users.  
    - ConnectionName `System.String`  
        Name of the Google Connection

- ### GetGroups `[method]`
    Returns: `System.Collections.Generic.List[System.Management.Automation.PSObject]`  
    Gets All Google groups.  
    - ConnectionName `System.String`  
        Name of the Google Connection

- ### GetGroupMembers `[method]`
    Returns: `System.Collections.Generic.List[System.Management.Automation.PSObject]`  
    Gets all members of the specified group.  
    - ConnectionName `System.String`  
        Name of the Google Connection

    - GroupId `System.String`  
        The Id of the group to retrieve members of

- ### GetOrgUnits `[method]`
    Returns: `System.Collections.Generic.List[System.String]`  
    Gets all Organizational Units  
    - ConnectionName `System.String`  
        Name of the Google Connection

