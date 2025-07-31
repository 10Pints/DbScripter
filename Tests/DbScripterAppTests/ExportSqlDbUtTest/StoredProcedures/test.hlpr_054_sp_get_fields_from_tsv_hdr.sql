SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: Tests the dbo.sp_get_fields_from_tsv_hdr routine
--
-- Tested rtn desc:
-- gets the fields from the first row of a tsv file
--
-- PRECONDITIONS:
-- PRE 01: @file_path must be specified   OR EXCEPTION 58000, 'file_path must be specified'
-- PRE 02: @file_path exists,             OR EXCEPTION 58001, 'file_path does not exist'
-- 
-- POSTCONDITIONS:
-- POST01:
--
-- CALLED BY:
-- ================================================================================================
CREATE PROCEDURE [test].[hlpr_054_sp_get_fields_from_tsv_hdr]
    @tst_num         NVARCHAR(50)
   ,@file_path       NVARCHAR(500)
   ,@exp_fields      NVARCHAR(4000) = NULL
   ,@exp_ex_num      INT            = NULL
   ,@exp_ex_msg      NVARCHAR(500)  = NULL
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn              NVARCHAR(35)= 'HLPR_get_fields_from_tsv_hdr'
   ,@act_fields      NVARCHAR(4000) = NULL
   ,@act_ex_num      INT            = -1
   ,@act_ex_msg      NVARCHAR(500)
   ,@line            NVARCHAR(80)='------------------------'
   PRINT CONCAT(NCHAR(13), NCHAR(10), @line, ' ', @tst_num, @line);
   EXEC sp_log 1, '000: starting
file_path: [',@file_path,  ']
exp_fields:[',@exp_fields, ']
exp_ex_num:[',@exp_ex_num, ']
exp_ex_msg:[',@exp_ex_msg, ']'
;
   ---------------------------------------------------------------------------
   -- Test setup: none
   ---------------------------------------------------------------------------
   ---------------------------------------------------------------------------
   -- Call tested fn
   ---------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '020: calling tested routine';
   IF @exp_ex_num IS NULL
   BEGIN
      EXEC sp_log 1, @fn, '025: do NOT expect an exception to be thrown';
      EXEC sp_get_fields_from_tsv_hdr
         @file_path = @file_path
        ,@fields    = @act_fields OUT
      EXEC sp_log 1, @fn, '030: an exception was not thrown - which is expected in this test';
   END
   ELSE -- i.e. @exp_ex_num IS NOT NULL
   BEGIN
      BEGIN TRY
         -- Expect exception here
         EXEC sp_log 1, @fn, '035: expect an exception to be thrown';
      EXEC sp_get_fields_from_tsv_hdr
         @file_path = @file_path
        ,@fields    = @act_fields OUT
         EXEC sp_log 4, @fn, '040: expected exception was NOT thrown';
         EXEC tSQLt.Fail 'expected exception was NOT thrown';
      END TRY
      BEGIN CATCH
         EXEC sp_log 1, @fn, '045: an exception was thrown - which is expected';
         EXEC test.sp_tst_hlpr_hndl_ex  @exp_ex_num, @exp_ex_msg;
      END CATCH
      --EXEC tSQLt.AssertEquals 1, @ex_thrown, 'Expected an exception to be thrown, but it was not', @tst_num;
      RETURN -- no more testing if exception thrown
   END
   ---------------------------------------------------------------------------
   -- Test
   ---------------------------------------------------------------------------
   IF @exp_fields IS NOT NULL EXEC tSQLt.AssertEquals @exp_fields, @act_fields, @tst_num;
   EXEC sp_log 1, @fn, '999: all subtests passed';
END
/*
EXEC tSQLt.Run 'test.test_054_sp_get_fields_from_tsv_hdr';
*/
GO

