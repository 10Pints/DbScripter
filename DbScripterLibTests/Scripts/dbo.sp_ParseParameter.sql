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
CREATE   PROCEDURE [dbo].[sp_ParseParameter]

    @table     VARCHAR(60)
   ,@filters   VARCHAR(4000)
AS
BEGIN
   DECLARE
    @fn              VARCHAR(30)  = N'ParseParameter'

   CREATE TABLE #t
   (
       table_nm   VARCHAR(60)
      ,clause     VARCHAR(200)
      ,field      VARCHAR(60)
      ,val        VARCHAR(255)
      ,is_char_ty BIT
      ,ordinal    INT
      ,operator   VARCHAR(10)
   )

      EXEC sp_log 1, @fn, '000: starting
table      :[', @table  , ']
filters    :[', @filters, ']'
;

   EXEC sp_log 1, @fn, '010: pop #t with  table_nm,clause,is_char_ty,ordinal';
   INSERT INTO #t(table_nm,clause,is_char_ty,ordinal)
   SELECT DISTINCT 
       @table                       AS table_nm
      ,val                          AS clause
      ,dbo.fnIsTextType(DATA_TYPE)  AS is_char_ty
      ,ordinal
   FROM dbo.fnSplitKeys(@filters, '|') x LEFT JOIN INFORMATION_SCHEMA.Columns sc
   ON SUBSTRING(LTRIM(val), 1, CHARINDEX(' ', LTRIM(val))-1) = sc.COLUMN_NAME;

   EXEC sp_log 1, @fn, '020: update #t, L trim clause wsp';
   UPDATE #t SET clause = LTRIM(clause);

   EXEC sp_log 1, @fn, '030: update #t, pop field,val,operator';
   UPDATE #t SET 
       field = SUBSTRING(clause, 1, CHARINDEX(' ', clause)-1)
      ,val   = SUBSTRING(clause, CHARINDEX(' ', clause)+1, dbo.fnLen(clause) - CHARINDEX(' ', clause))
      ,operator = CASE 
         WHEN CHARINDEX('=',    clause) >0 THEN '='
         WHEN CHARINDEX('<>',   clause) >0 THEN '<>'
         WHEN CHARINDEX('LIKE', clause) >0 THEN 'LIKE'
         ELSE '????'
      END;

   EXEC sp_log 1, @fn, '040: update #t, val based on operator';
   UPDATE #t SET val = CASE 
         WHEN CHARINDEX('=',    clause) >0 THEN LTRIM(SUBSTRING(clause, CHARINDEX('=',    clause)+1, dbo.fnLen(clause)))
         WHEN CHARINDEX('<>',   clause) >0 THEN LTRIM(SUBSTRING(clause, CHARINDEX('<>',   clause)+3, dbo.fnLen(clause)))
         WHEN CHARINDEX('LIKE', clause) >0 THEN LTRIM(SUBSTRING(clause, CHARINDEX('LIKE', clause)+5, dbo.fnLen(clause)))
         ELSE '????'
         END;

   EXEC sp_log 1, @fn, '050: update #t, REPLACE " with '''' '''' on val';
   UPDATE #t SET val =REPLACE(val, '"', '''');

   SELECT * FROM #t ORDER BY ordinal;
   EXEC sp_log 1, @fn, '999: leaving, OK';
END
/*
EXEC sp_ParseParameter 'Staging2', 'pathogens:LIKE "butt"|pathogens:LIKE "butt%"|pathogens:LIKE "%butt"|pathogens:LIKE "%,butt%"';

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
