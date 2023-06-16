# SQLServer
## Used to enteract with SQLServer Databases

- ### Requires [Connections](_Modules/Connections/README.md)  
- ### `Method` SetConnection
    Sets a SQLServer connection either in memory or persisted.  
    - Name `System.String`  
        Name of the Connection

    - Comments `System.String`  
        Comments for the Connection

    - IsPersisted `System.String`  
        True to store in file system.

    - Instance `System.String`  
        The address of the server

    - Database `System.String`  
        The database name

    - IntegratedSecurity `System.Boolean`  
        If true will use Windows Integrated security instead of User Name and Password

    - UserName `System.String`  
        The user name

    - Password `System.String`  
        The password for the user account

- ### GetConnection `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Gets a SQLServer connection either from memory or from file storage.  
    - Name `System.String`  
        Name of the Connection

- ### GetConnectionString `[method]`
    Returns: `System.String`  
    Returns the connection string for the SQLServer connection.  
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

- ### `Method` ProcExecute
    Executes the specified procedure on the named connection.  
    - ConnectionName `System.String`  
        The named connection to execute against

    - Schema `System.String`  
        The schema name for the proc

    - Procedure `System.String`  
        The name for the proc

    - Parameters `System.Collections.Hashtable`  
        The parameter values for any parameters in the script

- ### ProcGetRecords `[method]`
    Returns: `System.Collections.Generic.List[System.Management.Automation.PSCustomObject]`  
    Executes the specified procedure on the connection and returns the records.  
    - ConnectionName `System.String`  
        The named connection to execute against

    - Schema `System.String`  
        The schema name for the proc

    - Procedure `System.String`  
        The name for the proc

    - Parameters `System.Collections.Hashtable`  
        The parameter values for any parameters in the script

    - Fields `System.Collections.Generic.List[System.String]`  
        The fields to return. If * is used all fields will be returned.

- ### ProcGetScalar `[method]`
    Returns: `System.Object`  
    Executes the specified procedure on the connection and returns the first field from the first record.  
    - ConnectionName `System.String`  
        The named connection to execute against

    - Schema `System.String`  
        The schema name for the proc

    - Procedure `System.String`  
        The name for the proc

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

- ### `Method` ClearTable
      
    - ArgName `System.String`  
        

- ### `Method` DoesTableHaveColumn
      
    - ArgName `System.String`  
        

- ### `Method` Execute
      
    - ArgName `System.String`  
        

- ### `Method` GetConnection
      
    - ArgName `System.String`  
        

- ### `Method` GetConnectionString
      
    - ArgName `System.String`  
        

- ### `Method` GetRecords
      
    - ArgName `System.String`  
        

- ### `Method` GetScalar
      
    - ArgName `System.String`  
        

- ### `Method` GetTableRowCount
      
    - ArgName `System.String`  
        

- ### `Method` ProcExecute
      
    - ArgName `System.String`  
        

- ### `Method` ProcGetRecords
      
    - ArgName `System.String`  
        

- ### `Method` ProcGetScalar
      
    - ArgName `System.String`  
        

- ### `Method` SetConnection
      
    - ArgName `System.String`  
        

