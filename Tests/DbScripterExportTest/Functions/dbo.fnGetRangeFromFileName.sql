SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2023
-- Description:
--  returns a 1 row table holding the file path and the range from the @filePath_inc_rng parameter
--
-- Postconditions:
--   POST01: returns 1 row [file_path, range]
-- ===============================================================================================
CREATE FUNCTION [dbo].[fnGetRangeFromFileName](@filePath_inc_rng VARCHAR(600))
RETURNS
@t TABLE
(
    file_nm   VARCHAR(100)
   ,file_path VARCHAR(500)
   ,[range]   VARCHAR(605)
   ,ext       VARCHAR(20)
   ,ndx       INT
)
AS
BEGIN
   DECLARE
      @file_path  VARCHAR(500)
     ,@file_nm    VARCHAR(100)
     ,@range      VARCHAR(60)
     ,@ndx        INT
     ,@ext        VARCHAR(20)
   SET @ndx       = CHARINDEX('!',@filePath_inc_rng);
   SET @file_path = IIF(@ndx=0, @filePath_inc_rng,  SUBSTRING(@filePath_inc_rng, 1, @ndx-1));
   SELECT
       @ext    = ext
      ,@file_nm= fileNm
   FROM dbo.fnGetFileDetails(@file_path)
   ;
   SET @range= IIF
   (
      @ext IN('xlsx', 'xls')
      ,IIF(
            @ndx=0
            ,'Sheet1$'
            ,SUBSTRING(@filePath_inc_rng, @ndx+1, dbo.fnLen(@filePath_inc_rng)-@ndx)
         )
      ,NULL
   ); -- Excel range has a max len of 31
   INSERT INTO @t(file_nm, file_path, [range], ext, ndx) VALUES (@file_nm, @file_path, @range, @ext, @ndx);
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_013_fnGetRangeFromFileName';
SELECT * FROM dbo.fnGetFileDetails('D:\Dev\Farming\Tests\test_066\LRAP-221018-2.txt');
*/
GO

