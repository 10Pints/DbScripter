SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================
-- Author:      Terry Watts
-- Create date: 19-AUG-20223
-- Description: List the Products in order - 
--  use to help look for duplicates and misspellings and errors
-- =================================================================
ALTER   FUNCTION [dbo].[fnListProducts]()
RETURNS 
@t TABLE (pathogen VARCHAR(250))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 100000 
   product 
   FROM Staging2 
   ORDER BY product;

   RETURN 
END
/*
SELECT pathogen from dbo.fnListProducts()
*/


GO
