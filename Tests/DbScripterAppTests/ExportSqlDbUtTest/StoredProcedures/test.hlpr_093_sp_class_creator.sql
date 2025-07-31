SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      03-May-2024
-- Description: test helper for the dbo.sp_class_creator routine tests 
--
-- Tested rtn description:
-- C# Class Creator
--=============================================================================================================
CREATE PROCEDURE [test].[hlpr_093_sp_class_creator] -- fnCrtHlprCodeHlprSig
    @tst_num              NVARCHAR(50) -- fnCrtHlprSigParams 16
   ,@tst_key              SQL_VARIANT
   ,@inp_table_name       NVARCHAR(50)
   ,@exp_row_cnt          INT
   ,@exp_line             NVARCHAR(293)
   ,@exp_column_name      NVARCHAR(128)
   ,@exp_data_type        NVARCHAR(128)
   ,@exp_is_nullable      VARCHAR(3)
   ,@exp_newtype          NVARCHAR(128)
   ,@exp_defn             VARCHAR(18)
    -- fnCrtHlprSigExpParamsSp
   ,@exp_ex_num           INT = NULL
   ,@exp_ex_msg NVARCHAR(500) = NULL
   ,@display_script           BIT = 0
AS -- fnCrtHlprCodeBegin
BEGIN
   -- fnCrtHlprCodeDecl
   -- fnCrtHlprCodeDeclCoreParams
   DECLARE
       @fn          NVARCHAR(35) = N'hlpr_093_sp_class_creator'
      ,@act_ex_num  INT
      ,@act_ex_msg  NVARCHAR(500)
      ,@error_msg   NVARCHAR(1000)
   -- fnCrtHlprCodeDeclActParams
      ,@act_row_cnt        INT
      ,@act_Line           NVARCHAR(293)
      ,@act_COLUMN_NAME    NVARCHAR(128)
      ,@act_DATA_TYPE      NVARCHAR(128)
      ,@act_IS_NULLABLE    VARCHAR(3)
      ,@act_NewType        NVARCHAR(128)
      ,@act_defn           VARCHAR(18)
   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @fn, @tst_num;
      -- SETUP:
      -- <TBA>:
      -- fnCrtHlprCodeCallBloc
      -- RUN tested procedure: -- SP-RN-TST
      EXEC sp_log 1, @fn, '005: running sp_class_creator';
      -- @rtn_ty_code:P
   WHILE 1 = 1 -- fnCrtHlprCodeCallProc]
   BEGIN
      BEGIN TRY
         DROP TABLE IF EXISTS test.results;
         CREATE TABLE test.results
         (
             Line          NVARCHAR(293)
            ,COLUMN_NAME   NVARCHAR(128)
            ,DATA_TYPE     NVARCHAR(128)
            ,IS_NULLABLE   VARCHAR(3)
            ,NewType       NVARCHAR(128)
            ,defn          VARCHAR(18)
         )
         EXEC sp_log 1, @fn, '010: Calling tested routine: dbo.sp_class_creator';
          --this may fail if there is dynamic SQL in the SP
          --the SELECT INTO EXEC will fail if there is dynamic SQL in the SP
          --in which case manually create the results table based on the sp output 
         INSERT INTO test.Results EXEC dbo.sp_class_creator
             @table_name      = @inp_table_name
         ;
         IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
         BEGIN
            EXEC sp_log 4, @fn, '010: oops! Expected exception was not thrown';
            THROW 51000, ' Expected exception was not thrown', 1;
         END
      END TRY
      BEGIN CATCH
         SET @act_ex_num = ERROR_NUMBER();
         SET @act_ex_msg = ERROR_MESSAGE();
         EXEC sp_log 1, @fn, '015: caught exception', @act_ex_num, @act_ex_msg;
            EXEC sp_log 1, @fn, '020 check ex num , exp: ', @exp_ex_num, ' act: ', @act_ex_num;
         EXEC sp_log_exception @fn;
         IF @exp_ex_num IS NULL AND @exp_ex_msg IS NULL
         BEGIN
            EXEC sp_log 4, @fn, '08: oops! Unexpected an exception here';
            THROW 51000, ' caught unexpected exception', 1;
         END
         ------------------------------------------------------------
         -- ASSERTION: if here then expected exception
         ------------------------------------------------------------
         IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num        ,'ex_num mismatch';
         IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg        ,'ex_msg mismatch';
         
         EXEC sp_log 2, @fn, '030 test# ',@tst_num, ': exception test PASSED;'
         BREAK
      END CATCH
      -- TEST:
      EXEC sp_log 2, @fn, '10: running tests...';
      -- fnCrtHlprCodeChkExps
      IF @exp_row_cnt        IS NOT NULL EXEC tSQLt.AssertEquals @exp_row_cnt       , @act_row_cnt       ,'row_cnt        4'
      IF @exp_Line           IS NOT NULL EXEC tSQLt.AssertEquals @exp_Line          , @act_Line          ,'Line           5'
      IF @exp_COLUMN_NAME    IS NOT NULL EXEC tSQLt.AssertEquals @exp_COLUMN_NAME   , @act_COLUMN_NAME   ,'COLUMN_NAME    6'
      IF @exp_DATA_TYPE      IS NOT NULL EXEC tSQLt.AssertEquals @exp_DATA_TYPE     , @act_DATA_TYPE     ,'DATA_TYPE      7'
      IF @exp_IS_NULLABLE    IS NOT NULL EXEC tSQLt.AssertEquals @exp_IS_NULLABLE   , @act_IS_NULLABLE   ,'IS_NULLABLE    8'
      IF @exp_NewType        IS NOT NULL EXEC tSQLt.AssertEquals @exp_NewType       , @act_NewType       ,'NewType        9'
      IF @exp_defn           IS NOT NULL EXEC tSQLt.AssertEquals @exp_defn          , @act_defn          ,'defn           10'
      -- passed tests
      BREAK
   END --WHILE
   EXEC sp_log 2, @fn, '17: all tests ran OK'
   EXEC test.sp_tst_hlpr_hndl_success;
      -- Tests:-- fnCrtHlprCodeTestBloc
      -- CLEANUP: -- CRT-HLPR-CLS-BLOC
      -- <TBD>
      EXEC test.sp_tst_hlpr_hndl_success;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
END
/*
   EXEC tSQLt.Run 'test.test_093_sp_class_creator';
*/
GO

