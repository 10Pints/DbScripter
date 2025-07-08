SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 02-AUG-2023
-- Description: fixup staging2 pathogens: modifies the staging 2 table
-- Use this to correct common pathogen sp errors and amend names that have 'and' in them
-- eg: replace perrenial -> perennial  
-- Annual and perrenial broadleaf weeds and grasses 
--
-- POSTCONDITIONS:
-- PO1: 'Cabagge moth' and 'Golden apple Snails' do not exists in staging2.pathogens
--
-- CHANGES:
-- 231013: added post condition 'Cabagge moth' and 'Golden apple Snails' do not exists in staging2.pathogens
--         changed import replace from based on id to based on data - id is nt good
--         added changes to the fixup cnt
--         added post condition chks on 'Cabagge moth' and 'Golden apple Snails'
-- 241019: correct common pathogen sp errors and amend names that have 'and' in them
--         some like Annual and perrenial broadleaf weeds and grasses  in volver several changes
-- ======================================================================================================
CREATE   PROCEDURE [dbo].[sp_pre_fixup_s2_pathogens_deprecated]
     @fixup_cnt       INT=NULL OUT
AS
BEGIN
   SET NOCOUNT OFF
   DECLARE
       @fn              VARCHAR(35) = 'FIXUP S2 PATHOGENS'

   IF @fixup_cnt IS NULL SET @fixup_cnt = 0;

   EXEC sp_log 2, @fn, '000: starting, @fixup_cnt: ',@fixup_cnt
   EXEC sp_register_call @fn;
