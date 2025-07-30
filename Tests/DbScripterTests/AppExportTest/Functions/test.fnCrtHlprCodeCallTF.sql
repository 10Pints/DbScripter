SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
-- Description: creates the test helper code for a scalar fn
-- Preconditions:
--    test.rtnDetails and test.ParamDetails populated
--
-- POSTCONDITIONS:
-- POST 01:
--
-- Called by: fnCrtHlprCodeCallBloc
--
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeCallTF]()
RETURNS @t TABLE
(
    id    INT
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab1            VARCHAR(3) = dbo.fnGetNTabs(1)
   ,@tab2            VARCHAR(6) = dbo.fnGetNTabs(2)
   ,@tab3            NCHAR(9)    = dbo.fnGetNTabs(3)
   ,@tab4            NCHAR(12)   = dbo.fnGetNTabs(4)
   ,@tab5            NCHAR(15)   = dbo.fnGetNTabs(5)
   ,@line            VARCHAR(1000)
   ,@qrn             VARCHAR(100)
   ,@ad_stp          BIT
   ,@st_inp_ordinal  INT
   ,@inp_prm_cnt     INT = 0
   ,@display_tables  BIT
   ;
   SELECT
       @qrn            = qrn
      ,@ad_stp         = ad_stp
      ,@display_tables = display_tables
   FROM test.RtnDetails;
   SELECT @inp_prm_cnt = COUNT(*) FROM test.ParamDetails
   WHERE tst_ty='INP'
   ;
   INSERT INTO @t (line) VALUES
    (CONCAT(@tab4,'DROP TABLE IF EXISTS test.results', IIF(@ad_stp = 1 ,' -- fnCrtHlprCodeCallTF', '')))
   ,('')
   ;
   SELECT @st_inp_ordinal = MIN(ordinal)
   FROM test.ParamDetails
   WHERE tst_ty='INP'
   ;
   --------------------------------
   -- Handle 0 or 1 params inline
   --------------------------------
   IF @inp_prm_cnt = 0
   BEGIN
      SET @line = CONCAT(@tab4, 'SELECT * INTO test.Results FROM ', @qrn, '();');
      INSERT INTO @t (line) VALUES (@line);
   END
   IF @inp_prm_cnt = 1
   BEGIN
      SET @line = CONCAT(@tab4, 'SELECT * INTO test.Results FROM ', @qrn, '(');
      SET  @line =
      (
         SELECT TOP 1 CONCAT( @line, '@inp_', param_nm)
         FROM test.ParamDetails
         WHERE tst_ty ='INP'
      );
      SET  @line = CONCAT(@line, ');');
      INSERT INTO @t (line) VALUES (@line);
   END
   IF @inp_prm_cnt > 1
   BEGIN
      -------------------------------------
      -- Handle multiple params 1 per line
      -------------------------------------
      INSERT INTO @t (line) VALUES
          (CONCAT(@tab4, 'SELECT * INTO test.Results FROM ', @qrn))
         ,(CONCAT(@tab4, '('))
      ;
      -- Add params 1per line
      INSERT INTO @t (line)
      SELECT CONCAT( @tab5, iif(ordinal = @st_inp_ordinal,' ',',') , '@inp_', param_nm)
      FROM test.ParamDetails
      WHERE tst_ty ='INP';
      -- Close off fn ()
      INSERT INTO @t (line) VALUES
       (CONCAT(@tab4, ');'))
      ,('')
      ;
   END
   -- If not inline separate rtn call from next by 1 blnk line
   IF @inp_prm_cnt <2
      INSERT INTO @t (line) VALUES ('');
   -- If display tables then display tables
   INSERT INTO @t (line) VALUES (CONCAT(@tab4, 'IF @display_tables=1 SELECT * FROM test.results'));
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeCallTF();
EXEC test.sp__crt_tst_rtns 'test].[fnCrtHlprCodeCallTF', @ad_stp=1
*/
GO

