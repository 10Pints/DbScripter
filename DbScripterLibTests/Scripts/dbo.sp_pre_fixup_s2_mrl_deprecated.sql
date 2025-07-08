SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 04-AUG-2023
-- Description: Fixup the Stage 1 mrl field
-- ======================================================================================================
CREATE   PROCEDURE [dbo].[sp_pre_fixup_s2_mrl_deprecated] 
   @fixup_cnt INT = NULL OUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn                       VARCHAR(30)  = N'FIXUP S2 MRL'

   EXEC sp_log 2, @fn,'01: starting: @fixup_cnt: ',@fixup_cnt;
   --EXEC sp_register_call @fn;

   UPDATE staging1 SET mrl = REPLACE(mrl, NCHAR(10), ',') WHERE mrl LIKE CONCAT('%',NCHAR(10),'%');
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   -- UPDATE staging1 SET mrl = @replace_clause WHERE mrl LIKE @search_clause
   EXEC sp_s2_fixup_mrl_hlpr '-'                                                 , NULL                                                         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '--'                                                , NULL                                                         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '.'                                                 , NULL                                                         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '_'                                                 , NULL                                                         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '='                                                 , NULL                                                         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.0ppm'                                            , '0.0 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.01 ug/g'                                         , '0.01 µg/g'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.02 mg/ kg Pyriftalid  0.02,mg/kg Bensulfuron-methyl','Pyriftalid: 0.02 mg/kg, Bensulfuron-methyl: 0.02 mg/kg'   , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.03 ppm,0.03 ppm'                                 , '0.03 ppm, 0.03 ppm'                                         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.05 Ág/g'                                         , '0.05 µg/g'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.05-0.10'                                         , '0.05-0.10 ppm'                                              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.2mg/ kg'                                         , '0.2 mg/kg'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.2mg/Kg'                                          , '0.2 mg/kg'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.2ppm'                                            , '0.2 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.5mg/Kg'                                          , '0.5 mg/kg'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.5ppm'                                            , '0.5 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.5ppm Thiamethoxam;, 0.5ppm Lambdacyhalothrin'    , 'Thiamethoxam: 0.5 ppm, Lambdacyhalothrin: 0.5 ppm'          , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.60 ppm'                                          , '0.6 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.80ppm'                                           , '0.8 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.8ppm'                                            , '0.8 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1.00 ppm'                                          , '1 ppm'                                                      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1ppm'                                              , '1 ppm'                                                      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1.0ppm'                                            , '1 ppm'                                                      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1.0ppm Thiamethoxam; 0.50ppm Lambdacyhalothrin'    , 'Thiamethoxam: 1 ppm, Lambdacyhalothrin: 0.50 ppm'           , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '2.0ppm'                                              , '2 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '10ppm'                                             , '10 ppm'                                                     , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.01ppm,Difenoconazole 0.01ppm'       , 'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm'           , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.05ppm Difenoconazole 0.1ppm'        , 'Azoxystrobin: 0.05 ppm, Difenoconazole: 0.1 ppm'            , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.20ppm Tebuconazole 0.10ppm'         , 'Azoxystrobin: 0.2 ppm, Tebuconazole: 0.10 ppm'              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.2ppm Difenoconazole 0.07ppm'        , 'Azoxystrobin: 0.2 ppm, Difenoconazole: 0.07 ppm'            , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin-0.01 Difenoconazole-0.01'             , 'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm'           , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin-0.01 mg/Kg; Difenoconazole-0.01 mg/Kg', 'Azoxystrobin: 0.01 mg/kg; Difenoconazole: 0.01 mg/kg'       , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin-0.2 Difenoconazole-0.07'              , 'Azoxystrobin: 0.2 ppm, Difenoconazole: 0.07 ppm'            , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin-0.3 mg/Kg; Difenoconazole-0.3 mg/Kg'  , 'Azoxystrobin: 0.3 mg/kg, Difenoconazole: 0.3 mg/kg'         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin-1.0ppm Tebuconazole-0.1ppm'           , 'Azoxystrobin: 1 ppm, Tebuconazole: 0.1 ppm'                 , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin-5.0 ppm Tebuconazole-1.0ppm'          , 'Azoxystrobin: 5.0 ppm, Tebuconazole: 1 ppm'                 , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.1 mg/kg (Beta-cyfluthrin) ; 0.7 mg/ kg (Imidacloprid)','Beta-cyfluthrin: 0.1 mg/kg, Imidacloprid: 0.7 mg/kg'    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Beta-cyfluthrin 0.02ppm,Imidacloprid 0.20ppm'      , 'Beta-cyfluthrin: 0.02 ppm, Imidacloprid: 0.20 ppm'          , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Buprofezin 0.5ppm MIPC 0.5ppm'                     , 'Buprofezin: 0.5 ppm, MIPC: 0.5 ppm'                         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Butachlor 0.1ppm Propanil 0.1ppm'                  , 'Butachlor: 0.1 ppm Propanil: 0.1 ppm'                       , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Difenoconazole 0.5ppm Propiconazole 0.5ppm'        , 'Difenoconazole: 0.5 ppm Propiconazole: 0.5 ppm'             , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Fenoxaprop p-ethyl 0.05ppm Ethoxysulfuron 0.01 ppm', 'Fenoxaprop p-ethyl 0.05 ppm, Ethoxysulfuron: 0.01 ppm'      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1.0 mg/kg Floupyram 0.7,mg/kg Trifloxystobin'      , 'Floupyram: 1.0 mg/kg, Trifloxystobin: 0.7,mg/kg'            , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Imidacloprid = 2.0 Ág/g Deltamethrin -  0.5Ág/g'   , 'Imidacloprid: 2.0 µg/g, Deltamethrin: 0.5 µg/g'             , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Phenthoate-0.05 ppm'                               , 'Phenthoate: 0.05 ppm'                                       , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Tebuconazole-0.05 ppm;Triadimenol-0.2 ppm'         , 'Tebuconazole: 0.05 ppm, Triadimenol: 0.2 ppm'               , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Tebuconazole-0.09 Trifloxystrobin-0.08'            , 'Tebuconazole: 0.09 ppm, Trifloxystrobin: 0.08 ppm'          , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'z', 'z'                                                                                                           , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.02 mg/ kg Pyriftalid  0.02,mg/kg Bensulfuron-methyl', 'Pyriftalid: 0.02 mg/kg, Bensulfuron-methyl: 0.02 mg/kg'  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.005ppm',                                                '0.005 ppm'                                              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.01 mg/ Kg',                                            '0.01 mg/kg'                                             , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.008-Tebuconazole 0.01- Trifloxystrobin',               'Tebuconazole: 0.008, Trifloxystrobin: 0.01'             , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.008-Tebuconazole 0.01-,Trifloxystrobin',               'Tebuconazole: 0.008, Trifloxystrobin: 0.01'             , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.01 mg/kg Clothianidin 0.05,mg/kg Imidacloprid',        'Clothianidin: 0.01 mg/kg, Imidacloprid 0.05 mg/kg'      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.01 mg/kg(Tefuryltrione),0.01 mg/kg(Triafamone)',       'Tefuryltrione: 0.01 mg/kg, Triafamone: 0.01 mg/kg'      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.01 ppm(Mesotrione)',                                   'Mesotrione: 0.01 ppm'                                   , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.01 ug/g',                                              '0.01 ug/g'                                              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.01ppm',                                                '0.01 ppm'                                               , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.02 mg/ Kg',                                            '0.02 mg/kg'                                             , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.02 mg/kg Floupyram; 0.08,mg/kg Trifloxystrobin',       'Floupyram: 0.02 mg/kg, Trifloxystrobin: 0.08mg/kg'      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.02 mg/kg Isoxafloute 0.03,mg/kg Thiencarbazone-',      'Isoxafloute: 0.02 mg/kg, Thiencarbazone: 0.03 mg/kg'    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.02ppm',                                                '0.02 ppm'                                               , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.03 mg/Kg',                                             '0.03 mg/kg'                                             , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.04 mg/Kg',                                             '0.04 mg/kg'                                             , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.05 mg/Kg Fluopicolide; 0.3 mg/Kg Propamocarb HCI',     'Fluopicolide: 0.05 mg/kg, Propamocarb HCI: 0.3 mg/kg'   , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.05ppm',                                                '0.05 ppm'                                               , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.05ppm Thiamethoxam; 0.5ppm Lambdacyhalothrin',         'Thiamethoxam: 0.05 ppm, Lambdacyhalothrin: 0.5 ppm'     , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.05ppm Thiamethoxam;,0.5ppm Lambdacyhalothrin',         'Thiamethoxam: 0.05 ppm, Lambdacyhalothrin: 0.5 ppm'     , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.0603 Áq/q',                                            '0.0603 ug/q'                                            , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.07 mg/Kg (Floupyram) 0.08 mg/Kg (Trifloxystrobin)',    'Floupyram: 0.07 mg/kg, Trifloxystrobin: 0.08 mg/kg '    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.1 mg/kg (Beta-cyfluthrin) ;,0.7 mg/ kg (Imidacloprid)','Beta-cyfluthrin: 0.1 mg/kg, Imidacloprid: 0.7 mg/kg'    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.1 Thiamethoxam; 0.1,Lambdacyhalothrin',                'Thiamethoxam: 0.1, Lambdacyhalothrin: 0.1'              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.1 Thiamethoxam; 0.1 Lambdacyhalothrin',                'Thiamethoxam: 0.1, Lambdacyhalothrin: 0.1'              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.1 Thiamethoxam; 0.2 Lambdacyhalothrin',                '0.1 Thiamethoxam: 0.2 Lambdacyhalothrin'                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.1 Thiamethoxam; 0.2,Lambdacyhalothrin',                '0.1 Thiamethoxam: 0.2 Lambdacyhalothrin'                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.1 Thiamethoxam: 0.2 Lambdacyhalothrin',                'Thiamethoxam: 0.1, Lambdacyhalothrin: 0.2'              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.15 mg/kg Floupyram; 0.02,mg/kg Trifloxystrobin',       'Floupyram: 0.15 mg/kg,Trifloxystrobin: 0.02 mg/kg'      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.1ppm',                                                 '0.1 ppm'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.2 Thiamethoxam; 0.2 Lambdacyhalothrin',                'Thiamethoxam: 0.2, Lambdacyhalothrin: 0.2'              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.2 Thiamethoxam; 0.2,Lambdacyhalothrin',                'Thiamethoxam: 0.2, Lambdacyhalothrin: 0.2'              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.20 mg/kg',                                             '0.2 mg/kg'                                              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.20 ppm',                                               '0.2 ppm'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.20-2.0 mg/kg',                                         '0.2-2.0 mg/kg'                                          , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.3mg/kg',                                               '0.3 mg/kg'                                              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.3ppm',                                                 '0.3 ppm'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.4 mg/Kg',                                              '0.4 mg/kg'                                              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.40 mg/kg Floupyram; 1.00,mg/kg Trifloxystrobin',       'Floupyram: 0.4 mg/kg, Trifloxystrobin: 1 mg/kg'         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.5 mg/kg Floupyram 0.1,mg/kg Trifloxystrobin',          'Floupyram: 0.5 mg/kg, Trifloxystrobin: 0.1,mg/kg'       , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.5 mg/kg Floupyram 1.0,mg/kg Trifloxystrobin',          'Floupyram: 0.5 mg/kg, Trifloxystrobin: 1,mg/kg'         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.5 ppm Thiamethoxam; 0.5 ppm, Lambdacyhalothrin',       'Thiamethoxam: 0.5 ppm, Lambdacyhalothrin: 0.5 ppm'      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.50 ppm',                                               '0.5 ppm'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.5 Thiamethoxam; 0.2(with pod) Lambdacyhalothrin',      'Thiamethoxam: 0.5, Lambdacyhalothrin: 0.2'              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.5 Thiamethoxam; 0.2(with,pod) Lambdacyhalothrin',      'Thiamethoxam: 0.5, Lambdacyhalothrin: 0.2'              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.5ppm Thiamethoxam;,0.5ppm Lambdacyhalothrin',          'Thiamethoxam: 0.5 ppm, Lambdacyhalothrin: 0.5 ppm'      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.60 mg/kg',                                             '0.6 mg/kg'                                              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.6-mg/kg(Tebuconazole),0.01mg/kg(Fluoxastrobin)',       'Tebuconazole: 0.6 mg/kg, Fluoxastrobin: 0.01 mg/kg'     , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.80 ppm',                                               '0.8 ppm'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '0.90 ppm',                                               '0.9 ppm'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1.0 mg/kg',                                              '1 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1.0 mg/kg, Fluopyram: 1.5 mg/Kg',                        '1 mg/kg, Fluopyram: 1.5 mg/Kg'                          , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1.0 ppm',                                                '1 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1 ppm Thiamethoxam, 0.50 ppm, Lambdacyhalothrin',        'Thiamethoxam: 1 ppm, Lambdacyhalothrin: 0.50 ppm'       , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1 mg/kg Fluopicolide  2mg/kg,Propamocarb HCI',           'Fluopicolide: 1 mg/kg, Propamocarb HCI: 2 mg/kg'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1.0 mg/kg Fluopyram 1.5 mg/Kg',                          '1.0 mg/kg, Fluopyram: 1.5 mg/kg'                        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '1.0ppm Thiamethoxam;,0.50ppm Lambdacyhalothrin',         'Thiamethoxam: 1.0 ppm, Lambdacyhalothrin: 0.50 ppm'     , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '10.0 mg/kg',                                             '10 mg/kg'                                               , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '2.0 mg/Kg',                                              '2 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '2 mg/Kg',                                                '2 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '2.0 ppm',                                                '2 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '2.00 ppm',                                               '2 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '2.0mg/Kg',                                               '2 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '3.0 mg/kg',                                              '3 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '3.0 ppm',                                                '3 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '3.0 mg/kg Floupyram 0.1 mg/kg Trifloxystrobin',          'Floupyram: 3 mg/kg, Trifloxystrobin: 0.1 mg/kg'         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '3.00 ppm',                                               '3 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '3ppm',                                                   '3 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '4.0 ppm',                                                '4 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '5.0 mg/Kg',                                              '5 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '6 mg/Kg',                                                '6 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '5 mg/kg Propamocarb HCI 0.5 mg/kg Fluopicolide',         'Propamocarb HCI: 5 mg/kg, Fluopicolide: 0.5 mg/kg'      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr '5.00 ppm',                                               '5 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.01 mg/Kg; Difenoconazole 0.01 mg/Kg',     'Azoxystrobin: 0.01 mg/kg, Difenoconazole: 0.01 mg/kg'   , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.01 ppm, Difenoconazole 0.01 ppm',         'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm'       , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.05 ppm, Difenoconazole 0.1 ppm',          'Azoxystrobin: 0.05 ppm, Difenoconazole: 0.1 ppm'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.05ppm,Difenoconazole 0.1ppm',             'Azoxystrobin: 0.05 ppm, Difenoconazole 0.1 ppm'         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.06ppm,Difenoconazole 0.4ppm',             'Azoxystrobin: 0.06 ppm, Difenoconazole: 0.4 ppm'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.2 ppm, Difenoconazole 0.07 ppm',          'Azoxystrobin: 0.2 ppm, Difenoconazole: 0.07 ppm'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.2 ppm, Difenoconazole-0.07 ppm',          'Azoxystrobin: 0.2 ppm, Difenoconazole: 0.07 ppm'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.2 ppm, Tebuconazole 0.10 ppm',            'Azoxystrobin: 0.2 ppm, Tebuconazole 0.10 ppm'           , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.2ppm,Difenoconazole 0.07ppm',             'Azoxystrobin: 0.2 ppm, Difenoconazole: 0.07 ppm'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.3 mg/Kg, Difenoconazole 0.3 mg/Kg',       'Azoxystrobin: 0.3 mg/kg, Difenoconazole: 0.3 mg/kg'     , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 0.6ppm,Difenoconazole 0.4ppm',              'Azoxystrobin: 0.6 ppm,Difenoconazole: 0.4 ppm'          , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 1 ppm, Tebuconazole 0.1 ppm',               'Azoxystrobin: 1 ppm, Tebuconazole: 0.1 ppm'             , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin 5.0 ppm, Tebuconazole 1 ppm',               'Azoxystrobin: 5 ppm, Tebuconazole: 1 ppm'               , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm',       'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm'       , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin-0.01,Difenoconazole-0.01',                  'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm'       , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin-0.05,Difenoconazole-0.01',                  'Azoxystrobin: 0.05 ppm, Difenoconazole: 0.01 ppm'       , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin-0.6,Difenoconazole-0.4',                    'Azoxystrobin: 0.6 ppm, Difenoconazole: 0.4 ppm'         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Azoxystrobin-1.0ppm,Tebuconazole-0.1ppm',                'Azoxystrobin 1 ppm, Tebuconazole: 0.1 ppm'              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Beta-cyfluthrin: 0.02 ppm, Imidacloprid: 0.20 ppm',      'Beta-cyfluthrin: 0.02 ppm, Imidacloprid: 0.20 ppm'      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Buprofezin 0.5 ppm, MIPC 0.5 ppm',                       'Buprofezin: 0.5 ppm, MIPC: 0.5 ppm'                     , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Buprofezin 0.5ppm,MIPC 0.5ppm',                          'Buprofezin: 0. 5ppm, MIPC: 0.5 ppm'                     , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Butachlor 0.1 ppm Propanil 0.1 ppm',                     'Butachlor: 0.1 ppm, Propanil: 0.1 ppm'                  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Butachlor 0.1ppm 2,4-D IBE 0.1ppm',                      'Butachlor: 0.1ppm 2,4-D IBE: 0.1 ppm'                   , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Butachlor 0.1ppm,2,4-D IBE 0.1ppm',                      'Butachlor: 0.1ppm,2,4-D IBE 0.1 ppm'                    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Butachlor 0.1ppm,Propanil 0.1ppm',                       'Butachlor: 0.1ppm, Propanil: 0.1 ppm'                   , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Cabbage: 3ppm, broccoli &,cauliflower: 2 ppm',           'Cabbage: 3 ppm, Broccoli & cauliflower: 2 ppm'          , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Cucumber & melon: 0.2 ppm, watermelon and other',        'Cucumber & melon: 0.2 ppm, Watermelon and other'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Cyantraniliprole 4mg/kg,Pymetrozine 1mg/kg',             'Cyantraniliprole: 4 mg/kg, Pymetrozine: 1 mg/kg'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Difenoconazole 0.5 ppm Propiconazole 0.5 ppm',           'Difenoconazole: 0.5 ppm, Propiconazole: 0.5 ppm'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Difenoconazole 0.5ppm,Propiconazole 0.5ppm',             'Difenoconazole: 0.5 ppm, Propiconazole: 0.5 ppm'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Fenoxaprop p-ethyl 0.05 ppm, Ethoxysulfuron 0.01 ppm',   'Fenoxaprop p-ethyl: 0.05 ppm, Ethoxysulfuron: 0.01 ppm' , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Fenoxaprop p-ethyl 0.05ppm,Ethoxysulfuron 0.01 ppm',     'Fenoxaprop p-ethyl: 0.05ppm, Ethoxysulfuron: 0.01 ppm'  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Floupyram: 1.0 mg/kg, Trifloxystobin: 0.7,mg/kg',        'Floupyram: 1.0 mg/kg, Trifloxystobin: 0.7 mg/kg'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Imidacloprid - 0.005 ppm Deltamethrin -  0.02 ppm',      'Imidacloprid: 0.005 ppm, Deltamethrin: 0.02 ppm'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Imidacloprid - 0.005 ppm,Deltamethrin -  0.02 ppm',      'Imidacloprid: 0.005 ppm, Deltamethrin: 0.02 ppm'        , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Imidacloprid - 0.2 ppm,Deltamethrin -  0.5 ppm',         'Imidacloprid: 0.2 ppm, Deltamethrin: 0.5 ppm'           , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Imidacloprid - 0.5 ppm,Deltamethrin -  0.1 ppm',         'Imidacloprid: 0.5 ppm, Deltamethrin: 0.1 ppm'           , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Imidacloprid = 2.0 µg/g, Deltamethrin -  0.5 µg/g',      'Imidacloprid: 2.0 µg/g, Deltamethrin: 0.5 µg/g'         , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'M - 0.2 ppm B - 0.02 ppm',                               'M: 0.2 ppm, B: 0.02 ppm'                                , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Penoxsulam 0.1 ppm',                                     'Penoxsulam: 0.1 ppm'                                    , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Phenthoate 0.05 ppm',                                    'Phenthoate: 0.05 ppm'                                   , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Pyriftalid: 0.02 mg/kg, Bensulfuron-methyl: 0.02 mg/kg', 'Pyriftalid: 0.02 mg/kg, Bensulfuron-methyl: 0.02 mg/kg' , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Tebuconazole 0.05 ppm, Triadimenol-0.2 ppm',             'Tebuconazole: 0.05 ppm, Triadimenol: 0.2 ppm'           , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Tebuconazole 0.09 ppm, Trifloxystrobin 0.08 ppm',        'Tebuconazole: 0.09 ppm, Trifloxystrobin: 0.08 ppm'      , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Tebuconazole-0.01 mg/kg,Trifloxystrobin-0.05 mg/kg',     'Tebuconazole: 0.01 mg/kg, Trifloxystrobin: 0.05 mg/kg'  , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Tebuconazole-0.09,Trifloxystrobin-0.08',                 'Tebuconazole: 0.09, Trifloxystrobin: 0.08'              , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Tebuconazole-1.01 mg/kg,Trifloxystrobin-0.02 mg/kg',     'Tebuconazole: 1 mg/kg, Trifloxystrobin: 0.02 mg/kg'     , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Tetraconazole -0.5ppm,Carbendazim-0.5 ppm',              'Tetraconazole: 0.5ppm, Carbendazim: 0.5 ppm'            , @fixup_cnt OUT
   EXEC sp_s2_fixup_mrl_hlpr 'Triafamone: 0.01 mg/Kg,Ethoxysulfuron: 0.1 mg/Kg',       'Triafamone: 0.01 mg/kg, Ethoxysulfuron: 0.1 mg/kg'      , @fixup_cnt OUT

   EXEC sp_log 2, @fn,'99: leaving OK, @fixup_cnt: ', @fixup_cnt;
END
/*
EXEC sp_fixup_s2_mrl;
*/


GO
