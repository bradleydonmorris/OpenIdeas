# PSProScript
This is a framework for managing PowerShell scripts and building commonly used modules.

---
## Directory Structure

### Underneath the root directory will live two required sub directories
- `_Modules` will contain a directory for each available module. (See the [Writing Modules](MODULES.md) documentation for further information.)
- `_Packages` will contain any NuGet packages installed by the [NuGet](_Modules/NuGet/README.md) Module.

### Additional Directories
Any other directories underneath the root are for projects and scripts that use this framework. An example projects is the [ActiveDirectory](ActiveDirectory/README.md), which contains a script for importing ActiveDirectory users and groups in to a set of SQL Server tables.

---
## Required Files

- ## .init.ps1
    This script file should be ran by every other script. It is used to load configurations and Modules used by the scripts and sets up logging and other universal Modules.
    
    Example first line (from `ActiveDirectory\ImportModifications.ps1`)
    ```powershell
    . ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "ActiveDirectory",
    "ActiveDirectorySQLDatabases");
    ```

- ## .psps-config.json
    This file holds paths to where various job data is located. This file is in `.gitignore`, so that it will not be overwritten by future pulls. If this file does not exists on the first run of `.init.ps1`, it will be created. However, it will likely need to be edited.
    - #### Directories  
        These directories are used to store files needed by this framework. `LogsRoot`, `DataRoot`, and `ConnectionsRoot` directories should NOT be subdirectories in this repository, as sensitive information may be stored in them.

        - `LogsRoot` refers to the directory where logs will be stored. Sub directories will be created for each collection\script. For example, the log sub directory for the `ImportModifications.ps1` script in the `ActiveDirectory` collection would be `\ActiveDirectory\ImportModifications`
        - `DataRoot` refers to the directory where data for a script can be stored if needed. Such as files to be imported, etc. Sub directories will be created for each collection\script. For example, the log sub directory for the `ImportModifications.ps1` script in the `ActiveDirectory` collection would be `\ActiveDirectory\ImportModifications`
        - `ConnectionsRoot` refers to the directory where connection files will be stored. This directory should NOT contain any sub directories.
        - `CodeRoot` refers to the directory where this repository is stored.
        - `Modules` refers to the _Modules sub directory of this  repository.
        - `Packages` refers to the _Packages sub directory of this  repository.

    - #### LoggingDefaults  
        These settings can be overridden for specific scripts later in their configuruation.
        - `SMTPConnectionName` referes to the named connection to send emails via SMTP.
        - `RetentionDays` is the number of days that logs should be kept. 
        - `EmailRecipients` is the string array of email recipients. 

---

