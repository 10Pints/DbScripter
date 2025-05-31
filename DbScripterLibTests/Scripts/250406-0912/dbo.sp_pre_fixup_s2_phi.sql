SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 04-AUG-2023
-- Description: Fixup the Stage 2 phi field
--
-- Clean is done in various parts, the process is as follows:
-- 1. Import the main xls (as a tab delimted file)
-- 2. Use sp_fixup_s1_std_preprocessing to handle standard faults like Line feed (496) and quotes (745)
-- 3. sp_fixup_s1_phi will do some basic fixups ahead of the phi import like:
--    a) spelling mistakes
--         mdays -> days
--         harvested2
--          _ -> 0 days
--         'day '->'days '
--        requried -> required
--    b) convert spelled numbers to numbers like 'one' -> 1  'twenty four'-> 24
--    b) standardise the no PHI necessary
--       *no %harvest interval*      -> No PHI necessary
--       *No PHI *                  -> No PHI necessary
--       *on the day of *           -> No PHI necessary
--       '-'                        -> No PHI necessary
--       'No Pre-harvest Interval necessary'
--       No PHI necessary -> 0
-- No restriction
-- 4. Use the following rules to extract the PHI days number
--  1. *no harvest interval * -> No PHI necessary -> 0
--  2.
--  3. (n) hours -> /1 div 24 
--  (mmm-nnn) .* days -> average of mmm, nnn
--  (n) weeks  -> /1 * 7
--  (n) months -> /1 * 30
--  '(nnn)'    -> /1 days
--  
-- MORE INFO:
-- Numbers of days recommeded between last spray until harvest of the crops indicated in the table above
-- 120 days 15 days
-- ==============================================================================================================
ALTER   PROCEDURE [dbo].[sp_pre_fixup_s2_phi]
       @fixup_cnt    INT = NULL OUT
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE 
       @fn            VARCHAR(30)  = N'FIXUP S2 PHI'
      ,@fixup_cnt_delta         INT = 0

   EXEC sp_log 2, @fn,'01: starting: @fixup_cnt: ',@fixup_cnt;
   EXEC sp_register_call @fn;

   -- trim d quotes
   UPDATE staging2 SET phi = ut.dbo.fnTrim2(phi, '"') WHERE phi LIKE '"%"';
   -- replace char 10 with ' '
   UPDATE staging2 SET phi = REPLACE(phi, NCHAR(10), ' ') WHERE phi LIKE CONCAT('%',NCHAR(10),'%'); -- 496 rows
   SET @fixup_cnt_delta = @fixup_cnt_delta + @@ROWCOUNT;
   -- double spcs -> single spcs 
   EXEC sp_pre_fixup_s2_phi_hlpr '  '            , ' '             ,@fixup_cnt=@fixup_cnt_delta OUT;
   -- - . NULL-> ??
   EXEC sp_pre_fixup_s2_phi_hlpr '_', '??',@fixup_cnt=@fixup_cnt_delta OUT, @exact=1;
   EXEC sp_pre_fixup_s2_phi_hlpr '-', '??',@fixup_cnt=@fixup_cnt_delta OUT, @exact=1;
   UPDATE staging2 SET phi = '??'  WHERE phi IS NULL
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_pre_fixup_s2_phi_hlpr '.', '??',@fixup_cnt=@fixup_cnt_delta OUT, @exact=1;

   -- replace commas so we can set up maps
   EXEC sp_pre_fixup_s2_phi_hlpr ',', ';'                          ,@fixup_cnt=@fixup_cnt_delta OUT;
    -- Remove round brackets
   UPDATE staging2 SET phi= REPLACE(phi,' (', ' ') WHERE phi LIKE '% (%';
   UPDATE staging2 SET phi= REPLACE(phi, '(', ' ') WHERE phi LIKE '%(%';
   UPDATE staging2 SET phi= REPLACE(phi,')', '') WHERE phi LIKE '%)%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Spelling/ grammar mistakes:
   EXEC sp_pre_fixup_s2_phi_hlpr 'foilar', 'foliar'                ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'haevested', 'harvested'          ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'Ni PHI needed', 'No PHI needed'  ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'o day', '0 days', @not_clause='two day',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'requried', 'required'            ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'trated', 'treated'               ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr ' fpr ', ' for '                  ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'haevested', 'haevested'          ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'rggplant', 'eggplant'            ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'harvested2', 'harvested 2'       ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'Do nor spray'  , 'Do not spray'  ,@fixup_cnt=@fixup_cnt_delta OUT;

   EXEC sp_pre_fixup_s2_phi_hlpr 'Pre-harvest interval must consider at least 6 and 10 weeks from application on aper bud basis for banana cv'
   , '6-10 weeks from application on aper bud for bananas' ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'For Banana; harvesting may be done on the days of application. For other crops; do not apply  within 7-14', 'Banana: 0 days, other crops:7-14 days'  ,@fixup_cnt=@fixup_cnt_delta OUT;

   -- errata:
   -- Crops sprayed with ORTHENE 75 SP can be harvested 2 weeks after treated
   UPDATE Staging2 set phi = '14 days' WHERE product = 'Lancer 75 Sp' and phi like '%ORTHENE 75 SP can be harvested 2 weeks after treated%'; -- 230721:  8 records

   -- Pluralise day units
   EXEC sp_pre_fixup_s2_phi_hlpr ' day'                  , ' days'                               ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr ' Days'                 , ' days'            ,@case_sensitive=1 ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr ' week '                , ' weeks '                             ,@fixup_cnt=@fixup_cnt_delta OUT;

   -- Consistency
     
   -- Remove prduct from phi as the name often contains a number which messes up our phi extraction;
   UPDATE Staging2 SET phi = REPLACE( phi, product, '') WHERE phi like CONCAT('%', product, '%') COLLATE SQL_Latin1_General_CP1_CI_AI;
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   -- Crops trated With  can be harvested 3 days after application.
   -- Same time remove redundant 'Crops sprayed with ' 
   --: product: 'Alphamax 10 Ec'   phi:'Alphamax can be harvested three 3 days after spray application   Crops treated with Alphamax can be harvested three (3) days after spray application'
   EXEC sp_pre_fixup_s2_phi_hlpr 'Alphamax can', 'Alphamax 10 Ec can',@fixup_cnt=@fixup_cnt_delta OUT;
  -- UPDATE Staging2 SET phi = REPLACE( phi, 'Crops sprayed with ', '') WHERE phi like '%Crops sprayed with %';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE Staging2 SET phi = REPLACE( phi, 'Crops treated with ', 'Crops sprayed with ') WHERE phi like '%Crops treated with %';

   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- standardise time unit
   -- just a number (n) no unit -> n days
   update staging2 set phi = CONCAT(phi, ' days') WHERE isnumeric(phi) =1;
   -- twenty four hours -> 1 day
   EXEC sp_pre_fixup_s2_phi_hlpr 'twenty four hours',  '1 days',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr '24 hours'         ,  '1 days',@fixup_cnt=@fixup_cnt_delta OUT;
   -- two days-> 2 days
   EXEC sp_pre_fixup_s2_phi_hlpr 'two days'         ,  '2 days',@fixup_cnt=@fixup_cnt_delta OUT;
   -- two weeks-> 2 weeks -> 14 days
   EXEC sp_pre_fixup_s2_phi_hlpr 'two weeks'        , '14 days',@fixup_cnt=@fixup_cnt_delta OUT;
   -- 1 weeks-> 2 weeks -> 14 days
   EXEC sp_pre_fixup_s2_phi_hlpr '1 week'           ,  '7 days'    ,@fixup_cnt=@fixup_cnt_delta OUT;
   -- 8 months -> 240 days
   EXEC sp_pre_fixup_s2_phi_hlpr '8 months'         , '240 days',@fixup_cnt=@fixup_cnt_delta OUT;

   -- 'No PHI necessary' variants
   EXEC sp_pre_fixup_s2_phi_hlpr 'No PHI needed'                   , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'No PHI required'                 , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'No PHI proposed'                 , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'No PHI'                          , 'No PHI necessary',@fixup_cnt=@fixup_cnt_delta OUT;

   EXEC sp_pre_fixup_s2_phi_hlpr 'No%pre-harvest interval'         , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'Non Pre-harvest Interval'        , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'No harvest interval is necessary', 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'No_restriction'                  , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'Not applicable'                  , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'Not required'                    , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   
   -- spelled durations
   EXEC sp_pre_fixup_s2_phi_hlpr 'one days'                 , '1 days',@fixup_cnt=@fixup_cnt_delta OUT;

   -- Apply as long as pest threatens -> ??
   EXEC sp_pre_fixup_s2_phi_hlpr 'Apply as long as pest threatens', '??',@fixup_cnt=@fixup_cnt_delta OUT;
   -- number n with no period unit -> d days e.g.
   -- do this after '-' and '.' have been converted
   UPDATE staging2 SET phi = IIF(ISNUMERIC(phi)=1, CONCAT(phi, ' days'), phi);
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   -- It is recommended to observe a 7-days pre-harvest interval
   EXEC sp_pre_fixup_s2_phi_hlpr '7-days', '7 days',@fixup_cnt=@fixup_cnt_delta OUT;
   -- 14 days, Stem and Mat - 0 day   
   EXEC sp_pre_fixup_s2_phi_hlpr '14 days; Stem and Mat - 0 day', 'Fruit: 14 days, Stem and Mat: 0 day',@fixup_cnt=@fixup_cnt_delta OUT;
   -- 14 days; Stem and Mat 0-day
   EXEC sp_pre_fixup_s2_phi_hlpr '14 days; Stem and Mat 0-day'  , 'Fruit: 14 days, Stem and Mat: 0 day',@fixup_cnt=@fixup_cnt_delta OUT;
   -- n - m days -> n days
   -- Harvesting may be done right after spraying
   EXEC sp_pre_fixup_s2_phi_hlpr 'Harvesting may be done right after spraying'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- Harvesting may be done on the days of application
   EXEC sp_pre_fixup_s2_phi_hlpr 'Harvesting may be done on the days of application'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- Fruits that are already ripe on the days of treatment can be harvested without any harmful residue.Generally;
   EXEC sp_pre_fixup_s2_phi_hlpr 'Fruits that are already ripe on the days of treatment can be harvested without any harmful residue.Generally'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- Crop sprayed with  can be done as soon as spray deposits have dried
   EXEC sp_pre_fixup_s2_phi_hlpr 'Crop sprayed with  can be done as soon as spray deposits have dried'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- A days after spraying
   EXEC sp_pre_fixup_s2_phi_hlpr 'A day% after spraying'  , '1 days', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- Harvest can be done on the application days
   EXEC sp_pre_fixup_s2_phi_hlpr 'Harvest can be done on the application day'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- Harvesting can be done even a days after application;as long as the spray has already dried.
   EXEC sp_pre_fixup_s2_phi_hlpr 'Harvesting can be done even a days after application'  , '1 days', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- When applied of recommended rates; very shrort or no harvest interval will be normaly necessary
   EXEC sp_pre_fixup_s2_phi_hlpr 'When applied at recommended rates; very short or no harvest interval will be necessary'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- When applied of recommended rates; very shrort or no harvest interval will be normaly necessary
   EXEC sp_pre_fixup_s2_phi_hlpr 'When applied of recommended rates; very shrort or no harvest interval will be normaly necessary'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;

   -- spelled numbers
   EXEC sp_pre_fixup_s2_phi_hlpr ' one '  , ' 1 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr ' two '  , ' 2 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr ' three ', ' 3 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr ' four ' , ' 4 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr ' five ' , ' 5 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr ' six '  , ' 6 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr ' seven ', ' 7 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr ' eight ', ' 8 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr ' nine ',  ' 9 ',@fixup_cnt=@fixup_cnt_delta OUT;

   -- Crop sprayed with LANCER 75 SP can be done as soon as spray deposits have dried -> 0 days
   EXEC sp_pre_fixup_s2_phi_hlpr 'Crop sprayed with % can be done as soon as spray deposits have dried', '0 days',@fixup_cnt=@fixup_cnt_delta OUT;

   -- 1:M  Map of crop -> PHI  
   -- 7 days (Banana)
   EXEC sp_pre_fixup_s2_phi_hlpr '7 days (Banana)', 'Banana: 7 days',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr '7-14 days% except in banana 0 day%','Banana: 0 days, Other crops: 7-14 days',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_pre_fixup_s2_phi_hlpr 'Allow 7-14 days from last spray until harvest for all crops. Except for banana 0 day.%','Banana: 0 days, Other crops: 7-14 days',@fixup_cnt=@fixup_cnt_delta OUT;

   -- like 14 days before harvest fpr potato. 7 days before harvest for onion
   -- -> potato: 14 days, onion: 7 days
   -- 14 days for fruits, 10 days for field crops
   -- 7 days (Banana) -> Banana: 7 days
   -- 7-14 days. Banana 0 day -> Banana: 0 days, Oter crops: -14 days

   -- convert weeks to days

   -- pop phi resolved
   -- for now do not handle a-b days
   UPDATE staging2 set phi_resolved = dbo.fnGetFirstNumberFromString(phi) WHERE ISNUMERIC(dbo.fnGetFirstNumberFromString(phi)) =1;
   UPDATE staging2 set phi_resolved = dbo.fnGetNumericPairFromString(phi) WHERE phi like '%[0-9]-[0-9]%';
   UPDATE staging2 set phi_resolved = 0 WHERE phi like '%No PHI necessary%'
   SET @fixup_cnt = @fixup_cnt + @fixup_cnt_delta;
   EXEC sp_log 2, @fn,'99: leaving: @fixup_cnt_delta: ',@fixup_cnt_delta, ' @fixup_cnt: ', @fixup_cnt;
END
/*
EXEC sp_fixup_s2_phi
*/


GO
