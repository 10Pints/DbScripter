SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 23-MAR-2024
-- Description: this returns any pathogens in S1 or S2 that match the @pathFilter
--              NB: use % etc in the parameter as parameter is not wrapped in % by this routine
--
-- CHANGES:
-- ======================================================================================================
CREATE   FUNCTION [dbo].[fnListMatchingS12Pathogens]
(
   @pathFilter VARCHAR(200)
)
RETURNS table
AS RETURN
   SELECT id,s1_pathogens, s2_pathogens
   FROM s12_vw
   WHERE
      s1_pathogens LIKE @pathFilter
   OR s2_pathogens LIKE @pathFilter;

/*
SELECT * FROM dbo.fnListMatchingS12Pathogens('%Brown leafhopper%')
*/


GO
