SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2024
-- Description: this view is used to import the PathogenStaging table
--
-- PRECONDITIONS: none
-- ======================================================================================================
ALTER   VIEW [dbo].[Import_PathogenTypeStaging_vw]
AS
SELECT pathogenType_id,pathogenType_nm
FROM PathogenTypeStaging;
/*
SELECT * FROM Import_PathogenTypeStaging_vw;
SELECT * FROM PathogenTypeStaging;
*/


GO
