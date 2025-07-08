SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Description: this view displays the pathogens changes in S2 from s2_updateLog
-- Preconditions: 
-- Postconditions:
-- Design:        EA
-- Tests:         EXEC tSQLt.Run 'test.test_<nnn>_List_S2Updates_Pathogens';
-- Author:        Terry Watts
-- Create date: 10-JAN-2025
--
-- CHANGES:
-- ======================================================================================================
CREATE VIEW [dbo].[s2_updateLog_pathogens_vw]
AS
SELECT
 fixup_id
,new_pathogens
,old_pathogens
,old_crops     AS crops
FROM S2UpdateLOG
/*
SELECT TOP 10 * FROM s2_updateLog_pathogens_vw;
SELECT TOP 10 * FROM s2UpdateLog;
*/

GO
