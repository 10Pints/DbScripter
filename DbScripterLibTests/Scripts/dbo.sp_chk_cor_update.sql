SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2024
-- Description: helper when tracking Cor update issues
--
-- CHANGES:
-- ======================================================================================================
CREATE PROC [dbo].[sp_chk_cor_update]
   @pathogen NVARCHAR(400)
AS
BEGIN
   DECLARE
       @cmd NVARCHAR(2000)
      ,@ids NVARCHAR(4000) -- comma separated list of stg2_id
   -------------------------------------------------------------
   -- get and display the list of S2 rows that have this pathogen
   -------------------------------------------------------------
   SELECT @ids=string_agg(id, ',') FROM dbo.fnListPathogens2() WHERE pathogen = @pathogen;
   PRINT CONCAT( 'S2 ids: ', @ids);

   SELECT @pathogen as pathogen, @ids AS [s2 ids************************************************************************************************************************]
;

   EXEC sp_ListPathogenUpdateLogChangesForS2Ids @ids;
   SELECT pathogen_nm as [pathogen table nm] from Pathogen WHERE pathogen_nm = @pathogen;
   SELECT stg2_id, s1_pathogens as [original s1 id], s2_pathogens as [updated pathogens] 
   FROM s12_vw where s2_pathogens like CONCAT('%',@pathogen,'%') OR s1_pathogens like CONCAT('%',@pathogen,'%');
   SELECT id as [ImportCorrections id], search_clause, replace_clause FROM ImportCorrections WHERE search_clause LIKE CONCAT('%',@pathogen,'%') OR replace_clause LIKE CONCAT('%',@pathogen,'%');
   EXEC sp_ListPathogenUpdateLogCorIdsForS2Ids @ids;
   SELECT stg2_id, s1_pathogens, s2_pathogens, s2_crops  FROM s12_vw where s2_pathogens like CONCAT('%',@pathogen,'%');
END
/*
EXEC sp_chk_cor_update 'Looper';
EXEC sp_ListPathogenUpdateLogChangesForS2Ids '159,159,903,913,914,951'
SELECT * FROM ImportCorrections where id in (162,162,906,916,917,917,954)
*/

GO
