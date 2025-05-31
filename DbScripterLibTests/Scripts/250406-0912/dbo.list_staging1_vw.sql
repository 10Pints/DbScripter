SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===========================================
-- Author:      Terry Watts
-- Create date: 27-JUN-20223
-- Description: List the importand S2 fields
-- ===========================================
ALTER   VIEW [dbo].[list_staging1_vw]
AS
   SELECT id, [uses], product, ingredient, entry_mode, crops, pathogens, company, notes
   FROM Staging1;
/*
SELECT TOP 50 * FROM list_staging1_vw;
*/


GO
