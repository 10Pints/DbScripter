SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =======================================================================================================
-- Author:      Terry Watts
-- Create date: 27-JUL-2023
-- Description: Fixup rtn for stging2.chemicals
-- Jobs:
--    1. fixup separators to + no spcs
--
-- CHANGES:
-- 231024: updated the Bacillus Thuringiensis Varieties to reflect the bacteria name
-- 231103: moved Bacillus Thuringiensis Vipaa20 and Vip3aa20 from sp_fixup_s2_action_specific to here
-- =======================================================================================================
CREATE   PROCEDURE [dbo].[sp_pre_fixup_s2_chems_deprecated]
   @fixup_cnt       INT = NULL OUT
AS
BEGIN
   DECLARE 
       @fn              VARCHAR(30)=N'FIXUP_S2_CHEMS'

   SET NOCOUNT OFF;
   EXEC sp_log 2, @fn, '000: starting, @fixup_cnt: ',@fixup_cnt;
   EXEC sp_register_call @fn;
   IF @fixup_cnt IS NULL SET @fixup_cnt = 0;

   EXEC sp_log 2, @fn, '010: fixup separators: ,+ spcs, & '' and ''';

   -- 1. fixup separators: can be , + ' and '
   UPDATE staging2 set ingredient = REPLACE(ingredient, ', '   , ',') WHERE ingredient like '%, %';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- 2 spcs to 1 spc
   UPDATE staging2 set ingredient = REPLACE(ingredient, '  '   , ' ') WHERE ingredient like '%  %';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_log 2, @fn, '020:'
   UPDATE staging2 set ingredient = REPLACE(ingredient, ' & '  , '+') WHERE ingredient like '% & %';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 set ingredient = REPLACE(ingredient, ' + '  , '+') WHERE ingredient like '% + %';
   EXEC sp_log 2, @fn, '030:'
   UPDATE staging2 set ingredient = REPLACE(ingredient, ' and ', '+') WHERE ingredient like '% and %';

   EXEC sp_pre_fixup_s2_chems_hlpr '(z)-11-Hexadecenylacetate (7)-7 Dodecenyl Acetate','(z)-11-Hexadecenyl Acetate (7)-7 Dodecenyl Acetate', @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '040: '
   EXEC sp_pre_fixup_s2_chems_hlpr 'acetic Acid', 'Acetic Acid'                         , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'alkyl Dimethyl Benzyl ammonium Chloride', 'Alkyl Dimethyl Benzyl Ammonium Chloride', @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'alkyl Phenyl Polyoxyethylene Polyoxypropylene Ether', 'Alkyl Phenyl Polyoxyethylene Polyoxypropylene Ether', @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '050:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'alkyldimethyl Benzyl Ammonium Chloride', 'Alkyl Dimethyl Benzyl Ammonium Chloride', @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'allyl Ethoxylate', 'Allyl Ethoxylate'               , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Amectrotradin','Ametoctradin'                                               , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '060:'                                                                               
   EXEC sp_pre_fixup_s2_chems_hlpr 'Ametryne','Ametryn'                                                         , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Ammonium Salt Of Glyphosate','Glyphosate-Ammonium'                          , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'atrazine', 'Atrazine', @case_sensitive=1                                    , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '070:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'Bacillus Thuringiensis Ss. Aizawai', 'Bacillus Thuringiensis Var. Aizawai', @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Bacillus Thuringiensis Subsp.kurstaki Strain', 'Bac. Thur. Var. Kurstaki' , @case_sensitive=1 , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Cry1a.105', 'Bac. Thur. Var. Cry1a.105', @fixup_cnt=@fixup_cnt OUT; 
   EXEC sp_pre_fixup_s2_chems_hlpr 'Bacillus Thuringiensis Var. Bacillus Thuringiensis Var. Vip3aa20','Ba. Thur. Var. Vip3aa20'           , @case_sensitive=1     , @fixup_cnt=@fixup_cnt
   EXEC sp_pre_fixup_s2_chems_hlpr 'Vip3aa20','Bac. Thur. Var. Vip3aa20', @case_sensitive=1                    , @fixup_cnt=@fixup_cnt
   EXEC sp_pre_fixup_s2_chems_hlpr 'Cry1ab'  , 'Bac. Thur. Var. Cry1ab'                                        , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Cry2ab2' , 'Bac. Thur. Var. Cry2ab2'                                       , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Cry1f'   , 'Bac. Thur. Var. Cry1f'                                         , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '080:'

   UPDATE staging2 
      SET
          ingredient = REPLACE(ingredient, 'Bifenthrin+starbunch 2% Masterbatch', 'Bifenthrin+Starbunch') 
         ,notes='Use banana bags: starbunch 2% Masterbatch'
      WHERE ingredient LIKE '%Bifenthrin+starbunch 2%';

   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Bifenthrin+starbunch', 'Bifenthrin+Starbunch'       , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'bensulfuron-Methyl', 'Bensulfuron Methyl'           , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Benzyl C12 Alkyldimethylchloride','Benzyl C12 Alkyldimethyl Chloride',         @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'benzyl-C12-18-Alkyldimethyl Chloride)','Benzyl-C12-18-Alkyldimethyl Chloride', @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'beta-Cyfluthrin', 'Beta-Cyfluthrin'                 , @case_sensitive=0     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '090:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'Betacyfluthrin', 'Beta-Cyfluthrin'                  , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'bispyribac', 'Bispyribac'                           , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'bispyribac', 'Bispyribac'                           , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Bifenthrin/starbunch 2% Masterbatch' , 'Bifenthrin+starbunch 2% Masterbatch', @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'bifenthrin'                          , 'Bifenthrin' , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Bordeaux Mixture Micronized Tricalcium Tetracupric Sulfate' ,'Bordeaux Mixture',@fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Bordeux Mixture','Bordeaux Mixture'                                         , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'bpmc', 'BPMC'                                       , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '100'
   EXEC sp_pre_fixup_s2_chems_hlpr 'Branched/hydrocarbons', 'Branched Hydrocarbons'                             , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'bufrofezin/banaflex 21% Mb', 'Bufrofezin'                                   , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'buprofezin', 'Bufrofezin'                                                   , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'butachlor', 'Butachlor'                             , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'C14c18alkyl', 'C14 18 Alkyl', @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Calciumalkyl Benzene Sulfonate', 'Calcium Alkyl Benzene Sulfonate'          , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'calcium Dodecylbenzene','Calcium Dodecylbenzene',     @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '110:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'carbendazim' , 'Carbendazim'                                                , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'chlorimuron' , 'Chlorimuron'                                                , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'chloropicrin', 'Chloropicrin'                                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'chlorpyrifos', 'Chlorpyrifos'                                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'clothianidin', 'Clothianidin'                                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Condenced Oligosaccharides', 'Condensed Oligosaccharides'                   , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '120:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'copper Hydroxide', 'Copper Hydroxide'               , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'cyhalofop-Butyl', 'Cyhalofop-Butyl'                 , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Cymoxamil', 'Cymoxanil'                                                     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'cypermethrin', 'Cypermethrin'                       , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '130:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'Dialkyl Dimethyl Ammonium Chloride', 'Didecyl dimethyl ammonium chloride', @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Dibromo-3-Nitropropionamide', 'Dibromo-3-Nitrilopropionamide'               , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'didecyldimethyllammonium Chloride', 'Didecyl Dimethyl Ammonium Chloride'    , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Didecyl Dimethyl Ammonium Chloride', 'Didecyl Dimethyl Ammonium Chloride', @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'difenoconazole', 'Difenoconazole'                   , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'dimethomorph', 'Dimethomorph'                       , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'diuron', 'Diuron'                                   , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '140:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'Elemental Sulfur','Sulfur'                         , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'ethoxysulfuron', 'Ethoxysulfuron'                   , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'famoxadone', 'Famoxadone'                           , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'florpyrauxifen', 'Florpyrauxifen'                   , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Fludioxinil', 'Fludioxonil'                                                 , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Gamma-Cyhalothrin', 'Cyhalothrin'                                           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '150:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'Gibberellic Acid', 'Gibberellin'                                            , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Glufosinate Ammonium', 'Glufosinate-Ammonium'                               , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Glyphosate Ammonium' ,'Glyphosate-Ammonium'                                 , @fixup_cnt=@fixup_cnt OUT                                    -- 230721
   EXEC sp_pre_fixup_s2_chems_hlpr 'Glyphosate As Potassium Salt','Glyphosate-potassium'                        , @fixup_cnt=@fixup_cnt OUT;  
   EXEC sp_pre_fixup_s2_chems_hlpr 'Glyphosate Ipa','Glyphosate-Ipa'                                            , @fixup_cnt=@fixup_cnt OUT;                                    -- 230721
   EXEC sp_pre_fixup_s2_chems_hlpr 'Glyphosate-potassium', 'Glyphosate-Potassium', @case_sensitive=1            , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Heavy Paraffinic', 'Heavy Paraffinic Oil'                                   , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Hydrotreated Light, Heavy Paraffinic Andnapthenic Oil', 'Paraffin+napthenic Oil'    , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Hydrotreated Light,Heavy Paraffinic Oil AndNapthenic Oil', 'Paraffin+Napthenic Oil' , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Hydrotreated Light Paraffinic Distillates', 'Paraffin'                      , @fixup_cnt=@fixup_cnt OUT;                                    -- 230721
   EXEC sp_log 2, @fn, '160:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'imidacloprid', 'Imidacloprid'                       , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Iminoctadine Tris (albesilate)', 'Iminoctadine Tris (Albesilate)'           , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Lambdacyhalothrin','Lambda-Cyhalothrin'                                     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'mancozeb', 'Mancozeb'                               , @case_sensitive=1     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Mesotrione, Glyphosate, S-Metachlor', 'Mesotrione+Glyphosate+S-Metachlor'   , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'metalaxyl-M', 'Metalaxyl-M'                                                 , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '170:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'Metalaxyl-M+mancozeb', 'Metalaxyl-M+Mancozeb'                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'metalaxyl','Metalaxyl'                                                      , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Metam Sodium', 'Metam-Sodium'                                                                  , @fixup_cnt=@fixup_cnt OUT
   EXEC sp_pre_fixup_s2_chems_hlpr 'mipc', 'Mipcin'                                                             , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;                                   
   EXEC sp_pre_fixup_s2_chems_hlpr 'napthenic Oil', 'Napthenic Oil'                                             , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '180:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'nonypenol- Polyglycother', 'Nonylphenol Polyethylene Glycol Ether'          , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Oxadiazinon', 'Oxadiazon'                                                   , @fixup_cnt=@fixup_cnt OUT;
   UPDATE Staging2 SET ingredient = 'Oxytetracycline' WHERE ingredient='Oxytetracycline Hci';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE Staging2 SET ingredient = 'Paraffin'        WHERE ingredient LIKE '%Paraffinic%Oil%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'peg-300', 'Peg-300'                                                         , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'peg 300 Di-Oleate(di- Ester)', 'Peg-300'                                    , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'peg 300 Di-Oleate'           , 'Peg-300'                                    , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr '+Peg-300+Peg-300'            , 'Peg-300'                                    , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '190:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'Pentapotassuim Bis (peroxymonosulfate) Bis(sufate)' , 'Potassium Peroxymonosulfate' , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Pentapotassuim Bis (peroxymonosulfate) Bis (sufate)', 'Potassium Peroxymonosulfate' , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Phosphorous Acid Technical','Phosphoric Acid'                                       , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'piperonyl butoxide', 'Piperonyl Butoxide'                                   , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'piperonybutoxide','Piperonyl Butoxide'                                      , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'plastech','Plastech'                                                        , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'pyritiline','Pyritiline'                                                    , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '200:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'Polyether-Polymethylsiloxane Copolymer','Polyoxyethylene Alkyl Ether'       , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'polyoxyethylene Alkyl Ether','Polyoxyethylene Alkyl Ether'                  , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'polyoxyethylene Dodecyl Ether','Polyoxyethylene Dodecyl Ether'              , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'polyalkylene', 'Polyalkylene'                                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Polyalkylene Oxide Blockcopolymer','Polyalkylene Oxide Block Copolymer'     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Polyethylene Sorbitanoleats', 'Polyethylene Sorbitan Oleate'                , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Polyethylene Sorbitan Oleats','Polyethylene Sorbitan Oleate'                , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '210:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'Polyoxyethylene Sorbitanmonooleate', 'Polyoxyethylene Sorbitan Monooleate'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Polyoxyethylene Sorbitan Fattyacid','Polyoxyethylene Sorbitan Fatty Acid'   , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'polyoxyethylene', 'Polyoxyethylene'                    , @case_sensitive=1  , @fixup_cnt=@fixup_cnt OUT;
   UPDATE Staging2 SET ingredient  = 'Potassium Hydrogencarbonate' WHERE ingredient='Potassium Hydrogenerated Carbonate';
   EXEC sp_pre_fixup_s2_chems_hlpr 'polyoxyethylene', 'Polyoxyethylene'                    , @case_sensitive=1  , @fixup_cnt=@fixup_cnt OUT;
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Potassium Peroxymonosulphate', 'Potassium Peroxymonosulfate'                , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Potassium salts of fatty acid', 'Potassium Salts of Fatty Acids'            , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Pottasium Silicate','Potassium Silicate'                                    , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '220:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'pretilachlor', 'Pretilachlor'                                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'propamocarb Hci', 'Propamocarb-Hydrochloride'                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Propamocarb Hcl', 'Propamocarb-Hydrochloride'                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'propamocarb Hcl', 'Propamocarb-Hydrochloride'                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'propamocarb-hydrochloride', 'Propamocarb-Hydrochloride'                     , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'propanil', 'Propanil'                                                       , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'propiconazole', 'Propiconazole'                                             , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'pymetrozine', 'Pymetrozine'                                                 , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '230:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'pyrimethanil', 'Pyrimethanil'                                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT
   EXEC sp_pre_fixup_s2_chems_hlpr 'pyriproxyfen', 'Pyriproxyfen'                                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT 
   EXEC sp_pre_fixup_s2_chems_hlpr 'safener', 'Safener'                                                         , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'sodium Dichloroisocyanurate', 'Sodium Dichloroisocyanurate'                 , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   UPDATE Staging2 SET ingredient  = 'Sulphur' WHERE ingredient='Sulfur'
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'tebuconazole', 'Tebuconazole'                                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'tetraconazole', 'Tetraconazole'                                             , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '240: '
   EXEC sp_pre_fixup_s2_chems_hlpr 'tetrametrin', 'Tetramethrin'                                                , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'thiamethoxam', 'Thiamethoxam'                                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'thiamethoxam', 'Thiamethoxam'                                               , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'thiencarbazone-Methyl','Thiencarbazone-Methyl'                              , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Thiodiazole','Thiodiazole Copper'                                           , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'thiodicarb','Thiodicarb'                                                    , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'triadimenol', 'Triadimenol'                                                 , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'triafamone', 'Triafamone'                                                   , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '250:'
   EXEC sp_pre_fixup_s2_chems_hlpr 'Tricalciumtetracupric Sulfate', 'Tricalcium Tetra Cupric Sulfate'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'trifloxystrobin', 'Trifloxystrobin'                                         , @case_sensitive=1, @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Z-9tetradecenol', 'Z-9 tetradecenol'                                        , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr '(z,e)-9,12-Tetradecadien-1-Yl Acetate)', 'Z,e-9,12-Tetradecadienyl Acetate' , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_chems_hlpr 'Z,e-9,12- Tetradecadienyl Acetate',      'Z,e-9,12-Tetradecadienyl Acetate' , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_log 2, @fn, '996: leaving, @fixup_cnt: ',@fixup_cnt;
