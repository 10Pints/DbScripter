SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ================================================================================================
-- Author:      Terry Watts
-- Create date: 16-JUL-2023
-- Description: perform the stage 1 postcondition checks on the staging1 table
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01: no 'double and'
-- POST 02: no double quotes in flds: {company, ingredient, product, crops, entry_mode, pathogens, uses}
-- POST 03: no null fields tests in {company, ingredient, product, concentration, crops, formulation_type
--    uses, pathogens, toxicity_category, registrations, expiry dates, entry_modes)
--
-- CHANGES:
-- 21-JAN-2024 Added check for no double quotes in the uses field 
-- ================================================================================================
ALTER   PROCEDURE [dbo].[sp_fixup_s1_postcondition_checks] 
AS
BEGIN
   DECLARE
       @fn              VARCHAR(30)   = 'S1_FIXUP_POSTCONDITION_CHECKS'
      ,@RC              INT            = 0
      ,@result_msg      VARCHAR(500)  = ''
      ,@cnt             INT            = 0
      ,@default_fld_val VARCHAR(15)   = '*** UNKNOWN ***'
      ,@sql             VARCHAR(MAX)  = ''

   EXEC sp_log 2, @fn, '01: starting'
   -- POST 01: no 'double and' in the following fields: {company, ingredient, product, crops, entry_mode, pathogens, uses}
   EXEC sp_log 2, @fn, 'POST 01: no ''double and'' in the following fields: {company, ingredient, product, crops, entry_mode, pathogens, uses}'
   IF EXISTS (SELECT 1 FROM staging1 WHERE pathogens like '% and and %') THROW 60400,'AND AND present in S1.pathogens',1

   -- POST 02: no double quotes in the following fields: {company, ingredient, product, crops, entry_mode, pathogens, uses}
   EXEC sp_log 2, @fn, 'POST 01: no double quotes test in the following fields: {company, ingredient, product, crops, entry_mode, pathogens, uses}'
   SELECT @cnt = COUNT(*) FROM staging1  WHERE company LIKE '%"%'
   IF @cnt > 0 Throw 50130, '" still exists in s1.company', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE ingredient LIKE '%"%'
   IF @cnt > 0 Throw 50131, '" still exists in s1.ingredient', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE product LIKE '%"%'
   IF @cnt > 0 Throw 50132, '" still exists in s1.product', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE crops LIKE '%"%'
   IF @cnt > 0 Throw 50133, '" still exists in s1.crops', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE entry_mode LIKE '%"%'
   IF @cnt > 0 Throw 50134, '" still exists in s1.entry_mode', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE pathogens LIKE '%"%'
   IF @cnt > 0 Throw 50135, '" still exists in s1.pathogens', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE uses LIKE '%"%'
   IF @cnt > 0 Throw 50135, '" still exists in s1.uses', 1

   -- POST 03.1,: no null fields tests in {company, ingredient, product}
   EXEC sp_log 2, @fn, 'POST 03.1: no null fields tests in {company, ingredient, product}'
   SELECT @cnt = COUNT(*) FROM staging1 WHERE company           IS NULL;         
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL companies in S1';
   SELECT @cnt = COUNT(*) FROM staging1 WHERE ingredient        IS NULL;       
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL ingredients in S1';
   SELECT @cnt = COUNT(*) FROM staging1 WHERE product           IS NULL;          
   IF @cnt > 0  EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL products in S1';

   -- POST 03.2,: no null fields in {company, ingredient, product, concentration, crops, formulation_type, uses, pathogens, toxicity_category}
   EXEC sp_log 2, @fn, 'POST 03.2: null fields tests in concentration, crops, formulation_type, uses, pathogens, toxicity_category'
   SELECT @cnt = COUNT(*) FROM staging1 WHERE concentration     IS NULL;    
   IF @cnt > 0 EXEC sp_log 3, @fn, '50: there are ', @cnt, ' NULL concentration values in S1'; -- WARNING ONLY
   SELECT @cnt = COUNT(*) FROM staging1 WHERE formulation_type  IS NULL; 
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL formulation_types in S1';
   SELECT @cnt = COUNT(*) FROM staging1 WHERE uses              IS NULL;             
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL uses in S1';
   SELECT @cnt = COUNT(*) FROM staging1 WHERE toxicity_category IS NULL;
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL toxicity_categories in S1';

   -- POST 03.3,: no null fields in {registrations, expiry dates, entry_modes}
   EXEC sp_log 2, @fn, 'POST 03.3: no null fields in {registrations, expiry dates, entry_modes}'
   SELECT @cnt = COUNT(*) FROM staging1 WHERE registration     IS NULL;    
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL registrations in S1';

   SELECT @cnt = COUNT(*) FROM staging1 WHERE entry_mode            IS NULL;           
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL entry_mode in S1';

   SELECT @cnt = COUNT(*) FROM staging1 WHERE expiry            IS NULL;           
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL expiry dates in S1';
   
   --SELECT @cnt = COUNT(*) FROM staging1 WHERE entry_mode        IS NULL;       
   --IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL entry_modes';
   EXEC sp_log 2, @fn, '99: leaving, all ok, rc:', @rc,' msg:[', @result_msg,']';
END
/*
EXEC sp_fixup_s1_chks
EXEC sp__main_import_pesticide_register @import_file = 'D:\Dev\Repos\Farming\Data\Exports Ph DepAg Registered Pesticides LRAP-230721.pdf\LRAP-20230721.tsv.txt', @mode='LOG_LEVEL:1', @stage = 0 -- full
select * FROM staging1 where company is null
SELECT * FROM Staging1

*/


GO
