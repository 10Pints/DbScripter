SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================================
-- Author:      Terry Watts
-- Create date: 28-JUN-2023
-- Description: tidies up staging 2 after import and copy s1-s2
-- Remove:
-- the page header rows
-- wrapping quotes
-- standarise commas and &
-- 
-- CHANGES:
-- 06-JUL-2023 pathogens: replace and with ,
-- 06-JUL-2023 pathogens: standardise each pathogen in pathogens to capitalise first character of the first word
-- 22-OCT-2023 added ingredient fixup
-- ================================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2]
AS
BEGIN
   DECLARE
       @fn                    NVARCHAR(35)  = N'FIXUP_S2'
      ,@rc                    INT
      ,@cnt                   INT =0
      ,@default_fld_val_dash  NVARCHAR(15)  = '--'
      ,@fixup_cnt             INT

   SET NOCOUNT OFF;

   BEGIN TRY
      SET @fixup_cnt = Ut.dbo.fnGetSessionContextAsInt(N'fixup count');
      EXEC sp_log 1, @fn, '00: starting, @fixup_cnt: ', @fixup_cnt;
      EXEC sp_register_call @fn;

      EXEC sp_log 1, @fn, '01: pathogens: trim [] brackets, @fixup_cnt: ', @fixup_cnt;
      UPDATE dbo.staging2 SET pathogens = REPLACE(pathogens, '[, ]', ', ') WHERE pathogens LIKE '%[, ]%';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 1, @fn, '20: calling sp_fixup_s2_products';
      EXEC sp_fixup_s2_products @fixup_cnt = @fixup_cnt OUT;

      -- fixup pathogens
      EXEC sp_log 1, @fn, '30: calling sp_fixup_s2_pathogens';
      EXEC sp_fixup_s2_pathogens @fixup_cnt = @fixup_cnt OUT;

      -- Fixup the ingredient/chemical column
      EXEC sp_log 1, @fn, '40: calling sp_fixup_s2_chems';
      EXEC sp_fixup_s2_chems @fixup_cnt = @fixup_cnt OUT;

      -- Fixup crops
      EXEC sp_log 1, @fn, '50: calling sp_fixup_s2_crops';
      EXEC sp_fixup_s2_crops @must_update = 0, @fixup_cnt = @fixup_cnt OUT;

      -- Fixup uses
      EXEC sp_log 1, @fn, '60: calling sp_fixup_s2_uses';
      EXEC sp_fixup_s2_uses @fixup_cnt = @fixup_cnt OUT;

      -- Fixup entry_mode
      EXEC sp_log 1, @fn, '65: calling sp_fixup_s2_action_general';
      EXEC sp_fixup_s2_action_general  @fixup_cnt = @fixup_cnt OUT;

      EXEC sp_log 1, @fn, '70: calling sp_fixup_s2_action_specific';
      EXEC sp_fixup_s2_action_specific @fixup_cnt = @fixup_cnt OUT;

      -- Fixup MRL
      EXEC sp_log 1, @fn, '75: calling @fixup_cnt';
      EXEC  sp_fixup_s2_mrl @fixup_cnt = @fixup_cnt OUT;

      -- Fixup phi
      EXEC sp_log 1, @fn, '80: calling sp_fixup_s2_phi';
      EXEC sp_fixup_s2_phi @fixup_cnt = @fixup_cnt OUT;

      -- Fixup Company
      EXEC sp_log 1, @fn, '85: calling sp_fixup_s2_company';
      EXEC sp_fixup_s2_company @fixup_cnt = @fixup_cnt OUT;

      -- Fixup rate

      -- Fixup reentry
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_set_session_context N'fixup count', @fixup_cnt;
   EXEC sp_log 1, @fn, '999: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
EXEC sp_copy_s3_s2
EXEC sp_fixup_s2
*/

GO
