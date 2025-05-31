SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 27-JUN-2023
-- Description: used for teh bulk import of 221008 fmt imports
-- =============================================================
ALTER VIEW [dbo].[RegisteredPesticideImport_221018_vw]
AS
SELECT 
       id
      ,company
      ,ingredient
      ,[product]
      ,concentration
      ,formulation_type
      ,[uses]
      ,toxicity_category
      ,registration
      ,expiry
      ,entry_mode
      ,crops
      ,pathogens
  FROM [dbo].[staging1];
/*
SELECT TOP 50 * FROM RegisteredPesticideImport_221018_vw;
select top 5 * from staging1
*/

GO
