SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================
-- Author:      Terry Watts
-- Create date: 10-MAY-2012
-- Description: returns the substring in sql starting at pos until new line 
--              or 100 chars max, or the remaining string whichever is the 
--              the shortest
-- =========================================================================
CREATE FUNCTION [dbo].[fnGetLine]( @sql NVARCHAR(MAX), @pos INT)
RETURNS NVARCHAR(100)
AS
BEGIN
   RETURN dbo.fnGetLine2(@sql, @pos, 100)
END
GO

