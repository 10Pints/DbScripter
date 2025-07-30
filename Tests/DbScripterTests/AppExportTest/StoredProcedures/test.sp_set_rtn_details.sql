SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================================================================
-- Author:      Terry Watts
-- Create date: 03-APR-2024
-- Rtn:         test.sp_set_rtn_details
-- Description: Gets the routine details for the routine @q_rtn_nm
--    Populates
--       Test.RtnDetails   with the rtn level details
--       Test.ParamDetails with the parameter level details
--
-- Responsibilities:
-- Main entry point for the population of the 2 rtn metadata tables: {Test.RtnDetails, Test.RtnParamDetails}
-- Parameters:
-- @q_tstd_rtn the qualified tested routine name <schema>.<routine> optionally wrapped in []
--
-- Preconditions: none
--
-- Postconditions:
-- Populates
--       Test.RtnDetails   with the rtn level details
--       Test.ParamDetails with the parameter level details
------------------------------------------------------------------------------------------------------
-- RULES     Rule                       Ex num  ex msg
------------------------------------------------------------------------------------------------------
-- POST 01: find the routine         OR 70100,  Could not find the routine <@q_tstd_rtn>
-- POST 02: Test.RtnDetails      pop OR 70101,  Could not find the routine   details for <@q_tstd_rtn>
-- POST 03: Test.RtnParamDetails pop OR 70102,  Could not find the parameter details for <@q_tstd_rtn>
-- POST 04: qrn returned fully qualified with schema
--
-- Algorithm:
-- 1. populate test.RtnDetailsn   using sp_pop_rtn_details
-- 2. populate test.ParamDetails using sp_pop_param_details
-- All checks are delegated to the 2 pop rtns
--
-- Tests: test.hlpr_034_get_rtn_parameters
--
-- Changes:
-- 240415: redesign, added several fields to make it eassier to use latter in the test rtn creation
-- 241031: removed @tst_mode param
-- 241111: if @trn not supplied look for the first unused trn
-- ===================================================================================================
CREATE PROCEDURE [test].[sp_set_rtn_details]
    @qrn             VARCHAR(150)
   ,@trn             INT      = NULL
   ,@cora            NCHAR(1) = NULL
   ,@ad_stp          BIT      = NULL -- for teting
   ,@throw_if_err    BIT      = 1
   ,@display_tables  BIT      = 0
AS
BEGIN
   DECLARE
     @fn             VARCHAR(35)   = 'sp_set_rtn_details'
    ,@schema_nm      VARCHAR(50)
    ,@rtn_nm         VARCHAR(100)
    ,@cnt            INT
    ,@tst_rtn_nm     VARCHAR(50)
    ,@hlpr_rtn_nm    VARCHAR(50)
    ,@line           VARCHAR(100)= REPLICATE('-', 100)
   BEGIN TRY
      --------------------------------------------------------------------------------------------------------
      -- Pop the RtnDetails table
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '000: starting
qrn           :[', @qrn           ,']
trn           :[', @trn           ,']
cora          :[', @cora          ,']
ad_stp        :[', @ad_stp        ,']
throw_if_err  :[', @throw_if_err  ,']
display_tables:[', @display_tables,']'
;
      EXEC sp_log 1, @fn, '005: populating the RtnDetails table   ';
      EXEC test.sp_pop_rtn_details
          @qrn          = @qrn         OUT
         ,@trn          = @trn
         ,@cora         = @cora
         ,@ad_stp       = @ad_stp
         ,@throw_if_err = @throw_if_err
            ;
      --------------------------------------------------------------------------------------------------------
      -- Pop the param details
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '010:  populating the ParamDetails table   '
      EXEC test.sp_pop_param_details @throw_if_err = @throw_if_err;
      --------------------------------------------------------------------------------------
      -- Process complete
      --------------------------------------------------------------------------------------
      IF @display_tables = 1
      BEGIN
         SELECT @line;
         PRINT 'test.RtnDetails:'
         SELECT @line;
         SELECT * FROM test.RtnDetails;
PRINT '';
         SELECT @line;
         PRINT 'test.ParamDetails:'
         SELECT @line;
         SELECT * FROM test.ParamDetails;
         SELECT @line;
      END
      EXEC sp_log 1, @fn, '900: Process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '999: leaving';
END
/*
EXEC test.sp__crt_tst_rtns 'test].[sp_set_rtn_details'
EXEC test.sp_get_rtn_details 'dbo.sp_class_creator', @display_tables=1;
EXEC tSQLt.Run 'test.test_034_sp_get_param_details';
EXEC tSQLt.Run 'test.test_090_sp_get_rtn_details';
EXEC tSQLt.RunAll;
*/
GO

