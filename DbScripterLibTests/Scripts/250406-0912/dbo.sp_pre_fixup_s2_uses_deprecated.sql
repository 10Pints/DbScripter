SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  31-JUL-2012
-- Description:  Fixup routine for staging2 uses
--
-- CHANGES:
-- 231007: added Biophero'; other --> Biological Insecticide
-- 241021: cleanup for quoted items in uses
-- ======================================================================================================
ALTER   PROCEDURE [dbo].[sp_pre_fixup_s2_uses_deprecated]
   @fixup_cnt INT OUTPUT
AS
BEGIN
   DECLARE
        @fn             VARCHAR(35)= 'FIXUP S2 USES'

   IF @fixup_cnt is NULL SET @fixup_cnt=0;

   EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ', @fixup_cnt;
   EXEC sp_register_call @fn;

   -- Bulk updates
UPDATE staging2 SET uses = REPLACE(uses, 'Insecticide/fu Ngicide','Insecticide,Fungicide') WHERE uses LIKE '%Insecticide/fu Ngicide%';
UPDATE Staging2 SET uses = REPLACE(uses, '"','') WHERE uses LIKE '%"%';

   -- specific updates
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='uses'      , @where_op='LIKE', @where_clause='%Adjuvant%'                   , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='uses'      , @where_op='LIKE', @where_clause='%Emulsifier%'                 , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='uses'      , @where_op='LIKE', @where_clause='%insecticide%/%nematicide%'   , @new_uses ='Insecticide,Nematicide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='uses'      , @where_op='='   , @where_clause='Others*'                      , @new_uses ='Others'                  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='uses'      , @where_op='='   , @where_clause='Pgr'                          , @new_uses ='Growth Regulator'        , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Alcohol C13 Iso,-Ethoxylated%', @new_uses='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Allyl Ethoxylate%'            , @new_uses='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Alkyl Modified Heptamethyltrisiloxane%',@new_uses ='Wetting Agent'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Alkylphenol-Hydroxypolyoxyethelene%',@new_uses ='Wetting Agent'     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Aluminum Potassium Sulfate%' , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%ammonium chloride%'          , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Aviglycine Hydrochloride%'   , @new_uses ='Growth Regulator'        , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='Like', @where_clause='%Benzalkonium Chloride%'      , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%C18-C24 Linear+Branched Hydrocarbons%',@new_uses ='Fungicide'       , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Carboxylic Acid%'            , @new_uses ='Biological Insecticide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Carboxylic Acid%'            , @new_uses ='Biological Insecticide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Canola Oil%'                 , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Carbofuran%'                 , @new_uses ='Insecticide,Nematicide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Dazomet%'                    , @new_uses ='Soil Sterilant'          , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Di-1-P-Menthene%'            , @new_uses ='Foliar antitranspirant'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Ethephon%'                   , @new_uses ='Growth Regulator'        , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Ethoxylated Dodecyl Alcohol%', @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Fenamiphos%'                 , @new_uses ='Nematicide'              , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Fenazaquin%'                 , @new_uses ='Miticide,Acaricide,Insecticide', @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%glycol%Ether%'               , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Glyphosate-Ipa%'             , @new_uses ='Ripener'                 , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Heat-Killed Burkholderia Spp .strain A396%', @new_uses ='Biological Insecticide', @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Hydrogen Peroxide%'          , @new_uses ='Bleaching agent'         , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Iodine%'                     , @new_uses ='Fungicide'               , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Kerosene%'                   , @new_uses ='Fungicide,Insecticide'   , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Limonene%'                   , @new_uses ='Fungicide,Insecticide'   , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Metam-Sodium%'               , @new_uses ='Soil Sterilant'          , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Metiram%'                    , @new_uses ='Fungicide'               , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Methyl Eugenol%'             , @new_uses ='Insecticide'             , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Methylated Seed Oil%'        , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Oxytetracycline%'            , @new_uses ='Bactericide'             , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Paclobutrazol%'              , @new_uses ='Growth Regulator'        , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Paraffin%'                   , @new_uses ='Insecticide,Fungicide'   , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Polyethylene Sorbitan Oleate%',@new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Polymeric Terpenes%'         , @new_uses ='Insecticide'             , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Polyoxyethylene Dodecyl Ether%',@new_uses='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Polyoxyethylene Sorbitan Monooleate%',@new_uses='Wetting Agent'     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Pthalic Glycerol Alkyd%'     ,@new_uses = 'Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Sodium Dichloroisocyanurate' , @new_uses ='Disinfectant'            , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='Sodium Percarbonate'          , @new_uses ='Bleaching Agent'         , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='Soybean Oil'                  , @new_uses ='Insecticide,Acaricide,Growth regulator,Herbicide', @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='Soybean Oil,Ethoxylated'      , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='Spirotetramat'                , @new_uses ='Insecticide'             , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='Tea Tree Oil'                 , @new_uses ='Fungicide'               , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Tetradecadien%Acetate%'      , @new_uses ='Biological Insecticide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Trisiloxane Alkoxylate%'     , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Vipaa20%'                    , @new_uses ='Biological Insecticide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_pre_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%White Mineral Oil%'          , @new_uses ='Insecticide'             , @fixup_cnt=@fixup_cnt OUT;

   EXEC sp_log 2, @fn, '99: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
   EXEC sp_fixup_s2_uses;

   SELECT id, ingredient
   FROM Staging2
   WHERE ingredient in
   (SELECT distinct ingredient FROM staging2
   WHERE ingredient LIKE  '%Thur%'
   )  
   ORDER BY ingredient
*/


GO
