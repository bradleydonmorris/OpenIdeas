# ActiveDirectorySQLDatabase
## Enteracts with the ActiveDirectory schema in a specified SQL Server database.

- ### Requires [SQLServer](_Modules/SQLServer/README.md)  
- ### GetUserLastWhenChangedTime `[method]`
    Returns: `System.DateTime`  
    Gets the latest time any user was changed from the database.  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

- ### GetGroupLastWhenChangedTime `[method]`
    Returns: `System.DateTime`  
    Gets the latest time any group was changed from the database.  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

- ### `Method` ImportUser
    Imports a user object into the database  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

    - UserJSON `System.String`  
        The JSON representation of the User object

- ### `Method` ImportGroup
    Imports a group object into the database  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

    - GroupJSON `System.String`  
        The JSON representation of the Group object

- ### `Method` ProcessManagerialChanges
    Processes all the changes related to users' managers  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

- ### `Method` ProcessGroupMembershipChanges
    Processes all the changes related to group memberships  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

- ### `Method` ProcessGroupManagerChanges
    Processes all the changes related to group managers  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

- ### `Method` RebuildIndexes
    Rebuild all indexes on the database tables  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