END 
/*
--------------------------------------
EXEC sp_copy_s3_s2;
EXEC sp_fixup_s2_chems;
SELECT chemical from dbo.fnListChemicals() where chemical >= 'Peg' ORDER BY chemical;
SELECT chemical from dbo.fnListChemicals() where chemical like '%beta%' ORDER BY chemical;
--------------------------------------------------------------------------------------------------------
EXEC sp_reset_CallRegister;
DECLARE @fixup_cnt INT = 0;
EXEC sp_pre_fixup_s2_chems @fixup_cnt OUT;
PRINT @fixup_cnt;
-----------------------------------------------------------------------------------------------------------

Alkyl Dimethyl Benzyl Ammonium Chloride
alkyl Dimethyl Benzyl ammonium Chloride
--------------------------------------
SELECT distinct ingredient FROM staging2 WHERE ingredient LIKE '%Ametryn%'-- COLLATE Latin1_General_CS_AI;
SELECT id, ingredient FROM staging2            WHERE ingredient LIKE '%alkyl Dimethyl Benzyl ammonium Chloride%'-- COLLATE Latin1_General_CS_AI;
SELECT id, ingredient FROM staging2_bak_221008 WHERE ingredient LIKE '%alkyl Dimethyl Benzyl ammonium Chloride%'-- COLLATE Latin1_General_CS_AI;
SELECT distinct ingredient FROM staging1  ORDER BY ingredient;
SELECT distinct ingredient FROM staging2  where INGREDIENT LIKE '%+%' ORDER BY ingredient;
SELECT distinct ingredient FROM [dbo].[staging2_bak_221008] ORDER BY ingredient;
SELECT distinct ingredient FROM staging2  ORDER BY ingredient;
SELECT chemical from dbo.fnListChemicals(0) ORDER BY chemical;
*/


GO
