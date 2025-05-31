SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 11-JAN-2025
-- Description: returns the update changes made to S2 pathogens
--              for the given new pathogens search cls
-- Note: the S2 update trigger must be enabled - uses S2UpdateSummary and S2Updatelog tables
--
-- CHANGES:
-- ======================================================================================================
ALTER FUNCTION [dbo].[fnListUpdateChangesForNewPathogens]
(
   @srch_cls VARCHAR(300)
)
RETURNS table
AS RETURN
SELECT fixup_row_id, ic.row_id, row_cnt,v.search_clause, v.replace_clause, updt_id, new_pathogens, old_pathogens, old_crops, new_crops, ic.stg_file
FROM ListUpdateChanges_vw v JOIN ImportCorrections ic ON v.fixup_row_id = ic.id
WHERE new_pathogens like concat('%',@srch_cls, '%')
AND old_pathogens <> new_pathogens;
/*
SELECT * FROM dbo.[fnListUpdateChangesForNewPathogens]('Annual,')
*/

GO
