SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===================================================================================
-- Author:      Terry Watts
-- Create date: 26-JUN-2023
-- Description: Tidies up staging 1 after import so that it is comparable to staging2
--
-- RESPONSIBILITIES:
-- Remove:
-- the page header rows
-- wrapping quotes
-- standarise commas and &
-- spelling errors:
--    [Perrenial] -> [Perennial]
--
-- Error handling by exception handling
--
-- Preconditions: 
-- PRE 01: staging1 pop'd
--
-- returns 
--       (0 if success and @result_msg='') OR Error code and result_msg=error message
--
-- Postconditions:
-- POST 01: no occasional page headers as in LDAP 221008 version
-- POST 02: no wrapping quotes in the following fields {}         see sp_fixup_s1_preprocess
-- POST 03: no double quotes in flds: {company, ingredient, product, crops, entry_mode, pathogens, uses}
-- POST 04: no null fields tests in {company, ingredient, product, concentration, crops, formulation_type
--    uses, pathogens, toxicity_category, registrations, expiry dates, entry_modes)
-- POST 05: camel case the following fields {}                    see sp_fixup_s1_preprocess
-- POST 06: no double spaces in the following fields: {company, ingredient, product, crops, entry_mode, pathogens, uses}
-- POST 07: Fixup entry mode (Actions) issues                     see sp_fixup_s1_entry_mode
-- POST 08: Fixup Rate issues                                     see sp_fixup_s1_rate
-- POST 09: see sp_fixup_s1_chks
-- POST 10: no 'double and'
-- POST 11: no spelling errors
--
-- CHANGES:
-- 02-JUL-2023 Added CamelCase of various fields (for readability)
-- 04-JUL-2023 Added Stanardise Ands (for comparability with staging2)
-- 04-JUL-2023 Added Trim [] and double quotes
-- 04-JUL-2023 pathogens: á'
-- 16-JUL-2023 refactored
-- 21-JAN-2024 replace uses, 'Insecticide/fu ngicide' with 'Insecticide,fungicide'
-- ===================================================================================
CREATE PROCEDURE [dbo].[sp_fixup_s1]
   @fixup_cnt INT OUTPUT
AS
BEGIN
   DECLARE
       @fn              VARCHAR(30)   = 'sp_fixup_s1'
      ,@RC              INT            = 0
      ,@result_msg      VARCHAR(500)  = ''
      ,@cnt             INT            = 0
      ,@default_fld_val VARCHAR(15)   = '*** UNKNOWN ***'
      ,@sql             NVARCHAR(MAX)  = ''

   EXEC sp_log 2, @fn, '000: starting';

   ---------------------------------------------------------------------
   -- Validation
   ---------------------------------------------------------------------
   EXEC sp_log 2, @fn, '010: Validating parameters';
   EXEC sp_assert_not_null @fixup_cnt, '@fixup_cnt',@fn=@fn;

   -- PRE 01: staging1 pop'd
   EXEC sp_assert_tbl_pop 'staging1';

   ---------------------------------------------------------------------
   -- ASSERTION Validated parameters
   ---------------------------------------------------------------------
   EXEC sp_log 2, @fn, '020: ASSERTION: Validated parameters';

   IF @fixup_cnt IS NULL SET @fixup_cnt = dbo.fnGetSessionContextAsInt(N'fixup count');

   ---------------------------------------------------------------------
   -- Process
   ---------------------------------------------------------------------
   EXEC sp_log 1, @fn, '030: Process';
   EXEC sp_log 1, @fn, '040: removing occasional headers, calling: sp_fixup_s1_rem_hdrs';

   -- Remove occasional headers
   EXEC sp_fixup_s1_rem_hdrs @fixup_cnt OUT

   -- Std preprocess like removing wrapping quotes, camel case etc.
   EXEC sp_log 1, @fn, '050: removing wrapping quotes, camelcase list items, calling: sp_fixup_s1_preprocess';
   EXEC sp_fixup_s1_preprocess @fixup_cnt OUT;

   -- Specifics
   EXEC sp_log 1, @fn, '060: calling sp_fixup_s1_pathogens';
   EXEC sp_fixup_s1_pathogens @fixup_cnt OUT
   EXEC sp_log 1, @fn, '070: removing double spaces in company field';
   UPDATE staging1 SET company = REPLACE(company, '  ', ' ') WHERE company LIKE '%  %';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- 21-JAN-2024 replace uses, 'Insecticide/fu ngicide' with 'Insecticide,fungicide'
   UPDATE staging1 SET uses = REPLACE(uses, 'Insecticide/fu ngicide', 'Insecticide,Fungicide') WHERE uses LIKE '%Insecticide/fu ngicide%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Fixup entry mode (Actions) issues
   --EXEC sp_log 1, @fn, '05: Fixup entry mode (Actions) issues, calling sp_fixup_s1_entry_mode';
   --EXEC  sp_s1_fixup_entry_mode @fixup_cnt OUT;

   -- Fixup Rate issues
   EXEC sp_log 1, @fn, '080: Fixup Rate issues, calling sp_fixup_s1_rate';
   EXEC sp_fixup_s1_rate @fixup_cnt OUT;

   -- Checks
   EXEC sp_log 1, @fn, '090: perform post condition checks, calling sp_fixup_s1_chks';
   EXEC  dbo.sp_fixup_s1_postcondition_checks;

   EXEC sp_log 2, @fn, '999: leaving OK, @fixup_cnt: ', @fixup_cnt
END
/*
   EXEC sp_copy_staging1_s1_bak;
   EXEC sp_fixup_s1;
*/

GO
