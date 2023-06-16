# PostgreSQL
## Used to enteract with PostgreSQL Databases

- ### Requires [Connections](_Modules/Connections/README.md)  
- ### `Method` SetConnection
    Sets a PostgreSQL connection either in memory or persisted.  
    - Name `System.String`  
        Name of the Connection

    - Comments `System.String`  
        Comments for the Connection

    - IsPersisted `System.String`  
        True to store in file system.

    - Server `System.String`  
        The address of the server

    - Port `System.String`  
        The port for the server

    - Database `System.String`  
        The database name

    - UserName `System.String`  
        The user name

    - Password `System.String`  
        The password for the user account

- ### GetConnection `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Gets a PostgreSQL connection either from memory or from file storage.  
    - Name `System.String`  
        Name of the Connection

- ### GetConnectionString `[method]`
    Returns: `System.String`  
    Returns the connection string for the PostgreSQL connection.  
    - Name `System.String`  
        Name of the Connection

- ### `Method` Execute
    Executes the provided script against the connection.  
    - ConnectionName `System.String`  
        The named connection to execute against

    - CommandText `System.String`  
        The SQL script to execute

    - Parameters `System.Collections.Hashtable`  
        The parameter values for any parameters in the script

- ### GetRecords `[method]`
    Returns: `System.Collections.Generic.List[System.Management.Automation.PSCustomObject]`  
    Executes the provided script against the connection and returns the records.  
    - ConnectionName `System.String`  
        The named connection to execute against

    - CommandText `System.String`  
        The SQL script to execute

    - Parameters `System.Collections.Hashtable`  
        The parameter values for any parameters in the script

    - Fields `System.Collections.Generic.List[System.String]`  
        The fields to return. If * is used all fields will be returned.

- ### GetScalar `[method]`
    Returns: `System.Object`  
    Executes the provided script against the connection and returns the first field from the first record.  
    - ConnectionName `System.String`  
        The named connection to execute against

    - CommandText `System.String`  
        The SQL script to execute

    - Parameters `System.Collections.Hashtable`  
        The parameter values for any parameters in the script

- ### `Method` ClearTable
    Clears all records from the specified table  
    - ConnectionName `System.String`  
        The named connection to execute against

    - Schema `System.String`  
        The schema of the table to clear

    - Table `System.String`  
        The table to clear

- ### GetTableRowCount `[method]`
    Returns: `System.Int64`  
    Returns the number of record in the table.  
    - ConnectionName `System.String`  
        The named connection to execute against

    - Schema `System.String`  
        The schema of the table to clear

    - Table `System.String`  
        The table to clear

    - Filters `System.Collections.Hashtable`  
        If provided the fields and values will be used to filter the count. These are AND conditions.

- ### DoesTableHaveColumn `[method]`
    Returns: `System.Boolean`  
    Checks to see if a column exists on a table.  
    - ConnectionName `System.String`  
        The named connection to execute against

    - Schema `System.String`  
        The schema of the table

    - Table `System.String`  
        The table name

    - Column `System.String`  
        The column name

