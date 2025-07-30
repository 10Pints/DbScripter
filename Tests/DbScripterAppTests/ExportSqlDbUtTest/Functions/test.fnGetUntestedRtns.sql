SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:      Terry Watts
-- Create date: 06-DEC-22
-- Description: Gets the untested routines from 
--              dbo and test - filtered by @schema
--              NULL @schema_nm param means all
-- ===============================================
CREATE FUNCTION [test].[fnGetUntestedRtns]()
RETURNS @t  TABLE
(
    id         INT IDENTITY(1,1)
   ,schema_nm  NVARCHAR(25)
   ,rtn_nm     NVARCHAR(60)
   ,ty_code    NVARCHAR( 2)
)
AS
BEGIN
   INSERT INTO @t(schema_nm, rtn_nm, ty_code)
   SELECT schema_nm, rtn_nm, ty_code
   FROM test.UntestedRtns_vw
   ORDER BY schema_nm, ty_code, rtn_nm
   RETURN;
END
/*
SELECT * FROM test.fnGetUntestedRtns();
*/
GO

