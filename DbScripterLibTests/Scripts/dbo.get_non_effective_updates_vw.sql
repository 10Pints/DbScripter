SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 09-JUL-2023
-- Description: lists the import actions that did not affect any rows
-- ======================================================================================================
ALTER VIEW [dbo].[get_non_effective_updates_vw]
AS
SELECT *
FROM ImportCorrections_vw
WHERE
       act_cnt=0 
   AND doit not in ('0', 'skip')
   AND command <> 'SKIP';

/*
SELECT TOP 50 * FROM GetNonEffectiveUpdates_vw;
*/

GO
