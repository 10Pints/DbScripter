SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: list all view rows with nulls in any of the following columns:
--  use_id, crop_id, pathogen_id, Chemical_id, use_id
--
-- PRECONDITIONS: 
--    Dependencies: staging 2 up to date
-- ======================================================================================================
CREATE   VIEW [dbo].[all_vw_with_nulls]
AS
SELECT * FROM ALL_vw 
WHERE product_nm is NULL--product_id is NULL 
   OR use_NM IS NULL 
   OR (crop_NM     IS NULL AND crops <> '-')
   OR (pathogen_NM IS NULL AND pathogens <> '')
   OR chemical_NM  IS NULL 
   OR use_NM       IS NULL
   /*
SELECT * from all_vw_with_nulls --where crop_ID is NULL and CROPS <> '-'
*/


GO
