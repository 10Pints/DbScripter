SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: checks if table exists 
--    if not throws @ex_num=62250, @ex_msg= '[<table spec>] does not exist.'
-- Parameters:
-- @table_spec <db>.<schema>.<table> or <table>
-- @ex_num default @ex_num=62250
-- @ex_msg default is '[<table spec>] does not exist.'
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_table_exists]
    @table_spec   VARCHAR(60)    -- LIKE dbo.
   ,@ex_num       INT            = NULL OUT
   ,@ex_msg       VARCHAR(500)   = NULL OUT
   ,@fn           VARCHAR(60)    = N'*'
   ,@log_level    INT            = 0
AS
BEGIN
   DECLARE
       @fnThis    VARCHAR(35)   = N'sp_assert_table_exists'
      ,@schema_nm VARCHAR(20)
      ,@table_nm  VARCHAR(60)
      ,@sql       VARCHAR(200)
      ,@n         INT
      ,@exists    BIT

   EXEC sp_log @log_level, @fnThis, '000: starting,
@table_spec:[',@table_spec,']
@ex_num:    [',@ex_num,']
@ex_msg:    [',@ex_msg,']'
;

   IF @ex_num IS NULL SET @ex_num = 62250;
   IF @ex_msg IS NULL SET @ex_msg = CONCAT('[',@table_spec,'] does not exist.');

   IF dbo.fnTableExists(@table_spec) = 0
   BEGIN
      EXEC sp_raise_exception @ex_num, @ex_msg, @fn=@fn;
   END

   EXEC sp_log @log_level, @fnThis, '010: table exists';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_036_sp_chk_table_exists';
*/

GO
