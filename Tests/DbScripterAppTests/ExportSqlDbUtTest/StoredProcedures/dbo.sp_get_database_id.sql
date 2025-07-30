SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 14-JUL-2020
-- Description: returns datbase id if datbase exists, 0 otherwise
-- ===============================================================
CREATE PROCEDURE [dbo].[sp_get_database_id]
       @db           NVARCHAR(40)
AS
BEGIN
   DECLARE
       @schema_id    INT
   SET NOCOUNT ON;
   SET @schema_id = DB_ID();
   --PRINT @schema_id;
   RETURN @schema_id;
END
GO

