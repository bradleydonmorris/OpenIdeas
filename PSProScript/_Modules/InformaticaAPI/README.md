# InformaticaAPI
## Enteracts with Informatica's API to manage user and group information.

- ### Requires [Connections](_Modules/Connections/README.md)  
- ### `Method` SetConnection
    Sets a InformaticaAPI connection either in memory or persisted.  
    - Name `System.String`  
        Name of the Connection

    - Comments `System.String`  
        Comments for the Connection

    - IsPersisted `System.String`  
        True to store in file system.

    - V3LoginURI `System.String`  
        The login URI for version 3

    - V2LoginURI `System.String`  
        The login URI for version 2

    - UserName `System.String`  
        The user name

    - Password `System.String`  
        The password

- ### GetConnection `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Gets a InformaticaAPI connection either from memory or from file storage.  
    - Name `System.String`  
        Name of the Connection

- ### `Method` GetSession
    Creates the `Session` variable used by other methods to connect to the API.  
    - ConnectionName `System.String`  
        Name of the Connection

- ### GetAssets `[method]`
    Returns: `System.Collections.Generic.List[System.String]`  
    Gets assets for the specified project  
    - Project `System.String`  
        The name of the project

- ### ExportAssets `[method]`
    Returns: `System.Management.Automation.PSObject`  
    Gets and stores Assets locally  
    - Assets `System.Collections.Generic.List[System.String]`  
        The list of asset Ids to export

    - OutputDirectoryPath `System.String`  
        The path to the directory where asset files will be stored

    - IncludeConnections `System.Boolean`  
        Determines whether Connections will be exported as well

    - IncludeSchedules `System.Boolean`  
        Determines whether Schedules will be exported as well

- ### `Method` ExportLogs
      
    - OutputDirectoryPath `System.String`  
        The path to the directory where log files will be stored

    - LastDatabaseStartTime `System.DateTime`  
        The date and time to pull logs since

