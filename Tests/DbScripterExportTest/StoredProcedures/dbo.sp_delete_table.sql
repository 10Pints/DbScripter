SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================================
-- Author:      Terry Watts
-- Create date: 09-FEB-2024
-- Description:  deletes the table and logs the deletion
--
-- PRECONDITIONS:
--
-- POSTCONDITIONS:
-- =================================================================
CREATE   PROCEDURE [dbo].[sp_delete_table]
   @table VARCHAR(60)
AS
BEGIN
   DECLARE
       @fn     VARCHAR(35)   = 'DELETE_TABLE'
      ,@sql    VARCHAR(max)

   SET NOCOUNT ON;

   BEGIN TRY
      SET @sql = CONCAT('DELETE FROM ', @table, ';');
      EXEC (@sql);
      EXEC sp_log 1, @fn, '10: deleted ', @@ROWCOUNT, ' rows from the ', @table, ' table';
   END TRY
   BEGIN CATCH
      DECLARE @msg VARCHAR(35);
      SET @msg = Ut.dbo.fnGetErrorMsg();
      SET @msg = CONCAT('Error deleting rows from the ', @table,' ', @msg);
      EXEC sp_log 4, @fn, @msg;
      THROW 69403, @msg, 1;
   END CATCH
END
/*
   EXEC sp_delete_table 'ChemicalUseStaging';
*/


GO
