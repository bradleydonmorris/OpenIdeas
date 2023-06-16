# Connections
## Manages named connections in files and in memory.

- ### InMemory `[property]`
    Contains all connections retreived from file storage or created to be in memory only.
- ### Exists `[method]`
    Returns: `System.Boolean`  
    Checks if a named connection exists  
    - Name `System.String`  
        Name of the connection

- ### IsPersisted `[method]`
    Returns: `System.Boolean`  
    Checks if a named connection has been persisted to file storage  
    - Name `System.String`  
        Name of the connection

- ### Get `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Retrieves a connection either from in memory of file storage.  
    - Name `System.String`  
        Name of the connection

- ### `Method` Set
    Saves a connection either in membory or file storage.  
    - Name `System.String`  
        Name of the connection

    - Connection `System.String`  
        The connection object to store

    - IsPersisted `System.Boolean`  
        If true, the connection will be persisted to file storage

- ### `Method` Update
    Updates an existing connection. If the connection has been persisted, also updates the file.  
    - Name `System.String`  
        Name of the connection

    - Connection `System.String`  
        The connection object to store

