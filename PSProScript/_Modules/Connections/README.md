# Connections
## Manages named connections in files and in memory.

- ### InMemory `[property]`
    Contains all connections retreived or created to be in memory only.
- ### Exists `[method]`
    Returns: `System.Boolean`  
    Checks if a file exists for named connection  
    - Name `System.String`  
        Name of the connection
- ### Get `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Retrieves a connection either from in memobry of the file system.  
    - Name `System.String`  
        Name of the connection
- ### `Method` Set
    Saves a connection either in membory or on the file system.  
    - Name `System.String`  
        Name of the connection
    - Connection `System.String`  
        The connection object to store
    - IsPersisted `System.Boolean`  
        If true, the connection will be persisted to a file
