SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Helper routine the dbo.fnGetXLOpenRowsetSql Tests
-- =============================================
CREATE PROCEDURE [test].[hlpr_023_fnGetXLOpenRowsetSql]
       @test_num     NVARCHAR(10)
      ,@wrkbk_pth    NVARCHAR(260)
      ,@range        NVARCHAR(50)            -- can be a range or a sheet
      ,@select_cols  NVARCHAR(2000)          -- select column names for the insert to the table: can apply functions to the columns at this point
      ,@xl_cols      NVARCHAR(2000) = '*'    -- XL column names: can be *
      ,@extension    NVARCHAR(50)   = ''     -- e.g. 'HDR=NO;IMEX=1'
      ,@where_clause NVARCHAR(2000) =''      -- Where clause like "WHERE province <> ''"  or ""
      ,@exp          NVARCHAR(4000)
      ,@exp_ex_num   INT            = NULL
      ,@exp_ex_msg   NVARCHAR(MAX)  = NULL
      ,@exp_ex_st    INT            = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   = 'hlpr_023_fnGetXLOpenRowsetSql'
      ,@act          NVARCHAR(4000)
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
       SET @act = dbo.fnGetOpenRowSetXL_SQL
       (
           @wrkbk_pth   
          ,@range       
          ,@xl_cols     
          ,@extension   
       ); 
      IF @exp IS NOT NULL EXEC tSQLt.AssertEquals @exp, @act;
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg,@exp_ex_st;
   END TRY
   BEGIN CATCH
      DECLARE @_tmp NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
      -- Log input parameters
      EXEC sp_log 4, @fn,  'caught exception: ', @_tmp, @NL
         ,'@test_num    =[', @test_num    ,']', @NL
         ,'@wrkbk_pth   =[', @wrkbk_pth   ,']', @NL
         ,'@range       =[', @range       ,']', @NL
         ,'@select_cols =[', @select_cols ,']', @NL
         ,'@xl_cols     =[', @xl_cols     ,']', @NL
         ,'@extension   =[', @extension   ,']', @NL
         ,'@where_clause=[', @where_clause,']', @NL
         ,'@exp         =[', @exp         ,']', @NL
         ,'@act         =[', @act         ,']', @NL
         ,'@exp_ex_num  =[', @exp_ex_num  ,']', @NL
         ,'@exp_ex_msg  =[', @exp_ex_msg  ,']', @NL
         ,'@exp_ex_st   =[', @exp_ex_st   ,']', @NL
         , @NL
      -- Check the expected exception
      EXEC ut.test.sp_tst_hlpr_hndl_ex  
          @exp_ex_num = @exp_ex_num
         ,@exp_ex_msg= @exp_ex_msg
   END CATCH
END
/*
*/
GO

