SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 25-MAR-2024
-- Description: List the S2 update changes e.g. after fixup XL has run
--
-- PRECONDITIONS: none
--
-- ======================================================================================================
ALTER VIEW [dbo].[ListUpdateChanges_vw]
AS
SELECT
    s.id as sum_id
   ,s.fixup_row_id
   ,imp_file_nm
   ,row_cnt
   ,search_clause
   ,replace_clause
   ,L.id as updt_id
   ,old_pathogens
   ,new_pathogens
   ,old_crops
   ,new_crops
FROM S2UpdateSummary s LEFT JOIN S2Updatelog L ON s.fixup_row_id=L.fixup_id
/*
SELECT TOP 50 * FROM ListUpdatePathogenChanges_vw 
WHERE new_pathogens LIKE '%Nematodess%' and old_pathogens NOT LIKE '%Nematodess%';
SELECT top 10 * FROM S2UpdateSummary;
*/

GO
