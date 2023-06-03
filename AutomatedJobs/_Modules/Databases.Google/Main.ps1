Add-Member `
    -InputObject $Global:Job.Databases `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "Google" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
    Add-Member `
    -InputObject $Global:Job.Databases.Google `
    -Name "ImportOrganizationalUnit" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Collections.ArrayList])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $ConnectionName,

            [Parameter(Mandatory=$true)]
            [String] $OrgUnitJSON
        )
        [Collections.ArrayList] $Results = [Collections.ArrayList]::new();
        [Data.SqlClient.SqlConnection] $SqlConnection = [Data.SqlClient.SqlConnection]::new($Global:Job.Databases.GetSQLServerConnection($ConnectionName));
        [void] $SqlConnection.Open();
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[Google].[ImportOrganizationalUnit]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        [Data.SqlClient.SqlParameter] $SqlParameter_OrgUnitJSON = $SqlCommand.CreateParameter();
        $SqlParameter_OrgUnitJSON.ParameterName = "OrgUnitJSON";
        $SqlParameter_OrgUnitJSON.SqlDbType = [Data.SqlDbType]::NVarChar;
        $SqlParameter_OrgUnitJSON.Size = (-1);
        $SqlParameter_OrgUnitJSON.SqlValue = $OrgUnitJSON;
        [void] $SqlCommand.Parameters.Add($SqlParameter_OrgUnitJSON);

        [void] $SqlCommand.ExecuteNonQuery();

        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
        Return $Results;
    };
Add-Member `
    -InputObject $Global:Job.Databases.Google `
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
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[Google].[ImportUser]", $SqlConnection);
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
    -InputObject $Global:Job.Databases.Google `
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
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[Google].[ImportGroup]", $SqlConnection);
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
    -InputObject $Global:Job.Databases.Google `
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
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[Google].[ProcessManagerialChanges]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        $SqlCommand.CommandTimeout = 0;
        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.Google `
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
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[Google].[ProcessGroupMembershipChanges]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        $SqlCommand.CommandTimeout = 0;
        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.Google `
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
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[Google].[ProcessGroupManagerChanges]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        $SqlCommand.CommandTimeout = 0;
        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
Add-Member `
    -InputObject $Global:Job.Databases.Google `
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
        [Data.SqlClient.SqlCommand] $SqlCommand = [Data.SqlClient.SqlCommand]::new("[Google].[RebuildIndexes]", $SqlConnection);
        $SqlCommand.CommandType = [Data.CommandType]::StoredProcedure;
        $SqlCommand.CommandTimeout = 0;
        [void] $SqlCommand.ExecuteNonQuery();
        [void] $SqlCommand.Dispose();
        [void] $SqlConnection.Close();
        [void] $SqlConnection.Dispose();
    };
