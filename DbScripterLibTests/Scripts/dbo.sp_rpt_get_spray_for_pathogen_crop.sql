SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================
-- Author:		 Terry Watts
-- Create date: 22-OCT-2023
-- Description: Reports the chemicals and products 
--    for a given crop and pathogen
-- ================================================================
ALTER PROCEDURE [dbo].[sp_rpt_get_spray_for_pathogen_crop] 
	 @pathogen  NVARCHAR(50)
	,@crop      NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
   SELECT * FROM fnRptGetCropsAffectedByPathogen(@pathogen);
END
/*
   EXEC sp_rpt_get_spray_for_pathogen_crop 'sigatoka'
   SELECT DISTINCT entry_mode FROM Staging2 ORDER BY entry_mode
   SELECT crops, pathogens, ingredient, entry_mode FROM Staging2 ORDER BY entry_mode
   SELECT crops, pathogens, entry_mode, ingredient FROM Staging2 WHERE entry_node = 'Contact/selective'
*/

GO
