SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 21-NOV-2024
-- Description: checks if the routine exists
--
-- POSTCONDITIONS:
-- POST 01:
-- 
-- Changes:
--
-- Tests: test.test_029_fnChkRtnExists
-- ============================================================================================================================
CREATE FUNCTION [dbo].[fnGetStagingTables]
(
    @inc_core BIT
)
RETURNS @t TABLE
(
    table_nm VARCHAR(60)
)

AS
BEGIN
   DECLARE
       @schema       VARCHAR(20)
      ,@rtn_nm       VARCHAR(4000)
      ,@ty_nm        VARCHAR(20)

   INSERT INTO @t(table_nm)
   SELECT TOP (1000) table_nm
   FROM list_tables_vw
   WHERE table_nm LIKE '%staging';

   IF @inc_core = 0
      DELETE FROM @t 
      WHERE table_nm in ('ActionStaging','PathogenTypeStaging','TypeStaging','UseStaging')
   ;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetStagingTables(0);
SELECT * FROM dbo.fnGetStagingTables(1);
EXEC tSQLt.Run 'test.test_029_fnChkRtnExists';
*/

GO
