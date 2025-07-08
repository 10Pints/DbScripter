SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 29-NOV-2024
-- Description: Pathogen Search Utility in S1,S2
-- =============================================
CREATE   FUNCTION [dbo].[fnFindPathogenInS12](@pathogen VARCHAR(60))
RETURNS
@t TABLE
(
   staging_tbl VARCHAR(100) NULL,
   id          INT,
   pathogens   VARCHAR(250) NULL,
   crops       VARCHAR(250) NULL,
   chemical    VARCHAR(250) NULL

)
AS
BEGIN
   DECLARE @srch VARCHAR(60)

   SET @srch = CONCAT('%', dbo.fnTrim(@pathogen), '%');
--   INSERT INTO @t (staging_tbl)values( @srch);

   INSERT INTO @t
   SELECT TOP 10000 * FROM
   (
      SELECT 'Staging2' as staging_tbl, id as id, pathogens, crops, ingredient
      FROM Staging2
      WHERE pathogens LIKE @srch
      UNION
      SELECT 'Staging1' as staging_tbl, id as id, pathogens, crops, ingredient
      FROM Staging1
      WHERE pathogens LIKE @srch
   ) as x  ORDER BY id,staging_tbl

   RETURN;
END
/*
SELECT * FROM dbo.fnFindPathogenInS12('Sooty')     ORDER BY id,staging_tbl;
SELECT * FROM dbo.fnFindPathogenInS12('Alternaria')ORDER BY id,staging_tbl;
print CONCAT(dbo.fnTrim('Flea%beetle
'),']');
print 1
*/


GO
