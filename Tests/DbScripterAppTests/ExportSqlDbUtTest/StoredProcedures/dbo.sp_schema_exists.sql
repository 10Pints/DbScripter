SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 14-JUL-2020
-- Description: returns non 0 @schema_id if schema exists, 
-- false otherwise
-- =============================================================
CREATE PROCEDURE [dbo].[sp_schema_exists] 
       @db           NVARCHAR(40)
      ,@schema       NVARCHAR(20)
AS
BEGIN
   DECLARE
      @schema_id    INT
   EXEC @schema_id = dbo.sp_get_schema_id @db, @schema
   RETURN @schema_id;
END
/*
DECLARE @schema_id    INT
EXEC @schema_id = dbo.sp_get_schema_id  'ut', 'test';
PRINT @schema_id
*/
GO

