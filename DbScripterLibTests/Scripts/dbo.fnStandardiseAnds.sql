SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================================
-- Author:      Terry Watts
-- Create date: 04-JUL-2023
-- Description: standardises (replaces) combinations of & and space -> ' and'
-- ===============================================================================
CREATE   FUNCTION [dbo].[fnStandardiseAnds] (@s VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
   DECLARE @r VARCHAR(MAX)

   -- Add the T-SQL statements to compute the return value here
   RETURN REPLACE(REPLACE(REPLACE(REPLACE(@s, '& ', '&'), '& ', '&'), ' &', '&' ), '&', ' and ');
END
/*
Print CONCAT('[',dbo.fnStanardiseAnds('AB & CDE and FG&HIJ &KLM&NOP'),']');
Print CONCAT('[',dbo.fnStanardiseAnds('')                        ,']');
Print CONCAT('[',dbo.fnStanardiseAnds(NULL)                      ,']');
Print CONCAT('[',dbo.fnStanardiseAnds('&')                      ,']');
*/


GO
