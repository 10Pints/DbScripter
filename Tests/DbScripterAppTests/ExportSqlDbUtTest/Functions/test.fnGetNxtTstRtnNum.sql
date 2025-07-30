SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================
-- Author:      Terry Watts
-- Create date: 03-Dec-2023
-- Description: gets the next test rtn number
--
--- changes:
-- 240419: speeded up this routine by not using the SQL# IsNumeric routine
-- =========================================================================
CREATE FUNCTION [test].[fnGetNxtTstRtnNum]()
RETURNS INT
AS
BEGIN
DECLARE @ret INT
SELECT @ret = next_rtn_num
FROM
(
   SELECT CONVERT(INT, last_rtn_num)+1 AS next_rtn_num
   FROM
   (
      SELECT MAX(SUBSTRING(rtn_nm, 6,3)) as last_rtn_num 
      FROM SysRtns_vw 
      WHERE 
         schema_nm='test'
         AND ty_code = 'P'
         AND rtn_nm like 'test%'
         AND iif(SUBSTRING(rtn_nm, 6,3) LIKE '[0-9][0-9][0-9]', CONVERT(int, SUBSTRING(rtn_nm, 6,3)), 0) > 0
   ) X
) Y;
RETURN @ret;
END
/*
PRINT test.fnGetNxtTstRtnNum();
*/
GO

