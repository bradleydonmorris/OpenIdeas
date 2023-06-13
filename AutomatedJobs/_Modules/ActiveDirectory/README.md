# ActiveDirectory
## Enteracts with ActiveDirectory to manage user and group information.

- ### GetChangedGroups `[method]`
    Returns: `System.Collections.Generic.List[System.String]`  
    Gets all ActiveDirectory groups modified sinced the specified time.  
    - ConnectionName `System.String`  
        Name of the ActiveDirectory Connection
    - ChangedSince `System.DateTime`  
        Time to pull changes from
- ### GetChangedUsers `[method]`
    Returns: `System.Collections.Generic.List[System.String]`  
    Gets all ActiveDirectory users modified sinced the specified time.  
    - ConnectionName `System.String`  
        Name of the ActiveDirectory Connection
    - ChangedSince `System.DateTime`  
        Time to pull changes from
- ### GetGroup `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Gets an ActiveDirectory Group.  
    - ConnectionName `System.String`  
        Name of the ActiveDirectory Connection
    - DistinguishedName `System.String`  
        DN of the group to retrieve
- ### GetLDAPConnection `[method]`
    Returns: `System.String`  
    Gets LDAP Root LDIF from a named connection.  
    - Name `System.String`  
        Name of the ActiveDirectory Connection
- ### GetUser `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Gets an ActiveDirectory User.  
    - ConnectionName `System.String`  
        Name of the ActiveDirectory Connection
    - DistinguishedName `System.String`  
        DN of the user to retrieve
