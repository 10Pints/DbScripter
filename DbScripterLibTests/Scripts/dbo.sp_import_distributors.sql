SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 08-OCT-2023
-- Description: Handles the bulk import of theDistributors txt file
-- It does the following:
-- 1: imports the the distributor data into the Distributor,
-- 2: checks the post conditions
--
-- ALGORITHM:
-- Delete the log files if they exist
-- TRUNCATE the table
-- Bulk insert the file
-- Do any fixup
-- Do post condition checks
--
-- PRECONDITIONS:
-- PRE01: none
--
-- POSTCONDITIONS:
-- POST01: Distributor table must have rows
-- POST02: no trailing tabs
-- POST03: double quotes in name or address
--
-- TESTS:
--
-- CHANGES:
-- 240305: imports tsv or xlsx files
--         uses sp_bulk_import now
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_import_distributors]
    @import_file   NVARCHAR(500)
   ,@range         NVARCHAR(100) = 'Distributors$!A:H'
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'IMPRT_DISTRIBUTORS'
      ,@sql                NVARCHAR(MAX)
      ,@cmd                NVARCHAR(MAX)
      ,@error_file         NVARCHAR(400)  = NULL
      ,@error_msg          NVARCHAR(MAX)  = NULL
      ,@table_nm           NVARCHAR(35)   = 'Distributor'
      ,@rc                 INT            = -1
      ,@import_root        NVARCHAR(MAX)  
      ,@pathogen_row_cnt   INT            = -1
      ,@update_row_cnt     INT            = -1
      ,@null_type_row_cnt  INT            = -1
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      EXEC sp_log 1, @fn, '00: starting, @import_file:[',@import_file,']';

      ----------------------------------------------------------------------------------
      -- Process
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '05:clearing Distributor table';
      DELETE FROM Distributor;

      EXEC sp_log 1, @fn, '10:calling sp_bulk_import';
      EXEC dbo.sp_bulk_import 
          @import_file   = @import_file
         ,@table         = 'DistributorStaging'
         ,@view          = 'import_distributors_vw'
         ,@range         = @range
         ,@clr_first     = 1

      ----------------------------------------------------------------------------------
      -- Do any fixup
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '15: doing fixup'

      -- Remove double quotes from address and trailing tabs from the last column
      UPDATE DistributorStaging
      SET
          distributor_name = Ut.dbo.fnTrim2(distributor_name, '"')   -- double quotes
         ,[address]        = Ut.dbo.fnTrim2([address]       , '"')   -- double quotes
         ,[phone 2]        = Ut.dbo.fnTrim ([phone 2]);              -- trailing tabs

      EXEC sp_log 1, @fn, '15: checking post conditions'

      ----------------------------------------------------------------------------------
      -- Check postconditions
      ----------------------------------------------------------------------------------
      -- POST01: Distributor table must have rows
      EXEC sp_chk_tbl_populated 'DistributorStaging';

      -- POST02: no trailing tabs
      EXEC sp_log 2, @fn, '20: chking for trailing spcs'
      IF EXISTS(SELECT 1 FROM DistributorStaging 
         WHERE 
               [distributor_name] LIKE '%'+NCHAR(09)
            OR  region   LIKE '%'+NCHAR(09)
            OR  province LIKE '%'+NCHAR(09)
            OR [address] LIKE '%'+NCHAR(09)
            OR [phone 1] LIKE '%'+NCHAR(09)
            OR [phone 2] LIKE '%'+NCHAR(09)
         )
         THROW 54871, 'At least 1 DistributorStaging table column has a trailing tab',1;

      -- POST03: double quotes in name or address
      EXEC sp_log 2, @fn, '25: chking for trailing spcs'
      IF EXISTS(SELECT 1 FROM DistributorStaging WHERE [distributor_name] LIKE '"%"'
         )
         THROW 54872, 'DistributorStaging.name has wrapping double quotes',1;

      EXEC sp_log 2, @fn, '30: chking for trailing spcs'
      IF EXISTS(SELECT 1 FROM DistributorStaging WHERE [address] LIKE '"%"')
         THROW 54873, 'DistributorStaging.[address] has wrapping double quotes',1;

      -- chk for null rows
      EXEC sp_log 2, @fn, '35: chking for chk for null fields (region,province,manufacturers)'
      SELECT @null_type_row_cnt = COUNT(*)
      FROM DistributorStaging
      WHERE region         IS NULL
         OR province       IS NULL
         OR [address]      IS NULL
         OR manufacturers  IS NULL

      EXEC sp_log 1, @fn, '40: checking POST02: DistributorStaging table has no rows with a null pathogen_type_id';
      SET @error_msg = CONCAT('15: POST02: DistributorStaging table has ',@null_type_row_cnt,' null rows');
      EXEC Ut.dbo.sp_assert_equal 0, @null_type_row_cnt, @error_msg

      EXEC sp_log 1, @fn, '45: POST CONDITION chks passed';

            ----------------------------------------------------------------------------------
      -- Copy DistributorStaging table to Distributor table
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '50: Copying DistributorStaging tble to Distributor table';

      INSERT INTO Distributor ([distributor_id],[distributor_name],[region],[province],[address],[phone 1],[phone 2]) 
      SELECT [distributor_id],[distributor_name],[region],[province],[address],[phone 1],[phone 2]
      FROM DistributorStaging;
      ----------------------------------------------------------------------------------
      -- Completed processing OK
      ----------------------------------------------------------------------------------
      SET @rc = 0; -- OK
      EXEC sp_log 1, @fn, '95:completed import and fixup OK'
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving, RC: ', @rc
   RETURN @RC;
END
/*
EXEC sp_import_distributors 'D:\Dev\Repos\Farming\Data\Distributors.xlsx',--'Distributors$'--'Distributors$!A:H';
SELECT * FROM  Distributor;
SELECT * FROM  Distributor   WHERE name IS NULL OR region is NULL OR province IS NULL OR address IS NULL;
SELECT * FROM Distributor          
WHERE 
   [name]    LIKE '%'+NCHAR(09)
OR  region   LIKE '%'+NCHAR(09)
OR  province LIKE '%'+NCHAR(09)
OR [address] LIKE '%'+NCHAR(09)
OR [phone 1] LIKE '%'+NCHAR(09)
OR [phone 2] LIKE '%'+NCHAR(09)
SELECT * FROM Distributor
*/

GO
