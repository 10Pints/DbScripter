SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================================
-- Author:      Terry Watts
-- Create date: 05-JUL-2023
-- Description: trims whitespace and sets to NULL if trimmed clause is empty
--              Trims [] as well
-- ===============================================================================
ALTER FUNCTION [dbo].[fnScrubParameter] (@clause NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
   -- Add the T-SQL statements to compute the return value here
--   SET @clause = TRIM(@clause);
   SET @clause = TRIM('[] ' FROM @clause);
--   SET @clause = dbo.fnTrim2(@clause, ']');
--   SET @clause = TRIM(@clause);
   IF dbo.fnLen(@clause) = 0 SET @clause = NULL;

   RETURN @clause;
END
/*
Print CONCAT(dbo.fnScrubParameter(' [ ]AB & CDE and FG&HIJ &KLM&NOP [ ] '),'****');
Print CONCAT('[',dbo.fnScrubParameter('')                        ,']');
Print CONCAT('[',dbo.fnScrubParameter(NULL)                      ,']');
Print CONCAT('[',dbo.fnScrubParameter('&')                      ,']');
*/

GO
