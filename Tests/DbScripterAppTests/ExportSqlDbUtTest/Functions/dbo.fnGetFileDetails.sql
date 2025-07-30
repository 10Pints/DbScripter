SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 20-SEP-2024
--
-- Description: Gets the file details from the supplied file path:
--    [Folder, File name woyhout ext, extension]
--
-- Tests:
--
-- CHANGES:
-- ======================================================================================================
CREATE FUNCTION [dbo].[fnGetFileDetails]
(
   @file_path NVARCHAR(MAX)
)
RETURNS
@t TABLE
(
    folder        NVARCHAR(MAX)
   ,[file_name]   NVARCHAR(MAX)
   ,ext           NVARCHAR(MAX)
   ,fn_pos        INT
   ,dot_pos       INT
   ,[len]         INT
)
AS
BEGIN
   DECLARE
       @fn_pos        INT --  = 0
      ,@dot_pos       INT --  = 0
      ,@len           INT
      ,@file_name     NVARCHAR(MAX)
      ,@folder        NVARCHAR(MAX)
      ,@ext           NVARCHAR(MAX)
      ,@file_path_rev NVARCHAR(MAX)
   SET @len       = dbo.fnLen(@file_path);
   IF (@len <> 0) AND (CHARINDEX('\', @file_path) <> 0)
   BEGIN
      SET @file_path_rev = REVERSE(@file_path);
      SET @fn_pos    = CHARINDEX('\', @file_path_rev);
      SET @dot_pos   = CHARINDEX('.', @file_path_rev);
      SET @folder    = REVERSE(SUBSTRING(@file_path_rev, @fn_pos+1, @len - @fn_pos+1));
      SET @file_name = REVERSE(SUBSTRING(@file_path_rev, @dot_pos+1, @fn_pos-@dot_pos-1)); --REVERSE(SUBSTRING(@file_path_rev, 1, @dot_pos));
      SET @ext       = REVERSE(SUBSTRING(@file_path_rev, 1, @dot_pos-1)); -- REVERSE(SUBSTRING(@file_path_rev, @dot_pos+2, @len-@dot_pos-1));
      SET @fn_pos    = @len - @fn_pos;
      SET @dot_pos   = @len - @dot_pos;
   END
   INSERT INTO @t(folder, [file_name], ext, fn_pos, dot_pos, [len])
   VALUES
   (
       @folder    --SUBSTRING(@file_path, 1, @fn_pos)               -- folder
      ,@file_name --IIF(@len=0, NULL,SUBSTRING(@file_path, @fn_pos +2, @dot_pos-@fn_pos-1)) -- file_name
      ,@ext       --IIF(@len=0, NULL,SUBSTRING(@file_path, @dot_pos+2, @len-@dot_pos-1))    -- ext
      ,@fn_pos
      ,@dot_pos
      ,@len
   );
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_096_fnGetFileDetails';
SELECT * FROM dbo.fnGetFileDetails('D:\Dev\Ut\Tests\test_096_GetFileDetails\CallRegister.abc.txt')
SELECT * FROM dbo.fnGetFileDetails('CallRegister.abc.txt')
*/
GO

