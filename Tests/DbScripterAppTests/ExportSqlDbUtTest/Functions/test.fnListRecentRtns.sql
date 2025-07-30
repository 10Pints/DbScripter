SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================================
-- Author:      Terry Watts
-- Create date: 18-APR-2024
-- Description: Gets the recently created routines in the last n days
-- ===================================================================
CREATE FUNCTION [test].[fnListRecentRtns]
(
    @days   INT
)
RETURNS  @t TABLE
(
    schema_nm  NVARCHAR(32)
   ,rtn_nm     NVARCHAR(60)
   ,rtn_ty     NVARCHAR(32)
   ,ty_code    NVARCHAR(2)
   ,created    DATE
   ,modified   DATE
)
AS
BEGIN
   DECLARE 
       @dt_st     DATE
      ,@dt_end    DATE = GetDate()
   IF @days <0 SET @days = 999;
   SET @dt_st = DateAdd(DAY, 0-@days, @dt_end);
   INSERT INTO @t(schema_nm, rtn_nm, rtn_ty, ty_code, created, modified)
      SELECT schema_nm, rtn_nm, rtn_ty, ty_code, created, modified
      FROM dbo.list_recent_rtns_vw
      WHERE  created BETWEEN @dt_st AND @dt_end
      ORDER BY created DESC, rtn_nm DESC;
   RETURN;
END
/*
SELECT * FROM test.fnListRecentRtns(0);
SELECT * FROM test.fnListRecentRtns(1);
SELECT * FROM test.fnListRecentRtns(2);
SELECT * FROM test.fnListRecentRtns(3);
SELECT * FROM test.fnListRecentRtns(4);
SELECT * FROM test.fnListRecentRtns(5);
SELECT * FROM test.fnListRecentRtns(6);
SELECT * FROM test.fnListRecentRtns(10);
SELECT * FROM test.fnListRecentRtns(-1);
*/
GO

