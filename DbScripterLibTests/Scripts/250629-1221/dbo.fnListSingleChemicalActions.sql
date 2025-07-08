SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================================
-- Author:      Terry Watts
-- Create date: 22-OCT-20223
-- Description: List the individual entry modes and the id
--          from Staging2             
-- ================================================================
CREATE   FUNCTION [dbo].[fnListSingleChemicalActions]()
RETURNS 
@t TABLE (chemical_nm VARCHAR(100), action_nm VARCHAR(50))
AS
BEGIN
   INSERT INTO @t(chemical_nm, action_nm)
      SELECT DISTINCT TOP 100000
      ingredient, a.value as [action] -- i.value as ingredient, 
      FROM Staging2 
      --CROSS APPLY string_split(ingredient, '+') i
      CROSS APPLY string_split(entry_mode, ',') a
      WHERE ingredient NOT LIKE '%+%'   -- single ingredients only
      ORDER BY ingredient, [action]
   RETURN 
END
/*
SELECT * from dbo.fnListS2_SingleChemicalActions()
WHERE chemical_nm = 'Chlorothalonil';

SELECT DISTINCT
*/


GO
