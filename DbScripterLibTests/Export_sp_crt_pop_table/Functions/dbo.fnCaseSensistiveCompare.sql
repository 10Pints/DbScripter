SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 18-DEC-2019
-- Description: case sensitive compare helper function
-- Returns:     1 if match false 0
-- =============================================
CREATE FUNCTION [dbo].[fnCaseSensistiveCompare]
(
    @exp        VARCHAR(MAX)
   ,@act        VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
   IF @exp IS NULL AND @act IS NULL
      RETURN 1;

   IF (@exp IS NULL     AND @act IS NOT NULL) OR
      (@exp IS NOT NULL AND @act IS NULL)
      RETURN 0;

   RETURN IIF( @exp COLLATE Latin1_General_CS_AS  = @act COLLATE Latin1_General_CS_AS
   , 1, 0);
END
/*
   
   IF (@expected IS NULL)
      SET @exp_is_null = 1;

   IF (@actual IS NULL)
      SET @act_is_null = 1;

   IF (@exp_is_null = 1) AND (@act_is_null = 1)
      RETURN 1;

   IF (@exp_is_null = 1) AND (@act_is_null = 1)
      RETURN 1;

   IF ( dbo.fnLEN(@expected) = 0) AND ( dbo.fnLEN(@actual) = 0)
      RETURN 1;

   SET @exp = CONVERT(VARBINARY(8000), @expected);
   SET @act = CONVERT(VARBINARY(8000), @actual);

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
*/

GO
