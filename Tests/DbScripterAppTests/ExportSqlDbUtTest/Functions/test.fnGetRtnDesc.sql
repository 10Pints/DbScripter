SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 10-NOV-2023
-- Description: gets the rtn description from its meta data
--
-- POSTCONDITIONS: 
-- POST01: some rows must be returned or exception 54321
--
-- CHANGES:
--231112: renamed this rtn from and moved to test:
--        dbo.sp_get_rtn_description -> test.sp_get_rtn_desc
-- ===============================================================
CREATE FUNCTION [test].[fnGetRtnDesc]
(
   @qrn NVARCHAR(100)
)
RETURNS @t TABLE
(
    id   INT            IDENTITY(1,1)
   ,line NVARCHAR(MAX)  NULL
)
AS
BEGIN
   DECLARE
       @desc_st_row        INT = NULL
      ,@desc_end_row       INT = NULL
      ,@schema_nm          NVARCHAR(50)
      ,@tstd_rtn           NVARCHAR(100)
   SELECT 
       @schema_nm= schema_nm
      ,@tstd_rtn = rtn_nm
   FROM fnSplitQualifiedName(@qrn);
   INSERT INTO @t(line) 
   SELECT line
   FROM dbo.fnGetRtnDef(@qrn);
   SET @desc_st_row = (SELECT TOP 1 id FROM @t WHERE line LIKE '-- Desc%');
   SET @desc_end_row= (SELECT TOP 1 id FROM @t WHERE line LIKE '%====%' AND id>@desc_st_row);
   DELETE FROM @t WHERE id NOT BETWEEN @desc_st_row AND @desc_end_row-1;
   UPDATE @t
   SET line = dbo.fnTrim(REPLACE(line, '-- Description:', '--'));
   RETURN;
END
/*
SELECT * FROM test.fnGetRtnDesc('dbo.sp_bulk_insert_xl');
SELECT * FROM dbo.fnGetRtnDef('dbo.sp_bulk_insert_xl');
EXEC tSQLt.RunAll;
*/
GO

