SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================
-- Author:      Terry Watts
-- Create date: 08-MAR-2024
-- Description: Lists the Applog in descending order - can filter rows by parameter
--
-- Tests: test.test_fnListApplog
--
-- Changes:
-- ===========================================================================================================
ALTER FUNCTION [dbo].[fnListApplog]
(
    @fnFilter     NVARCHAR(50)   -- DEFAULT = ALL
   ,@msgFilter    NVARCHAR(128)  -- DEFAULT = ALL
   ,@idFilter     INT            -- DEFAULT = ALL
   ,@levelFilter  INT            -- DEFAULT = ALL
   ,@asc          BIT            -- DEFAULT = DESC
)
RETURNS @t TABLE
(
    id         INT
   ,fn         NVARCHAR(50)
   ,[msg                                                                                                                            .] NVARCHAR(128)
   ,[msg2                                                                                                                           .] NVARCHAR(128)
   ,[level]    INT
   ,row_count  INT
)
AS
BEGIN
   IF @asc IS NULL SET @asc = 0; -- DEFAULT = DESC

   IF @asc = 1
   BEGIN
      INSERT INTO @t(
          id
         ,fn
         ,[msg                                                                                                                            .]
         ,[msg2                                                                                                                           .]
         ,[level]
         ,row_count)
      SELECT
          id
         ,fn
         ,[msg                                                                                                                            .]
         ,[msg2                                                                                                                           .]
         ,[level]
         ,row_count
      FROM applog_vw_asc
      WHERE
         (fn LIKE @fnFilter       OR @fnFilter    IS NULL)
     AND ([msg                                                                                                                            .] LIKE @msgFilter 
                                  OR @msgFilter   IS NULL)
     AND (id      >= @idFilter    OR @idFilter    IS NULL)
     AND ([level] >= @levelFilter OR @levelFilter IS NULL)
   END
   ELSE
   BEGIN
      INSERT INTO @t(
          id
         ,fn
         ,[msg                                                                                                                            .]
         ,[msg2                                                                                                                           .]
         ,[level]
         ,row_count)
      SELECT
          id
         ,fn
         ,[msg                                                                                                                            .]
         ,[msg2                                                                                                                           .]
         ,[level]
         ,row_count
      FROM applog_vw_desc
      WHERE
         (fn LIKE @fnFilter       OR @fnFilter    IS NULL)
     AND ([msg                                                                                                                            .] LIKE @msgFilter 
                                  OR @msgFilter   IS NULL)
     AND (id      >= @idFilter    OR @idFilter    IS NULL)
     AND ([level] >= @levelFilter OR @levelFilter IS NULL)
   END;

   RETURN;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_fnListApplog';
--                             fn    msg   id    level
SELECT * FROM dbo.fnListApplog( NULL, NULL, NULL, NULL, 1);
SELECT * FROM dbo.fnListApplog('IMPORT_STATIC_DATA%', NULL, NULL, NULL, 1);
SELECT * FROM dbo.fnListApplog('IMPORT_STATIC_DATA%', '%exception%', NULL, NULL, 1);
SELECT * FROM dbo.fnListApplog('IMPORT_STATIC_DATA%', NULL, NULL, 2);
SELECT * FROM dbo.fnListApplog('MN_IMPORT%', NULL, 260, NULL, 1);
*/

GO
