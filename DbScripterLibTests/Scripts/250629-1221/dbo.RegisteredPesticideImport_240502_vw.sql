SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================
-- Author     : Terry Watts
-- Create date: 05-OCT-2024
-- Description: this view is used in the bulk insert operation 
--    of 230721 format imports
-- ==============================================================
CREATE   VIEW [dbo].[RegisteredPesticideImport_240502_vw]
AS
SELECT 
       id
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
  FROM [dbo].[staging1];

/*
SELECT TOP 50 * FROM RegisteredPesticideImport_240502_vw;
*/


GO
