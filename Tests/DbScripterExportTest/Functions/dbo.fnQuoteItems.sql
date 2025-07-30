SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry watts
-- Create date: 30-MAR-2020
-- Description: returns the comma sep list wrapped in quotes
-- like so: 
-- INPUT:  'a,b,c,d,e,f';
-- OUTPUT: 'a','b','c','d','e','f'
-- ===============================================================
CREATE FUNCTION [dbo].[fnQuoteItems](@s VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
   DECLARE @t VARCHAR(MAX);
   SELECT @t = CONCAT('''', string_agg(value, ''','''),'''') FROM string_split(@s, ',');
   RETURN @t
END
/*
PRINT fnQuoteItems('a,b,c,d,e,f');
*/
GO

