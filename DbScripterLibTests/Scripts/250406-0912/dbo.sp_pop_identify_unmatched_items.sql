SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ========================================================================================================
-- Author:      Terry watts
-- Create date: 02-NOV-2024
-- Description: Once the secondary data is established during an LRAP importFor 
-- For each secondary data type identify the list of unmatched items not found in the primary static data
-- ========================================================================================================
ALTER   PROCEDURE [dbo].[sp_pop_identify_unmatched_items]
AS
BEGIN
   SET NOCOUNT ON;
END
/*
EXEC sp_pop_identify_unmatched_items;
*/


GO
