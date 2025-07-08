SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 10-JAN-2025
-- Description: returns the changes made to S2 pathogens
--              for the given original pathogens search cls
-- Note: the S2 update trigger must be enabled - uses S2UpdateSummary and S2Updatelog tables
--
-- CHANGES:
-- ======================================================================================================
CREATE FUNCTION [dbo].[fnListUpdateChangesForOldPathogens]
(
   @srch_cls VARCHAR(300)
)
RETURNS table
AS RETURN
SELECT fixup_row_id, ic.row_id, row_cnt,v.search_clause, v.replace_clause, updt_id, new_pathogens, old_pathogens, old_crops, new_crops, ic.stg_file
FROM ListUpdateChanges_vw v JOIN ImportCorrections ic ON v.fixup_row_id = ic.id
WHERE old_pathogens like concat('%',@srch_cls, '%')
AND old_pathogens <> new_pathogens;
/*
SELECT * FROM dbo.fnListUpdateChangesForOldPathogens('bollworm,budworm')
*/

GO
