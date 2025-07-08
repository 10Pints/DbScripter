SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================================
-- Author:      Terry Watts
-- Create date: 03-DEC-2024
-- Description: this view is used to import the CropStaging table
--
-- PRECONDITIONS: none
-- ================================================================
CREATE   VIEW [dbo].[Import_CropStaging_vw]
AS
SELECT crop_id, crop_nm, latin_nm, alt_latin_nms, alt_common_nms, taxonomy, notes
FROM CropStaging;

/*
SELECT * FROM Import_CropStaging_vw;
SELECT * FROM CropStaging
*/


GO
