. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "Prompts",
    "AppleHealth"
);
[String] $DatabaseFilePath = "C:\Users\bmorris\source\repos\bradleydonmorris\OpenIdeas\PSProScript\AdHoc\AppleHealth.sqlite";
#[String] $DatabaseFilePath = [IO.Path]::ChangeExtension($PSCommandPath, ".sqlite");

$Global:Session.AppleHealth.OpenDatabase($DatabaseFilePath);
#$Global:Session.AppleHealth.Data.ImportXMLFile("C:\Users\bmorris\Downloads\export_20230804\apple_health_export\export.xml");
#$Global:Session.Utilities.SplitIntFromDateTime([DateTime]::UtcNow)

ForEach ($BloodPressure In $Global:Session.AppleHealth.Data.Views.BloodPressure())
{
    $BloodPressure.EntryGUID;
    $BloodPressure.EntryDate;
    $BloodPressure.EntryTime;
    $BloodPressure.EntryDateTimeUTC.ToString("yyyy-MM-dd HH:mm:ssZ");
    $BloodPressure.EntryDateTimeLocal.ToString("yyyy-MM-dd HH:mm:ssL");
    $BloodPressure.Key;
    $BloodPressure.DataProvider;
    $BloodPressure.Type;
    $BloodPressure.CreationDate.ToString("yyyy-MM-dd HH:mm:ssZ");
    $BloodPressure.StartDate.ToString("yyyy-MM-dd HH:mm:ssZ");
    $BloodPressure.EndDate.ToString("yyyy-MM-dd HH:mm:ssZ");
    $BloodPressure.Systolic;
    $BloodPressure.Diastolic;
    Break;
}

ForEach ($Weight In $Global:Session.AppleHealth.Data.Views.Weight())
{
    $Weight.EntryGUID;
    $Weight.EntryDate;
    $Weight.EntryTime;
    $Weight.EntryDateTimeUTC.ToString("yyyy-MM-dd HH:mm:ssZ");
    $Weight.EntryDateTimeLocal.ToString("yyyy-MM-dd HH:mm:ssL");
    $Weight.Key;
    $Weight.DataProvider;
    $Weight.Type;
    $Weight.CreationDate.ToString("yyyy-MM-dd HH:mm:ssZ");
    $Weight.StartDate.ToString("yyyy-MM-dd HH:mm:ssZ");
    $Weight.EndDate.ToString("yyyy-MM-dd HH:mm:ssZ");
    $Weight.Weight;
    Break;
}
