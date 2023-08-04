CREATE OR ALTER FUNCTION [DatesAndTimes].[GetDecimalDateTime]
(
	@DateTime [datetime2](0)
)
RETURNS [decimal](32, 27)
AS
BEGIN
	RETURN (1.0)
END