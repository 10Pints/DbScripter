SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 14-JUL-2020
-- Description: returns non 0 @schema_id if database exists,
-- false otherwise
-- =============================================================
CREATE PROCEDURE [dbo].[sp_database_exists] 
       @db_nm           NVARCHAR(40)
AS
BEGIN
   DECLARE
      @db_id    INT = 0
   EXEC @db_id = dbo.sp_get_database_id @db_nm
   RETURN @db_id;
END
/*
DECLARE @schema_id    INT
EXEC @schema_id = dbo.sp_database_exists  'ut';
PRINT @schema_id
*/
GO

