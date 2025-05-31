SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date10-JANL-2024
-- Description: Caches a copy of Staging2 to Staging4
--    Do after any stage once S2 is populated
--    To help with evolving the Pathogen corrections
--
-- CHANGES:
-- ==============================================================================
ALTER PROCEDURE [dbo].[sp_cpy_s2_s4]
AS
BEGIN
   DECLARE
       @fn           VARCHAR(35)  = N'CPY_S2_S4'

   SET NOCOUNT OFF;
   EXEC sp_log 2, @fn,'00: Caching COPYING staging2 to staging4 (backup) starting';

   TRUNCATE TABLE staging4;
  -- SET IDENTITY_INSERT staging4 ON;

   INSERT INTO dbo.staging4
   (
       id
      ,company
      ,ingredient
      ,product
      ,concentration
      ,formulation_type
      ,uses
      ,toxicity_category
      ,registration
      ,expiry
      ,entry_mode
      ,crops
      ,pathogens
      ,rate
      ,mrl
      ,phi
      ,phi_resolved
      ,reentry_period
      ,notes
      ,comments
   )
   SELECT
       id
      ,company
      ,ingredient
      ,product
      ,concentration
      ,formulation_type
      ,uses
      ,toxicity_category
      ,registration
      ,expiry
      ,entry_mode
      ,crops
      ,pathogens
      ,rate
      ,mrl
      ,phi
      ,phi_resolved
      ,reentry_period
      ,notes
      ,Comments
     FROM Staging2;

 --  SET IDENTITY_INSERT staging4 OFF;
   EXEC sp_log 2, @fn,'99: leaving: OK';
END
/*
EXEC sp_copy_s2_s4
*/

GO
