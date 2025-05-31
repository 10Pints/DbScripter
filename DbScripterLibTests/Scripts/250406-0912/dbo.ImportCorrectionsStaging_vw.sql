SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: slists the import corractions actions and results
--
-- PRECONDITIONS: Dependencies: Staging2 upto date
--   Dependencies: staging2
-- ======================================================================================================
ALTER VIEW [dbo].[ImportCorrectionsStaging_vw]
AS
SELECT
       id
      ,[action]
      ,command
      ,table_nm
      ,field_nm
      ,search_clause
      ,filter_field_nm
      ,filter_op
      ,filter_clause
      ,not_clause
      ,exact_match
      ,cs
      ,replace_clause
      ,field2_nm
      ,field2_op
      ,field2_clause
      ,must_update
      ,comments
  FROM Farming_Dev.dbo.ImportCorrectionsStaging;
/*
SELECT TOP 50 * FROM ImportCorrectionsStaging_vw;
*/

GO
