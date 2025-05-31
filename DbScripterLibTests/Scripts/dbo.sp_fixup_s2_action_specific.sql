SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================================
-- Author:      Terry Watts
-- Create date: 24-OCT-2023
-- Description: Fixup rtn for stging2.(z9,e12)9,12-Tetradecadien-1-Ol Acetate
-- Jobs:
--    1. fixup separators to + no spcs
--
-- Changes:
-- 231130: added an exception handler
-- 231103: moved Bacillus Thuringiensis Vipaa20 and Vip3aa20 from sp_fixup_s2_action_specific to sp_fixup_s2_chems
-- ================================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_action_specific]
   @fixup_cnt INT = NULL OUT
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35)=N'FIXUP_S2_ACTION_SPECIFIC'
      ,@delta_fixup_cnt INT = 0

   SET NOCOUNT OFF;
   BEGIN TRY
      EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt;
      EXEC sp_register_call @fn;
      EXEC sp_log 2, @fn, '02: fixup separators: ,+ spcs, & '' and ''';
      -- 1. general fixup modes
      UPDATE staging2 SET entry_mode = 'Systemic' WHERE ingredient ='(z9,e12)9,12-Tetradecadien-1-Ol Acetate' AND entry_mode = '';
      UPDATE staging2 SET entry_mode = 'Contact,Post-Emergent,Selective,Systemic' WHERE ingredient LIKE '%2,4-D%';
      UPDATE staging2 SET entry_mode = 'Contact,Post-Emergent,Selective,Systemic' WHERE ingredient LIKE 'Imazosulfuron';

      EXEC sp_fixup_s2_action_specific_hlpr '1,8 Cineole'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr '2,4-D'                                     , 'Contact,Post-Emergent,Selective,Systemic'             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Abamectin'                                 , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Acetamiprid'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Alkyl Dimethyl Benzyl Ammonium Chloride'   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Alkyl Modified Heptamethyltrisiloxane'     , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Alkyl Polyethylene Glycol Monoalkyl Ether' , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Alkylphenol-Hydroxypolyoxyethelene'        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Allyl Ethoxylate'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Alpha-Cypermethrin'                        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Acephate'                                  , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Aluminum Potassium Sulfate'                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Ametoctradin'                              , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Amyloliquefaciens'                         , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bacillus Thuringiensis'                    , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Beauveria Bassiana'                        , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Benomyl'                                   , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bensulfuron Methyl'                        , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Benzalkonium Chloride'                     , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Beta-cyfluthrin'                           , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Aviglycine Hydrochloride'                  , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Azadirachtin'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Azoxystrobin'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Benzoxonium Chloride'                      , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Beta-Cypermethrin'                         , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bifenthrin'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bispyribac Sodium'                         , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bitertanol'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bordeaux Mixture'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'BPMC'                                      , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Branched Hydrocarbons'                     , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Brodifacoum'                               , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Brofanilide'                               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bromacil'                                  , 'Pre-Emergent,Post-Emergent,Non-selective'             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bufrofezin'                                , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Butachlor'                                 , 'Selective,Systemic,Pre-Emergent,Post-Emergent'        , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'C14 18 Alkyl Carboxylic Acid Methyl Ester' , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'C18-C24 Linear'                            , 'Others'                                               , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Calcium Alkyl Benzene Sulfonate'           , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Calcium Hypochlorite'                      , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Canola Oil'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Canola Oil Methyl Ester'                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Captan'                                    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Carbaryl'                                  , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Carbendazim'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Carbofuran'                                , 'Systemic '                                            , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Carbosulfan'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Carfentrazone-Ethyl'                       , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cartap Hydrochloride'                      , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorantraniliprole'                       , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorfenapyr'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorfluazuron'                            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorimuron Ethyl'                         , 'Selective,Systemic,Pre-Emergent,Post-Emergent'        , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chloropicrin'                              , 'Soil Sterilant'                                       , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorothalonil'                            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorpyrifos'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlothianidin'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cinnamaldehyde'                            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Clethodim'                                 , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Clothianidin'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Copper Hydroxide'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Copper Oxychloride'                        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Coumatetralyl'                             , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cry1a.105'                                 , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cry1ab'                                    , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cry1f'                                     , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cry2ab2'                                   , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cupric Hydroxide'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cuprous Oxide'                             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cyantraniliprole'                          , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cyazofamid'                                , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cyhalofop-Butyl'                           , 'Selective,Post-Emergent,Systemic'                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cymoxanil'                                 , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cypermethrin'                              , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cyromazine'                                , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Dazomet'                                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Deltamethrin'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Di-1-P-Menthene'                           , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Diazinon'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Dibromo-3-Nitrilopropionamide'             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Dichloropropene'                           , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Didecyl Dimethyl Ammonium Chloride'        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Difenoconazole'                            , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Diuron'                                    , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'D-Limonene'                                , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Dodine'                                    , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Elemental Sulphur'                         , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Ethephon'                                  , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Ethoxylated Dodecyl Alcohol'               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Ethoxysulfuron'                            , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Ethyl Formate'                             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Famoxadone'                                , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fatty Alcohol Polyglycolether'             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fenazaquin'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fenbuconazole'                             , 'Protective,Curative,Systemic'                         , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fenpyroximate'                             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fenthion'                                  , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fenvalerate'                               , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fipronil'                                  , 'Selective'                                            , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Flocoumafen'                               , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Florpyrauxifen Benzyl'                     , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Floupyram'                                 , 'Curative,Protective,Systemic'                         , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluazifop-P-Butyl'                         , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluazinam'                                 , 'Contact,Protective'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Flubendiamide'                             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Flucetosulfuron'                           , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fludioxonil'                               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Flumioxazin'                               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluopicolide'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluopyram'                                 , 'Protective,Systemic'                                  , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluoxastrobin'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Flusulfamide'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluxapyroxad'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Formetanate Hci'                           , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fosthiazate'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Gibberellin'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Glufosinate-Ammonium'                      , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Glyphosate-Ammonium'                       , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Glyphosate-Ipa'                            , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Heat-Killed Burkholderia Spp .strain A396' , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Hexaconazole'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Hexazinone'                                , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Hexythiazox'                               , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Hydramethylnon'                            , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Hydrogen Peroxide'                         , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Imazalil'                                  , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Imazapic'                                  , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Imidacloprid'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Iminoctadine Tris (albesilate)'            , 'Contact,Protective'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Indoxacarb'                                , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Iodine'                                    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Isoprothiolane'                            , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Isopyrazam'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Isotianil'                                 , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Kerosene'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Kresoxim-Methyl'                           , 'Contact,Protective,Curative'                          , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Lambda-Cyhalothrin'                        , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Lauryl Alcohol Polyglycol Ether'           , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Limonene'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Lufenuron'                                 , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Magnesium Phosphide'                       , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Mancozeb'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Malathion'                                 , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Mandipropamid'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Metalaxyl-M'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Metaldehyde'                               , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Metam-Sodium'                              , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Methomyl'                                  , 'Contact,Systemic,Ingested'                            , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Methyl Bromide'                            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Methyl Eugenol'                            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Methylated Seed Oil'                       , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Metiram'                                   , 'Contact,Protective'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Metsulfuron Methyl'                        , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Milbemectin'                               , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Mipcin'                                    , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Natamycin'                                 , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Niclosamide'                               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Niclosamide Ethanolamine Salt'             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Nonylphenol Polyethylene Glycol Ether'     , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Novaluron'                                 , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Oxadiazon'                                 , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Oxyfluorfen'                               , 'Contact,Pre-Emergent,Post-Emergent'                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Oxytetracycline'                           , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Paclobutrazol'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Paraffin'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Peg Oleate(mono-Ester)'                    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Peg-300'                                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Penoxsulam'                                , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Permethrin'                                , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Phenthoate'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Phosphine'                                 , 'Fumigant'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Piperonyl Butoxide'                        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pirimiphos Methyl'                         , 'Fumigant'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyalkylene Oxide Block Copolymer'        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyether-Polymethylsiloxane Copolymer'    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polymeric Terpenes'                        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyoxyethylene Alkyl Ether'               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyoxyethylene Dodecyl Ether'             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyoxyethylene Sorbitan Fatty Acid'       , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyoxyethylene Sorbitan Monooleate'       , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Potassium Peroxymonosulfate'               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Potassium salts of fatty acids'            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Potassium Silicate'                        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pretilachlor'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Prochloraz'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Profenofos'                                , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Propamocarb-hydrochloride'                 , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Propiconazole'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Propineb'                                  , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Propylene Glycol'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Propyrisulfuron'                           , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pthalic Glycerol Alkyd'                    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pymetrozine'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pyraclostrobin'                            , 'Contact,Systemic,Ingested'                            , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pyrazosulfuron Ethyl'                      , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pyribenzoxim'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pyrimethanil'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sabadilla Alkaloids'                       , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Safener'                                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Saponin'                                   , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sethoxydim'                                , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sodium Dichloroisocyanurate'               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sodium Percarbonate'                       , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Soybean Oil'                               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Soybean Oil,Ethoxylated'                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Spinetoram'                                , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Spinosad'                                  , 'Systemic,Contact,Ingested'                            , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Spirotetramat'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Spiroxamine'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sulfoxaflor'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sulfuryl Flourides'                        , 'Fumigant'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sulphur'                                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tea Tree Oil'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tebuconazole'                              , 'Systemic,Protective,Curative,Eradicant'               , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tebufenozide'                              , 'Contact,Selective'                                    , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Terbufos'                                  , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tetraconazole'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tetramethrin'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tetraniliprole'                            , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Thiamethoxam'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Thiodiazole Copper'                        , 'Systemic,Protective,Therapeutic '                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Thiophanate Mesp_fixup_s2_action_specific_hlpr_hlprthyl'                        , 'Systemic'        , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Thiram'                                    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tributylpenol-Polyglycother'               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Triclopyr'                                 , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Trifloxystrobin'                           , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Triflumezopyrim'                           , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Triflumizole'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Triforine'                                 , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'White Mineral Oil'                         , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tetradecadien'                             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Z-9 Tetradecenol'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Zinc Phosphide'                            , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Zineb'                                     , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Zoxamide'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;

      IF @fixup_cnt IS NOT NULL SET @fixup_cnt = @fixup_cnt + @delta_fixup_cnt;

      EXEC sp_log 2, @fn, '99: leaving, made: ',@delta_fixup_cnt, ' changes';
   END TRY
   BEGIN CATCH
      DECLARE @error_msg NVARCHAR(MAX);
      EXEC Ut.dbo.sp_get_error_msg @error_msg OUT;
      EXEC sp_log 4, @fn, '50: caught exception: @stage_id: ',' error:', @error_msg;
      THROW;
   END CATCH
END
/*
EXEC sp_fixup_s2_entry_modes
SELECT * FROM S12_vw WHERE s1_chemical like '%Flusulfamide%' ORDER BY s2_chemical;
SELECT * FROM S12_vw WHERE s2_chemical like '%Fenazaquin%' ORDER BY s2_chemical;
*/

GO
