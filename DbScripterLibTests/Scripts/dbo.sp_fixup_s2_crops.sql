SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 01-AUG-2023
-- Description: Fixes up the crops field
-- Fixups:
--    '--' -> '-'
--    ''   -> '-'Bittergourd ─mpalaya'
--
-- CHANGES:
--    231006: Additional fixes - does not seem to be doing all fixes??
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_crops]
       @must_update  BIT = 0
      ,@fixup_cnt    INT = NULL OUT
AS
BEGIN
   DECLARE 
       @fn              NVARCHAR(30)= N'FIXUP S2 CROPS'
      ,@fixup_cnt_delta INT         = 0
      ,@idx             INT         = 1

   SET NOCOUNT OFF;
   EXEC sp_log 2, @fn,'01: starting: ';
   EXEC sp_register_call @fn;

   UPDATE staging2 SET crops = 'Rice' WHERE crops LIKE '%Direct-seeded%Pre-germinated%rice%'                                           SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE staging2 SET crops = 'Rice' WHERE crops LIKE '%Dry-seeded%Upland%rice%'                                                      SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
  
   EXEC sp_fixup_s2_crops_hlpr '(Dry-seeded (Upland) rice','Rice'                                                                      ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'As an adjuvant in combination with',''                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'As surfactant intended for ZYTOX 10 SC',''                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (an adjuvant for use in spreading &','Banana'                                                   ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana oil (as emulsifier)','Banana'                                                                   ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr '[Cavendish banana as insecticidal soap]', 'Banana (Cavendish)'                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE dbo.staging2 SET crops = 'Banana (Cavendish)' WHERE crops='Banana (Cavendish) as bunch spray'                                SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE dbo.staging2 SET crops = 'Banana (Cavendish)' WHERE crops='Banana (Cavendish) as disinfectant'                               SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE dbo.staging2 SET crops = 'Banana (Cavendish)' WHERE crops='Banana (Cavendish) as insecticidal soap'                          SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE dbo.staging2 SET crops = 'Banana (Cavendish)' WHERE crops='Banana (Cavendish) as tool disinfectant'                          SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) (Post- harvest treatment)' ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as bunch spray'            ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as disinfectant'           ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as insecticidal soap'      ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as insecticidal soap'      ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as tool disinfectant'      ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish),foot'                      ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Beans)','Beans'                                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr ' Beans','Beans', @not_clause='_ Beans'                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr ', Beans,',',Beans'                                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Bitter gourd','Bittergourd'                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE dbo.staging2 SET crops = 'Bittergourd'  WHERE crops like '%Bitter%palaya%';                                                  SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   EXEC sp_fixup_s2_crops_hlpr 'Bnana','Banana'                                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Bulb Onion','Onion'                                                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage & other crucifers','Cabbage, '                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage & othercrucifers','Cabbage,Cruciferae'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage (as seed treatment)','Cabbage'                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage/ Crucifers','Cruciferae'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage/Crucifers','Cruciferae'                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage/Wongbook','Cabbage,Chinese Cabbage'                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish Banana (Post-harvest treatment)','Banana'                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cantaloupes','Cantaloupe'                                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Carrots','Carrot'                                                                                      ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish Banana astool disinfectant,foot','Banana (Cavendish)'                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (melon,cucumber,squash,','Cucurbits'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (Cucumber,melon,squash,','Cucurbits'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (Cucumber,melon,watermelon)','Cucurbits'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish Banana asbunch spray','Banana'                                                               ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish banana asdisinfectant','Banana'                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish banana asinsecticidal soap','Banana'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish Banana','Banana (Cavendish)'                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Chili (pepper)','Chili pepper'                                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Chili/Pepper','Chili pepper'                                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Chinese Cabbage','Chinese cabbage'                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cocoa as PGR','Cocoa'                                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (as pheromone lure)','Corn'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn as Plant- Incorporated','Corn'                                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn as Plant-Incorporated','Corn'                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (as seed treatment)','Corn'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (Drone application)','Corn'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn,Glyphosate tolerant','Corn (Glyphosate tolerant)'                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE staging2 set crops = 'Corn (Sweet corn)' WHERE crops like 'Corn%sweet corn%' AND crops not like 'Corn (Sweet corn)';         SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE staging2 set crops = 'Corn'              WHERE crops like 'Corn(sweet and popcorn)';                                         SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;

   EXEC sp_fixup_s2_crops_hlpr 'Corn hybrid (preplant)','Corn'                                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (Sweet andPopcorn)','Corn'                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn(sweet & popcorn)','Corn'                                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn(sweet andpopcorn)'  ,'Corn'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cotton seed'             ,'Cotton'                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cowpea and other beans','Cowpea,Beans'                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cowpea and otherbeans','Cowpea,Beans'                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Crucifer','Cruciferae',                            @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Crucifers','Cruciferae'                                                                                ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cruciferae (Chinese Cabbage )','Cruciferae,Chinese Cabbage'                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cruciferae (Chinese Cabbage)','Cruciferae,Chinese Cabbage'                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucumber and othecucurbits','Cucurbits'                                                                ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucumber and other cucurbits','Cucurbits'                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (melon,cucumber, squash,','Cucurbits'                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (Cucumbermelon,squash,','Cucurbits'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (Cucumbermelon,watermelon)','Cucurbits'                                                      ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Direct seeded rice','Rice'                                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Field legumes','Legumes'                                                                               ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Garden Peas (Legumes)','Peas (garden),Legumes'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Garden Peas','Peas (garden)',                      @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Glyphosate tolerant','Corn,Glyphosate tolerant',   @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Glyphosate tolerant corn','Corn,Glyphosate tolerant'                                                   ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Glyphosate tolerantcorn','Corn,Glyphosate tolerant'                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Grape','Grapes',                                   @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Grapes seedling','Grapes'                                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Green Peas (Legumes)', 'Peas (green),Legumes'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Green peas', 'Peas (green)',                       @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Institutional agricultural crops (pineapple &','Pineapple'                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Legumes (MongoBeans,Soybeans,Other Beans)','Legumes,Mongo beans,Soyabean,Other beans'                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Legumes (Mongo,Soybean,Beans','Legumes,Mongo beans,Soybeans,Beans'                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Legumes (Mongo,Soyabeans,Beans','Legumes,Mongo beans,Soybeans,Beans'                                   ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'lettuce','Lettuce'                                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Lettuce and other Cruciferae','Lettuce,Cruciferae'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr ',Mongo,',',Mungbeans,'                                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Msngo','Mango'                                                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Mungbean','Mungbeans',                             @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Mungo','Mungbeans',                                @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'N/A',''                                                                                                ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Non-Agricultural Crop Areas','Non-crop areas'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'non-crop & minimal tillage system','Non-crop areas'                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'non-crop & minimum tillage system','Non-crop areas'                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Non-crop agricultural areas','Non-crop areas'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Non-crop agrricultural areas','Non-crop areas'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'non-crop areas','Non-crop areas'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Non-crop land','Non-crop areas'                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Non-cropped Land','Non-crop areas'                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'non-crop','Non-crop areas',                        @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Onion (Bulb/green)','Onion'                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Onion (Transplanted)','Onion'                                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Onion(as Pheromone)','Onion'                                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Papaya (Solo plant)','Papaya'                                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Papaya(Direct seeded)','Papaya'                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'peas,Legumes','Peas,Legumes'                                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Potted%','Potted plants',                                @wrap_wc=0                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE staging2 SET crops = 'Potted plants' WHERE crops like 'Potted%';                                                             SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE staging2 SET crops = 'Soyabeans'     WHERE crops ='Soyabean';                                                                SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   EXEC sp_fixup_s2_crops_hlpr 'Rice ( direct-seeded)','Rice'                                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (as seed treatment)','Rice'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct Seeded Pre- Germinated)','Rice'                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct Seeded)','Rice'                                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct-Seeded and transplanted)','Rice'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct-Seeded lowland)','Rice'                                                                   ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct-seeded Wet Sown)','Rice'                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct-Seeded)','Rice'                                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct-Seededlowland)','Rice'                                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Dry-Seeded)','Rice'                                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (hybrid)','Rice'                                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (lowland)','Rice'                                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Pre-emergent and early post-emergent','Rice'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Transplanted and Direct-Seeded)','Rice'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Transplanted)','Rice'                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Upland)','Rice'                                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice(Direct seeded)','Rice'                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice(Direct seeded lowland)','Rice'                                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice(Transplanted)','Rice'                                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rodenticide',''                                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soil and Space Fumigant','','Soil and Space Fumigant'                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soil fumigant','','Soil fumigant'                                                                      ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Solanaceous crops',''                                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soybeanss','Soyabeans'                                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soyabeans & other beans','Soyabeans,Beans'                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soyabeans/Mungbeans','Soyabeans,Mungbeans'                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soyabean,','Soyabeans,',@not_clause='Soyabeans'                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE staging2 SET crops = 'Soyabeans'     WHERE crops ='Soybeans';                                                                SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   EXEC sp_fixup_s2_crops_hlpr 'Stored commodities & processed foods','','Stored commodities & processed foods'                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Stored grain','','Stored grain'                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Stringbean','Stringbeans',                              @wrap_wc=0                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Sugarcane (plant canes) & ratoon','Sugarcane'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Sugarcane (plant canes)& ratoon','Sugarcane'                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Sweet peas','Peas (sweet)'                                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Swine and poultry farms',''                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Tomato and other','Tomato,Solanaceae'                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Transplante rice','Rice'                                                                               ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Transplanted onion','Onion'                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Transplanted rice','Rice'                                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Turf','Turf grass',                                     @wrap_wc=0                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Vegetables (under minimum or reduced','Vegetables'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Vegetables under minimum or tillage','Vegetables'                                                      ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE staging2 SET crops = 'Vegetables'     WHERE crops LIKE'Vegetables %under minimum%';                                          SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   EXEC sp_fixup_s2_crops_hlpr 'Wongbok','Chinese cabbage'                                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage, ','Cabbage',                                   @wrap_wc=0                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;

   -- 231007: additional fixes
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) (Post- harvest treatment)' ,'Banana (Cavendish)', @note_clause='Post- harvest treatment',@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as bunch spray' ,'Banana (Cavendish)', @note_clause='as bunch spray'                ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as disinfectant' ,'Banana (Cavendish)', @note_clause='as disinfectant'              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as insecticidal soap' ,'Banana (Cavendish)', @note_clause='as insecticidal soap'    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as tool disinfectant' ,'Banana (Cavendish)', @note_clause='as tool disinfectant'    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Chili' ,'Chili pepper'                                 , @not_clause='Chili pepper'                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (Sweet corn' ,'Corn ', @note_clause='(Sweet corn)', @not_clause='Corn (Sweet corn)'               ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (Sweet corn)' ,'Corn', @note_clause='(Sweet corn)'                                                ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn, Popcorn)' ,'Corn'   , @note_clause='(Sweet and Popcorn)'                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Peas (garden)', 'peas'    , @note_clause='(garden)'                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT; 
   EXEC sp_fixup_s2_crops_hlpr 'Peas (green)' , 'peas'    , @note_clause='(green)'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT; 
   EXEC sp_fixup_s2_crops_hlpr 'Peas (sweet)' , 'peas'    , @note_clause='(sweet)'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT; 
   EXEC sp_fixup_s2_crops_hlpr 'Soybeans & other beans', 'Soyabeans,Beans'                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soybeans/Mungbeans', 'Soyabeans,Mungbeans'                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soybeans', 'Soyabeans'                                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soybean', 'Soyabeans'                                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Stored commodities & processed foods', ''  , @note_clause='Stored commodities & processed foods'       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Grassland','Grass'                         , @note_clause='Grassland'                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn,Glyphosate tolerant','Corn'           , @note_clause='Glyphosate tolerant'                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;

   UPDATE Staging2 SET crops = '' WHERE crops = 'Field' AND ingredient='Zinc Phosphide' AND uses='Rodenticide';SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE Staging2 SET crops = '' WHERE crops = 'Soil and Space Fumigant' AND ingredient='Methyl Bromide+chloropicrin' AND uses='Fumigant';SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1; 
   UPDATE Staging2 SET crops = '', uses='Soil Sterilant' WHERE crops = 'Soil fumigant' AND ingredient='Dazomet' AND uses='Others';SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;

   EXEC sp_log 2, @fn,'99: leaving OK, @fixup_cnt_delta: ',@fixup_cnt_delta, ' @fixup_cnt: ',@fixup_cnt;
END
/*
EXEC sp_fixup_s2_crops;
*/

GO
