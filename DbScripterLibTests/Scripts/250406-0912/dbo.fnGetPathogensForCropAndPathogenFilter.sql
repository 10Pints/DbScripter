SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 16-OCT-2024
-- Description: 
-- =============================================
ALTER   FUNCTION [dbo].[fnGetPathogensForCropAndPathogenFilter]
(
    @crop      VARCHAR(60)
   ,@pathogen  VARCHAR(60)
)
RETURNS 
@t TABLE
(
    bkt     VARCHAR(255)
   ,value   VARCHAR(255)
   ,cnt     INT
)
AS
BEGIN
   INSERT INTO @t(bkt,value, cnt)
   SELECT TOP 10000 CONCAT('[', value, ']') as bkt, value, count(*) AS cnt
   FROM s12_vw
   CROSS APPLY STRING_SPLIT ( s2_pathogens, ',',1) 
   WHERE s1_crops LIKE CONCAT('%', @crop, '%') AND s2_pathogens LIKE CONCAT('%', @pathogen, '%') AND value like CONCAT('%', @pathogen, '%')
   GROUP BY value
   ORDER BY dbo.fnLen(value) DESC;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetPathogensForCropAndPathogenFilter('Mango','borer');
*/


GO
