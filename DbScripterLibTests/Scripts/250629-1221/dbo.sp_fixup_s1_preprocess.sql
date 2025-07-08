SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- --------------------------------------------------------------------------------------------------------------------------=
-- Author:      Terry Watts
-- Create date: 16=JUL=2023
-- Description: does the following std preprocess:
--    1. Removing wrapping double quotes from following columns:
--       company, ingredient product, crops, entry_mode, pathogens
--    2. pathogens: replace á -> spc
--    3. pathogens: standardise whitespace [tab, line fedd, hard space] -> spc
--    4. pathogens: make all double spaces -> single spc
--    5. standardise null fields to default
--    6. Camel case the following columns: company, ingredient, product, uses, entry_mode
--    7. standardise ands
-- CALLED BY:
--    sp_fixup_s1 < sp_main_import_stage_03_s1_fixup < sp__main_import
--
-- CHANGES:
-- 230717: _, [, ], and ^ need to be escaped, they are special characters in LIKE searches so replace [] with () here
-- 231015: factored the update sql, cunting and msg to a helper fn: sp_fixup_s1_preprocess_hlpr
-- 240121: remove double quotes from uses
-- --------------------------------------------------------------------------------------------------------------------------=
CREATE PROCEDURE [dbo].[sp_fixup_s1_preprocess]
      @fixup_cnt       INT OUT
