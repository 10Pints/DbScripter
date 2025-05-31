SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================================================
-- Author:      Terry Watts
-- Create date: 21-JUN-20223
-- Description: List the Pathogens in order - use to
--    look for duplicates and misspellings and errors
--
--    *** NB: use list_unregistered_pathogens_vw in preference to fnListPathogens()
--    as fnListPathogens returns a false leading space on some items
-- ========================================================================================
ALTER FUNCTION [dbo].[fnFndPathogens]
(
   @srch_cls VARCHAR(200)
)
RETURNS
@t TABLE
(
    pathogen_nm      VARCHAR(100)
   ,alt_common_names VARCHAR(200)
   ,latin_name       VARCHAR(150)
   ,alt_latin_names  VARCHAR(200)
   ,ph_common_names  VARCHAR(50)
   ,crops            VARCHAR(500)
)
AS
BEGIN
   INSERT INTO @t
   SELECT
       pathogen_nm
      ,alt_common_nms
      ,latin_nm
      ,alt_latin_nms
      ,ph_common_nms
      ,crops
   FROM Pathogen
   WHERE pathogen_nm      LIKE CONCAT('%',@srch_cls,'%')
      OR alt_common_nms LIKE CONCAT('%',@srch_cls,'%')
      OR ph_common_nms  LIKE CONCAT('%',@srch_cls,'%')
   ;

   RETURN;
END
/*
SELECT * from dbo.fnFndPathogens('WEEVIL');
*/

GO
