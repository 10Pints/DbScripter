SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ========================================================
-- Author:      Terry Watts
-- Create date: 18-Nov-2024
-- Description: imports the PrecautionaryStatement table
--
--
-- PRECONDITIONS:
-- none
--
-- POSTCONDITIONS:
-- POST 01:PrecautionaryStatement table is populated
-- ========================================================
CREATE   PROCEDURE [dbo].[sp_import_PrecautionaryStatement]
    @file             VARCHAR(70)
   ,@field_terminator NCHAR(1)
   ,@non_null_flds    VARCHAR(500) = NULL
   ,@display_table    BIT = 0
   ,@first_row        INT = 2
   ,@last_row         INT = NULL
   ,@exp_row_cnt      INT = NULL
   ,@row_cnt          INT = NULL      OUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn   VARCHAR(35) = 'sp_import_PrecautionaryStatement'
      ,@path VARCHAR(600)

   EXEC sp_log 1, @fn, '000: starting
file            :[' ,@file            , ']
field_terminator:[' ,@field_terminator, ']
non_null_flds   :[' ,@non_null_flds   , ']
display_table   :[' ,@display_table   , ']
first_row       :[' ,@first_row       , ']
last_row        :[' ,@last_row        , ']
exp_row_cnt     :[' ,@exp_row_cnt     , ']
row_cnt         :[' ,@row_cnt         , ']'
   ;

   EXEC sp_import_txt_file
       @table           = PrecautionaryStatement
      ,@view            = NULL
      ,@file            = @file
      ,@field_terminator= @field_terminator
      ,@display_table   = @display_table
      ,@first_row       = @first_row
      ,@last_row        = @last_row
      ,@exp_row_cnt     = @exp_row_cnt
      ,@non_null_flds   = @non_null_flds
      ,@row_cnt         = @row_cnt OUT
      ;

   EXEC sp_log 1, @fn, '999: leaving, @row_cnt: ', @row_cnt;
END
/*
   @fn VARCHAR(35) = 'T32_SP_IMPORT_PRECAUTIONARYSTATEMENT' -- fnCrtMnCodeCallHlpr
EXEC tSQLt.Run 'test.test_032_sp_import_PrecautionaryStatement';
EXEC test.sp__crt_tst_rtns '[dbo].[sp_import_PrecautionaryStatement]', 32
*/


GO
