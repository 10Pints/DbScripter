SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- --------------------------------------------------------------------------------------------------------------------------=
-- Author:      Terry Watts
-- Create date: 16=JUL=2023
-- Description: does the following std preprocess:
--    1. Removing wrapping double quotes from following columns:
--       company, ingredient product, crops, entry_mode, pathogens
--    2. remove á from pathogens
--    3. pathogens: standardise whitespace [tab, line fedd, hard space] = spc
--    4. pathogens: make all double spaces => single spc
--    5. standardise null fields to default
--    6. Camel case the following columns: company, ingredient, product, uses, entry_mode
--    7. standardise ands
--
-- CHANGES:
-- 230717: _, [, ], and ^ need to be escaped, they are special characters in LIKE searches so replace [] with () here
-- 231015: factored the update sql, cunting and msg to a helper fn: sp_fixup_s1_preprocess_hlpr
-- 240121: remove double quotes from uses
-- --------------------------------------------------------------------------------------------------------------------------=
ALTER PROCEDURE [dbo].[sp_fixup_s1_preprocess]
      @fixup_cnt       INT = 0 OUT
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   = 'FIXUP S1 PREPROCESS:'
      ,@row_count    INT
      ,@ndx          INT = 3
      ,@spc          NVARCHAR(1) = N' '

   BEGIN TRY
      SET NOCOUNT OFF;
      EXEC sp_log 2, @fn, '00: starting, @fixup_cnt: ',@fixup_cnt;
      EXEC sp_register_call @fn;

      --3.1  standardise whitespace line feed in fields {company, crops, entry_mode, ingredient, mrl, phi, pathogens, product, rate, uses}
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in company, crops, entry_mode, ingredient, product, pathogens, rate, mrl, phi, uses}';
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in company';
      UPDATE staging1 SET company   = REPLACE(company    , NCHAR(10),  ' ') WHERE company    LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in crops, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET crops     = REPLACE(crops      , NCHAR(10),  ' ') WHERE crops      LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in entry_mode, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET entry_mode= REPLACE(entry_mode       , NCHAR(10),  ' ') WHERE entry_mode       LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in ingredient, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET ingredient= REPLACE(ingredient , NCHAR(10),  ' ') WHERE ingredient LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in mrl.fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET mrl       = REPLACE(mrl        , NCHAR(10),  ' ') WHERE mrl        LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in pathogens. fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET pathogens = REPLACE(pathogens  , NCHAR(10),  ' ') WHERE pathogens  LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in phi, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET phi       = REPLACE(phi        , NCHAR(10),  ' ') WHERE phi        LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in product, fixup_cnt:',@fixup_cnt;;
      UPDATE staging1 SET product   = REPLACE(product    , NCHAR(10),  ' ') WHERE product    LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in rate, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET rate      = REPLACE(rate       , NCHAR(10),  ' ') WHERE rate       LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in uses, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET uses      = REPLACE(uses       , NCHAR(10),  ' ') WHERE uses       LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 1, @fn, '02: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_log 1, @fn, '03: company: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'company', '"', ''        , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '04: ingredient: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'ingredient', '"', ''     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '05: product: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'product', '"', '  '      , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '06: crops: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'crops', '"', ''          , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '07: entry_mode: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'entry_mode', '"', ''     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '08: pathogens: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'pathogens', '"', ''      , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '09: rate: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'rate', '"', ''           , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '10: mrl: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'mrl', '"', ''            , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '11: phi: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'phi', '"', ''            , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '12: registration: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'registration', '"', ''   , @ndx OUT, @fixup_cnt OUT;

      -- 240121: remove double quotes from uses
      EXEC sp_fixup_s1_preprocess_hlpr  'uses'        , '"', ''   , @ndx OUT, @fixup_cnt OUT;

      -- 240121: replace uses 'Insecticide/fu ngicide' with 'Insecticide,Fungicide' 'Insecticide/fu ngicide'
      EXEC sp_fixup_s1_preprocess_hlpr  'uses'        , 'Insecticide/fu ngicide', 'Insecticide,Fungicide'   , @ndx OUT, @fixup_cnt OUT;
      UPDATE staging1 SET uses = 'Insecticide,Fungicide' WHERE uses LIKE  '%Insecticide/fu ngicide%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;

      -- 22. pathogens: á
      EXEC sp_log 1, @fn, @ndx, '. replacing á with spc'; SET @ndx = @ndx +1;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', 'á', @spc     , @ndx OUT, @fixup_cnt OUT;
   
      EXEC sp_fixup_s1_preprocess_hlpr 'product', 'á', ' '     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'company', 'á', ' '     , @ndx OUT, @fixup_cnt OUT;

      -- 3. pathogens: standardise whitespace from [tab, line feed, hard space] = spc
      UPDATE staging1 SET pathogens = REPLACE(pathogens, NCHAR(9) ,  ' ') WHERE pathogens LIKE  '%'+NCHAR(9) +'%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;
   
      EXEC sp_log 1, @fn, '06: pathogens: standardised whitespace: tab', @row_count = @row_count;

      UPDATE staging1 SET pathogens = REPLACE(pathogens, NCHAR(13),  ' ') WHERE pathogens LIKE  '%'+NCHAR(13)+'%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;
      EXEC sp_log 1, @fn, '05: pathogens: standardised whitespace: CHAR(13)', @row_count = @row_count;

      UPDATE staging1 SET pathogens = REPLACE(pathogens, NCHAR(160), ' ') WHERE pathogens LIKE  '%'+NCHAR(160)+'%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;
      EXEC sp_log 1, @fn, '05: pathogens: standardised whitespace: CHAR(160)', @row_count = @row_count;

      -- 3.2 (was 7) standardise ands
      EXEC sp_log 1, @fn, '7. standardise ands'
      -- Do this before calling fnStanardiseAnds()  because exists: 'Annual and Perennial grasses, sedges and and Broadleaf weeds'
      -- Do before making comma space consistent in pathogens and crops
      --UPDATE dbo.staging1 SET pathogens = REPLACE(pathogens, ' and & ', ',') WHERE pathogens like '% and & %';
      --SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' and & ', ',' , @ndx OUT, @fixup_cnt OUT;

      -- 04-JUL-2023 Added Stanardise Ands (for comparability with staging2)
      UPDATE dbo.staging1 SET pathogens = dbo.fnStanardiseAnds (pathogens) WHERE pathogens LIKE '%&%' OR pathogens LIKE '% and ' OR  pathogens LIKE '% AND '; 
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- Remove duplicate ands
      --UPDATE dbo.staging1 SET pathogens = REPLACE(pathogens,' and and ',' and ') WHERE pathogens like '% and and %'
      --SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' and and ',' and ' , @ndx OUT, @fixup_cnt OUT;

      -- 3.5  make comma space consistent in pathogens and crops
      EXEC sp_log 1, @fn, '8. standardise comma spcs in pathogens and crops';
      --UPDATE staging1 SET pathogens = dbo.fnReplace(dbo.fnReplace(pathogens, N', ', N','), N' ,', N',') WHERE pathogens like '%, %' OR pathogens like '% ,%';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',', ', ','      , @ndx OUT, @fixup_cnt OUT;
      --update staging2 set pathogens = Replace(Pathogens, ', ,', ',') WHERE Pathogens LIKE '%, ,%';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',', ,', ','     , @ndx OUT, @fixup_cnt OUT;
      --update staging2 set pathogens = Replace(Pathogens, ', ,', ',') WHERE Pathogens LIKE ', ,%';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', ', ,', ','    , @ndx OUT, @fixup_cnt OUT;
      --update staging2 set pathogens = Replace(Pathogens, ',,', ',')  WHERE Pathogens LIKE '%,,%';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', ',,', ','     , @ndx OUT, @fixup_cnt OUT;
      --update staging2 set pathogens = Replace(Pathogens, ', ', ',')  WHERE Pathogens LIKE  '%, %';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', ', ', ','     , @ndx OUT, @fixup_cnt OUT;
      --update staging2 set pathogens = Replace(Pathogens, ' ,', ',')  WHERE Pathogens LIKE '% ,%';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' ,', ','      , @ndx OUT, @fixup_cnt OUT;

      --SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- fixup Crops 
      EXEC sp_log 1, @fn, '8.5. Fixup crops';
      EXEC sp_log 1, @fn, '8.6. crops: standardise comma spc = not counting fixups';
      UPDATE staging1 SET crops = dbo.fnReplace(dbo.fnReplace(crops, N', ', N','), N' ,', N',') WHERE crops LIKE '%, %' OR crops LIKE '% ,%';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '8.7. crops: replace char(100 with spc'
      UPDATE staging1 SET crops = REPLACE(crops, NCHAR(10),  ' ') WHERE crops LIKE '%'+NCHAR(10)+'%';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- fixup phi
      EXEC sp_log 1, @fn, '8.6. Fixup phi';
      EXEC sp_fixup_s1_preprocess_hlpr 'phi','  ', ' '      , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'phi',';', ','      , @ndx OUT, @fixup_cnt OUT;

      -- 3.6: remove double spaces in crops and pathogens, phi
      EXEC sp_log 1, @fn, '9. remove double spaces in crops and pathogens';
      EXEC sp_fixup_s1_preprocess_hlpr 'crops', '  ', ' '     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', '  ', ' '     , @ndx OUT, @fixup_cnt OUT;

      -- 10  _, [, ], and ^ need to be escaped, they are special characters in LIKE searches 
      -- replace [] with () here
      EXEC sp_log 1, @fn, '10. remove square bracketes [] in crops';
      UPDATE staging1 set crops = Replace(crops, '[', '(') WHERE crops LIKE '%\[%' ESCAPE NCHAR(92);
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      UPDATE staging1 set crops = Replace(crops, ']', ')') WHERE crops LIKE '%\]%' ESCAPE NCHAR(92);
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- 11. standardise null fields to default sht, row
      EXEC sp_log 1, @fn, '11. standardise null fields to default';
      UPDATE staging1 SET formulation_type   = ''                   WHERE formulation_type   IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      UPDATE staging1 SET toxicity_category  = ''                   WHERE toxicity_category  IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      UPDATE staging1 SET entry_mode         = ''                   WHERE entry_mode         IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      UPDATE staging1 SET crops              = ''                   WHERE crops              IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      UPDATE staging1 SET pathogens          = ''                   WHERE pathogens          IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- 12. Camel case the following columns: company, ingredient, product, uses, entry_mode
      EXEC sp_log 1, @fn, '12. Camel case the following columns: company, ingredient, product, uses, entry_mode';

      UPDATE staging1 SET 
         company      = Ut.dbo.fnCamelCase(company   )
       , ingredient   = Ut.dbo.fnCamelCase(ingredient)
       , product      = Ut.dbo.fnCamelCase(product   )
       , uses         = Ut.dbo.fnCamelCase(uses      )
       , entry_mode   = Ut.dbo.fnCamelCase(entry_mode)
      ;
   END TRY
   BEGIN CATCH
      DECLARE @msg NVARCHAR(500);
      SET @msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: caught exception: ',@msg;
      throw;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK, @fixup_cnt: ',@row_count = @fixup_cnt;
