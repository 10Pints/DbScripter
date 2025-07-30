SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 18-Apr-2024
-- Description: creates the tested rtn call dependant on the rtn type code
--
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions:
-- Returns: lines of detailed test
--
-- Method:
-- delegate to a specific rtn based on rtn type
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeCallBloc]()
RETURNS @t TABLE
(
    id    INT IDENTITY(1,1)
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab          NVARCHAR(3) = '   '
   ,@tab2         NVARCHAR(6) = dbo.fnGetNTabs(2)
   ,@qrn          NVARCHAR(100)
   ,@rtn_ty_code  NVARCHAR(2)
   ,@ad_stp       BIT
   SELECT
       @rtn_ty_code = rtn_ty_code
      ,@ad_stp      = ad_stp
   FROM test.RtnDetails
   IF @ad_stp = 1
      INSERT INTO @t (line) VALUES
      (CONCAT(@tab2,'-- fnCrtHlprCodeCallBloc'));
   INSERT INTO @t (line) VALUES
     (CONCAT(@tab2,'-- RUN tested procedure:', IIF( @ad_stp = 1,CONCAT(' -- SP-RN-TST fn ty: ',@rtn_ty_code),'')))
    ,(CONCAT(@tab2,'EXEC sp_log 1, @fn, ''005: running ',@qrn,''';'))
    ,('')
    ;
   WHILE 1=1
   BEGIN
      INSERT INTO @t (line) VALUES( CONCAT(@tab2, '-- @rtn_ty_code:', @rtn_ty_code));
      IF @rtn_ty_code = 'P'
      BEGIN
         INSERT INTO @t (line)
            SELECT line FROM test.fnCrtHlprCodeCallProc();
         BREAK;
      END
      IF @rtn_ty_code = 'FN'
      BEGIN
         INSERT INTO @t (line)
            SELECT line FROM test.fnCrtHlprCodeCallFn();
         BREAK;
      END
      IF @rtn_ty_code = 'TF'
      BEGIN
         INSERT INTO @t (line)
            SELECT line FROM test.fnCrtHlprCodeCallTF();
         BREAK;
      END
      -- if here then unrecognised @rtn_ty_code
      INSERT INTO @t (line) VALUES( CONCAT('-- Unrecognised @rtn_ty_code:', @rtn_ty_code));
      BREAK;
   END -- while
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
EXEC tSQLt.RunAll
SELECT * FROM test.fnCrtHlprCodeCall('SP',1);
SELECT * FROM test.fnCrtHlprCodeCall('F',1);
SELECT * FROM test.fnCrtHlprCodeCall('TF',1);
SELECT * FROM test.RtnDetails;
*/
GO

