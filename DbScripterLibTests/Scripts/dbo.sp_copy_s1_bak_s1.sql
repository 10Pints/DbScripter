SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 17-JUL-2023
-- Description: copies staging1_bak to staging1.
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- ==============================================================================
CREATE PROC [dbo].[sp_copy_s1_bak_s1]
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(30)   = 'CPY S1_BAK STG1'

   EXEC sp_log 2, @fn, 'starting';
   TRUNCATE TABLE staging1;
   --SET IDENTITY_INSERT staging1 ON

   INSERT INTO [dbo].[staging1]
   (
       stg1_id
      ,[company]
      ,[ingredient]
      ,[product]
      ,[concentration]
      ,[formulation_type]
      ,[uses]
      ,[toxicity_category]
      ,[registration]
      ,[expiry]
      ,[entry_mode]
      ,[crops]
      ,[pathogens]
      ,rate
      ,mrl
      ,phi
      ,reentry_period
      ,[notes]
   )
   SELECT 
       stg1_id
      ,[company]
      ,[ingredient]
      ,[product]
      ,[concentration]
      ,[formulation_type]
      ,[uses]
      ,[toxicity_category]
      ,[registration]
      ,[expiry]
      ,[entry_mode]
      ,[crops]
      ,[pathogens]
      ,rate
      ,mrl
      ,phi
      ,reentry_period
      ,[notes]
   FROM staging1_bak;

   --SET IDENTITY_INSERT staging1 OFF
   EXEC sp_log 2, @fn, 'leaving';
END

GO
