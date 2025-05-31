SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 20-SEP-2024
--
-- Description: Gets the file details from the supplied file path:
--    [Folder, File name without ext, extension, fn_pos, dot_pos, len]
--
-- Tests:
--
-- CHANGES:
-- ======================================================================================================
ALTER FUNCTION [dbo].[fnGetFileDetails]( @filePath VARCHAR(600))
RETURNS
@t TABLE
(
    filePath     VARCHAR(600)
   ,folder       VARCHAR(500)
   ,fileNm       VARCHAR(200)
   ,fileNmNoExt  VARCHAR(200)
   ,ext          VARCHAR(60)
   ,filePathRev  VARCHAR(600)
   ,[len]        INT
   ,slashpos     INT
   ,slashRevPos  INT
   ,dotPos       INT
   ,dotRevPos    INT
)
AS
BEGIN
DECLARE
    @fn           VARCHAR(35)='sp_fnGetFileDetails'
   ,@slashPos     INT
   ,@slashRevPos  INT
   ,@dotPos       INT
   ,@dotRevPos    INT
   ,@len          INT
   ,@fileNm       VARCHAR(200)
   ,@fileNmNoExt  VARCHAR(200)
   ,@fileNmRev    VARCHAR(200)
   ,@folder       VARCHAR(500)
   ,@ext          VARCHAR(60)
   ,@filePathRev  VARCHAR(1000)
   ,@bckslsh      VARCHAR(1) = NCHAR(92)
;

      SET @len         = dbo.fnLen(@filePath);
      SET @filePathRev = REVERSE(@filePath);
      SET @slashRevPos = CHARINDEX(@bckslsh, @filePathRev);
      SET @dotRevPos   = CHARINDEX('.', @filePathRev);
      SET @dotPos      = iif(@dotRevPos=0, 0, @len - @dotRevPos+1);
      SET @slashPos    = @len - @slashRevPos+1;

   -- Beware empty file path
      IF (@len > 0) AND (@slashRevPos > 1)
      BEGIN
         SET @folder     = REVERSE(SUBSTRING(@filePathRev, @slashRevPos+1, @len - @slashRevPos+1));
         SET @fileNmRev  = SUBSTRING(@filePathRev, @dotRevPos+1, @slashRevPos-@dotRevPos-1);
         SET @fileNm     = REVERSE(SUBSTRING(@filePathRev, 1, @slashRevPos-1));
         SET @ext        = REVERSE(SUBSTRING(@filePathRev, 1, @dotRevPos-1));
         SET @fileNmNoExt= SUBSTRING(@filePath, @slashPos+1, @dotPos-@slashPos-1);
      END

      IF(CHARINDEX(@bckslsh, @filePath) = 0)
      BEGIN
         SET @fileNm     = @filePath;
         SET @ext        = iif(@len>1 AND (@len-@dotPos > 0), SUBSTRING(@filePath, @dotPos+1, @len-@dotPos), NULL);
         SET @slashPos   = 0
         SET @folder     = NULL
         SET @fileNmNoExt= SUBSTRING(@filePath, @slashPos+1, iif(@dotPos = 0, @len,@dotPos-@slashPos-1))
      END

      INSERT INTO @t( filePath, folder, FileNm, fileNmNoExt, ext, filePathRev,[len], slashPos, slashRevPos, dotPos, dotRevPos)
      VALUES        (@filePath,@folder,@fileNm,@fileNmNoExt,@ext,@filePathRev,@len ,@slashPos,@slashRevPos,@dotPos,@dotRevPos);
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_096_fnGetFileDetails';
SELECT * FROM dbo.fnGetFileDetails('Caller')

SELECT * FROM dbo.fnGetFileDetails('D:\Dev\Farming\Data\CallRegister.txt.abc')
SELECT * FROM dbo.fnGetFileDetails('D:\Dev\Farming\Data\CallRegister.abc')
SELECT * FROM dbo.fnGetFileDetails('CallRegister.abc.txt')
SELECT * FROM dbo.fnGetFileDetails('')
SELECT * FROM dbo.fnGetFileDetails(NULL)

                   20
D:\Dev\Farming\Data\CallRegister.txt
                17
txt.retsigeRllaC\ataD\gnimraF\veD\:D

            13
CallRegister.txt
SELECT * FROM dbo.fnGetFileDetails('D:\Dev\Farming\Tests\test_096_GetFileDetails\CallRegister.abc.txt')

SELECT * FROM dbo.fnGetFileDetails('LRAP-221018.txt')
*/

GO
