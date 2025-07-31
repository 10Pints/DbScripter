SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      21-Nov-2023
-- Description:      main test rtn for the dbo.fnGetTyCodeFrmTyNm rtn being tested
-- Tested rtn desc:
--  returns the type name from the type code  
--e.g. sysobjects xtype code   
--
-- Tested rtn params: 
--    @ty_name  NVARCHAR(2),
--
-- returns NVARCHAR(30)
--========================================================================================
CREATE PROCEDURE [test].[test_059_fnGetTyCodeFrmTyNm]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_059_fnGetTyCodeFrmTyNm' -- bug was 'N'test_059_'
   EXEC sp_log 2, @fn,'01: starting'
---- SETUP
   -- <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='CLR aggregate function',@exp_res= 'AF'  ,@exp_ex=0, @subtest='TG001';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='CHECK constraint'      ,@exp_res= 'C'   ,@exp_ex=0, @subtest='TG002';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='DEFAULT'               ,@exp_res= 'D'   ,@exp_ex=0, @subtest='TG003';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Edge constraint'       ,@exp_res= 'EC'  ,@exp_ex=0, @subtest='TG004';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='External table'        ,@exp_res= 'ET'  ,@exp_ex=0, @subtest='TG005';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Foreign key'           ,@exp_res= 'F'   ,@exp_ex=0, @subtest='TG006';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Scalar function'       ,@exp_res= 'FN'  ,@exp_ex=0, @subtest='TG007';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='CLR scalar function'   ,@exp_res= 'FS'  ,@exp_ex=0, @subtest='TG008';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='CLR table function'    ,@exp_res= 'FT'  ,@exp_ex=0, @subtest='TG009';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Inline table function' ,@exp_res= 'IF'  ,@exp_ex=0, @subtest='TG010';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Intrnal table'         ,@exp_res= 'IT'  ,@exp_ex=0, @subtest='TG011';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Procedure'             ,@exp_res= 'P'   ,@exp_ex=0, @subtest='TG012';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='CLR procedure'         ,@exp_res= 'PC'  ,@exp_ex=0, @subtest='TG013';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Plan guide'            ,@exp_res= 'PG'  ,@exp_ex=0, @subtest='TG014';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Procedure'             ,@exp_res= 'P'   ,@exp_ex=0, @subtest='TG015';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Primary key'           ,@exp_res= 'PK'  ,@exp_ex=0, @subtest='TG016';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Rule'                  ,@exp_res= 'R'   ,@exp_ex=0, @subtest='TG017';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Repl fltr proc'        ,@exp_res= 'RF'  ,@exp_ex=0, @subtest='TG018';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Sys base table'        ,@exp_res= 'S'   ,@exp_ex=0, @subtest='TG019';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Synonym'               ,@exp_res= 'SN'  ,@exp_ex=0, @subtest='TG020';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Sequence object'       ,@exp_res= 'SO'  ,@exp_ex=0, @subtest='TG021';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Service queue'         ,@exp_res= 'SQ'  ,@exp_ex=0, @subtest='TG022';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='CLR DML trigger'       ,@exp_res= 'TA'  ,@exp_ex=0, @subtest='TG023';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Table function'        ,@exp_res= 'TF'  ,@exp_ex=0, @subtest='TG024';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='SQL DML trigger'       ,@exp_res= 'TR'  ,@exp_ex=0, @subtest='TG025';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Table type'            ,@exp_res= 'TT'  ,@exp_ex=0, @subtest='TG026';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Table'                 ,@exp_res= 'U'   ,@exp_ex=0, @subtest='TG027';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Unique Key'            ,@exp_res= 'UQ'  ,@exp_ex=0, @subtest='TG028';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='View'                  ,@exp_res= 'V'   ,@exp_ex=0, @subtest='TG029';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Extended procedure'    ,@exp_res= 'X'   ,@exp_ex=0, @subtest='TG030';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name='Unkown type'           ,@exp_res= '????',@exp_ex=0, @subtest='TG031';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name=NULL                    ,@exp_res= '????',@exp_ex=0, @subtest='TG031';
   EXEC test.hlpr_059_fnGetTyCodeFrmTyNm @ty_name=''                      ,@exp_res= '????',@exp_ex=0, @subtest='TG031';
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   --EXEC test.hlpr_059_fnGetTyCodeFrmTyNm ='',@ty_name='',@exp_ex=1, @subtest='TR001';
   EXEC sp_log 2, @fn, '99: All subtests PASSED'
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_059_fnGetTyCodeFrmTyNm';
*/
GO

