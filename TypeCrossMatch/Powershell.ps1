Function Get-TypeCrossMatchFromSQLServerType()
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param (
        [Parameter()]
        [String] $SQLServerTypeName
    )
    [PSObject] $ReturnValue = [PSObject]::new();
    Switch ($SQLServerTypeName)
    {
        "bigint"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "bigint";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlInt64];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Int64];
        }
        "binary"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "binary";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlBytes];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Byte$null];
        }
        "bit"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "bit";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlBoolean];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Boolean];
        }
        "char"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "char";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlChars];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Char$null];
        }
        "cursor"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "cursor";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value $null;
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value $null;
        }
        "date"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "date";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlDateTime];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.DateTime];
        }
        "datetime"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "datetime";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlDateTime];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.DateTime];
        }
        "datetime2"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "datetime2";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlDateTime];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.DateTime];
        }
        "datetimeoffset"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "datetimeoffset";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value $null;
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.DateTimeOffset];
        }
        "decimal"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "decimal";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlDecimal];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Decimal];
        }
        "float"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "float";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlDouble];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Double];
        }
        "geography"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "geography";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlGeography];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value $null;
        }
        "geometry"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "geometry";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlGeometry];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value $null;
        }
        "hierarchyid"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "hierarchyid";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlHierarchyId];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value $null;
        }
        "image"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "image";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlBinary];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Byte$null];
        }
        "int"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "int";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlInt32];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Int32];
        }
        "money"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "money";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlMoney];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Decimal];
        }
        "nchar"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "nchar";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlChars];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Char$null];
        }
        "ntext"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "ntext";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlString];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.String];
        }
        "numeric"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "numeric";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlDecimal];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Decimal];
        }
        "nvarchar"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "nvarchar";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlString];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.String];
        }
        "real"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "real";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlSingle];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Single];
        }
        "rowversion"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "rowversion";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value $null;
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Byte$null];
        }
        "smallint"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "smallint";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlInt16];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Int16];
        }
        "smallmoney"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "smallmoney";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlMoney];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Decimal];
        }
        "sql_variant"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "sql_variant";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value $null;
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Object];
        }
        "table"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "table";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value $null;
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value $null;
        }
        "text"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "text";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlString];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.String];
        }
        "time"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "time";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value $null;
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.TimeSpan];
        }
        "timestamp"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "timestamp";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlBinary];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Byte$null];
        }
        "tinyint"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "tinyint";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlByte];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Byte];
        }
        "uniqueidentifier"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "uniqueidentifier";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlGuid];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Guid];
        }
        "varbinary"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "varbinary";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlBytes, SqlBinary];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.Byte$null];
        }
        "varchar"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "varchar";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlString];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value [System.String];
        }
        "xml"
        {
            Add-Member -InputObject $ReturnValue -TypeName "String"  -MemberType NoteProperty -Name "SQLServerType" -Value "xml";
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "SqlType" -Value [System.Data.SqlTypes.SqlXml];
            Add-Member -InputObject $ReturnValue -TypeName "System.Type"  -MemberType NoteProperty -Name "CLRType" -Value $null;
        }
        Default
        {
            $ReturnValue = $null;
        }
    }
    Return $ReturnValue;
}

Clear-Host;
Get-TypCrossMatchFromSQLServerType -SQLServerTypeName "nvarchar";
