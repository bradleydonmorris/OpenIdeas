# Logging
## Allows management of logging.

- ### OpenLogTime `[property]`
    The time the Log was opened.
- ### CloseLogTime `[property]`
    The time the Log was closed.
- ### ElapsedLogTime `[property]`
    The time span the log was opened.
- ### DirectoryPath `[property]`
    The path to the directory of log storage.
- ### ConfigFilePath `[property]`
    The path to the configuration file.
- ### LogFileTimestamp `[property]`
    The time stamp used in the log file name.
- ### LogFileNameTemplate `[property]`
    The template used for the log file name.
- ### LogFilePathTemplate `[property]`
    The template used for the log file path.
- ### LastLogFileNumber `[property]`
    Last number used for log files.
- ### CurrentLogFilePath `[property]`
    The path to the current log file.
- ### JSONFilePath `[property]`
    The path to the current log file in JSON format.
- ### LastEntryNumber `[property]`
    Last number used for entries.
- ### Entries `[property]`
    Collection of log entires.
- ### Variables `[property]`
    A hash table of variables used by other methods.
- ### `Method` WriteEntry
    Writes an entry to the log  
    - Level `System.String`  
        One of Information, Warning, Error, Debug, or Fatal

- ### GetNextLogFile `[method]`
    Returns: `System.Collections.Hashtable`  
    Gets the next log file to use to store extended exception information.
- ### `Method` WriteException
    Stores an exception in the file system.  
    - Exception `System.Exception`  
        The exception to write

- ### `Method` WriteExceptionWithData
    Stores an exception in the file system with additional data.  
    - Exception `System.Exception`  
        The exception to write

    - AdditionalData `System.String`  
        The additional data to write

- ### `Method` WriteVariables
    Writes a collection of variables to the log.  
    - SetName `System.String`  
        A name given to the set of variables

    - Variables `System.Collections.Hashtable`  
        The variables to write

- ### `Method` Close
    Closes the log.
- ### `Method` ClearLogs
    Removes old log files.
- ### `Method` Send
    Emails log information to the recipients specified in the config file.
- ### `Method` TimedExecute
    Creates timers and executes the script.  
    - Name `System.String`  
        The name given to the timer

