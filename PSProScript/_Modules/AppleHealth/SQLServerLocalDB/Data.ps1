[void] $Global:Session.LoadModule("Utilities");
[void] $Global:Session.LoadModule("SQLServerLocalDB");

Add-Member `
    -InputObject $Global:Session.AppleHealth `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Data" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data `
    -Name "VerifyDatabase" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
        )
        ForEach ($FileName In @(
            "Schema.sql",
            "Tables\Aggregate.sql",
            "Tables\UnitOfMeasure.sql",
            "Tables\DataProvider.sql",
            "Tables\Type.sql",
            "Tables\Reading.sql",
            "Tables\Correlation.sql",
            "Tables\CorrelationReading.sql",
            "Tables\Workout.sql",
            "Tables\WorkoutStatistic.sql",

            "Views\BloodPressure.sql",
            "Views\BloodPressureFirstOfTheDay.sql",
            "Views\EnergyBurned.sql",
            "Views\RestingHeartRate.sql",
            "Views\RestingHeartRateFirstOfTheDay.sql",
            "Views\Steps.sql",
            "Views\Weight.sql",
            "Views\WeightFirstOfTheDay.sql",
            "Views\WorkoutHIIT.sql",
            "Views\WorkoutWalk.sql",

            "Functions\GetBloodPressureYearlyStatistics.sql",
            "Functions\GetEnergyBurnedYearlyStatistics.sql",
            "Functions\GetRestingHeartRateYearlyStatistics.sql",
            "Functions\GetStepsYearlyStatistics.sql",
            "Functions\GetWeightYearlyStatistics.sql",

            "Procedures\ImportXML.sql",
            "Procedures\GetYearlyStatistics.sql"
        ))
        {
            $Global:Session.SQLServerLocalDB.Execute(
                $Global:Session.AppleHealth.ConnectionName,
                [IO.File]::ReadAllText(
                    [IO.Path]::Combine(
                        [IO.Path]::GetDirectoryName($PSCommandPath),
                        "SQLScripts",
                        $FileName)
                ),
                $null
            );
        }
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data `
    -Name "ImportXML" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
        )
        $Global:Session.Logging.TimedExecute("Execute [AppleHealth].[ImportXML]", {
            Try {
                If ($Global:Session.Variables.Get("IsExtracted"))
                {
                    [xml] $XMLHealthData = [IO.File]::ReadAllText($Global:Session.Variables.Get("AppleHealthExportXMLFilePath"));
                    $Global:Session.SQLServerLocalDB.ProcExecute($Global:Session.AppleHealth.ConnectionName, "AppleHealth", "ImportXML", @{ "XMLHealthData" = $XMLHealthData.DocumentElement });
                }
                Else
                {
                    $Global:Session.Variables.Set("ExportXMLOpened", $false);
                }
            }
            Catch { [void] $Global:Session.Logging.WriteException($_.Exception); }
        });
    }
Add-Member `
    -InputObject $Global:Session.AppleHealth.Data `
    -Name "GetYearlyStatistics" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([PSObject])]
        Param
        (
            [Int32] $Year
        )
        [PSObject] $ReturnValue = $null;
        [String] $Results = $Global:Session.SQLServerLocalDB.ProcGetScalar($Global:Session.AppleHealth.ConnectionName, "AppleHealth", "GetYearlyStatistics", @{ "Year" = $Year });
        If (![String]::IsNullOrEmpty($Results))
        {
            $ReturnValue = (ConvertFrom-Json -InputObject $Results -Depth 100)
        }
        Return $ReturnValue;
    }
