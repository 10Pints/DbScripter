SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 19-Sep-2024
--
-- Description: Gets the file extension from the supplied file path
--
-- Tests:
--
-- CHANGES:
-- ======================================================================================================
CREATE FUNCTION [dbo].[fnGetFileExtension](@path NVARCHAR(MAX))
RETURNS NVARCHAR(200)
AS
BEGIN
   DECLARE
    @t TABLE
    (
       id int IDENTITY(1,1) NOT NULL
      ,val NVARCHAR(200)
    );
   DECLARE 
       @val NVARCHAR(4000)
      ,@ndx INT = -1
   INSERT INTO @t(val)
   SELECT value from string_split(@path,'.'); -- ASCII 92 = Backslash
   SET @val = (SELECT TOP 1 val FROM @t ORDER BY id DESC);
   IF dbo.fnLen(@val) = 0 SET @val = NULL;
   RETURN @val;
END
/*
EXEC tSQLt.Run 'test.test_092_fnGetFileExtension';
EXEC tSQLt.RunAll;
*/
GO

