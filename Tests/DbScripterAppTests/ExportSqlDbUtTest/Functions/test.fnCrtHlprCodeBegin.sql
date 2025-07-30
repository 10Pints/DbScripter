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
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeBegin]
(
--    @tst_proc_hlpr_nm   NVARCHAR(60)
--   ,@detld_rtn_ty_code  NVARCHAR(2)
--   ,@qrn                NVARCHAR(100)
--   ,@sc_fn_ret_ty       NVARCHAR(50)
--   ,@add_step           BIT = 0
)
RETURNS @t TABLE 
(
    id    INT
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab            NVARCHAR(3) = '   '
   ,@ad_stp         BIT
   ,@max_prm_len    INT
   SELECT
       @max_prm_len  = max_prm_len
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
   ,(CONCAT(@tab,'BEGIN TRY'))
   ,(CONCAT(@tab,@tab,'EXEC test.sp_tst_hlpr_st @fn, @tst_num;'))
   ,('')
   ,(CONCAT(@tab,@tab,'-- SETUP:'))
   ,(CONCAT(@tab,@tab,'-- <TBA>:'))
   ,('')
   ;
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeBegin();
EXEC test.sp_get_rtn_details 'dbo.sp_class_creator', @ad_stp=1, @display_tables = 1;
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
EXEC tSQLt.RunAll;
SELECT * FROM test.RtnDetails;
*/
GO

