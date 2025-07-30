SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 23-JUL-2024
-- Description: upgraded the tested rtn to return a row of data
-- =============================================================
CREATE PROCEDURE [test].[hlpr_029_fnGetRtnDetails]
    @tst_num       NVARCHAR(100)
   ,@qrn           NVARCHAR(100)
   ,@exp_schema_nm NVARCHAR(32)   = NULL
   ,@exp_rtn_nm    NVARCHAR(4000) = NULL
   ,@exp_rtn_ty    NVARCHAR(20)   = NULL
   ,@exp_ty_code   NVARCHAR(25)   = NULL
   ,@exp_is_clr    BIT            = NULL
   ,@expect_null   BIT            = NULL
   ,@exp_ex_num    INT            = NULL
   ,@exp_ex_msg    NVARCHAR(MAX)  = NULL
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35) = 'HLPR_021_FN_GET_RTN_DETS'
      ,@act_schema_nm   NVARCHAR(20)
      ,@act_rtn_nm      NVARCHAR(4000)
      ,@act_rtn_ty      NVARCHAR(20)
      ,@act_ty_code     NVARCHAR(25)
      ,@act_is_clr      BIT
      ,@NL              NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
   EXEC test.sp_tst_hlpr_st @tst_num;
   BEGIN TRY
      EXEC sp_log 0, @fn,'010: calling  dbo.fnGetRtnDetails(', @qrn, ')';
      SELECT 
          @act_schema_nm = schema_nm
         ,@act_rtn_nm = rtn_nm 
         ,@act_rtn_ty = rtn_ty  
         ,@act_ty_code= ty_code
         ,@act_is_clr = is_clr 
      FROM dbo.fnGetRtnDetails(@qrn);
      EXEC sp_log 0, @fn,'020: testing results';
      IF @exp_schema_nm IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm, @exp_schema_nm, 'schema_nm'
      EXEC sp_log 0, @fn,'021';
      IF @exp_rtn_nm    IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm   , @act_rtn_nm   , 'rtn_nm'
      EXEC sp_log 0, @fn,'022';
      IF @exp_rtn_ty    IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_ty   , @act_rtn_ty   , 'rtn_ty'
      EXEC sp_log 0, @fn,'023';
      IF @exp_ty_code   IS NOT NULL EXEC tSQLt.AssertEquals @exp_ty_code  , @act_ty_code  , 'ty_code'
      EXEC sp_log 0, @fn,'024';
      IF @exp_is_clr    IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_clr   , @act_is_clr   , 'is_clr'
      EXEC sp_log 0, @fn,'025';
      -- NULL test for not exists
      IF @expect_null IS NOT NULL   EXEC tSQLt.AssertEquals NULL          , @exp_rtn_nm   , 'null test'
      EXEC test.sp_tst_hlpr_try_end --@exp_ex_num, @exp_ex_msg--,@exp_ex_st;
   END TRY
   BEGIN CATCH
      DECLARE @_tmp NVARCHAR(500) = dbo.fnGetErrorMsg()
      -- Log input parameters
      EXEC sp_log 4, @fn,  'caught exception: ', @_tmp, @NL
         ,'@tst_num      =[', @tst_num       ,']', @NL
         ,'@qrn          =[', @qrn           ,']', @NL
         ,'@exp_schema_nm=[', @exp_schema_nm ,']', @NL
         ,'@act_schema_nm=[', @act_schema_nm ,']',@NL
         ,'@exp_rtn_nm   =[', @exp_rtn_nm    ,']', @NL
         ,'@act_rtn_nm   =[', @act_rtn_nm    ,']',@NL
         ,'@exp_rtn_ty   =[', @exp_rtn_ty    ,']', @NL
         ,'@exp_ty_code  =[', @exp_ty_code   ,']', @NL
         ,'@act_ty_code  =[', @act_ty_code   ,']',@NL
         ,'@exp_is_clr   =[', @exp_is_clr    ,']', @NL
         ,'@act_is_clr   =[', @act_is_clr    ,']',@NL
         ,'@expect_null  =[', @expect_null   ,']', @NL
         ,'@exp_ex_num   =[', @exp_ex_num    ,']', @NL
         ,'@exp_ex_msg   =[', @exp_ex_msg    ,']', @NL
         , @NL;
      -- Check the expected exception
      EXEC test.sp_tst_hlpr_hndl_ex 
          @exp_ex_num = @exp_ex_num
         ,@exp_ex_msg = @exp_ex_msg
   END CATCH
   EXEC test.sp_tst_hlpr_hndl_success;
END
GO

