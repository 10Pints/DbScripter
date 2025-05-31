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
ALTER   VIEW [dbo].[Import_PathogenStaging_vw]
AS
SELECT
 pathogen_nm
,pathogenType_nm
,subtype
,latin_name
,alt_common_names
,alt_latin_names
,ph_common_names
,crops
,taxonomy
,notes
,urls
FROM PathogenStaging;
/*
SELECT * FROM Import_PathogenStaging_vw;
SELECT * FROM PathogenStaging
*/


GO
