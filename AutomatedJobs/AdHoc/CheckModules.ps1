. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1"));

# [Collections.Generic.List[PSObject]] $AvailableModules = $Global:Job.GetAvailableModules();
# ForEach ($AvailableModule In $AvailableModules | Where-Object -FilterScript { $_.Name -eq "Compression7Zip"})
# {
#     $AvailableModule.Name;
#     #$Global:Job.CreateModuleDocFile($AvailableModule.Name);
#     [void] $Global:Job.CreateModuleReadMeFile($AvailableModule.Name);
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
    #$Global:Job.CreateModuleDocFile($AvailableModule.Name);
    [void] $Global:Job.CreateModuleReadMeFile($Module);
}
