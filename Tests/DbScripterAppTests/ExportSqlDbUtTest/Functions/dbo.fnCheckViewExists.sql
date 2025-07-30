SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-DEC-2019
-- Description: Checks if a view exists
-- Returns      1 if exists, 0 otherwise
-- default schema: dbo
-- =============================================
CREATE FUNCTION [dbo].[fnCheckViewExists]
(
   @table NVARCHAR(100)
   ,@schema NVARCHAR(100) = NULL
)
RETURNS bit
AS
BEGIN
   DECLARE @ret BIT;
   IF @schema IS NULL
      SET @schema = 'dbo';
   SELECT @ret = CASE WHEN
      EXISTS
      (
         SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
         WHERE   TABLE_NAME      = @table
         AND TABLE_SCHEMA    = @schema
      ) THEN 1
      ELSE 0
      END;
   RETURN @ret;
END
GO

