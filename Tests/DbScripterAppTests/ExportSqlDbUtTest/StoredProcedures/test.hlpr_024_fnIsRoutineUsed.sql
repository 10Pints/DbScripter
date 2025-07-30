SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Helper routine the dbo.fnIsRoutineUsed Tests
-- =============================================
CREATE PROCEDURE [test].[hlpr_024_fnIsRoutineUsed]
       @test_num     NVARCHAR(25)
      ,@rtn_nm       NVARCHAR(4000)
      ,@exp          NVARCHAR(4000) = NULL
      ,@exp_ex_num   INT            = NULL -- -1 means check exception thrown, but dont chk details
      ,@exp_ex_msg   NVARCHAR(500)  = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   =  'hlpr_024_fnIsRoutineUsed'
      ,@NL           NVARCHAR(2)    = dbo.fnGetNL()
      ,@act          BIT
      ,@act_ex_num   INT            = NULL
      ,@act_ex_msg   NVARCHAR(500)  = NULL
      EXEC sp_log 1, @fn, '01: starting';
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num
      -- Call the tested routine
      EXEC sp_log 1, @fn, '10:';
      IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
      BEGIN
         BEGIN TRY
            SET @act = dbo.fnIsRoutineUsed(@rtn_nm);
            EXEC tSQLt.Fail 'Did not get expected exception';
         END TRY
         BEGIN CATCH
            -- expected this but check detials if asked to
            EXEC sp_log 1, @fn, '20: caught expected exception';
            SET @act_ex_num = ERROR_NUMBER();
            SET @act_ex_msg = ERROR_MESSAGE();
            EXEC sp_log 1, '@act_ex_num: ', @act_ex_num;
            EXEC sp_log 1, '@act_ex_msg: [', @act_ex_msg,']';
            IF @exp_ex_num IS NOT NULL AND @exp_ex_num <> -1
            BEGIN
               EXEC sp_log 1, 'checking ex_num ...';
               EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num;
               EXEC sp_log 1, 'OK';
            END
            IF @exp_ex_msg IS NOT NULL
            BEGIN
               EXEC sp_log 1, 'checking ex_msg ...';
               EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg;
               EXEC sp_log 1, 'OK';
            END
         END CATCH
      END
      ELSE
      BEGIN
         -- Do not expect exception here
         SET @act = dbo.fnIsRoutineUsed(@rtn_nm);
         IF @exp  IS NOT NULL EXEC tSQLt.AssertEquals @exp, @act;
      END
      EXEC sp_log 1, @fn, '20:';
      IF @exp IS NOT NULL EXEC ut.test.sp_tst_gen_chk N'01', @exp, @act,'exp';
      --EXEC test.sp_tst_hlpr_try_end --@exp_ex_num, @exp_ex_msg;
      EXEC test.sp_tst_hlpr_hndl_success;
      EXEC sp_log 1, @fn, '30:';
      EXEC sp_log 1, @fn, '99 leaving:';
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_024_fnIsRoutineUsed'
*/
GO

