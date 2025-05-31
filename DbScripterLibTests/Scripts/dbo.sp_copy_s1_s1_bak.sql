SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 17-JUL-2023
-- Description: copies staging1 to staging1_bak.
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- ==============================================================================

CREATE PROC [dbo].[sp_copy_s1_s1_bak]
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(30)   = 'CPY STG1 S1_BAK'

   EXEC sp_log 2, @fn, 'starting';
   TRUNCATE TABLE staging1_bak;
   --SET IDENTITY_INSERT staging1_bak ON

   INSERT INTO [dbo].[staging1_bak]
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
   FROM staging1;

  -- SET IDENTITY_INSERT staging1_bak OFF
   EXEC sp_log 2, @fn, 'leaving';
END
/*
EXEC sp_copy_s1_s1_bak
*/

GO