END
/*
EXEC sp_fixup_s1_preprocess;
SELECT distinct uses from Staging1 ORDER by uses
select stg1_id, uses FROM Staging1 WHERE uses like '%/fu%ngicide%'
select stg1_id, uses FROM Staging1 WHERE uses like '%/fu ngicide%'
select stg1_id, uses FROM Staging1 WHERE uses like '%/fu'+NCHAR(10)+'ngicide%'
------------------------------------------------------------------------------------------------=
DECLARE 
 @row_count    INT
,@ndx          INT = 1
,@fixup_cnt    INT = 0
EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', 'á', ' ', @ndx OUT, @fixup_cnt OUT;

(2 rows affected)
(2 rows affected)
INFO   : FIXUP S1 PREPROCESS:          : 11. standardise null fields to default
(86 rows affected)
(0 rows affected)
ERROR  : MN_IMPORT_RTN                 : 50: caught exception: @stage_id: 2 error:564298 proc: sp_staging1_on_update_trigger line :16 msg: sp_staging1_on_insert_trigger: caught update of = in toxicity_category sev: 16 st:1, #fixups so far: 0 , ret: -1
Msg 564298, Level 16, State 1, Procedure sp_staging1_on_update_trigger, Line 16 [Batch Start Line 268]
sp_staging1_on_insert_trigger: caught update of = in toxicity_category
*/

GO
