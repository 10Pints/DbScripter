SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================================
-- Author:      Terry Watts
-- Create date: 19-Sep-2024
--
-- Description: Gets the file extension from the supplied file path 
--              without the dot prefix
--
-- Tests:
--
-- CHANGES:
-- 240919: made return null if no extension - not '' as is the case with split fn
-- =================================================================================
ALTER   FUNCTION [dbo].[fnGetFileExtension](@path VARCHAR(MAX))
RETURNS VARCHAR(200)
AS
BEGIN
   DECLARE
    @t TABLE
    (
       id int IDENTITY(1,1) NOT NULL
      ,val VARCHAR(200)
    );

   DECLARE
       @val VARCHAR(4000)
      ,@ndx INT = -1

   INSERT INTO @t(val)
   SELECT value from string_split(@path,'.'); -- ASCII 92 = Backslash
   SET @val = (SELECT TOP 1 val FROM @t ORDER BY id DESC);

   IF dbo.fnLen(@val) = 0 SET @val = NULL;

   RETURN @val;
END
/*
-- For tests see test.test_092_fnGetFileExtension
*/


GO
