SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: replaces CREAET (Routien) with ALTER (Routine)
-- for use with fnReplaceTabsAndReformat(x,y)
-- =============================================================
CREATE FUNCTION [dbo].[fnReplaceCreateWithAlter]( @sql NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
   RETURN REPLACE(REPLACE(@sql, 'CREATE PROCEDURE', 'ALTER PROCEDURE'), 'ALTER FUNCTION', 'ALTER FUNCTION')
END
GO

