# ActiveDirectory
## Enteracts with ActiveDirectory to manage user and group information.

- ### Requires [Connections](_Modules/Connections/README.md)  
- ### `Method` SetConnection
    Sets an ActiveDirectory connection either in memory or persisted.  
    - Name `System.String`  
        Name of the Connection

    - Comments `System.String`  
        Comments for the Connection

    - IsPersisted `System.String`  
        True to store in file system.

    - RoodLDIF `System.String`  
        The LDIF Root for the ActiveDirectory (e.g. LDAP://dc=domainName,dc=local)

- ### GetConnection `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Gets an ActiveDirectory connection either from memory or from file storage.  
    - Name `System.String`  
        Name of the Connection

- ### GetConnectionString `[method]`
    Returns: `System.String`  
    Returns the Root LDIF for the ActiveDirectory connection.  
    - Name `System.String`  
        Name of the Connection

- ### GetChangedUsers `[method]`
    Returns: `System.Collections.Generic.List[System.String]`  
    Gets all ActiveDirectory users modified sinced the specified time.  
    - ConnectionName `System.String`  
        Name of the ActiveDirectory Connection

    - ChangedSince `System.DateTime`  
        Time to pull changes from

- ### GetUser `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Gets an ActiveDirectory User.  
    - ConnectionName `System.String`  
        Name of the ActiveDirectory Connection

    - DistinguishedName `System.String`  
        DN of the user to retrieve

- ### GetChangedGroups `[method]`
    Returns: `System.Collections.Generic.List[System.String]`  
    Gets all ActiveDirectory groups modified sinced the specified time.  
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

