SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 23-MAR-2024
-- Description: returns the update changes made to S2 pathogens
-- Note: the S2 update trigger must be enabled - uses S2UpdateSummary and S2Updatelog tables
--
-- CHANGES:
-- ======================================================================================================
ALTER FUNCTION [dbo].[fnListUpdateChangesForFixupId]
(
   @fixup_id INT
)
RETURNS table
AS RETURN
SELECT *
FROM ListUpdateChanges_vw
WHERE fixup_row_id=@fixup_id;
/*
SELECT * FROM dbo.fnListUpdateChangesForFixupId(225)
*/

GO
