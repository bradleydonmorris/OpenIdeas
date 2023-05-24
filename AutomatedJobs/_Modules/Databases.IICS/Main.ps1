Add-Member `
    -InputObject $Global:Job.Databases `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "IICS" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Databases.IICS `
    -Name "ClearStaged" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [Boolean] $ClearAsset,

            [Parameter(Mandatory=$true)]
            [Boolean] $ClearAssetFile,

            [Parameter(Mandatory=$true)]
            [Boolean] $ClearActivityLog
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();

        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new();
        $SqlCommand.CommandTimeout = 0;
        $SqlCommand.Connection = $SqlConnection;
        $SqlCommand.CommandText = "[IICS].[ClearStaged]";
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;

        [Data.SqlClient.SqlParameter] $SqlParameter_ClearAsset = $SqlCommand.CreateParameter();
        $SqlParameter_ClearAsset.ParameterName = "ClearAsset";
        $SqlParameter_ClearAsset.SqlDbType = [Data.SqlDbType]::Bit;
        $SqlParameter_ClearAsset.SqlValue = $ClearAsset;
        [void] $SqlCommand.Parameters.Add($SqlParameter_ClearAsset);

        [Data.SqlClient.SqlParameter] $SqlParameter_ClearAssetFile = $SqlCommand.CreateParameter();
        $SqlParameter_ClearAssetFile.ParameterName = "ClearAssetFile";
        $SqlParameter_ClearAssetFile.SqlDbType = [Data.SqlDbType]::Bit;
        $SqlParameter_ClearAssetFile.SqlValue = $ClearAssetFile;
        [void] $SqlCommand.Parameters.Add($SqlParameter_ClearAssetFile);

        [Data.SqlClient.SqlParameter] $SqlParameter_ClearActivityLog = $SqlCommand.CreateParameter();
        $SqlParameter_ClearActivityLog.ParameterName = "ClearActivityLog";
        $SqlParameter_ClearActivityLog.SqlDbType = [Data.SqlDbType]::Bit;
        $SqlParameter_ClearActivityLog.SqlValue = $ClearActivityLog;
        [void] $SqlCommand.Parameters.Add($SqlParameter_ClearActivityLog);

        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();

        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.IICS `
    -Name "PostStagedAssets" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [Collections.ArrayList] $Assets
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();

        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new();
        $SqlCommand.CommandTimeout = 0;
        $SqlCommand.Connection = $SqlConnection;
        $SqlCommand.CommandText = "[IICS].[PostStagedAssets]";
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;

        [Data.SqlClient.SqlParameter] $SqlParameter_JSON = $SqlCommand.CreateParameter();
        $SqlParameter_JSON.ParameterName = "JSON";
        $SqlParameter_JSON.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_JSON.Size = (-1);
        $SqlParameter_JSON.SqlValue = ($Assets | ConvertTo-Json -Depth 100);
        [void] $SqlCommand.Parameters.Add($SqlParameter_JSON);

        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();

        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.IICS `
    -Name "PostStagedAssetFiles" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [Collections.ArrayList] $AssetFiles
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();

        ForEach ($AssetFile In $AssetFiles)
        {
            If ([IO.File]::Exists($AssetFile.FilePath))
            {
                [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new();
                $SqlCommand.CommandTimeout = 0;
                $SqlCommand.Connection = $SqlConnection;
                $SqlCommand.CommandText = "[IICS].[PostStagedAssetFile]";
                $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
                
                [Data.SqlClient.SqlParameter] $SqlParameter_FederatedId = $SqlCommand.CreateParameter();
                $SqlParameter_FederatedId.ParameterName = "FederatedId";
                $SqlParameter_FederatedId.SqlDbType = [Data.SqlDbType]::VarChar;
                $SqlParameter_FederatedId.Size = 50;
                $SqlParameter_FederatedId.SqlValue = $AssetFile.FederatedId;
                [void] $SqlCommand.Parameters.Add($SqlParameter_FederatedId);
                
                [Data.SqlClient.SqlParameter] $SqlParameter_FileName = $SqlCommand.CreateParameter();
                $SqlParameter_FileName.ParameterName = "FileName";
                $SqlParameter_FileName.SqlDbType = [Data.SqlDbType]::VarChar;
                $SqlParameter_FileName.Size = 50;
                $SqlParameter_FileName.SqlValue = $AssetFile.FileName;
                [void] $SqlCommand.Parameters.Add($SqlParameter_FileName);
                
                [Data.SqlClient.SqlParameter] $SqlParameter_FileType = $SqlCommand.CreateParameter();
                $SqlParameter_FileType.ParameterName = "FileType";
                $SqlParameter_FileType.SqlDbType = [Data.SqlDbType]::VarChar;
                $SqlParameter_FileType.Size = 50;
                $SqlParameter_FileType.SqlValue = $AssetFile.FileType;
                [void] $SqlCommand.Parameters.Add($SqlParameter_FileType);
                
                [Data.SqlClient.SqlParameter] $SqlParameter_Content = $SqlCommand.CreateParameter();
                $SqlParameter_Content.ParameterName = "Content";
                $SqlParameter_Content.SqlDbType = [Data.SqlDbType]::NVarChar;
                $SqlParameter_Content.Size = (-1);
                $SqlParameter_Content.SqlValue = [IO.File]::ReadAllText($AssetFile.FilePath);
                [void] $SqlCommand.Parameters.Add($SqlParameter_Content);
                
                [void] $SqlCommand.ExecuteNonQuery();
                [void] $SqlCommand.Dispose();
            }
        }

        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.IICS `
    -Name "PostStagedActivityLogs" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $JSON
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();

        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new();
        $SqlCommand.CommandTimeout = 0;
        $SqlCommand.Connection = $SqlConnection;
        $SqlCommand.CommandText = "[IICS].[PostStagedActivityLogs]";
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;

        [Data.SqlClient.SqlParameter] $SqlParameter_JSON = $SqlCommand.CreateParameter();
        $SqlParameter_JSON.ParameterName = "JSON";
        $SqlParameter_JSON.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_JSON.Size = (-1);
        $SqlParameter_JSON.SqlValue = $JSON;
        [void] $SqlCommand.Parameters.Add($SqlParameter_JSON);

        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();

        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.IICS `
    -Name "Parse" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();

        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new();
        $SqlCommand.CommandTimeout = 0;
        $SqlCommand.Connection = $SqlConnection;
        $SqlCommand.CommandText = "[IICS].[Parse]";
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();

        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.IICS `
    -Name "ParseActivityLogs" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();

        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new();
        $SqlCommand.CommandTimeout = 0;
        $SqlCommand.Connection = $SqlConnection;
        $SqlCommand.CommandText = "[IICS].[ParseActivityLogs]";
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();

        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.IICS `
    -Name "GetActivityLogLastStartTime" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([DateTime])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();

        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new();
        $SqlCommand.CommandTimeout = 0;
        $SqlCommand.Connection = $SqlConnection;
        $SqlCommand.CommandText = "[IICS].[GetActivityLogLastStartTime]";
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        [Object] $Result = $SqlCommand.ExecuteScalar();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        If ($Result -is [DateTime])
        {
            Return [DateTime]::SpecifyKind($Result, [System.DateTimeKind]::Utc);
        }
        Else
        {
            Return $null;
        }
    };
Add-Member `
    -InputObject $Global:Job.Databases.IICS `
    -Name "RemoveOldActivityLogs" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [Int32] $KeepLogsForDays
        )
        If ($KeepLogsForDays -gt 0)
        {
            [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($ConnectionName));
            [void] $SqlConnection.Open();

            [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new();
            $SqlCommand.CommandTimeout = 0;
            $SqlCommand.Connection = $SqlConnection;
            $SqlCommand.CommandText = "[IICS].[RemoveOldActivityLogs]";
            $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;

            [Data.SqlClient.SqlParameter] $SqlParameter_KeepLogsForDays = $SqlCommand.CreateParameter();
            $SqlParameter_KeepLogsForDays.ParameterName = "KeepLogsForDays";
            $SqlParameter_KeepLogsForDays.SqlDbType = [Data.SqlDbType]::Int;
            $SqlParameter_KeepLogsForDays.SqlValue = $KeepLogsForDays;
            [void] $SqlCommand.Parameters.Add($SqlParameter_KeepLogsForDays);

            [void] $SqlCommand.ExecuteNonQuery();
            [void] $SqlCommand.Dispose();

            [void] $SqlConnection.Close();
            [void] $SqlConnection.Dispose();
        }
    };



#[IICS].[PostTempBDM]
Add-Member `
    -InputObject $Global:Job.Databases.IICS `
    -Name "PostTempBDM" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $JSON
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Connections.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();

        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new();
        $SqlCommand.CommandTimeout = 0;
        $SqlCommand.Connection = $SqlConnection;
        $SqlCommand.CommandText = "[IICS].[PostTempBDM]";
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;

        [Data.SqlClient.SqlParameter] $SqlParameter_JSON = $SqlCommand.CreateParameter();
        $SqlParameter_JSON.ParameterName = "JSON";
        $SqlParameter_JSON.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_JSON.Size = (-1);
        $SqlParameter_JSON.SqlValue = $JSON;
        [void] $SqlCommand.Parameters.Add($SqlParameter_JSON);

        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();

        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
