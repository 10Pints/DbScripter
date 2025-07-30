SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--===========================================================
-- Author:      Terry Watts
-- Create date: 22-APR-2024
-- Description: lists the unused Test Routine Numbers
-- ===========================================================
CREATE VIEW [test].[GetUnusedTRNs_vw]
AS
WITH CTE
AS
(
   SELECT 
      'UNUSED' as [type]
      ,rtn_nm
      ,trn
   ,Lag(TRY_CONVERT(INT,SUBSTRING(rtn_nm, 6,3)), 1) OVER( ORDER BY SUBSTRING(rtn_nm, 6,3) ASC) AS prev_trn
   ,Lag(rtn_nm, 1) OVER( ORDER BY SUBSTRING(rtn_nm, 6,3) ASC) AS prev_rtn
   FROM
   (
      SELECT
       rtn_nm
      ,TRY_CONVERT(INT,SUBSTRING(rtn_nm, 6,3)) AS trn
      FROM SysRtns_vw
      WHERE 
         schema_nm='test'
         AND ty_code = 'P'
         AND rtn_nm like 'test%'
         AND SUBSTRING(rtn_nm, 6,3) LIKE '[0-9][0-9][0-9]'
         ) AS X
)
SELECT TOP 200 [type], prev_trn+1 AS unused_trn, prev_rtn, rtn_nm as next_rtn, prev_trn, trn as next_trn
FROM CTE
   WHERE trn <> prev_trn+1
ORDER BY trn
UNION ALL 
SELECT 'DUPLICATE', trn, prev_rtn, rtn_nm, prev_trn, trn as next_trn 
FROM CTE
   WHERE trn = prev_trn
   UNION ALL
SELECT 'NEW', MAX(trn)+1,'','',MAX(trn) ,MAX(trn)+1--prev_rtn, rtn_nm,prev_trn,trn
FROM CTE;
/*
SELECT * FROM test.GetUnusedRtns_vw;
*/
GO

