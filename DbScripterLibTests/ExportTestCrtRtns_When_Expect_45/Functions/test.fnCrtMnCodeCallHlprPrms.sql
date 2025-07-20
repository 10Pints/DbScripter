SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 12-NOV-2024
-- Description: creates the parameter list for
-- the helper call in the mn tst rtn
-- =============================================
CREATE FUNCTION [test].[fnCrtMnCodeCallHlprPrms]()
RETURNS
@t TABLE
(
    id    INT
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab1         VARCHAR(3) = '   '
   ,@tab2         VARCHAR(6) = '      '
   ,@max_prm_len  INT
   ,@ad_stp       BIT        = 0
   ,@rtn_ty_code  NCHAR(2)
   ,@tst_rtn_nm   VARCHAR(60)

   SELECT
       @tst_rtn_nm   = tst_rtn_nm
      ,@ad_stp       = ad_stp
      ,@rtn_ty_code  = rtn_ty_code
      ,@max_prm_len  = max_prm_len
   FROM test.RtnDetails;

   -----------------------------------------------------------------
   -- Add the hdr parameters @tst_num, @tst_key
   -----------------------------------------------------------------
   INSERT INTO @t (line) 
   SELECT
      CONCAT
      (
         @tab2, iif(ordinal=1, ' ', ',')
        ,dbo.fnPadRight
               (
                  iif(param_nm = 'display_tables' AND tst_ty='TST', CONCAT('@', param_nm), test.fnGetParamWithSuffix(param_nm))
                 , @max_prm_len+5
               ) 
            , ' = '
        , iif(is_chr_ty=1, iif(ordinal=1, '''001''',''''''), '0')
        , iif(ordinal=1 AND @ad_stp = 1, ' -- fnCrtMnCodeCallHlprPrms', '')
      )
   FROM test.ParamDetails
   WHERE tst_ty = 'TST';

   -----------------------------------------------------------------
   -- Add the tested rtn parameters
   -----------------------------------------------------------------
   INSERT INTO @t (line) 
   SELECT
      CONCAT
      (
         @tab2, iif(ordinal=1, ' ', ',')
      , dbo.fnPadRight(test.fnGetParamWithSuffix(param_nm), @max_prm_len+5), ' = ', iif(is_chr_ty=1, '''''', '0'))
   FROM test.ParamDetails
   WHERE tst_ty = 'INP';

   -----------------------------------------------------------------
   -- Add the expected parameters
   -----------------------------------------------------------------
   INSERT INTO @t (line)
   SELECT
      CONCAT
      (
          @tab2, iif(ordinal=1, ' ', ',')
         ,dbo.fnPadRight(test.fnGetParamWithSuffix(param_nm), @max_prm_len+5), ' = NULL'
      )
   FROM test.ParamDetails
   WHERE tst_ty = 'EXP' AND is_exception = 0;

   INSERT INTO @t (line) 
   SELECT
      CONCAT
      (
          @tab2, iif(ordinal=1, ' ', ',')
         ,dbo.fnPadRight(test.fnGetParamWithSuffix(param_nm), @max_prm_len+5), ' = NULL'
      )
   FROM test.ParamDetails
   WHERE tst_ty = 'EXP' AND is_exception = 1;

   -----------------------------------------------------------------
   -- Close the Decl statement
   -----------------------------------------------------------------
   INSERT INTO @t (line) VALUES(CONCAT(@tab1, ';'));
   RETURN;
END

GO
