SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--===========================================================
-- Author:      Terry Watts
-- Create date: 22-APR-2024
-- Description: lists the unused Test Routine Numbers
-- ===========================================================
CREATE VIEW [test].[GetUnusedRoutines_vw]
AS
SELECT schema_nm , rtn_nm, ty_code FROM dbo.fnSysRtnCfg(NULL, '%', NULL)
WHERE schema_nm NOT IN ('tSQLt', 'SQL#')
AND NOT EXISTS
(SELECT 1 FROM dbo.fnSysGetDependencies(schema_nm, rtn_nm))
/*
SELECT * FROM test.GetUnusedRoutines_vw;
*/
GO

