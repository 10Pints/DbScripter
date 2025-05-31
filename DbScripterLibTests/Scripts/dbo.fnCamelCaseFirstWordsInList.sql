SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================================================
-- Author:      Terry Watts
-- Create date: 06-JUL-2023
-- Description: Camel cases the first word in each comma separated item provided
-- ===================================================================================
ALTER FUNCTION [dbo].[fnCamelCaseFirstWordsInList]()
RETURNS 
@t TABLE 
(
   value NVARCHAR(MAX)
)
AS
BEGIN
INSERT INTO @t
(value)
SELECT DISTINCT ut.dbo.fnInitialCap( ut.dbo.fnTrim( cs.value)) AS pathogen
   FROM Staging2 
   CROSS APPLY string_split(pathogens, ',') cs
   WHERE  cs.value not in ('', ' ', '\t', '-')
   AND stg2_id <5

   RETURN
END
/*
SELECT * FROM [dbo].[fnCamelCaseFirstWordsInList]()
*/

GO
