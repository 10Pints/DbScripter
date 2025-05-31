SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================================
-- Author:      Terry Watts
-- Create date: 28-JUN-2023
-- Description: tidies up staging 2 after import and copy s1-s2
--
-- Use this to correct common pathogen sp errors and amend names that have 'and' in them
-- eg: replace perrenial -> perennial  
-- Annual and perrenial broadleaf weeds and grasses 
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
ALTER PROCEDURE [dbo].[sp_pre_fixup_s2]
       @fixup_cnt            INT OUTPUT
AS
BEGIN
   DECLARE
       @fn                    VARCHAR(35)  = N'PRE_FIXUP_S2'
      ,@rc                    INT
      ,@cnt                   INT =0
      ,@default_fld_val_dash  VARCHAR(15)  = '--'

   SET NOCOUNT OFF;

   /***************************************************************
   *                                                              *
   * DO NOT DELETE TILL THIS FUNCTIONALITY HAS BEEN DATA DRIVEN   *
   *                                                              *
   ****************************************************************/

   BEGIN TRY
   /*
      --SET @fixup_cnt = dbo.fnGetSessionContextAsInt(N'fixup count');
      EXEC sp_log 1, @fn, '000: starting, @fixup_cnt: ', @fixup_cnt;
      EXEC sp_register_call @fn;

      EXEC sp_log 1, @fn, '010: pathogens: trim [] brackets, @fixup_cnt: ', @fixup_cnt;
      UPDATE dbo.staging2 SET pathogens = REPLACE(pathogens, '[, ]', ', ') WHERE pathogens LIKE '%[, ]%';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      */
   /***************************************************************
   *                                                              *
   * DO NOT DELETE TILL THIS FUNCTIONALITY HAS BEEN DATA DRIVEN   *
   *                                                              *
   ****************************************************************/
      EXEC sp_log 1, @fn, '020: calling sp_fixup_s2_products';
      EXEC sp_pre_fixup_s2_products_deprecated @fixup_cnt = @fixup_cnt OUT;

      -- fixup pathogens
      EXEC sp_log 1, @fn, '030: calling sp_fixup_s2_pathogens';
      EXEC sp_pre_fixup_s2_pathogens_deprecated @fixup_cnt = @fixup_cnt OUT;

      -- Fixup the ingredient/chemical column
      EXEC sp_log 1, @fn, '040: calling sp_fixup_s2_chems';
      EXEC sp_pre_fixup_s2_chems_deprecated @fixup_cnt = @fixup_cnt OUT;

      -- Fixup crops
      EXEC sp_log 1, @fn, '050: calling sp_fixup_s2_crops';
      EXEC sp_pre_fixup_s2_crops_deprecated @must_update = 0, @fixup_cnt = @fixup_cnt OUT;

      -- Fixup uses
      EXEC sp_log 1, @fn, '060: calling sp_fixup_s2_uses';
      EXEC sp_pre_fixup_s2_uses_deprecated @fixup_cnt = @fixup_cnt OUT;

      -- Fixup entry_mode
      EXEC sp_log 1, @fn, '070: calling sp_fixup_s2_action_general';
      EXEC sp_pre_fixup_s2_action_general  @fixup_cnt = @fixup_cnt OUT;

      EXEC sp_log 1, @fn, '080: calling sp_fixup_s2_action_specific';
      EXEC sp_pre_fixup_s2_action_specific_deprecated @fixup_cnt = @fixup_cnt OUT;

      -- Fixup MRL
      EXEC sp_log 1, @fn, '090: calling @fixup_cnt';
      EXEC  sp_pre_fixup_s2_mrl_deprecated @fixup_cnt = @fixup_cnt OUT;

      -- Fixup phi
      EXEC sp_log 1, @fn, '100: calling sp_fixup_s2_phi';
      EXEC sp_pre_fixup_s2_phi @fixup_cnt = @fixup_cnt OUT;

      -- Fixup Company
      EXEC sp_log 1, @fn, '110: calling sp_fixup_s2_company';
      EXEC sp_pre_fixup_s2_company @fixup_cnt = @fixup_cnt OUT;

      -- Fixup the actions / entry mode
      EXEC sp_log 1, @fn, '120: calling sp_fixup_s2_actions';
   /***************************************************************
   *                                                              *
   * DO NOT DELETE TILL THIS FUNCTIONALITY HAS BEEN DATA DRIVEN   *
   *                                                              *
   ****************************************************************/
      --EXEC sp_pre_fixup_s2_action @fixup_cnt = @fixup_cnt OUT;

      -- Fixup rate

      -- Fixup reentry
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   --EXEC sp_set_session_context N'fixup count', @fixup_cnt;
   EXEC sp_log 1, @fn, '999: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
EXEC sp_copy_s3_s2
EXEC sp_fixup_s2
*/

GO
