SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 03-Nov-2023
--
-- Description: Gets the file name optionally with the extension from the supplied file path
--
-- Tests:
--
-- CHANGES:
-- 240307: added @with_ext flag parameter to signal to get either the file with or without the extension
-- ======================================================================================================
CREATE   FUNCTION [dbo].[fnGetFileNameFromPath](@path VARCHAR(MAX), @with_ext BIT)
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
   SELECT value from string_split(@path, NCHAR(92)); -- ASCII 92 = Backslash
   SET @val = (SELECT TOP 1 val FROM @t ORDER BY id DESC);

   IF @with_ext = 0
   BEGIN
      SET @ndx = CHARINDEX('.', @val);

      SET @val = IIF(@ndx=0, @val, SUBSTRING(@val, 1, @ndx-1));
   END

   RETURN @val;
END
/*
EXEC test.test_084_fnGetFileNameFromPath;
*/


GO
