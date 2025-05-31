SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2024
-- Description: returns the chnges made to S2 during XL fixup for the given set of ids
--
-- CHANGES:
-- ======================================================================================================
CREATE PROC [dbo].[sp_ListPathogenUpdateLogChangesForS2Ids]
   @s2_ids NVARCHAR(400) -- comma separated list o6 stg2_id
AS
BEGIN
   DECLARE @cmd NVARCHAR(2000)

   IF @s2_ids IS NOT NULL
   BEGIN
   SET @cmd = CONCAT('SELECT s.id, s.fixup_id,row_cnt,search_clause,replace_clause,s1.pathogens as [original], L.stg2_id,L.old_pathogens, L.new_pathogens, s2.crops
   FROM S2UpdateSummary s 
   LEFT JOIN S2Updatelog L ON s.fixup_id=L.fixup_id
   LEFT join Staging2 s2 ON s2.stg2_id = L.stg2_id
   LEFT join Staging1 s1 ON s1.stg1_id = L.stg2_id
   WHERE L.stg2_id IN (', ut.dbo.fnTrim2(SUBSTRING(@s2_ids,1,400), ','),') ORDER BY s.fixup_id, L.stg2_id;');
   END
   ELSE
   SELECT 'No changes found';

   PRINT @cmd;
   EXEC (@cmd);
END
/*
EXEC sp_ListPathogenUpdateLogChangesForS2Ids '7976';
EXEC sp_ListPathogenUpdateLogChangesForS2Ids '7976,5053,7976';
*/

GO
