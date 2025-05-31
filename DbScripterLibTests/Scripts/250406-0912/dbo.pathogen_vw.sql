SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: lists the pathogens name and other names
--
-- PRECONDITIONS: 
-- Dependencies: Staging2 table
-- ======================================================================================================
ALTER VIEW [dbo].[pathogen_vw]
AS
SELECT TOP 100000 
pathogen_nm, pathogenType_nm, alt_common_nms, latin_nm, alt_latin_nms
FROM Pathogen
ORDER BY pathogen_nm
;
/*
SELECT TOP 50 * FROM pathogen_vw;
*/

GO
