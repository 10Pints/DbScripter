SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ================================================================
-- Author:      Terry Watts
-- Create date: 22-OCT-20223
-- Description: List the individual entry modes and the id
--          from Staging2             
-- ================================================================
ALTER   FUNCTION [dbo].[fnListChemicalActions]()
RETURNS 
@t TABLE (chemical_nm VARCHAR(100), action_nm VARCHAR(50))
AS
BEGIN
   INSERT INTO @t(chemical_nm, action_nm)
      SELECT DISTINCT TOP 100000
          i.value  AS ingredient
         , a.value AS [action]
      FROM Staging2 
      CROSS APPLY string_split(ingredient, '+') i
      CROSS APPLY string_split(entry_mode, ',') a
      ORDER BY ingredient, [action]
   RETURN 
END
/*
SELECT distinct chemical_nm from dbo.fnListS2_ChemicalActions(); -- 315 rows
-- WHERE chemical_nm = 'Chlorothalonil';
*/


GO
