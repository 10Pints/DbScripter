SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnGetXLOpenRowsetSql routine
-- =============================================
CREATE PROCEDURE [test].[test_023_fnGetXLOpenRowsetSql]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)
      ,@sf        INT            = 1
   EXEC ut.test.sp_tst_mn_st 'test 023 fnGetXLOpenRowsetSql'
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         EXEC test.hlpr_023_fnGetXLOpenRowsetSql
             @test_num     = '001'
            ,@wrkbk_pth    = 'D:\Data\Family\Terry\Jobs\Archive\Met Office\Met Office Check List.xlsx'
            ,@range        = 'Sheet1$A1:C8'
            ,@select_cols  = 'Item,Status'
            ,@xl_cols      = 'Item,Status,Notes'
            ,@extension    = 'HDR=YES;IMEX=1'
            ,@where_clause = NULL
            ,@exp          = 'OPENROWSET ( ''Microsoft.ACE.OLEDB.12.0'',
''Excel 12.0;HDR=YES;IMEX=1; Database=D:\Data\Family\Terry\Jobs\Archive\Met Office\Met Office Check List.xlsx'',
''SELECT Item,Status,Notes
FROM [Sheet1$A1:C8]'');'
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      EXEC ut.test.sp_tst_mn_cls;
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_023_fnGetXLOpenRowsetSql'
This kills sql server service
SELECT * FROM OPENROWSET
(
   'Microsoft.ACE.OLEDB.12.0'
   ,'Excel 12.0 Xml;Database=D:\Data\Family\Terry\Money\Banks\Barclays\NOTBACKEDUP\TPRI 03187063\TPRI 231128 From 221129.xlsx;'
   ,Sheet1$
); 
*/
GO

