SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 29-MAR-2020
-- Description: returns 1 if character is text or a number
--  @A-Z, a=z, 0-9, _
-- ========================================================
CREATE FUNCTION [dbo].[fnIsText]( @c NVARCHAR(1) )
RETURNS BIT
AS
BEGIN
   DECLARE @v INT;
   SET @v = ASCII(@c);
   RETURN 
      CASE
         WHEN dbo.fnIsNumber( @c) =   1      THEN 1
         WHEN (((@v >= 64) AND (@v<= 90)))   THEN 1
         WHEN (((@v >= 97) AND (@v<=122)))   THEN 1  -- a-z
         WHEN @v = 95                        THEN 1
         ELSE                                     0
      END;
END
GO

