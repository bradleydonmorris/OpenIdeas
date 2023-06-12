. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1"));

[Collections.Generic.List[PSObject]] $AvailableModules = $Global:Job.GetAvailableModules();
ForEach ($AvailableModule In $AvailableModules | Where-Object -FilterScript { $_.Name -ne "ActiveDirectory"})
{
    $AvailableModule.Name;
    #$Global:Job.CreateModuleDocFile($AvailableModule.Name);
    $Global:Job.CreateModuleReadMeFile($AvailableModule.Name);
}
