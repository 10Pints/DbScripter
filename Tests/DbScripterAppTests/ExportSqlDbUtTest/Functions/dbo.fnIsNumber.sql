SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 29-MAR-2020
-- Description: returns 1 if character is a number
-- Excluding .+-E
-- ========================================================
CREATE FUNCTION [dbo].[fnIsNumber]( @c NVARCHAR(1) )
RETURNS BIT
AS
BEGIN
   DECLARE @v INT
   SET @v = ASCII(@c);
   RETURN iif (((@v >= 48) AND (@v<=57)), 1, 0);
END
GO

