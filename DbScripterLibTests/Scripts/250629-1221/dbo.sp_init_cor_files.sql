SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Procedure:   sp_init_state
-- Author:      Terry Watts
-- Create date: 14-FEB-2025
-- Description: initialises the Corfiles table
-- Returns      the count of cor files
-- Design:
-- Tests:
-- PRECONDITIONS:
-- PRE 01: ImportState table pop
-- =============================================
CREATE PROCEDURE [dbo].[sp_init_cor_files]
    @cor_files   VARCHAR(500)   = NULL -- must be specified if stage < 5
   ,@import_root VARCHAR(500)
AS
BEGIN
DECLARE
    @fn VARCHAR(35) = 'sp_init_state'
   ,@cor_file_cnt INT
   ;

   SET NOCOUNT ON;
   EXEC sp_log 1, @fn,'000: starting
cor_files   :[', @cor_files       ,']
import_root :[', @import_root ,']
';

   TRUNCATE TABLE CorFiles;

   -- Chkd preconditions
   EXEC sp_assert_tbl_pop 'ImportState','010', @fn=@fn;
   UPDATE ImportState SET import_root = @import_root;

   INSERT into Corfiles([file])
   SELECT value FROM string_split(@cor_files, ',');
   SET @cor_file_cnt = (SELECT COUNT(*) FROM Corfiles);
   EXEC sp_log 1, @fn,'999: leaving, @cor_file_cnt: ',@cor_file_cnt;

   -- Returns the count of cor files
   RETURN @cor_file_cnt;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/

GO
