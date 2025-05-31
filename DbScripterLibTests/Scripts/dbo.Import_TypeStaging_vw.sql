SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 08-MARL-2024
-- Description: this view splits out the individual uses from Staging 2 and the Use table
--
-- PRECONDITIONS: Dependencies:
--                Tables: Staging2, [Use]
--
-- ======================================================================================================
ALTER VIEW [dbo].[Import_TypeStaging_vw]
AS
SELECT [type_id], type_nm
FROM TypeStaging;
/*
SELECT * FROM Import_TypeStaging_vw;
*/

GO
