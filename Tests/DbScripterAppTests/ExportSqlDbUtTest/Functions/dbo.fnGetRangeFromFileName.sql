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
CREATE FUNCTION [dbo].[fnGetRangeFromFileName](@filePath_inc_rng NVARCHAR(600))
RETURNS
@t TABLE
(
    file_path NVARCHAR(500)
   ,[range]   NVARCHAR(255)
)
AS
BEGIN
   DECLARE 
      @file_path  NVARCHAR(500)
     ,@range      NVARCHAR(255)
     ,@ndx        INT
   SET @ndx       = CHARINDEX('!',@filePath_inc_rng);
   SET @file_path = IIF(@ndx=0, @filePath_inc_rng,  SUBSTRING(@filePath_inc_rng, 1, @ndx-1));
   SET @range     = IIF(@ndx=0, 'Sheet1$', SUBSTRING(@filePath_inc_rng, @ndx+1, 31)); -- Excel range has a max len of 31
   INSERT INTO @t(file_path, [range]) VALUES (@file_path, @range);
   RETURN;
END
/*
   EXEC test.test_fnGetRangeFromFileName;
*/
GO

