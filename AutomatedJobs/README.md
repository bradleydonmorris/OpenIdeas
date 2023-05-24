# automated-jobs

- ## .init.ps1
    This script file should be ran by every other script. It is used to load configurations and Modules used by the scripts and sets up logging and other universal Modules.
    
    Example first line (from `ActiveDirectory\ImportModifications.ps1`)
    ```powershell
    . ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "ActiveDirectory",
    "Databases.ActiveDirectory");
    ```

- ## .jobs-config.json
    This file holds paths to where various job data is located. These directories should NOT be subdirectories in this repository, as sensitive information may be stored in them. This file is in `.gitignore`, so that it will not be overwritten be future pulls.
    - #### Directories
        - `LogsRoot` refers to the directory where logs will be stored. Sub directories will be created for each collection\script. For example, the log sub directory for the `ImportModifications.ps1` script in the `ActiveDirectory` collection would be `\ActiveDirectory\ImportModifications`
        - `DataRoot` refers to the directory where data for a script can be stored if needed. Such as files to be imported, etc. Sub directories will be created for each collection\script. For example, the log sub directory for the `ImportModifications.ps1` script in the `ActiveDirectory` collection would be `\ActiveDirectory\ImportModifications`
        - `ConnectionsRoot` refers to the directory where connection files will be stored. This directory should NOT contain any sub directories.
        - `CodeRoot` refers to the directory where this repository is stored.
        - `Modules` refers to the _Modules sub directory of this  repository.

---

## Collections and scripts
- ## ActiveDirectory
    - ### ImportModifications.ps1
        This script will import modifications made to users and groups in ActiveDirectory.
        - #### ImportModifications.config.json
            - `DatabaseConnectionName` refers to the connection file in `ConnectionsRoot` directory that contains the database connection information for the `ActiveDirectory` schema in SQL Server.
            - `LDAPConnectionName` refers to the connection file in the `ConnectionsRoot` directory that contains the connection information for ActiveDirectory.
