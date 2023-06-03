Add-Member `
    -InputObject $Global:Job.Databases `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "ActiveDirectory" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.Databases.ActiveDirectory `
    -Name "GetUserLastWhenChangedTime" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([DateTime])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [DateTime] $Results = [DateTime]::new(1970, 1, 1, 0, 0, 0);
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Databases.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[ActiveDirectory].[GetUserLastWhenChangedTime]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;

        [Data.SqlClient.SqlDataReader] $SqlDataReader = $SqlCommand.ExecuteReader();
        While ($SqlDataReader.Read())
        {
            $Results = $SqlDataReader.GetDateTime(0);
            $Results = [DateTime]::SpecifyKind($Results, [System.DateTimeKind]::Utc);
        }
        [void] $SqlDataReader.Close();
        [void] $SqlDataReader.Dispose();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.Databases.ActiveDirectory `
    -Name "GetGroupLastWhenChangedTime" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([DateTime])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [DateTime] $Results = [DateTime]::new(1970, 1, 1, 0, 0, 0);
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Databases.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[ActiveDirectory].[GetGroupLastWhenChangedTime]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;

        [Data.SqlClient.SqlDataReader] $SqlDataReader = $SqlCommand.ExecuteReader();
        While ($SqlDataReader.Read())
        {
            $Results = $SqlDataReader.GetDateTime(0);
            $Results = [DateTime]::SpecifyKind($Results, [System.DateTimeKind]::Utc);
        }
        [void] $SqlDataReader.Close();
        [void] $SqlDataReader.Dispose();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.Databases.ActiveDirectory `
    -Name "ImportUser" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $UserJSON
        )
        [Collections.ArrayList] $Results = [Collections.ArrayList]::new();
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Databases.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[ActiveDirectory].[ImportUser]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        [Data.SqlClient.SqlParameter] $SqlParameter_UserJSON = $SqlCommand.CreateParameter();
        $SqlParameter_UserJSON.ParameterName = "UserJSON";
        $SqlParameter_UserJSON.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_UserJSON.Size = (-1);
        $SqlParameter_UserJSON.SqlValue = $UserJSON;
        [void] $SqlCommand.Parameters.Add($SqlParameter_UserJSON);

        [void] $SqlCommand.ExecuteNonQuery();

        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.Databases.ActiveDirectory `
    -Name "ImportGroup" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $GroupJSON
        )
        [Collections.ArrayList] $Results = [Collections.ArrayList]::new();
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Databases.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[ActiveDirectory].[ImportGroup]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        [Data.SqlClient.SqlParameter] $SqlParameter_GroupJSON = $SqlCommand.CreateParameter();
        $SqlParameter_GroupJSON.ParameterName = "GroupJSON";
        $SqlParameter_GroupJSON.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_GroupJSON.Size = (-1);
        $SqlParameter_GroupJSON.SqlValue = $GroupJSON;
        [void] $SqlCommand.Parameters.Add($SqlParameter_GroupJSON);

        [void] $SqlCommand.ExecuteNonQuery();

        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.Databases.ActiveDirectory `
    -Name "ProcessManagerialChanges" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Databases.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[ActiveDirectory].[ProcessManagerialChanges]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        $SqlCommand.CommandTimeout = 0;
        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.ActiveDirectory `
    -Name "ProcessGroupMembershipChanges" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Databases.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[ActiveDirectory].[ProcessGroupMembershipChanges]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        $SqlCommand.CommandTimeout = 0;
        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.ActiveDirectory `
    -Name "ProcessGroupManagerChanges" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Databases.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[ActiveDirectory].[ProcessGroupManagerChanges]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        $SqlCommand.CommandTimeout = 0;
        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.ActiveDirectory `
    -Name "RebuildIndexes" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName
        )
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Databases.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[ActiveDirectory].[RebuildIndexes]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        $SqlCommand.CommandTimeout = 0;
        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
