[String] $BearerToken = "Bearer 00DHn0000019aWS!AQIAQHckR1CH3rlyf3qi2t1UBVhe9uhwv5F01nUwIyR8.uj.JFDVtq1_iGPo5TRoUYMKYkHYP8ecM9f0PWlpQ7Kbv6Df.RGn"
[String] $ListJobsRequestURI = "https://selfemployed63-dev-ed.develop.my.salesforce.com/services/data/v58.0/jobs/ingest/"
[Collections.Hashtable] $ListJobsRequestHeaders = @{
    "Authorization" = $BearerToken;
    "Content-Type" = "application/json";
    "X-PrettyPrint" = "1";
}
$ListJobsResponse = Invoke-RestMethod -Uri $JobRequestURI -Method GET -Headers $JobRequestHeaders;

ForEach ($Job In $ListJobsResponse.records)
{
    Write-Host ($Job.id + " = " + $Job.state);
<#    If ($Job.state -eq "Open")
    {
        [Collections.Hashtable] $AbortJobBody = @{
            "state" = "Aborted";
        };
        [String] $AbortJobURI = [String]::Format(
            "https://selfemployed63-dev-ed.develop.my.salesforce.com/services/data/v58.0/jobs/ingest/{0}/",
            $Job.id
        );
        [Collections.Hashtable] $AbortJobHeaders = @{
            "Authorization" = $BearerToken;
            "Content-Type" = "application/json";
        }
        $AbortJobResponse = Invoke-RestMethod -Uri $AbortJobURI -Method PATCH -Body (ConvertTo-Json $AbortJobBody -Depth 10) -Headers $AbortJobHeaders;
        $AbortJobResponse
    }#>
}