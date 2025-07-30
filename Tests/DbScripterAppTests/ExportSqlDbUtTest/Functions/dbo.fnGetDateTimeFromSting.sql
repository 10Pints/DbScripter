SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================
-- Author:      Terry Watts
-- Create date: 21-APR-2024
-- Description: Gets a DATETIME2 value from string @s
-- Returns 1 if equal, 0 otherwise
--
-- tests: test.test_022_fnGetTimestamp
-- =========================================================
CREATE FUNCTION [dbo].[fnGetDateTimeFromSting]( @s NVARCHAR(13))
RETURNS DATETIME2
AS
BEGIN
   RETURN
      CONCAT
      (
         '20'
         ,SUBSTRING(@s,1,2)
         ,'-'
         ,SUBSTRING(@s,3,2)
         ,'-'
         ,SUBSTRING(@s,5,2)
         ,' '
         ,SUBSTRING(@s,8,2)
         ,':'
         , SUBSTRING(@s,10,2)
         );
END
/*
PRINT FORMAT( dbo.fnGetDateTimeFromSting('191210-2345'), 'yy-MM-dd HH:mm');
PRINT FORMAT( dbo.fnGetDateTimeFromSting('240421-0900'), 'yy-MM-dd HH:mm');
EXEC tSQLt.Run 'test.test_022_fnGetTimestamp';
EXEC tSQLt.RunAll;
*/
GO

