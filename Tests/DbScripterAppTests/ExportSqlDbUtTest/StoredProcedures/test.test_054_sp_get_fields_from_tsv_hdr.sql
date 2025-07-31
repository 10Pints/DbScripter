SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: Tests the dbo.sp_get_fields_from_tsv_hdr routine
--
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
-- ========================================================================
CREATE PROCEDURE [test].[test_054_sp_get_fields_from_tsv_hdr]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn              NVARCHAR(35) = 'TEST_GET_FIELDS_FROM_TSV_HDR'
  EXEC sp_log 1, @fn,'00: starting:';
  EXEC test.hlpr_054_sp_get_fields_from_tsv_hdr 
    @tst_num   = 'Test 001: NULL'
   ,@file_path = NULL
   ,@exp_fields= NULL
   ,@exp_ex_num= 58000
   ,@exp_ex_msg= 'file must be specified'
   ;
  EXEC test.hlpr_054_sp_get_fields_from_tsv_hdr 
    @tst_num         = 'Test 002: EMPTY'
   ,@file_path = ''
   ,@exp_fields= NULL
   ,@exp_ex_num= 58000
   ,@exp_ex_msg= 'should not be empty file must be specified'
   ;
  EXEC test.hlpr_054_sp_get_fields_from_tsv_hdr 
    @tst_num         = 'Test 003: non exist file'
   ,@file_path = ' non exist file'
   ,@exp_fields= NULL
   ,@exp_ex_num= 58001
   ,@exp_ex_msg= 'file does not exist'
   ;
  EXEC test.hlpr_054_sp_get_fields_from_tsv_hdr 
    @tst_num         = 'Test 004: green'
   ,@file_path = 'D:\Dev\Farming\Data\LRAP-221018-230813.txt'
   ,@exp_fields= 'id,NAME OF COMPANY,ACTIVE INGREDIENT,PRODUCT NAME,CONCENTRATION,FORMULATION TYPE,USE/S,TOXICITY CATEGORY,REGISTRATION NO.,EXPIRY DATE,MODE OF ENTRY,CROPS,PESTS / WEEDS / DISEASES,import_id'
   ,@exp_ex_num= NULL
   ,@exp_ex_msg= NULL
   ;
/*
  EXEC test.hlpr_054_sp_get_fields_from_tsv_hdr 
    @tst_num         = 'Test 005: bad file format'
   ,@file_path = 'D:\Dev\Repos\Farming\Data\LRAP-221018 230813.txt'
   ,@exp_fields= NULL
   ,@exp_ex_num= NULL
   ,@exp_ex_msg= NULL
   ;
*/
  EXEC sp_log 2, @fn,'99: leaving, All tests passed';
END
/*
EXEC tSQLt.Run 'test.test_054_sp_get_fields_from_tsv_hdr';
EXEC tSQLt.RunAll;
*/
GO

