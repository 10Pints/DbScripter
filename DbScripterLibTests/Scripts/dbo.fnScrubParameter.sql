SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================================
-- Author:		 Terry Watts
-- Create date: 05-JUL-2023
-- Description: trims whitespace and sets to NULL if trimmed clause is empty
--              Trims [] as well
-- ===============================================================================
ALTER FUNCTION [dbo].[fnScrubParameter] (@clause NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @ret NVARCHAR(MAX)

	-- Add the T-SQL statements to compute the return value here
	SET @ret = Ut.dbo.fnTrim(@clause); 
	SET @ret = Ut.dbo.fnTrim2(@clause, '['); 
	SET @ret = Ut.dbo.fnTrim2(@clause, ']'); 
	SET @ret = Ut.dbo.fnTrim(@clause); 
   IF Ut.dbo.fnLen(@ret) = 0 SET @ret = NULL;

   RETURN @ret;
END
/*
Print CONCAT('[',dbo.fnStanardiseAnds('AB & CDE and FG&HIJ &KLM&NOP'),']');
Print CONCAT('[',dbo.fnStanardiseAnds('')                        ,']');
Print CONCAT('[',dbo.fnStanardiseAnds(NULL)                      ,']');
Print CONCAT('[',dbo.fnStanardiseAnds('&')                      ,']');
*/

GO
