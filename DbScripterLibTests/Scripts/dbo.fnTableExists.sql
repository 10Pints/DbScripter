SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: returns true (1) if table exxists else false (0)
-- schema default is dbo
-- =============================================
ALTER FUNCTION [dbo].[fnTableExists](@table_spec NVARCHAR(60))
RETURNS BIT
AS
BEGIN
   DECLARE
       @schema                    NVARCHAR(10)
      ,@table_nm                  NVARCHAR(60)
      ,@n                         INT

   SET @n = CHARINDEX('.', @table_spec)
   SET @schema = CASE WHEN  @n > 0 THEN SUBSTRING( @table_spec, 1, @n-1) ELSE 'dbo' END
   SET @table_nm  = CASE WHEN  @n > 0 THEN SUBSTRING( @table_spec, @n+1, Len(@table_spec)- @n) ELSE @table_spec END

   RETURN 
      CASE 
         WHEN EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_nm AND TABLE_SCHEMA = @schema) 
         THEN 1 
         ELSE 0 
      END
END


GO
