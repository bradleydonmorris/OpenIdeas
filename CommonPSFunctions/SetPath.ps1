If (!$env:PATH.Contains("C:\Program Files\Git\cmd"))
{
    $env:PATH += ";C:\Program Files\Git\cmd";
}
If (!$env:PATH.Contains("C:\Program Files\wkhtmltopdf\bin"))
{
    $env:PATH += ";C:\Program Files\wkhtmltopdf\bin";
}
