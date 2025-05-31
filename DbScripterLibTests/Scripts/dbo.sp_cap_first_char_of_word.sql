SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================
-- Author:		 Terry watts
-- Create date: 07-JUL-2023
-- Description: Capitalise first character of the first word 
-- ===========================================================
ALTER PROCEDURE [dbo].[sp_cap_first_char_of_word]
AS
BEGIN
   -- pathogens: Capitalise first character of the first word 
   PRINT 'sp_cap_first_char_of_word pathogens: Capitalise first character of the first word  '
   UPDATE staging2 SET pathogens = agPathogens
   FROM staging2 s2 JOIN 
   (SELECT stg2_id, STRING_AGG( ut.dbo.fnInitialCap(cs.value), ',') as agPathogens
   FROM staging2
   CROSS APPLY string_split(pathogens, ',') cs
   GROUP BY stg2_id) X ON s2.stg2_id = X.stg2_id;
END
/*
EXEC sp_cap_first_char_of_word
SELECT * FROM s2vw;

*/

GO
