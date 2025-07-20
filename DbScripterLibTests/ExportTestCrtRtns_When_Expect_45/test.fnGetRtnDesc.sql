SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry Watts
-- Create date: 10-NOV-2023
-- Description: gets the rtn description from its meta data
--
-- PRECONDITIONS:
-- PRE 01: the tested rtn details are set
--
-- POSTCONDITIONS:
-- POST01: some rows must be returned or exception 54321
--
-- CHANGES:
--231112: renamed this rtn from and moved to test:
--        dbo.sp_get_rtn_description -> test.sp_get_rtn_desc
-- ===============================================================
CREATE FUNCTION [test].[fnGetRtnDesc]()
RETURNS @t TABLE
(
    id   INT            IDENTITY(1,1)
   ,line VARCHAR(MAX)  NULL
)
AS
BEGIN
   DECLARE
    @fn VARCHAR(35) = 'fnGetRtnDesc'
   ,@desc_st_row     INT = NULL
   ,@desc_end_row    INT = NULL
   ,@schema_nm       VARCHAR(50)
   ,@ad_stp          BIT            = 0
   ,@tstd_rtn        VARCHAR(100)
   ,@qrn             VARCHAR(100)
   ;

   SELECT
       @qrn       = qrn
      ,@schema_nm = schema_nm
      ,@tstd_rtn  = rtn_nm
      ,@ad_stp    = ad_stp
   FROM test.RtnDetails;

   if(@ad_stp=1) INSERT INTO @t(line) VALUES(CONCAT('-- ', @fn));

   INSERT INTO @t(line) 
   SELECT line
   FROM dbo.fnGetRtnDef();

   SET @desc_st_row = (SELECT TOP 1 id FROM @t WHERE line LIKE '--%Description%');
   SET @desc_end_row= (SELECT TOP 1 id FROM @t WHERE line LIKE '%====%' AND id>@desc_st_row);
   DELETE FROM @t WHERE id NOT BETWEEN @desc_st_row AND @desc_end_row-1;

   UPDATE @t
   SET line = dbo.fnTrim(REPLACE(line, '-- Description:', '--'));
   RETURN;
END
/*
SELECT * from Test.RtnDetails;
SELECT * from Test.ParamDetails;
SELECT * FROM test.fnGetRtnDesc();
SELECT * FROM dbo.fnGetRtnDef();
EXEC tSQLt.RunAll;
SELECT * FROM test.RtnDetails;
*/



GO
