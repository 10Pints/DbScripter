SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===================================================
-- Author:      Terry Watts
-- Create date: 17-JUL-2023
-- Description: List the Companies in Staging2
--    look for duplicates and misspellings and errors
-- ===================================================
CREATE   FUNCTION [dbo].[fnListS2Companies]()
RETURNS
@t TABLE (company VARCHAR(250))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 10000 company
   FROM Staging2
   ORDER BY company;

   RETURN;
END
/*
SELECT company from dbo.fnListS2Companies();
*/


GO
