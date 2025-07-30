SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 16-MAR-2020
-- Description: Drop all the SQLTreeO extended properties
-- for testing
-- =============================================
CREATE PROCEDURE [dbo].[sp_sqltreeo_drop_folders] 
AS
BEGIN
   DECLARE
             @cursor        CURSOR
         ,@name          NVARCHAR(100)
         ,@value         NVARCHAR(500)
   
   BEGIN TRY
      SET @cursor = CURSOR FAST_FORWARD FOR SELECT name, value FROM dbo.SQLTreeOConfig;
      OPEN @cursor;
      FETCH NEXT FROM @cursor INTO @name, @value
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- add the dynamic folder if it does not alreaady exist
         IF EXISTS (SELECT 1 FROM TEMPDB.sys.extended_properties WHERE name = @name)
                EXEC TEMPDB.sys.sp_dropextendedproperty @name;
      FETCH NEXT FROM @cursor INTO @name, @value;
      END
   END TRY
   BEGIN CATCH
      CLOSE @cursor;
   END CATCH
END
GO

