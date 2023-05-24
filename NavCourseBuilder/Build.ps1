. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), "CommonPSFunctions\NavCourseFunctions.ps1"));


[String] $Path = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "SARTopoGeo.json");
[String] $OutputFolder = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Output");

[String] $MainTemplatePath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Template_Main.html");
[String] $FormSetAnswerTemplatePath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Template_FormSetAnswer.html");
[String] $FormSetBlankTemplatePath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "Template_FormSetBlank.html");
[String] $LegsCSVPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "5Legs.csv");
[String] $RouteNameListPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($PSCommandPath), "NameList.txt");
[Int32] $NumberOfRoutes = 16;

Write-NavCourseRoutes `
    -Path $Path `
    -OutputFolder $OutputFolder `
    -MainTemplatePath $MainTemplatePath `
    -FormSetAnswerTemplatePath $FormSetAnswerTemplatePath `
    -FormSetBlankTemplatePath $FormSetBlankTemplatePath `
    -LegsCSVPath $LegsCSVPath `
    -NumberOfRoutes $NumberOfRoutes `
    -RouteNameListPath $RouteNameListPath;
