SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 16-MAR-2021
-- Description: Displays header for logging
-- =============================================
CREATE PROCEDURE [dbo].[sp_disp_hdr] @title NVARCHAR(200)
AS
BEGIN
   DECLARE @line  NVARCHAR(200)
         , @NL    NVARCHAR(2) = dbo.fnGetNL()
         , @len   INT         = 0
   SET @len = dbo.fnLen(@title);
   IF @len = 0 SET @len = 80;
   SET @line = SUBSTRING(@line, 1, @len + 5);
   EXEC sp_log '', @line;
   EXEC sp_log '', @title;
   EXEC sp_log '', @line;
END
GO

