# IICSSQLDatabase
## Enteracts with the IICS schema in a specified SQL Server database.

- ### Requires [SQLServer](_Modules/SQLServer/README.md)  
- ### `Method` ClearStaged
    Clears staging tables  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

    - ClearAsset `System.Boolean`  
        If true, clears the StagedAsset table

    - ClearAssetFile `System.Boolean`  
        If true, clears the StagedAssetFile table

    - ClearActivityLog `System.Boolean`  
        If true, clears the StagedActivityLog table

- ### `Method` PostStagedAssets
    Imports asset objects into the database  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

    - AssetsJSON `System.String`  
        The JSON representation of the Assets

- ### `Method` PostStagedAssetFiles
    Clears staging tables  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

    - FederatedId `System.String`  
        The FederatedId of the asset the file is related to

    - FileName `System.String`  
        The file name

    - FileType `System.String`  
        The type of file

    - Content `System.String`  
        The content of the file

- ### `Method` PostStagedActivityLogs
    Clears staging tables  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

    - JSON `System.String`  
        The JSON representation of the activity log entries

- ### `Method` Parse
    Parses all staged asset data  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

- ### `Method` ParseActivityLogs
    Parses all staged activity log data  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

- ### GetActivityLogLastStartTime `[method]`
    Returns: `System.DateTime`  
    Gets the start time of the last activity log entry  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

- ### `Method` RemoveOldActivityLogs
    Removes old activity log entries  
    - ConnectionName `System.String`  
        Name of the SQL database Connection

    - KeepLogsForDays `System.Int32`  
        The number of days of logs to keep

