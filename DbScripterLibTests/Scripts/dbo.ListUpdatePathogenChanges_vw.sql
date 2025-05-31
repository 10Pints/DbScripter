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
ALTER VIEW [dbo].[ListUpdatePathogenChanges_vw]
AS
SELECT s.id, s.fixup_id,row_cnt,search_clause,replace_clause,L.stg2_id,L.old_pathogens, L.new_pathogens
FROM S2UpdateSummary s
LEFT JOIN S2Updatelog L ON s.fixup_id=L.fixup_id

/*
SELECT TOP 50 * FROM ListUpdatePathogenChanges_vw 
WHERE new_pathogens LIKE '%Nematodess%' and old_pathogens NOT LIKE '%Nematodess%';
*/

GO
