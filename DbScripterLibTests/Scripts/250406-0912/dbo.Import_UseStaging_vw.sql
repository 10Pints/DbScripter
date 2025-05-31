SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 07-NOV-2023
-- Description: this view splits out the individual uses from Staging 2 and the Use table
--
-- PRECONDITIONS: Dependencies:
--                Tables: Staging2, [Use]
--             
-- ======================================================================================================
ALTER   VIEW [dbo].[Import_UseStaging_vw]
AS
SELECT TOP 1000 use_id, use_nm
FROM UseStaging
ORDER BY use_id;
/*
SELECT TOP 50 * FROM ImportUseStaging_vw;
*/


GO
