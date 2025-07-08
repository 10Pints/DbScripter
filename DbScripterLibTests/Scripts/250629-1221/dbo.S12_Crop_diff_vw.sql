SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: this view compares staging1 and 2
--
-- ======================================================================================================
CREATE   VIEW [dbo].[S12_Crop_diff_vw]
AS
SELECT sb.id, sb.crops as sb_crops, s1.crops as s1_crops 
FROM staging1_bak sb FULL JOIN staging1 s1 ON sb.id=s1.id;

/*
SELECT TOP 50 * FROM S12_Crop_diff_vw;
*/


GO
