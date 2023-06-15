# automated-jobs/_Modules



These Module scripts are loaded by `.init.ps1`. To use `.init.ps1` and these Module scripts, the first line of the project/script should be similar to the following with the `RequiredModuleGroups` array changed to the appropriate list.

Example first line (from `ActiveDirectory\ImportModifications.ps1`)
```powershell
. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModuleGroups @(
"ActiveDirectory",
"Databases.ActiveDirectory");
```

---
## ALWAYS LOADED
The following Module scripts will ALWAYS be loaded anytime `.init.ps1` is called.

- ### [Logging.ps1](Logging/Logging.md)
    This file adds methods to the `$Global:Job.Logging` object for handling logging.
- ### [Connections.ps1](Connections.md)
    This file adds methods to the `$Global:Job.Connections` object for handling files in the Connections directory where connection information is stored.
- ### [Databases.ps1](Databases.md)
    This file adds methods to the `$Global:Job.Databases` object for handling basic database functionallity, such as clearing tables files and importing CSV.

---
## LOADED ON REQUEST
The following Module scripts may be loaded by adding them to the `RequiredModuleGroups` parameter of `.init.ps1`.

- ### [ActiveDirectory.ps1](ActiveDirectory.md)
    This file adds methods to the `$Global:Job.ActiveDirectory` object for handling calls to ActiveDirectory services.
- ### [Compression.ps1](Compression.md)
    This file adds methods to the `$Global:Job.Compression` object for handling files that have been compressed. (Uses `7-Zip` command line.)
- ### [SFTP.ps1](SFTP.md)
    This file adds methods to the `$Global:Job.SFTP` object for handling SFTP transfers. (Uses the `Posh-SSH` PowerShell module.)

### Database Modules
- ### [Databases.ActiveDirectory.ps1](Databases.ActiveDirectory.md)
    This file adds methods to the `$Global:Job.Databases.ActiveDirectory` object for handling calls to the stored procedures of the `ActiveDirectory` schema in SQL Server.
- ### [Databases.Google.ps1](Databases.Google.md)
    This file adds methods to the `$Global:Job.Databases.Google` object for handling calls to the stored procedures of the `Google` schema in SQL Server.
- ### [Databases.IICS.ps1](Databases.IICS.md)
    This file adds methods to the `$Global:Job.IICS.Google` object for handling calls to the stored procedures of the `IICS` schema in SQL Server.



[ActiveDirectory](ActiveDirectory/README.md)
