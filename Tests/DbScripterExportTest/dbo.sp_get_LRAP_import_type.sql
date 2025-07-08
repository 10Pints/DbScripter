SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===================================================================================
-- Author:      Terry Watts
-- Create date: 05-Oct-20243
-- Description: gets the import type id for a given LRAP import - xls or tsv
-- ===================================================================================
CREATE PROCEDURE [dbo].[sp_get_LRAP_import_type]
    @import_file  VARCHAR(500)
   ,@import_id    INT            OUT
AS
BEGIN
   DECLARE
       @fields    VARCHAR(4000) = NULL
      ,@fn        VARCHAR(50)   = 'sp_get_LRAP_import_type'
      ,@file_type BIT

   SET NOCOUNT OFF;

   EXEC sp_log 2, @fn,'000: starting
   import_file:[',@import_file,']';

   EXEC sp_get_flds_frm_hdr_txt
       @file      = @import_file
      ,@fields    = @fields    OUT
      ,@file_type = @file_type OUT
   ;

   SET @fields = LOWER(RTRIM(@fields, ','));
   PRINT @fields;

   SET @import_id =
   CASE 
   WHEN @fields = 'id,company,ingredient,product,concentration,formulation_type,uses,toxicity_category,registration,expiry,entry_mode,crops,pathogens'
      THEN 1
   WHEN @fields = 'id,name of company,active ingredient,product name,concentration,formulation type,use/s,toxicity category,registration no.,expiry date,mode of entry,crops,pests / weeds / diseases'
      THEN 1
   WHEN @fields = 'id,company,active ingredient,product name,concentration,formltn ty,uses,tox cat,registration no.,expiry date,mode of entry,crops,pathogens,recommended rate,mrl,phi,re-entry period'
      THEN 2
   WHEN @fields = 'id,name of company,active ingredient,product name,concentration,formulation type,use/s,toxicity category,registration no.,expiry date,mode of entry,crops,pests / weeds / diseases,recommended rate,mrl (proposed),phi,re-entry period'
      THEN 3
   WHEN @fields = 'id,name of company,active ingredient,product name,concentration,formltn ty,use/s,toxicity category,registration no.,expiry date,mode of entry,crops,pests / weeds / diseases,recommended rate,mrl,phi,re-entry period'
      THEN 3
   WHEN @fields = 'id,name of company,active ingredient,product name,concentration,formulation type,use/s,toxicity category,registration no.,expiry date,mode of entry,crops,pests / weeds / diseases,recommended rate,mrl (proposed),phi,re-entry period'
      THEN 3
   ELSE -1
   END

   EXEC sp_log 1, @fn, '999: leaving, import_id = ', @import_id;
END
/*
ID,NAME OF COMPANY,ACTIVE INGREDIENT,PRODUCT NAME,CONCENTRATION,FORMLTN TY,USE/S,TOXICITY CATEGORY,REGISTRATION NO.,EXPIRY DATE,MODE OF ENTRY,CROPS,PESTS / WEEDS / DISEASES,RECOMMENDED RATE,MRL,PHI,RE-ENTRY PERIOD

   EXEC tSQLt.Run 'test.test_087_sp_get_LRAP_import_type';
   EXEC tSQLt.RunAll;

id,COMPANY,INGREDIENT,PRODUCT,CONCENTRATION,FORMULATION_TYPE,USES,TOXICITY_CATEGORY,REGISTRATION,EXPIRY,ENTRY_MODE,CROPS,Pathogens'
id,NAME OF COMPANY,ACTIVE INGREDIENT,PRODUCT NAME,CONCENTRATION,FORMULATION TYPE,USE/S,TOXICITY CATEGORY,REGISTRATION NO.,EXPIRY DATE,MODE OF ENTRY,CROPS,PESTS / WEEDS / DISEASES'
ID,COMPANY,ACTIVE INGREDIENT,PRODUCT NAME,CONCENTRATION,FORMLTN TY,USES,TOX CAT,REGISTRATION NO.,EXPIRY DATE,MODE OF ENTRY,CROPS,Pathogens,RECOMMENDED RATE,MRL,PHI,RE-ENTRY PERIOD'

 'id,NAME OF COMPANY,ACTIVE INGREDIENT,PRODUCT NAME,CONCENTRATION,FORMULATION TYPE,USE/S,TOXICITY CATEGORY,REGISTRATION NO.,EXPIRY DATE,MODE OF ENTRY,CROPS,PESTS / WEEDS / DISEASES,RECOMMENDED RATE,MRL (Proposed),PHI,RE-ENTRY PERIOD'

*/

GO
