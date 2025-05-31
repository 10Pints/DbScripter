SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:		 Terry Watts
-- Create date: 16-NOV-2023
-- Description: List the Pathogens in order - 
-- from Stging1, 
-- This rtn is like fnListPathogens which operates on Staging2
-- 
-- ===========================================================
ALTER FUNCTION [dbo].[fnListPathogensS1]()
RETURNS 
@t TABLE (pathogen NVARCHAR(400))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 100000 
   cs.value AS pathogen 
   FROM Staging1 
   CROSS APPLY string_split(pathogens, ',') cs
   WHERE cs.value <> ''
   ORDER BY pathogen;

   RETURN 
END
/*
SELECT pathogen from dbo.fnListPathogensS1()
*/

GO
