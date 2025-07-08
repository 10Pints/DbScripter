SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================
-- Author:      Terry Watts
-- Create date: 27-JUN-20223
-- Description: Lists the important S1 fields
-- ============================================
CREATE   VIEW [dbo].[list_staging2_vw]
AS
   SELECT id, [uses], product, ingredient, entry_mode, crops, pathogens, company, notes
   FROM Staging2
/*
SELECT TOP 50 * FROM list_staging2_vw;
*/


GO
