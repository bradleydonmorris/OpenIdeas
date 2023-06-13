# GoogleAPI
## 

- ### GetGroupMembers `[method]`
    Returns: `System.Collections.Generic.List[System.Management.Automation.PSObject]`  
    Gets all members of the specified group.  
    - ConnectionName `System.String`  
        Name of the Google Connection
    - GroupId `System.String`  
        The Id of the group to retrieve members of
- ### GetGroups `[method]`
    Returns: `System.Collections.Generic.List[System.Management.Automation.PSObject]`  
    Gets All Google groups.  
    - ConnectionName `System.String`  
        Name of the Google Connection
- ### GetOrgUnits `[method]`
    Returns: `System.Collections.Generic.List[System.String]`  
    Gets all Organizational Units  
    - ConnectionName `System.String`  
        Name of the Google Connection
- ### GetRefreshedToken `[method]`
    Returns: `System.String`  
    Attempts to refresh the authentication token and store it in the connection.  
    - ConnectionName `System.String`  
        Name of the Google Connection
- ### GetUsers `[method]`
    Returns: `System.Collections.Generic.List[System.Management.Automation.PSObject]`  
    Gets All Google users.  
    - ConnectionName `System.String`  
        Name of the Google Connection
- ### `Method` NewConnection
      
    - ArgName `System.String`  
        
