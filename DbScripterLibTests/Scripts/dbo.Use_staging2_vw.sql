SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: this view splits out the individual uses from Staging 2 and the Use table
--
-- PRECONDITIONS: Dependencies:
--                Tables: Staging2, [Use]
-- ======================================================================================================
ALTER VIEW [dbo].[Use_staging2_vw]
AS
SELECT distinct TOP 20000 use_nm
FROM all_vw s
ORDER BY use_nm
/*
SELECT TOP 50 * FROM Use_staging2_vw;
*/

GO