AS
BEGIN
   DECLARE
       @fn           VARCHAR(35)   = 'sp_fixup_s1_preprocess'
      ,@row_count    INT
      ,@row_count_st INT
      ,@ndx          INT = 3
      ,@spc          VARCHAR(1) = N' '

   BEGIN TRY
      SET NOCOUNT OFF;
      SET @row_count_st = @row_count;
      EXEC sp_log 2, @fn, '000: starting, @fixup_cnt: ',@fixup_cnt;
      EXEC sp_assert_not_null @fixup_cnt, '@fixup_cnt',@fn=@fn;

      --3.1  standardise whitespace line feed in fields {company, crops, entry_mode, ingredient, mrl, phi, pathogens, product, rate, uses}
      EXEC sp_log 1, @fn, '010 standardise chrs(10) in company, crops, entry_mode, ingredient, product, pathogens, rate, mrl, phi, uses}';
      EXEC sp_log 1, @fn, '020 standardise chrs(10) in company';
      UPDATE staging1 SET company   = REPLACE(company    , NCHAR(10),  ' ') WHERE company    LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '030 standardise chrs(10) in crops, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET crops     = REPLACE(crops      , NCHAR(10),  ' ') WHERE crops      LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '040 standardise chrs(10) in entry_mode, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET entry_mode= REPLACE(entry_mode       , NCHAR(10),  ' ') WHERE entry_mode       LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '050 standardise chrs(10) in ingredient, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET ingredient= REPLACE(ingredient , NCHAR(10),  ' ') WHERE ingredient LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '060 standardise chrs(10) in mrl.fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET mrl       = REPLACE(mrl        , NCHAR(10),  ' ') WHERE mrl        LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '070 standardise chrs(10) in pathogens. fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET pathogens = REPLACE(pathogens  , NCHAR(10),  ' ') WHERE pathogens  LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '080 standardise chrs(10) in phi, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET phi       = REPLACE(phi        , NCHAR(10),  ' ') WHERE phi        LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '090 standardise chrs(10) in product, fixup_cnt:',@fixup_cnt;;
      UPDATE staging1 SET product   = REPLACE(product    , NCHAR(10),  ' ') WHERE product    LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '100 standardise chrs(10) in rate, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET rate      = REPLACE(rate       , NCHAR(10),  ' ') WHERE rate       LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '110 standardise chrs(10) in uses, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET uses      = REPLACE(uses       , NCHAR(10),  ' ') WHERE uses       LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 1, @fn, '120: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_log 1, @fn, '130: company: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'company', '"', ''        , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '140: ingredient: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr  'ingredient', '"', ''     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '150: product: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr  'product', '"', '  '      , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '160: crops: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr  'crops', '"', ''          , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '170: entry_mode: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr  'entry_mode', '"', ''     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '180: pathogens: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr  'pathogens', '"', ''      , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '190: rate: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr  'rate', '"', ''           , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '200: mrl: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr  'mrl', '"', ''            , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '210: phi: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr  'phi', '"', ''            , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '220: registration: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr  'registration', '"', ''   , @ndx OUT, @fixup_cnt OUT;

      -- 240121: remove double quotes from uses
      EXEC sp_log 1, @fn, '230: uses: remove double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr  'uses'        , '"', ''   , @ndx OUT, @fixup_cnt OUT;

      -- 240121: replace uses 'Insecticide/fu ngicide' with 'Insecticide,Fungicide' 'Insecticide/fu ngicide'
      EXEC sp_log 1, @fn, '240: uses: replace Insecticide/fu ngicide < Insecticide,Fungicide, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr  'uses'        , 'Insecticide/fu ngicide', 'Insecticide,Fungicide'   , @ndx OUT, @fixup_cnt OUT;
      --UPDATE staging1 SET uses = 'Insecticide,Fungicide' WHERE uses LIKE  '%Insecticide/fu ngicide%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;

      -- 22. pathogens: replace á with spc
      EXEC sp_log 1, @fn, @ndx, '250: pathogens: replacing á with spc, @fixup_cnt:',@fixup_cnt;
      SET @ndx = @ndx +1;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', 'á', @spc     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, @ndx, '260: product: replacing á with spc, @fixup_cnt:',@fixup_cnt; SET @ndx = @ndx +1;
      EXEC sp_fixup_s1_preprocess_hlpr 'product', 'á', ' '     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, @ndx, '270: company: replacing á with spc, @fixup_cnt:',@fixup_cnt; SET @ndx = @ndx +1;
      EXEC sp_fixup_s1_preprocess_hlpr 'company', 'á', ' '     , @ndx OUT, @fixup_cnt OUT;

      -- 3. pathogens: standardise whitespace from [tab, line feed, hard space] = spc
      EXEC sp_log 1, @fn, @ndx, '280: pathogens: standardise whitespace from [tab, line feed, hard space] = spc, @fixup_cnt:',@fixup_cnt; SET @ndx = @ndx +1;
      UPDATE staging1 SET pathogens = REPLACE(pathogens, NCHAR(9) ,  ' ') WHERE pathogens LIKE  '%'+NCHAR(9) +'%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;
   
      EXEC sp_log 1, @fn, '290: pathogens: standardised whitespace: CHAR(13), @fixup_cnt:',@fixup_cnt, @row_count = @row_count;

      UPDATE staging1 SET pathogens = REPLACE(pathogens, NCHAR(13),  ' ') WHERE pathogens LIKE  '%'+NCHAR(13)+'%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;
      EXEC sp_log 1, @fn, '300: pathogens: standardised whitespace: CHAR(160), @fixup_cnt:',@fixup_cnt, @row_count = @row_count;
      UPDATE staging1 SET pathogens = REPLACE(pathogens, NCHAR(160), ' ') WHERE pathogens LIKE  '%'+NCHAR(160)+'%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;
      EXEC sp_log 1, @fn, '310: pathogens: standardised whitespace: CHAR(160), @fixup_cnt:',@fixup_cnt, @row_count = @row_count;

      -- 3.2 (was 7) standardise ands
      EXEC sp_log 1, @fn, '320: pathogens: standardise ands, @fixup_cnt:',@fixup_cnt;
      -- Do this before calling fnStanardiseAnds()  because exists: 'Annual and Perennial grasses, sedges and and Broadleaf weeds'
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' and & ', ',' , @ndx OUT, @fixup_cnt OUT;

      -- 04-JUL-2023 Added Stanardise Ands (for comparability with staging2)
      UPDATE dbo.staging1 SET pathogens = dbo.fnStandardiseAnds (pathogens) WHERE pathogens LIKE '%&%' OR pathogens LIKE '% and ' OR  pathogens LIKE '% AND '; 
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- Remove duplicate ands
      EXEC sp_log 1, @fn, '330: pathogens: remove duplicate ands, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' and and ',' and ' , @ndx OUT, @fixup_cnt OUT;

      -- 3.5  make comma space consistent in pathogens and crops
      EXEC sp_log 1, @fn, '350. standardise comma spcs in pathogens, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',', ', ','      , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',', ,', ','     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', ', ,', ','    , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', ',,', ','     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', ', ', ','     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' ,', ','      , @ndx OUT, @fixup_cnt OUT;

      -- fixup Crops 
      EXEC sp_log 1, @fn, '360:. Fixup crops, @fixup_cnt:',@fixup_cnt;
      EXEC sp_log 1, @fn, '370: crops: standardise comma spc = not counting fixups';
      UPDATE staging1 SET crops = dbo.fnReplace(dbo.fnReplace(crops, N', ', N','), N' ,', N',') WHERE crops LIKE '%, %' OR crops LIKE '% ,%';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '380: crops: replace char(10( with spc, @fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET crops = REPLACE(crops, NCHAR(10),  ' ') WHERE crops LIKE '%'+NCHAR(10)+'%';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- fixup phi
      EXEC sp_log 1, @fn, '390: Fixup phi commas and semi-colons, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr 'phi','  ', ' '      , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'phi',';', ','       , @ndx OUT, @fixup_cnt OUT;

      -- 3.6: remove double spaces in crops and pathogens, phi
      EXEC sp_log 1, @fn, '400: crops and pathogens: remove double spaces, @fixup_cnt:',@fixup_cnt;
      EXEC sp_fixup_s1_preprocess_hlpr 'crops', '  ', ' '     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', '  ', ' '     , @ndx OUT, @fixup_cnt OUT;

      -- 10  _, [, ], and ^ need to be escaped, they are special characters in LIKE searches 
      -- replace [] with () here
      EXEC sp_log 1, @fn, '410: crops remove square bracketes [], @fixup_cnt:',@fixup_cnt;
      UPDATE staging1 set crops = Replace(crops, '[', '(') WHERE crops LIKE '%\[%' ESCAPE NCHAR(92);
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      UPDATE staging1 set crops = Replace(crops, ']', ')') WHERE crops LIKE '%\]%' ESCAPE NCHAR(92);
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- 11. standardise null fields to default sht, row
      EXEC sp_log 1, @fn, '420: formulation_type: standardise null to default, @fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET formulation_type   = ''                   WHERE formulation_type   IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 1, @fn, '430: toxicity_category: standardise null to default, @fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET toxicity_category  = ''                   WHERE toxicity_category  IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 1, @fn, '440: entry_mode: standardise null to default, @fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET entry_mode         = ''                   WHERE entry_mode         IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 1, @fn, '450: crops: standardise null to default, @fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET crops              = ''                   WHERE crops              IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 1, @fn, '460: pathogens: standardise null to default, @fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET pathogens          = ''                   WHERE pathogens          IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- 12. Camel case the following columns: company, ingredient, product, uses, entry_mode
      EXEC sp_log 1, @fn, '470: Camel case the following columns: company, ingredient, , product, uses, entry_mode, @fixup_cnt:',@fixup_cnt;

      UPDATE staging1 SET 
         company      = dbo.fnCamelCase(company)
       , ingredient   = dbo.fnCamelCase(ingredient)
       , pathogens    = dbo.fnCamelCase(pathogens)
       , [product]    = dbo.fnCamelCase([product])
       , uses         = dbo.fnCamelCase(uses)
       , entry_mode   = dbo.fnCamelCase(entry_mode)
      ;

      --------------------------------------------------------
      -- Completed processing
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '800: completed processing, @fixup_cnt:',@fixup_cnt;
   END TRY
   BEGIN CATCH
      DECLARE @msg VARCHAR(500);
      SET @msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fn, '500: caught exception: ',@msg;
      THROW;
   END CATCH

   SET @row_count_st = @row_count - @row_count_st;
   EXEC sp_log 2, @fn, '999: leaving OK, delta fixup: ',@row_count_st, ' @fixup_cnt: ', @fixup_cnt, @row_count = @fixup_cnt;
END
/*
EXEC sp_fixup_s1_preprocess;
*/

GO
