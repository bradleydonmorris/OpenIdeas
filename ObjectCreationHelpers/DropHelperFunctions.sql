PRINT 'Dropping Helper Objects'
PRINT CONCAT(CHAR(9),N'Function: [dbo].[SchemaExists]')
DROP FUNCTION IF EXISTS [dbo].[SchemaExists]
PRINT CONCAT(CHAR(9),N'Function: [dbo].[TableExists]')
DROP FUNCTION IF EXISTS [dbo].[TableExists]
PRINT CONCAT(CHAR(9),N'Function: [dbo].[IndexExists]')
DROP FUNCTION IF EXISTS [dbo].[IndexExists]
PRINT CONCAT(CHAR(9),N'Function: [dbo].[GetIndexCreateStatement]')
DROP FUNCTION IF EXISTS [dbo].[GetIndexCreateStatement]
PRINT CONCAT(CHAR(9),N'Function: [dbo].[GetTableCreateStatement]')
DROP FUNCTION IF EXISTS [dbo].[GetTableCreateStatement]
