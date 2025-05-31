SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON


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
CREATE   PROC [dbo].[sp_fnGetFileDetails] @filePath VARCHAR(600)
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
   ,@t [test].[FileDetailsTbl]
   ;

   EXEC sp_log 1, @fn, '000: starting, @filePath: ',@filePath;

   BEGIN TRY
      SET @len         = dbo.fnLen(@filePath);
      SET @filePathRev = REVERSE(@filePath);
      SET @slashRevPos = CHARINDEX(@bckslsh, @filePathRev);
      SET @dotRevPos   = CHARINDEX('.', @filePathRev);
      SET @dotPos      = iif(@dotRevPos=0, 0, @len - @dotRevPos+1);
      SET @slashPos    = @len - @slashRevPos+1;
      EXEC sp_log 1, @fn, '020 values:
len         = [',@len        ,']
filePathRev = [',@filePathRev,']
slashRevPos = [',@slashRevPos,']
dotRevPos   = [',@dotRevPos  ,']
dotPos      = [',@dotPos     ,']
slashPos    = [',@slashPos   ,']
';
      -- Beware empty file path
      IF (@len > 0) AND (@slashRevPos > 1)
      BEGIN
      EXEC sp_log 1, @fn, '030';
         SET @folder     = REVERSE(SUBSTRING(@filePathRev, @slashRevPos+1, @len - @slashRevPos+1));
         SET @fileNmRev  = SUBSTRING(@filePathRev, @dotRevPos+1, @slashRevPos-@dotRevPos-1);
      EXEC sp_log 1, @fn, '050';
         SET @fileNm     = SUBSTRING(@filePath, @slashPos +1, @len-@slashRevPos); --REVERSE(@fileNmRev);
         SET @ext        = REVERSE(SUBSTRING(@filePathRev, 1, @dotRevPos-1)); -- REVERSE(SUBSTRING(@filePathRev, @dotPos+2, @len-@dotPos-1));
         SET @fileNmNoExt= SUBSTRING(@filePath, @slashPos+1, @dotPos-@slashPos-1);
      EXEC sp_log 1, @fn, '080';
      END
      EXEC sp_log 1, @fn, '090';

      -- If @filePath is just the file name like abc.txt
      IF(CHARINDEX(@bckslsh, @filePath) = 0)
      BEGIN
      EXEC sp_log 1, @fn, '100: @filePath is just the file name like abc.txt';
         SET @fileNm     = @filePath;--SUBSTRING(@folder, 1, @dotPos-1);
         SET @ext        = iif(@len>1 AND (@len-@dotPos > 0), SUBSTRING(@filePath, @dotPos+1, @len-@dotPos), NULL);
      EXEC sp_log 1, @fn, '110';
         SET @slashPos   = 0
         SET @folder     = NULL
         SET @fileNmNoExt= SUBSTRING(@filePath, @slashPos+1, iif(@dotPos = 0, @len,@dotPos-@slashPos-1))
      END

      EXEC sp_log 1, @fn, '120';
      INSERT INTO @t( filePath, folder, FileNm, fileNmNoExt, ext, filePathRev,[len], slashPos, slashRevPos, dotPos, dotRevPos)
      VALUES        (@filePath,@folder,@fileNm,@fileNmNoExt,@ext,@filePathRev,@len ,@slashPos,@slashRevPos,@dotPos,@dotRevPos);
      EXEC sp_log 1, @fn, '130';
      SELECT * FROM @t;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, OK';
   RETURN;
END
/*

D:\Dev\Ut\Tests\test_096_GetFileDetails   CallRegister.abc   txt   39         56       60
SELECT * FROM dbo.fnGetFileDetails('D:\Dev\Farming\Tests\test_096_GetFileDetails\CallRegister.abc.txt')
fn pos rev should be 21
--------------------------------------------------------------------------------
folder                                    file_name         ext   fn_pos   dot_pos  len
--------------------------------------------------------------------------------
DECLARE @s VARCHAR(200) ='D:\Dev\Farming\Tests\test_096_GetFileDetails\CallRegister.abc.txt'
   ,@bckslsh       VARCHAR(1) = NCHAR(92)
SELECT CHARINDEX(@bckslsh,'D:\Dev\Farming\Tests\test_096_GetFileDetails\CallRegister.abc.txt', 20)

SELECT * FROM dbo.fnGetFileDetails(@s)
SELECT SUBSTRING(@s, 41, 56-41+1) as fileName

---------------------------------------------
DECLARE @s VARCHAR(200) ='D:\Dev\Farming\Tests\test_096_GetFileDetails\CallRegister.abc.txt'
   ,@bckslsh       VARCHAR(1) = NCHAR(92)
SELECT dbo.fnLen(@s)
SELECT CHARINDEX(@bckslsh,'txt.cba.retsigeRllaC\sliateDeliFteG_690_tset\stseT\gnimraf\veD\:D')

D:\Dev\Farming\Tests\test_096_GetFileDetails\CallRegister.abc.txt
EXEC tSQLt.Run 'test.test_096_fnGetFileDetails';
*/

GO
