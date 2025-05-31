SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================================
-- Author:		 Terry Watts
-- Create date: 31-JUL-2023
-- Description: Investigator for chemical name sync
-- ===================================================================
ALTER PROCEDURE [dbo].[sp_investigate_chemical]
   @name NVARCHAR(250)
AS
BEGIN
SELECT distinct name as JapName                    FROM JapChemical  WHERE name        LIKE CONCAT('%',@name,'%');
SELECT distinct chemical_nm                        FROM Chemical     WHERE chemical_nm LIKE CONCAT('%',@name,'%'); 
SELECT distinct ingredient as staging2_name        FROM Staging2     WHERE ingredient  LIKE CONCAT('%',@name,'%');
SELECT distinct ingredient as staging1_name        FROM Staging1     WHERE ingredient  LIKE CONCAT('%',@name,'%');

SELECT 
    stg2_id
   ,ingredient
   ,uses
   ,crops
   ,pathogens
FROM Staging2     
WHERE ingredient  LIKE CONCAT('%',@name,'%');
END
/*
EXEC dbo.sp_investigate_chemical 'Glyphosate%potassium'
*/

GO
