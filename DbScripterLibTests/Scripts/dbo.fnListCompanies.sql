SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================
-- Author:		 Terry Watts
-- Create date: 17-JUL-20223
-- Description: List the Companies in order - use to
--    look for duplicates and misspellings and errors
-- ===================================================
ALTER FUNCTION [dbo].[fnListCompanies]()
RETURNS 
@t TABLE (company NVARCHAR(250))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 99999  company
   FROM Staging2 
   --WHERE company NOT IN ('', '-','--') AND company IS NOT NULL
   ORDER BY company;

	RETURN 
END
/*
SELECT company from dbo.fnListCompanies();
*/

GO
