SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 02-AUG-2023
-- Description: fixup staging2 pathogens: modifies the staging 2 table
--
-- POSTCONDITIONS:
-- PO1: 'Cabagge moth' and 'Golden apple Snails' do not exists in staging2.pathogens
--
-- CHANGES:
-- 231013: added post condition 'Cabagge moth' and 'Golden apple Snails' do not exists in staging2.pathogens
--         changed import replace from based on id to based on data - id is nt good
--         added changes to the fixup cnt
--         added post condition chks on 'Cabagge moth' and 'Golden apple Snails'
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_pathogens]
     @fixup_cnt       INT=NULL OUT
AS
BEGIN
   SET NOCOUNT OFF
   DECLARE
       @fn              NVARCHAR(35) = 'FIXUP S2 PATHOGENS'

   EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt
   EXEC sp_register_call @fn;

   -- pathogens: standardise -
   EXEC sp_log 1, @fn, '2.03: pathogens: standardise -'
   UPDATE dbo.staging2 SET pathogens = '' WHERE pathogens = '-';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE dbo.staging2 SET pathogens = '' WHERE pathogens = '- ';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE dbo.staging2 SET pathogens = '' WHERE pathogens = ' ';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- pathogens: standardise ' and ', ', and ', '',',And ' to ','
   EXEC sp_log 1, @fn, '2.10: pathogens: standardise '' and '' to '','' ';
   UPDATE staging2 SET pathogens = REPLACE(pathogens, ', and ',',');
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET pathogens = REPLACE(pathogens, ' and ',',');
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   -- ,And 
   UPDATE staging2 SET pathogens = REPLACE(pathogens, ',And ',',');
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- pathogens: Capitalise first character of the first word 
   EXEC sp_log 1, @fn, '2.14: pathogens: Capitalise first character of the first word';
   EXEC sp_cap_first_char_of_word;

   -- Missing data: pathogens
   EXEC sp_log 1, @fn, '2.15: pathogens: Fixup some missing data - cotton/Mancozeb -> Path: Alternaria Leaf Spot';

   UPDATE staging2 SET pathogens = CONCAT(pathogens, ',', 'Alternaria Leaf Spot')
   WHERE crops like '%Cotton%' AND ingredient like '%Mancozeb%' AND pathogens NOT like 'Alternaria Leaf Spot';

   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   EXEC sp_log 1, @fn, '03: As foot';
   UPDATE staging2
   SET 
     notes = 'As foot bath,tire dip,tool and machinery disinfectant'
    ,pathogens='Moko disease,Fusarium wilt'
   WHERE pathogens like '%As foot bath,tire dip,tool and machinery disinfectant for the control of Moko disease and Fusarium wilt%';

   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   EXEC sp_log 1, @fn, '04: ''Anthracnose fruit rot leaf spot'' -> ''Anthracnose fruit rot, Leaf spot''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Anthracnose fruit rot leaf spot', 'Anthracnose fruit rot, Leaf spot')  WHERE pathogens like '%Anthracnose fruit rot leaf spot%'; -- 282 rows
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Cabagge moth
   EXEC sp_log 1, @fn, '056: ''Cabagge moth'' -> ''Cabbage moth''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Cabagge moth', 'Cabbage moth')  WHERE pathogens like '%Cabagge moth%'; -- 393 rows
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_log 1, @fn, '3: pathogens, replacing Cabagge moth, @ROWCOUNT: ',@@ROWCOUNT;

   -- Cadelle beetle beetles
   EXEC sp_log 1, @fn, '06: ''Cadelle beetle beetles'' -> ''Cadelle beetle''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Cadelle beetle beetles', 'Cadelle beetle')  WHERE pathogens like '%Cadelle beetle beetles%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Coconut coconut nut rot
   EXEC sp_log 1, @fn, '07: ''Coconut coconut nut rot'' -> ''Coconut nut rot''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Coconut coconut nut rot', 'Coconut nut rot')  WHERE pathogens like '%Coconut coconut nut rot%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Confused flour beetles
   EXEC sp_log 1, @fn, '08: ''Confused flour beetles'' -> ''Confused flour beetle''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Confused flour beetles', 'Confused flour beetle')  WHERE pathogens like '%Confused flour beetles%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Cotton cotton leafworm
   EXEC sp_log 1, @fn, '09: ''Cotton cotton leafworm'' -> ''Cotton leafworm''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Cotton cotton leafworm', 'Cotton leafworm')  WHERE pathogens like '%Cotton cotton leafworm%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- [Diamondback moth caterpillars] ->[Diamondback moth caterpillar]
   EXEC sp_log 1, @fn, '10: ''Diamondback moth caterpillars'' -> ''Diamondback moth caterpillar''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Diamondback moth caterpillars', 'Diamondback moth caterpillar')  WHERE pathogens like '%Diamondback moth caterpillars%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Egyptian cotton cotton leafworm
   EXEC sp_log 1, @fn, '12: ''Egyptian cotton cotton leafworm'' -> ''Egyptian cotton leafworm''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Egyptian cotton cotton leafworm', 'Egyptian cotton leafworm')  WHERE pathogens like '%Egyptian cotton cotton leafworm%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Mango mango tip borer
   EXEC sp_log 1, @fn, '13: ''Mango mango tip borer'' -> ''Mango tip borer''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Mango mango tip borer', 'Mango tip borer')  WHERE pathogens like '%Mango mango tip borer%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Sugarcane sugarcane white grub
   EXEC sp_log 1, @fn, '14: ''Sugarcane sugarcane white grub'' -> ''Sugarcane white grub''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Sugarcane sugarcane white grub', 'Sugarcane white grub')  WHERE pathogens like '%Sugarcane sugarcane white grub%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- POST conditions:
   -- PO1: chk 'Cabagge moth' and 'Golden apple Snails' do not exists in staging2.pathogens
   IF EXISTS ( SELECT 1 FROM staging2 WHERE pathogens like '%Cabagge%' )-- 393 rows
   THROW 53978, 'sp_fixup_s2_pathogens: ''Cabagge moth'' still exists in pathogens', 1;

   EXEC sp_log 2, @fn, '99: leaving OK, @fixup_cnt: ',@fixup_cnt;
END
/*
EXEC sp_fixup_s2_pathogens
*/

GO
