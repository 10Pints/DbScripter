SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================
-- Author:		Terry Watts
-- Create date: 29-JUL-2023
-- Description: this view is used in the bulk insert operation 
--    of 230721 format imports
-- ==============================================================
ALTER VIEW [dbo].[RegisteredPesticideImport_230721_vw]
AS
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
      ,rate-- as [RECOMMENDED RATE]
      ,mrl
      ,phi
      ,reentry_period
  FROM [dbo].[staging1];

/*
SELECT TOP 50 * FROM RegisteredPesticideImport_230721_vw;
*/


GO
