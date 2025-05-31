SET ANSI_NULLS ON

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
ALTER FUNCTION [dbo].[fnGetFileDetails]
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
       @fn_pos  INT
      ,@dot_pos INT
      ,@len     INT

   SET @len    = dbo.fnLen(@file_path);
   SET @fn_pos = IIF(@len=0, NULL,@len - CHARINDEX('\', REVERSE(@file_path)));
   SET @dot_pos= IIF(@len=0, NULL,@len - CHARINDEX('.', REVERSE(@file_path)));

   INSERT INTO @t(folder, [file_name], ext, fn_pos, dot_pos, [len])
   VALUES
   (
       SUBSTRING(@file_path, 1, @fn_pos)               -- folder
      ,IIF(@len=0, NULL,SUBSTRING(@file_path, @fn_pos +2, @dot_pos-@fn_pos-1)) -- file_name
      ,IIF(@len=0, NULL,SUBSTRING(@file_path, @dot_pos+2, @len-@dot_pos-1))    -- ext
      ,@fn_pos
      ,@dot_pos
      ,@len
   );

   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_096_fnGetFileDetails';
SELECT * FROM dbo.fnGetFileDetails('D:\Dev\Ut\Tests\test_096_GetFileDetails\CallRegister.abc.txt')
*/

GO
