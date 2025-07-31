SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnGetOpenRowSet routine
--
-- Requirements:
-- R01: If @ext is not supplied then is defaulted to 'HDR=YES;IMEX=1'
-- R02: Makes sure a $ exists in the range - appending one if not to the end
-- R03: If the columns are not specified use * to get all columns
-- =============================================
CREATE PROCEDURE [test].[test_018_fnGetOpenRowSetXL]
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(40)    =  N'test 018 fnGetOpenRowSetXL'
   EXEC ut.test.sp_tst_mn_st @fn
--   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         -- R01: If @ext is not supplied then is defaulted to 'HDR=YES;IMEX=1'
         -- If @ext is not supplied then is defaulted to 'HDR=YES;IMEX=1'
         EXEC test.hlpr_018_fnGetOpenRowSetXL_SQL
             @test_num     = '001 ext not spec'
            ,@wrkbk        = 'non existent'
            ,@range        = 'Sheet1$'
            ,@xl_cols      = '*'        -- select XL column names: can be *
            ,@ext          = NULL       -- default: 'HDR=NO;IMEX=1'
            ,@exp_sql      = 'OPENROWSET ( ''Microsoft.ACE.OLEDB.12.0'',
''Excel 12.0;HDR=YES;IMEX=1; Database=non existent'',
''SELECT *
FROM [Sheet1$]'');'        -- test default: 'IGNORE'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
            ,@exp_ex_st    = NULL
         -- R01: If @ext is not supplied then is defaulted to 'HDR=YES;IMEX=1'
         -- If @ext is supplied then it is used instead of 'HDR=YES;IMEX=1'
         EXEC test.hlpr_018_fnGetOpenRowSetXL_SQL
             @test_num     = '002 ext spec'
            ,@wrkbk        = 'non existent'
            ,@range        = 'Sheet1$'
            ,@xl_cols      = '*'        -- select XL column names: can be *
            ,@ext          = 'FRED'       -- default: 'HDR=NO;IMEX=1'
            ,@exp_sql      = 'OPENROWSET ( ''Microsoft.ACE.OLEDB.12.0'',
''Excel 12.0;FRED; Database=non existent'',
''SELECT *
FROM [Sheet1$]'');'        -- test default: 'IGNORE'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
            ,@exp_ex_st    = NULL
         -- R02: Makes sure a $ exists in the range - appending one if not to the end
         EXEC test.hlpr_018_fnGetOpenRowSetXL_SQL
             @test_num     = '003 ext spec'
            ,@wrkbk        = 'non existent'
            ,@range        = 'Sheet1'        -- leave off the trailing $
            ,@xl_cols      = 'col1, col2, col3'             -- select XL column names: can be *
            ,@ext          = NULL            -- default: 'HDR=NO;IMEX=1'
            ,@exp_sql      = 'OPENROWSET ( ''Microsoft.ACE.OLEDB.12.0'',
''Excel 12.0;HDR=YES;IMEX=1; Database=non existent'',
''SELECT col1, col2, col3
FROM [Sheet1$]'');'        -- test default: 'IGNORE'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
            ,@exp_ex_st    = NULL
         -- R03: If the columns are not specified use * to get all columns
         EXEC test.hlpr_018_fnGetOpenRowSetXL_SQL
             @test_num     = '004 @xl_cols not spec''d'
            ,@wrkbk        = 'non existent'
            ,@range        = 'Sheet1'        -- leave off the trailing $
            ,@xl_cols      = NULL            -- select XL column names: can be *
            ,@ext          = NULL            -- default: 'HDR=NO;IMEX=1'
            ,@exp_sql      = 'OPENROWSET ( ''Microsoft.ACE.OLEDB.12.0'',
''Excel 12.0;HDR=YES;IMEX=1; Database=non existent'',
''SELECT *
FROM [Sheet1$]'');'        -- test default: 'IGNORE'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
            ,@exp_ex_st    = NULL
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      EXEC ut.test.sp_tst_mn_cls;
--   END TRY
--   BEGIN CATCH
--      EXEC ut.test.sp_tst_mn_hndl_ex;
--   END CATCH
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_018_fnGetOpenRowSetXL'
EXEC [test].[test 018 fnGetOpenRowSetXL]
*/
GO

