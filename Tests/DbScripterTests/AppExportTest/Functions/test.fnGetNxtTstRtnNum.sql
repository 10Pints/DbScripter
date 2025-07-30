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
-- 240419: speeded up this routine by NOT USING the SQL# IsNumeric routine
-- 241111: first look for the first unused trn less than the max used trn
--         if not found take the max used trn + 1
-- =========================================================================
CREATE FUNCTION [test].[fnGetNxtTstRtnNum]()
RETURNS INT
AS
BEGIN
   DECLARE @ret INT
   -- first look for the first unused trn less than the max used trn
   SET @ret =
   (
      SELECT TOP 1 FORMAT(trn+1, '000') AS nxt_trn
      FROM
      (
         SELECT SUBSTRING(rtn_nm, 6,3) AS trn, LEAD(SUBSTRING(rtn_nm, 6,3)) OVER(ORDER BY rtn_nm) AS nxt_trn
         FROM SysRtns_vw 
         WHERE
             schema_nm = 'test'
         AND ty_code   = 'P'
         AND rtn_nm like 'test%'
         AND iif(SUBSTRING(rtn_nm, 6,3) LIKE '[0-9][0-9][0-9]', CONVERT(int, SUBSTRING(rtn_nm, 6,3)), 0) > 0
      ) X
      WHERE nxt_trn>trn + 1
   );
   -- If not found take the max used trn + 1
   IF @ret IS NULL
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
               AND IIF(SUBSTRING(rtn_nm, 6,3) LIKE '[0-9][0-9][0-9]', CONVERT(int, SUBSTRING(rtn_nm, 6,3)), 0) > 0
         ) X
      ) Y;
   IF @ret IS NULL SET @ret = 0;
   RETURN @ret;
END
/*
PRINT test.fnGetNxtTstRtnNum();
*/
GO