/*
   -- standardise pathogens:  -
   --EXEC sp_log 1, @fn, '010: pathogens: standardise -'
   --UPDATE dbo.staging2 SET pathogens = '' WHERE pathogens = '-';
   --SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   --EXEC sp_log 1, @fn, '020: pathogens: standardise spaces, @fixup_cnt: ', @fixup_cnt;
   --UPDATE dbo.staging2 SET pathogens = '' WHERE pathogens = '- ';
   --SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   --UPDATE dbo.staging2 SET pathogens = '' WHERE pathogens = ' ';
   --SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- pathogens: remove leading/trailing space
   --UPDATE dbo.staging2 SET pathogens = TRIM(pathogens); SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   --EXEC sp_log 1, @fn, '022: @fixup_cnt: ',@fixup_cnt;

   -- replace perrenial -> perennial
--   UPDATE dbo.staging2 SET pathogens = REPLACE(pathogens, 'perrenial', 'perennial'); SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   --EXEC sp_pre_fixup_s2_pathogens_hlpr 'perrenial', 'perennial', @fixup_cnt OUT;
   --EXEC sp_log 1, @fn, '024: @fixup_cnt: ',@fixup_cnt;
   -- Translate certain [A and B .C AND D] to[ A C], [A D], [B C], [B D]
   -- Translate certain [A and B] to [A B]
   -- Annual and perennial broadleaf weeds and grasses 
   --EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual and perennial broadleaf weeds and grasses', 'Broadleaf weeds,Grasses', @fixup_cnt OUT;
   -- Annual and perennial broadleaf weeds and grases
   --EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual and perennial broadleaf weeds and grases' , 'Broadleaf weeds,Grasses', @fixup_cnt OUT;
   ---- Annual and Perennial broadleaves and grasses
   --EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual and Perennial broadleaves and grasses'    , 'Broadleaf weeds,Grasses', @fixup_cnt OUT;
   ---- Annual and perrenial broadleaves and grasses
   --EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual and perrenial broadleaves and grasses'    , 'Broadleaf weeds,Grasses', @fixup_cnt OUT;
   -- Annual and perennial broadleaf weeds
   EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual and perennial broadleaf weeds', 'Broadleaf weeds', @fixup_cnt OUT;
   -- annual and perennial broadleaves
   EXEC sp_pre_fixup_s2_pathogens_hlpr 'annual and perennial broadleaves', 'Broadleaf weeds', @fixup_cnt OUT;
   -- Annual broadleaves and certain annual grasses
   EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual broadleaves and certain annual grasse', 'Annual broadleaf weeds,Annual grasses', @fixup_cnt OUT;
   -- Annual broadleaves and grasses
   EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual broadleaves and grasses', 'Annual broadleaf weeds,Annual grasses', @fixup_cnt OUT;
   -- annual and perennial broadleaves
   EXEC sp_pre_fixup_s2_pathogens_hlpr 'annual and perennial broadleaves', 'Broadleaf weeds', @fixup_cnt OUT;
   -- Annual and perennial grasses and broadleaves
   EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual and perennial grasses and broadleaves', 'Broadleaf weeds,Grasses', @fixup_cnt OUT;
   -- Annual and Perennial grasses
   EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual and Perennial grasses', 'Grasses', @fixup_cnt OUT;
   -- Annual and Perennial weeds
   EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual and Perennial weeds', 'Weeds', @fixup_cnt OUT;
   -- Annual grasses and broadleaf weeds
   EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual grasses and broadleaf weeds', 'Annual broadleaf weeds,Annual grasses', @fixup_cnt OUT;
   -- Annual grasses and broadleaves
   EXEC sp_pre_fixup_s2_pathogens_hlpr 'Annual grasses and broadleaves', 'Annual broadleaf weeds,Annual grasses', @fixup_cnt OUT;

   ------------------------------------------------------------------------------------------
   -- *** ASSERTION: must have made all updates to pathogens where real name has ' and ' in it
   ------------------------------------------------------------------------------------------

   EXEC sp_log 1, @fn, '030: pathogens: standardise '' and '' to '','' , @fixup_cnt: ', @fixup_cnt;

   -- pathogens: standardise ' and ', ', and ', '',',And ' to ','
   EXEC sp_log 1, @fn, '030: pathogens: standardise '' and '' to '','' , @fixup_cnt: ', @fixup_cnt;
   UPDATE staging2 SET pathogens = REPLACE(pathogens, ', and ',',');
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET pathogens = REPLACE(pathogens, ' and ',',');
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   -- ,And 
   UPDATE staging2 SET pathogens = REPLACE(pathogens, ',And ',',');
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- pathogens: Capitalise first character of the first word 
   EXEC sp_log 1, @fn, '040: pathogens: Capitalise first character of the first word, @fixup_cnt: ', @fixup_cnt;
   EXEC sp_cap_first_char_of_word;

   -- Missing data: pathogens
   EXEC sp_log 1, @fn, '050: pathogens: Fixup some missing data - cotton/Mancozeb -> Path: Alternaria Leaf Spot';

   UPDATE staging2 SET pathogens = CONCAT(pathogens, ',', 'Alternaria Leaf Spot') WHERE crops like '%Cotton%' AND ingredient like '%Mancozeb%' AND pathogens NOT like 'Alternaria Leaf Spot';

   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
*/
   EXEC sp_log 1, @fn, '060: As foot, @fixup_cnt: ', @fixup_cnt;
   UPDATE staging2
   SET 
     notes = 'As foot bath,tire dip,tool and machinery disinfectant'
    ,pathogens='Moko disease,Fusarium wilt'
   WHERE pathogens like '%As foot bath,tire dip,tool and machinery disinfectant for the control of Moko disease and Fusarium wilt%';

   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   EXEC sp_log 1, @fn, '070: ''Anthracnose fruit rot leaf spot'' -> ''Anthracnose fruit rot, Leaf spot'', @fixup_cnt: ', @fixup_cnt;
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Anthracnose fruit rot leaf spot', 'Anthracnose fruit rot, Leaf spot')  WHERE pathogens like '%Anthracnose fruit rot leaf spot%'; -- 282 rows
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Cabagge moth
   EXEC sp_log 1, @fn, '080: ''Cabagge moth'' -> ''Cabbage moth'', @fixup_cnt: ', @fixup_cnt;
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Cabagge moth', 'Cabbage moth')  WHERE pathogens like '%Cabagge moth%'; -- 393 rows
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_log 1, @fn, '090: pathogens, replacing Cabagge moth, @ROWCOUNT: ',@@ROWCOUNT;

   -- Cadelle beetle beetles
   EXEC sp_log 1, @fn, '100: ''Cadelle beetle beetles'' -> ''Cadelle beetle'', @fixup_cnt: ', @fixup_cnt;
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Cadelle beetle beetles', 'Cadelle beetle')  WHERE pathogens like '%Cadelle beetle beetles%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Coconut coconut nut rot
   EXEC sp_log 1, @fn, '110: ''Coconut coconut nut rot'' -> ''Coconut nut rot''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Coconut coconut nut rot', 'Coconut nut rot')  WHERE pathogens like '%Coconut coconut nut rot%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Confused flour beetles
   EXEC sp_log 1, @fn, '120: ''Confused flour beetles'' -> ''Confused flour beetle'', @fixup_cnt: ', @fixup_cnt;
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Confused flour beetles', 'Confused flour beetle')  WHERE pathogens like '%Confused flour beetles%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Cotton cotton leafworm
   EXEC sp_log 1, @fn, '130: ''Cotton cotton leafworm'' -> ''Cotton leafworm'', @ROWCOUNT: ',@@ROWCOUNT;
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Cotton cotton leafworm', 'Cotton leafworm')  WHERE pathogens like '%Cotton cotton leafworm%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- [Diamondback moth caterpillars] ->[Diamondback moth caterpillar]
   EXEC sp_log 1, @fn, '140: ''Diamondback moth caterpillars'' -> ''Diamondback moth caterpillar''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Diamondback moth caterpillars', 'Diamondback moth caterpillar')  WHERE pathogens like '%Diamondback moth caterpillars%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Egyptian cotton cotton leafworm
   EXEC sp_log 1, @fn, '150: ''Egyptian cotton cotton leafworm'' -> ''Egyptian cotton leafworm'', @ROWCOUNT: ',@@ROWCOUNT;
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Egyptian cotton cotton leafworm', 'Egyptian cotton leafworm')  WHERE pathogens like '%Egyptian cotton cotton leafworm%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Mango mango tip borer
   EXEC sp_log 1, @fn, '160: ''Mango mango tip borer'' -> ''Mango tip borer'', @ROWCOUNT: ',@@ROWCOUNT;
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Mango mango tip borer', 'Mango tip borer')  WHERE pathogens like '%Mango mango tip borer%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Sugarcane sugarcane white grub
   EXEC sp_log 1, @fn, '170: ''Sugarcane sugarcane white grub'' -> ''Sugarcane white grub'', @ROWCOUNT: ',@@ROWCOUNT;
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Sugarcane sugarcane white grub', 'Sugarcane white grub')  WHERE pathogens like '%Sugarcane sugarcane white grub%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- POST conditions:
   -- PO1: chk 'Cabagge moth' and 'Golden apple Snails' do not exists in staging2.pathogens

   EXEC sp_log 2, @fn, '999: leaving OK, @fixup_cnt: ',@fixup_cnt;
END
/*
EXEC sp_copy_s3_s2;
EXEC sp_reset_CallRegister;
EXEC sp_pre_fixup_s2_pathogens
*/


GO
