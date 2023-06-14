. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1"));

# [Collections.Generic.List[PSObject]] $AvailableModules = $Global:Session.GetAvailableModules();
# ForEach ($AvailableModule In $AvailableModules | Where-Object -FilterScript { $_.Name -eq "Compression7Zip"})
# {
#     $AvailableModule.Name;
#     #$Global:Session.CreateModuleDocFile($AvailableModule.Name);
#     [void] $Global:Session.CreateModuleReadMeFile($AvailableModule.Name);
# }
$Modules = @(
    "ActiveDirectory"
    "ActiveDirectorySQLDatabase"
    "Compression7Zip"
    "Connections"
    "GoogleAPI"
    "GoogleSQLDatabase"
    <#
IICSSQLDatabase
InformaticaAPI
Logging
NuGet
PostgreSQL
PreciousMetalsTracking
Prompts
ScriptSQLServerDatabase
SFTP
Sqlite
SQLServer
SQLServerFileImport
SSHTunnel
WebServer
    #>
);
ForEach ($Module In $Modules)
{
    $Module;
    #$Global:Session.CreateModuleDocFile($AvailableModule.Name);
    [void] $Global:Session.CreateModuleReadMeFile($Module);
}
