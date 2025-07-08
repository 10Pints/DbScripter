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
--
-- ======================================================================================================
CREATE   VIEW [dbo].[Import_Use_vw]
AS
SELECT u.use_id, u.use_nm
FROM [Use] u;

/*
SELECT TOP 50 * FROM ImportUse_vw;
*/


GO
