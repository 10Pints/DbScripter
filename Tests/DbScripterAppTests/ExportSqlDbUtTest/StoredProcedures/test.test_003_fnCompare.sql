SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: Tests the finction fnCompare
-- =============================================
CREATE PROCEDURE [test].[test_003_fnCompare]
AS
BEGIN
   DECLARE
       @fn                       NVARCHAR(30)    =   'test 003 fnCompare'
      ,@rc                       INT
      ,@folder                   NVARCHAR(260)
      ,@cursor                   CURSOR
      ,@workbook_nm              NVARCHAR(100)  -- file name
      ,@workbook_path            NVARCHAR(260)
      ,@exp_workbook_path        NVARCHAR(260)
      ,@exp_extension            NVARCHAR(50)
      ,@exp_clause               NVARCHAR(4000)
      ,@act_clause               NVARCHAR(4000)
      ,@xl_cols                  NVARCHAR(1000)
      ,@range                    NVARCHAR(50)
      ,@bgy_table_nm             NVARCHAR(50)  -- for testing - change target table
      ,@per_table_nm             NVARCHAR(50)  -- for testing - change target table
      ,@match                    BIT
      ,@msg                      NVARCHAR(150)
      ,@tst_count_tot            INT             = 5
      ,@tst_count_passed         INT             = 0
      ,@error_msg                NVARCHAR(200)
   BEGIN TRY
      SET NOCOUNT ON
      EXEC sp_log 1, @fn,'01: starting'
      EXEC test.sp_tst_mn_st @fn;
      --EXEC sp_log 1, @fn,'02: running test T003.01'
      -- Mismatch on penultimate character
      EXEC test.hlpr_003_fnCompare
          @test_num  = 'T003.01'
         ,@a         = 'String 1 '
         ,@b         = 'String 2 '
         ,@exp_pos   = 8
         ,@exp_char_a= '1'
         ,@exp_char_b= '2'
         ;
      -- Mismatch on first character
      EXEC sp_log 1, @fn,'03: '
      SET @rc = dbo.fnCompare('String 1', 'String 2');
      --EXEC sp_log 1, @fn,'04: running test T003.02'
      EXEC test.hlpr_003_fnCompare
          @test_num  = 'T003.02: mismatch on first character'
         ,@a         = 'string 1'
         ,@b         = 'String 2'
         ,@exp_pos   = 1
         ,@exp_char_a= 's'
         ,@exp_char_b= 'S'
         ;
      -- Mismatch on S1 longer than S2
      --EXEC sp_log 1, @fn,'05: running test T003.03'
      EXEC test.hlpr_003_fnCompare
          @test_num  = 'T003.03 S1 longer than S2'
         ,@a         = 'String 1 '
         ,@b         = 'String 1'
         ,@exp_pos   = 9
         ,@exp_char_a= ' '
         ,@exp_char_b= 'NULL'
         ;
      -- Mismatch on Null/non null
      --EXEC sp_log 1, @fn,'06: running test T003.04'
      EXEC test.hlpr_003_fnCompare 
          @test_num  = 'T003.04: mismtch on null/non null'
         ,@a         = null
         ,@b         = ''
         ,@exp_pos   = 1
         ,@exp_char_a= 'NULL'
         ,@exp_char_b= 'NULL'
         ;
      -- Mismatch on non null/null
      --EXEC sp_log 1, @fn,'07: running test T003.05'
      EXEC test.hlpr_003_fnCompare
          @test_num  = 'T003.05: mismatch on null/non null'
         ,@a         = ''
         ,@b         = null
         ,@exp_pos   = 1
         ,@exp_char_a= 'NULL'
         ,@exp_char_b= 'NULL'
         ;
      -- Mismatch on null/null
      --EXEC sp_log 1, @fn,'08: running test T003.06'
      EXEC test.hlpr_003_fnCompare
          @test_num  = 'T003.06: match on null/null'
         ,@a         = NULL
         ,@b         = NULL
         ,@exp_pos   = 0
         ,@exp_char_a= 'NULL'
         ,@exp_char_b= 'NULL'
         ;
      -- Mismatch on null/non null
      --EXEC sp_log 1, @fn,'09: running test T003.07'
      EXEC test.hlpr_003_fnCompare
          @test_num  = 'T003.07: match on null/null'
         ,@a         = NULL
         ,@b         = "asdfghj"
         ,@exp_pos   = 1
         ,@exp_char_a= 'NULL'
         ,@exp_char_b= 'a'
         ;
      -- Mismatch on null/non null
      --EXEC sp_log 1, @fn,'10: running test T003.08'
      EXEC test.hlpr_003_fnCompare
          @test_num  = 'T003.08: match on null/null'
         ,@a         = "asdfghj"
         ,@b         = NULL
         ,@exp_pos   = 1
         ,@exp_char_a= 'a'
         ,@exp_char_b= 'NULL'
         ;
      EXEC sp_log 1, @fn,'11: completed tests ok';
      EXEC ut.test.sp_tst_mn_cls;
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
   EXEC sp_log 1, @fn,'99: leaving OK, all tests PASSED';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_003_fnCompare';
*/
GO

