SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 09-JUL-2023
-- Description: Restores Staging2 from Staging4 cache.
-- ===============================================================
CREATE PROCEDURE [dbo].[sp_cpy_s4_s2]
AS
BEGIN
   DECLARE @fn VARCHAR(35)  = N'CPY_S4_S2'

   SET NOCOUNT OFF;
   EXEC sp_log 1, @fn,'000: Uncaching S4 -> S1';

   TRUNCATE TABLE Staging2;
   DELETE FROM Staging1;
   SET IDENTITY_INSERT Staging1 ON;

   INSERT INTO [dbo].[Staging1]
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
      ,comments
   FROM Staging4;

   SET IDENTITY_INSERT Staging1 Off;
   EXEC sp_log 1, @fn,'010: Uncaching S4 -> S2';

   INSERT INTO [dbo].[Staging2]
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
      ,comments
   FROM Staging4;

   --SET IDENTITY_INSERT Staging2 Off;
   EXEC sp_assert_tbl_pop 'staging1', 1;
   EXEC sp_assert_tbl_pop 'staging2', 1;
   EXEC sp_log 1, @fn, 'leaving ok'
END
/*
EXEC  sp_copy_s4_s2;
*/

GO
