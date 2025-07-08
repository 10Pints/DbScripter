SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===========================================
-- Author:      Terry Watts
-- Create date: 18-DEC-2019
-- Description: case sensitive compare
-- Returns:     1 if match 0 otherwise
--
-----------------------------------------------
-- Postconditions:               Match Y-1/N=0
-----------------------------------------------
-- POST01: if both NULL                1
-- POST01: if 1 NULL other not null    0
-- POST01: if both NOT NULL AND a = b  1
-- POST01: if both NOT NULL AND a<>b   0
-- ===========================================
CREATE   FUNCTION [dbo].[fnCaseSensistiveCompare]
(
    @a  VARCHAR(MAX)
   ,@b  VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
   DECLARE
       @exp             VARBINARY(40)
      ,@act             VARBINARY(40)
      ,@res             bit  = 0
      ,@exp_is_null     bit  = 0
      ,@act_is_null     bit  = 0

   IF (@a IS NULL)
      SET @exp_is_null = 1;

   IF (@b IS NULL)
      SET @act_is_null = 1;

   -- NULL v NULL is a match
   IF (@a IS NULL) AND (@b IS NULL)
      RETURN 1;

   -- NULL v NOT NULL is a mismatch
   IF ((@a IS NULL) AND (@b IS NOT NULL)) OR ((@b IS NULL) AND (@a IS NOT NULL))
      RETURN 0;

   -- MT v MT 0s a match
   IF ( dbo.fnLEN(@a) = 0) AND ( dbo.fnLEN(@b) = 0)
      RETURN 1;

   SET @exp = CONVERT(VARBINARY(4000), @a);
   SET @act = CONVERT(VARBINARY(4000), @b);

   IF (@exp = 0x) AND (@act = 0x)
   BEGIN
      SET @res = 1;
   END
   ELSE
   BEGIN
      IF @exp = @act
         SET @res = 1;
      ELSE
         SET @res = 0;
   END

   -- ASSERTION @res is never NULL
   RETURN @res;
END
/*
 EXEC test.sp__crt_tst_rtns 'dbo].[fnCaseSensistiveCompare', 36;
 PRINT DB_Name();
CREATE OR ALTER PROCEDURE test.hlpr_037_fnCaseSensistiveCompare -- fnCrtHlprCodeHlprSig*/


GO
