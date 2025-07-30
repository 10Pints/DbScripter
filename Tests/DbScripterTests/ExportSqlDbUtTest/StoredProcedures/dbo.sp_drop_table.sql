SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:      Terry Watts
-- Create date: 16-JUN-2025
-- Description: Drops a table if it exists
-- Design:      
-- Tests:       
--
-- PRECONDITIONS:
-- PRE 01 @tbl_nm must be specified NOT NULL or EMPTY Checked
--
-- POSTCONDITIONS:
-- POST01: table does not exist
-- ==============================================================
CREATE PROCEDURE [dbo].[sp_drop_table]
    @q_table_nm        VARCHAR(80)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
     @fn          VARCHAR(35) = 'sp_drop_table'
    ,@sql         NVARCHAR(MAX)
    ,@ret         INT
   ;
   BEGIN TRY
      EXEC sp_log 1, @fn, '000 dropping table [', @q_table_nm, ']';
      -----------------------------------------------------------------
      -- Validation
      -----------------------------------------------------------------
      -- PRE 01 @fk_nm NOT NULL or EMPTY  Checked
      EXEC sp_log 1, @fn, '010 validating checked preconditions';
      SET @q_table_nm = dbo.fnDeLimitIdentifier(@q_table_nm);
      EXEC sp_assert_not_null_or_empty @q_table_nm, '@q_table_nm must be specified', @fn=@fn;
      -- delimit [ brkt name if necessary
      SET @q_table_nm = dbo.fnDeLimitIdentifier(@q_table_nm);
      -- chk if the table existed initially
      SET @ret = dbo.fnTableExists(@q_table_nm);
      SET @sql = CONCAT('DROP table if exists ', @q_table_nm);
      EXEC sp_log 1, @fn, '030 executing the drop Table SQL:
',@sql;
      EXEC (@sql);
      EXEC sp_log 1, @fn, '040 checking postconditions'
      ---------------------------------------------------------
      --- ASSERTION: POST01: table does not exist
      ---------------------------------------------------------
      EXEC sp_assert_tbl_exists @q_table_nm, 0;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 1, @fn, '999: successfully dropped table ', @q_table_nm;
   return @ret; -- table did exist
END
/*
EXEC test.sp__crt_tst_rtns '[dbo].[sp_drop_table]';
*/
GO

