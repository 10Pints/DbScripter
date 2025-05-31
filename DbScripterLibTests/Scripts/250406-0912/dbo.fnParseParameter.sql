SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================================
-- Author:      Terry watts
-- Create date: 08-OCT-2024
-- Description: splits out the filter parameters 
--    into name, operator, value, is char type
--
-- CALLED BY: sp_list_items a helper rtn for fixing LRAP import errors
-- ==========================================================================
ALTER   FUNCTION [dbo].[fnParseParameter]
(
    @table     VARCHAR(60)
   ,@filters   VARCHAR(4000)
)
RETURNS 
@t TABLE 
(
    table_nm   VARCHAR(60)
   ,clause     VARCHAR(200)
   ,field      VARCHAR(60)
   ,val        VARCHAR(255)
   ,is_char_ty BIT
   ,ordinal    INT
   ,operator   VARCHAR(10)
)
AS
BEGIN
   INSERT INTO @t(table_nm,clause,is_char_ty,ordinal)
   SELECT DISTINCT 
       @table                       AS table_nm
      ,val                          AS clause
      ,dbo.fnIsTextType(DATA_TYPE)  AS is_char_ty
      ,ordinal
   FROM dbo.fnSplitKeys(@filters, '|') x LEFT JOIN INFORMATION_SCHEMA.Columns sc
   ON SUBSTRING(LTRIM(val), 1, CHARINDEX(' ', LTRIM(val))-1) = sc.COLUMN_NAME;

   UPDATE @t SET clause = LTRIM(clause);
   UPDATE @t SET 
       field = SUBSTRING(clause, 1, CHARINDEX(' ', clause)-1)
      ,val   = SUBSTRING(clause, CHARINDEX(' ', clause)+1, dbo.fnLen(clause) - CHARINDEX(' ', clause))
      ,operator = CASE 
         WHEN CHARINDEX('=',    clause) >0 THEN '='
         WHEN CHARINDEX('<>',   clause) >0 THEN '<>'
         WHEN CHARINDEX('LIKE', clause) >0 THEN 'LIKE'
         ELSE '????'
      END;

   UPDATE @t SET val = CASE 
         WHEN CHARINDEX('=',    clause) >0 THEN LTRIM(SUBSTRING(clause, CHARINDEX('=',    clause)+1, dbo.fnLen(clause)))
         WHEN CHARINDEX('<>',   clause) >0 THEN LTRIM(SUBSTRING(clause, CHARINDEX('<>',   clause)+3, dbo.fnLen(clause)))
         WHEN CHARINDEX('LIKE', clause) >0 THEN LTRIM(SUBSTRING(clause, CHARINDEX('LIKE', clause)+5, dbo.fnLen(clause)))
         ELSE '????'
         END;

   UPDATE @t SET val =REPLACE(val, '"', '''');
   --UPDATE @t SET val = iif(is_char_ty=1, CONCAT('''', val, ''''), val);
   RETURN;
END
/*
SELECT * FROM dbo.fnParseParameter('Staging2', 'pathogens:LIKE "%Beanfly%"| pathogens:= "Leafhopper"| pathogens:<> "Leafhoppers"') ORDER BY ordinal;

--------------------------------------------------------------------------------------------------
SELECT 
 CONCAT('[',table_nm,']') AS table_nm
,CONCAT('[',clause,']') AS clause
,CONCAT('[',field,']') AS field
,CONCAT('[',val,']') AS val
,CONCAT('[',is_char_ty,']') AS is_char_ty
,CONCAT('[',operator,']') AS operator
FROM dbo.fnParseParameter('Staging2', 'pathogens:LIKE "%Beanfly%", pathogens:= "Leafhopper", pathogens:<> "Leafhoppers"');

['Leafhoppers']
['Leafhopper']
['%Beanfly%']

Staging2   pathogens :  LIKE  " %Beanfly% "   pathogens    ' %Beanfly% '   1   LIKE
--------------------------------------------------------------------------------------------------
*/


GO
