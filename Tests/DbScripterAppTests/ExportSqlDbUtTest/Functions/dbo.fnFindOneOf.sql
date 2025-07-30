SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-JAN-2020
-- Description: Finds one of a set of comma sepretd search items in string s
-- Returns:     The 1 based index if found or 0
-- =============================================
CREATE FUNCTION [dbo].[fnFindOneOf]( @items NVARCHAR(500), @s  NVARCHAR(500), @sep NCHAR = ',')
RETURNS INT
AS
BEGIN
   DECLARE @rc INT = 0
   DECLARE @item  NVARCHAR(500)
   IF @sep IS NULL SET @sep =  ','
   SELECT TOP 1 @rc = CHARINDEX(@item, @s) From [dbo].[fnSplit](@items, @sep)
   WHERE CHARINDEX(@item, @s) <> 0;
   
   RETURN @rc
END
GO

