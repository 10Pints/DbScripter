SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================================
-- Author:      Terry Watts
-- Create date: 14-MAR-2024
-- Description: utility function to call S12_vw - use when correcting imports
-- this performs approximate matches
--
-- see also: fnVwS12PathogensExact for exact matches
-- ======================================================================================================================
ALTER FUNCTION[dbo].[fnVwS12Pathogens](@clause VARCHAR(4000))
RETURNS TABLE
AS RETURN
   SELECT TOP 100 id,s2_pathogens, s2_crops, s1_crops,s1_pathogens
   FROM S12_vw 
   WHERE
      s2_pathogens = @clause                          -- single pathogen match
   OR s2_pathogens LIKE CONCAT(@clause, ',%')         -- beginning of field
   OR s2_pathogens LIKE CONCAT('%,', @clause, ',%')   -- mid field
   OR s2_pathogens LIKE CONCAT('%,', @clause)         -- end of field
   OR s2_pathogens LIKE CONCAT('%', @clause, '%')         -- end of field
   OR s1_pathogens = @clause                          -- single pathogen match
   OR s1_pathogens LIKE CONCAT(@clause, ',%')         -- beginning of field
   OR s1_pathogens LIKE CONCAT('%,', @clause, ',%')   -- mid field
   OR s1_pathogens LIKE CONCAT('%,', @clause)         -- end of field
   OR s1_pathogens LIKE CONCAT('%', @clause, '%')         -- end of field
   ;

/*
--Itchgrasses,Field bindweed,Cinderella weed,Buttonweed,Spindletop,Calopo,Hairy beggarticks,Tropical whiteweed
SELECT * FROM dbo.fnVwS12Pathogens('Itchgrasses');
SELECT id, crops,pathogens FROM Staging2 WHERE pathogens like '%Itchgrasses%';
SELECT id,s1_pathogens,s2_pathogens, s1_crops FROM S12_vw WHERE s2_pathogens like '%Itchgrasses%';
Itchgrasses,Field bindweed,Cinderella weed,Buttonweed,Spindletop,Calopo,Hairy beggarticks,Tropical whiteweed
DECLARE @clause VARCHAR(1000) = 'Itchgrasses';
SELECT TOP 100 id,s1_pathogens,s2_pathogens, s1_crops, s2_chemical, s1_chemical, s1_uses
FROM S12_vw 
WHERE
   s2_pathogens = @clause                          -- single pathogen match
OR s2_pathogens LIKE CONCAT(@clause, ',%')         -- beginning of field
OR s2_pathogens LIKE CONCAT('%,', @clause, ',%')   -- mid field
OR s2_pathogens LIKE CONCAT('%,', @clause)         -- end of field
;
*/

GO
