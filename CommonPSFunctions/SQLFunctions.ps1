Function Invoke-SQLScript()
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Instance,

        [Parameter(Mandatory=$true)]
        [String] $Database,

        [Parameter(Mandatory=$true)]
        [String] $CommandText,

        [Parameter(Mandatory=$false)]
        [Collections.Hashtable] $Parameters
    )
    [System.Data.SqlClient.SqlInfoMessageEventHandler] $SqlInfoMessageEventHandler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {
        Param( $senderObj, $SqlInfoMessageEventArgs )
        [Collections.ArrayList] $Output = [Collections.ArrayList]::new();
        If ($SqlInfoMessageEventArgs.Errors.Count -eq 0)
        {
            [void] $Output.Add($SqlInfoMessageEventArgs.Message);
        }
        Else
        {
            ForEach ($SqlError in $SqlInfoMessageEventArgs.Errors)
            {
                If ($SqlError.Class -eq 0)
                {
                    [void] $Output.Add($SqlError.Message);
                }
                Else
                {
                    [String] $ErrorMessage = "ERROR";
                    $ErrorMessage += "`n`tSource: " + $SqlError.Source.ToString();
                    $ErrorMessage += "`n`tServer: " + $SqlError.Server.ToString();
                    $ErrorMessage += "`n`tSeverity: " + $SqlError.Class.ToString();
                    $ErrorMessage += "`n`tState: " + $SqlError.State.ToString();
                    $ErrorMessage += "`n`tNumber: " + $SqlError.Number.ToString();
                    $ErrorMessage += "`n`tLineNumber: " + $SqlError.LineNumber.ToString();
                    $ErrorMessage += "`n`tProcedure: " + $SqlError.Procedure.ToString();
                    $ErrorMessage += "`n`tMessage: " + $SqlError.Message.ToString();
                    [void] $Output.Add($ErrorMessage);
                }
            }
        }
        If ($Output.Count -gt 0)
        {
            ForEach ($Item In $Output)
            {
                Write-Host $Item;
            }
        }
    }

    ForEach ($ParameterKey In $Parameters.Keys)
    {
        $CommandText = $CommandText.Replace("`$($ParameterKey)", $Parameters[$ParameterKey].ToString());
    }
    [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
    [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
    [void] $SqlConnection.add_InfoMessage($SqlInfoMessageEventHandler); 
    $SqlConnection.FireInfoMessageEventOnUserErrors = $true;
    [void] $SqlConnection.Open();

    ForEach ($Command In ($CommandText -split "GO"))
    {
        If (![String]::IsNullOrEmpty($Command.Trim()))
        {
            [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($Command, $SqlConnection);
            $SqlCommand.CommandType = [Data.CommandType]::Text
            $SqlCommand.CommandTimeout = 0;
            [void] $SqlCommand.ExecuteNonQuery();
            [void] $SqlCommand.Dispose();
        }
    }
    [void] $SqlConnection.Close();
    [void] $SqlConnection.Dispose();
}

Function Get-LargeSQLScalarValue()
{
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Instance,

        [Parameter(Mandatory=$true)]
        [String] $Database,

        [Parameter(Mandatory=$true)]
        [String] $CommandText,

        [Parameter(Mandatory=$false)]
        [Collections.Hashtable] $Parameters
    )
    [String] $ReturnValue = $null;
    ForEach ($ParameterKey In $Parameters.Keys)
    {
        $CommandText = $CommandText.Replace("`$($ParameterKey)", $Parameters[$ParameterKey].ToString());
    }

    [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
    [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
    [void] $SqlConnection.Open();

    ForEach ($Command In ($CommandText -split "GO"))
    {
        If (![String]::IsNullOrEmpty($Command.Trim()))
        {
            [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($Command, $SqlConnection);
            $SqlCommand.CommandType = [Data.CommandType]::Text
            $SqlCommand.CommandTimeout = 0;
            [Object] $ScalarObject = $SqlCommand.ExecuteScalar();
            If ($ScalarObject -is [String])
            {
                $ReturnValue = [String]$ScalarObject
            }
            [void] $SqlCommand.Dispose();
        }
    }
    [void] $SqlConnection.Close();
    [void] $SqlConnection.Dispose();
    Return $ReturnValue;
}

Function Invoke-SQLProcedure()
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Instance,

        [Parameter(Mandatory=$true)]
        [String] $Database,

        [Parameter(Mandatory=$true)]
        [String] $Procedure,

        [Parameter(Mandatory=$false)]
        [Collections.Hashtable] $Parameters,

        [Parameter(Mandatory=$false)]
        [Switch] $HasScalarOutput

    )
    [Object] $ReturnValue = $null;
    [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
    [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
    [void] $SqlConnection.Open();

    [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($Procedure, $SqlConnection);
    $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure
    $SqlCommand.CommandTimeout = 0;

    ForEach ($ParameterKey In $Parameters.Keys)
    {
        [String] $ParameterName = $ParameterKey;
        If ($ParameterName.Substring(1) -eq "@")
        {
            $ParameterName = $ParameterName.Substring(1, ($ParameterName.Length - 1));
        }
        [void] $SqlCommand.Parameters.AddWithValue($ParameterName, $Parameters[$ParameterKey]);
    }

    If ($HasScalarOutput)
    {
        $ReturnValue = $SqlCommand.ExecuteScalar();
    }
    Else
    {
        [void] $SqlCommand.ExecuteNonQuery();
    }

    [void] $SqlCommand.Dispose();
    [void] $SqlConnection.Close();
    [void] $SqlConnection.Dispose();
    If ($HasScalarOutput)
    {
        Return $ReturnValue;
    }
}

Function Get-RowsToFlatFile()
{
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Instance,

        [Parameter(Mandatory=$true)]
        [String] $Database,

        [Parameter(Mandatory=$true)]
        [String] $CommandText,

        [Parameter(Mandatory=$false)]
        [Collections.Hashtable] $Parameters,

        [Parameter(Mandatory=$true)]
        [String] $OutputPath,

        [Parameter(Mandatory=$true)]
        [String] $RowDelimiter
    )
    If (-not $RowDelimiter)
    {
        $RowDelimiter = "";
    }
    [IO.File]::WriteAllText($OutputPath, "");
    ForEach ($ParameterKey In $Parameters.Keys)
    {
        $CommandText = $CommandText.Replace("`$($ParameterKey)", $Parameters[$ParameterKey].ToString());
    }

    [String] $ConnectionString = "Server=$Instance;Database=$Database;Trusted_Connection=True;Application Name=" + [IO.Path]::GetFileName($PSCommandPath);
    [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($ConnectionString);
    [void] $SqlConnection.Open();

    ForEach ($Command In ($CommandText -split "GO"))
    {
        If (![String]::IsNullOrEmpty($Command.Trim()))
        {
            [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new($Command, $SqlConnection);
            $SqlCommand.CommandType = [Data.CommandType]::Text
            $SqlCommand.CommandTimeout = 0;
            [Data.SqlClient.SqlDataReader] $SqlDataReader =  $SqlCommand.ExecuteReader();
            While ($SqlDataReader.Read())
            {
                [IO.File]::AppendAllText($OutputPath, $SqlDataReader.GetString(0) + $RowDelimiter);
            }
            [void] $SqlDataReader.Close();
            [void] $SqlDataReader.Dispose();
            [void] $SqlCommand.Dispose();
        }
    }
    [void] $SqlConnection.Close();
    [void] $SqlConnection.Dispose();
}