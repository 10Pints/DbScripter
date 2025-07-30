SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
-- Description: adds the expected parameters for a stored procedure test
-- Preconditions:
--    test.ParamDetails populated
--
-- Postconditions:
-- POST 01:
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprSigExpParamsSp]()
RETURNS @t TABLE 
(
    id    INT IDENTITY(1,1)
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab          NVARCHAR(3) = '   '
   ,@ad_stp       BIT
   ,@max_prm_len INT
   SELECT
       @ad_stp       = ad_stp
      ,@max_prm_len  = max_prm_len
   FROM test.RtnDetails;
   IF @ad_stp=1
   INSERT INTO @t( line)
   VALUES (CONCAT(@tab,' -- fnCrtHlprSigExpParamsSp',''));
   INSERT INTO @t (line) VALUES
    (CONCAT(@tab,dbo.fnPadRight(',@exp_ex_num',    @max_prm_len + 4), 'INT            = NULL'))
   ,(CONCAT(@tab,dbo.fnPadRight(',@exp_ex_msg',    @max_prm_len + 4), 'NVARCHAR(500)  = NULL'))
   ,(CONCAT(@tab,dbo.fnPadRight(',@display_script',@max_prm_len + 4), 'BIT            = 0'))
   RETURN;
END
/*
SELECT line FROM test.fnCrtHlprSigExpParamsSp()
   EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script'
SELECT * 
FROM sys.dm_exec_describe_first_result_set_for_object
(OBJECT_ID('dbo.sp_class_creator'), 0);
*/
GO

