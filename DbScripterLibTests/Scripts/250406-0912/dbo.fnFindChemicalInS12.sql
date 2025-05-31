SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 30-NOV-2024
-- Description: Chemical Search Utility in S1,S2
-- =============================================
ALTER   FUNCTION [dbo].[fnFindChemicalInS12](@ingredient VARCHAR(60))
RETURNS
@t TABLE
(
    chemical    VARCHAR(250) NULL
   ,product     VARCHAR(250) NULL
   ,pathogens   VARCHAR(250) NULL
   ,crops       VARCHAR(250) NULL
   ,staging_tbl VARCHAR(100) NULL
   ,id          INT
)
AS
BEGIN
   DECLARE @srch VARCHAR(60)
   SET @srch = CONCAT('%', dbo.fnTrim(@ingredient), '%');

   INSERT INTO @t
   SELECT TOP 1000 * FROM
   (
      SELECT ingredient, product, pathogens, crops, 'Staging2' as staging_tbl, id as id
      FROM Staging2
      WHERE pathogens LIKE @srch
      UNION
      SELECT ingredient, product, pathogens, crops, 'Staging1' as staging_tbl, id as id
      FROM Staging1
      WHERE ingredient LIKE @srch
   ) AS x  ORDER BY pathogens,ingredient,product, staging_tbl

   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_047_fnGetCropPathogenChemicalStagingVwData';
SELECT * FROM dbo.fnFindChemicalInS12('Carbaryl') ORDER BY id,staging_tbl;
WHERE staging_tbl='Staging2'
--Carbaryl--
SELECT TOP 100 * from dbo.S2UpdateLog
*/


GO
