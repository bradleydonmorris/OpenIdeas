# ActiveDirectorySQLDatabase
## Enteracts with the ActiveDirectory schema in a specified SQL Server database.

- ### GetGroupLastWhenChangedTime `[method]`
    Returns: `System.DateTime`  
    Gets the latest time any group was changed from the database.  
    - ConnectionName `System.String`  
        Name of the SQL database Connection
- ### GetUserLastWhenChangedTime `[method]`
    Returns: `System.DateTime`  
    Gets the latest time any user was changed from the database.  
    - ConnectionName `System.String`  
        Name of the SQL database Connection
- ### `Method` ImportGroup
    Imports a group object into the database  
    - ConnectionName `System.String`  
        Name of the SQL database Connection
    - GroupJSON `System.String`  
        The JSON representation of the Group object
- ### `Method` ImportUser
    Imports a user object into the database  
    - ConnectionName `System.String`  
        Name of the SQL database Connection
    - UserJSON `System.String`  
        The JSON representation of the User object
- ### `Method` ProcessGroupManagerChanges
    Processes all the changes related to group managers  
    - ConnectionName `System.String`  
        Name of the SQL database Connection
- ### `Method` ProcessGroupMembershipChanges
    Processes all the changes related to group memberships  
    - ConnectionName `System.String`  
        Name of the SQL database Connection
- ### `Method` ProcessManagerialChanges
    Processes all the changes related to users' managers  
    - ConnectionName `System.String`  
        Name of the SQL database Connection
- ### `Method` RebuildIndexes
    Rebuild all indexes on the database tables  
    - ConnectionName `System.String`  
        Name of the SQL database Connection
