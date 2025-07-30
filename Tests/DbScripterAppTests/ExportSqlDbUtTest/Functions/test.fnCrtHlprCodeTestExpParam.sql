SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================
-- Author:           Terry Watts
-- Create date:      25-Jul-2024
-- Description: test helper for the dbo.fnDeltaStats routine tests 
--
-- =========================================================
CREATE FUNCTION [test].[fnCrtHlprCodeTestExpParam]
( 
   @param_nm NVARCHAR(60)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
   DECLARE 
     @line        NVARCHAR(MAX)
    ,@tab         NVARCHAR(3)   = '   '
    ,@max_prm_len INT
    ;
   SELECT @max_prm_len = max(dbo.fnLen(param_nm)) + 1 FROM test.ParamDetails WHERE TST_TY = 'EXP';
   SET @line = 
      CONCAT
      ( 
          @tab, @tab
         ,'IF @exp_', dbo.fnPadRight(@param_nm, @max_prm_len), 'IS NOT NULL EXEC tSQLt.AssertEquals @exp_'
         , dbo.fnPadRight(@param_nm, @max_prm_len)
         , ',@act_', dbo.fnPadRight(@param_nm, @max_prm_len)
         , ',''',@param_nm,''';'
      );
   RETURN @line;
END
/*
select * from test.RtnDetails;
select * from test.ParamDetails;
PRINT CONCAT('[',test.fnCrtHlprCodeTestExpParam('country'),']');
PRINT CONCAT('[',test.fnCrtHlprCodeTestExpParam('import_date_end'),']');
DROP TABLE DUMMY;
SELECT * INTO dummy FROM (SELECT test.fnCrtHlprCodeTestExpParam(param_nm) as res FROM test.ParamDetails) X;
SELECT * FROM  dummy;
import_date_end]
*/
GO

