SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 17-Dec-2023
-- Description: creates the scriptlet for stage 07 of test.sp_crt_tst_hlpr
--
-- POSTCONDITIONS:
-- RETURNS: @rtnDef
-- POST 01:
--
-- 241205: added sp_lop starting with parameter list
--         simplified logic and sorted tab issues
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeBegin]()
RETURNS @t TABLE 
(
    id    INT
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab1           VARCHAR(3) = '   '
   ,@tab2           VARCHAR(6) = '      '
   ,@ad_stp         BIT
   ,@rtn_ty         VARCHAR(2)
   ,@max_prm_len    INT
   SELECT
       @rtn_ty       = rtn_ty
      ,@max_prm_len  = max_prm_len
      ,@ad_stp       = ad_stp
   FROM
      test.RtnDetails;
   ------------------------------------------------------------------------------------------------
   -- Add the As - BEGIN-DECL
   ------------------------------------------------------------------------------------------------
   INSERT INTO @t (line) VALUES
    (CONCAT('AS', IIF(@ad_stp = 1 ,' -- fnCrtHlprCodeBegin', '')))
   ,('BEGIN')
   INSERT INTO @t(line)
   SELECT line
   FROM test.fnCrtHlprCodeDecl();
   INSERT INTO @t (line) VALUES
    ('')
   ,(CONCAT(@tab1,'BEGIN TRY'))
   ,(CONCAT(@tab2,'EXEC test.sp_tst_hlpr_st @tst_num;'))
   ,('')
   ,(CONCAT(@tab2,'EXEC sp_log 1, @fn ,'' starting'))
   ;
   INSERT INTO @t (line) SELECT line FROM test.fnCrtHlprLogParams();
   INSERT INTO @t (line) VALUES
    ('')
   ,(CONCAT(@tab2,'-- SETUP: ??'))
   ,('')
   ;
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeBegin();
EXEC test.sp_get_rtn_details 'dbo.sp_class_creator', @ad_stp=1, @display_tables = 1;
EXEC tSQLt.Run 'test.test_025_sp_crt_tst_hlpr_script';
EXEC tSQLt.RunAll;
SELECT * FROM test.RtnDetails;
*/
GO

