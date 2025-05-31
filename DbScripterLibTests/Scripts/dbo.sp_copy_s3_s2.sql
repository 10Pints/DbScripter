SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 09-JUL-2023
-- Description: Restores Staging2 from Staging3 cache.
-- ===============================================================
ALTER PROCEDURE [dbo].[sp_copy_s3_s2]
AS
BEGIN
   DECLARE @fn NVARCHAR(35)  = N'CPY_S3_S2'
   EXEC sp_log 1, @fn, 'starting'
   SET NOCOUNT OFF;

   TRUNCATE TABLE Staging2;

   INSERT INTO [dbo].[Staging2]
   (
       stg2_id
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
      ,comment
    )
    SELECT 
       stg_id
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
      ,comment
   FROM Staging3;

   EXEC sp_log 1, @fn, 'leaving ok'
END
/*
EXEC  sp_copy_s3_s2
*/

GO
