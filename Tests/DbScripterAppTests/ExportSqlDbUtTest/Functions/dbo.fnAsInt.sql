SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 18-JAN-2020
-- Description: returns int if int or null if not
-- =============================================
CREATE FUNCTION [dbo].[fnAsInt](@v NVARCHAR(12))
RETURNS INT
AS
BEGIN
   return TRY_CONVERT(int, @v)
END
GO

