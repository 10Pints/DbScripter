SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ===============================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: Gets the import id from the file header based on its column names
-- CHANGES:
-- 
-- ===============================================================================
CREATE PROC [dbo].[sp_GetImportIdFromFile]
     @LRAP_data_file NVARCHAR(150)
    ,@import_id      INT OUT
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(30)   = 'GET_IMPRT_ID_FRM_FILE'
      ,@is_xl           BIT;

   EXEC sp_log 2, @fn, 'starting';

   -- Get the header row
   SET @is_xl = Ut.dbo.IsExcel( @LRAP_data_file);
   THROW 59000, 'Implement', 1;
   EXEC sp_log 2, @fn, 'leaving';
END


GO
