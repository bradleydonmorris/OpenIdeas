# SFTP
## Used to enteract with an SFTP server

- ### Requires [Connections](_Modules/Connections/README.md)  
- ### `Method` SetConnection
    Sets an SFTP connection either in memory or persisted.  
    - Name `System.String`  
        Name of the Connection

    - Comments `System.String`  
        Comments for the Connection

    - IsPersisted `System.String`  
        True to store in file system.

    - AuthType `System.String`  
        Either Passowrd or KeyFile

    - HostAddress `System.String`  
        The address of the SFTP server

    - Port `System.Int32`  
        The port of the SFTP server

    - UserName `System.String`  
        The user name

    - Password `System.String`  
        The password for the user account. Ignored for KeyFile auth type

    - KeyFilePath `System.String`  
        The path to the key file. Ignored for Password auth type

- ### GetConnection `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Gets an SFTP connection either from memory or from file storage.  
    - Name `System.String`  
        Name of the Connection

- ### GetSession `[method]`
    Returns: `SSH.SftpSession`  
    Gets an SFTP seesion.  
    - ConnectionName `System.String`  
        The named connection to create the session for

- ### GetFileList `[method]`
    Returns: `System.Collections.Generic.List[System.Management.Automation.PSObject]`  
    Gets a list of files in a remote directory. This method will aslo attempt to parse date/time from file name if format string and starting position are provided.  
    - ConnectionName `System.String`  
        The named connection

    - RemotePath `System.String`  
        The remote directrory to get the file list for

    - DateTimeFormatString `System.String`  
        Can be null. The date/time format string that is used for any dates and times in file names

    - DateTimeStartPosition `System.Int32`  
        The starting position of any date/times in the file name

- ### GetFilesNewerThan `[method]`
    Returns: `System.Collections.Generic.List[System.Management.Automation.PSObject]`  
    Downloads files from a remote directory where the date/time in the file name is newer than that provided.  
    - ConnectionName `System.String`  
        The named connection

    - RemotePath `System.String`  
        The remote directrory to get the file list for

    - LocalDirectoryPath `System.String`  
        The local directory to store the file in

    - DateTimeFormatString `System.String`  
        Can be null. The date/time format string that is used for any dates and times in file names

    - DateTimeStartPosition `System.Int32`  
        The starting position of any date/times in the file name

    - NewerThan `System.DateTime`  
        The DateTime that the file date/time must be newer than

    - Overwrite `System.Boolean`  
        If true, any local file with the same name will be overwritten

- ### `Method` GetFile
    Downloads a file from an SFTP server to the local file stoarge.  
    - ConnectionName `System.String`  
        The named connection

    - RemoteFilePath `System.String`  
        The path to the remote file to download

    - LocalDirectoryPath `System.String`  
        The local directory to store the file in

    - Overwrite `System.Boolean`  
        If true, any local file with the same name will be overwritten

- ### `Method` WriteFile
    Uploads a file to an SFTP server from the local file stoarge.  
    - ConnectionName `System.String`  
        The named connection

    - RemoteDirectoryPath `System.String`  
        The remote directory to write the file to

    - LocalFilePath `System.String`  
        The local file to upload

