SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:	    Terry Watts
-- Create date: 21-JUL-2024
-- Description: Creates the script file name from the q rtn name
-- ==============================================================
CREATE FUNCTION [test].[fnCrtScrptFileNm]( @qrn NVARCHAR(120))
RETURNS NVARCHAR(MAX)
AS
BEGIN
   DECLARE @schema_nm NVARCHAR(30)
         , @rtn_nm    NVARCHAR(60)
   SELECT 
       @schema_nm = schema_nm
      ,@rtn_nm    = rtn_nm
   FROM test.fnSplitQualifiedName(@qrn);
	RETURN CONCAT('create_', @schema_nm, '.', @rtn_nm, '_script.sql');
END
/*
PRINT  test.fnCrtScrptFileNm('[dbo].[fn_total_vaccinations_2]')
PRINT  test.fnCrtScrptFileNm('[dbo].fn_total_vaccinations_2]')
PRINT  test.fnCrtScrptFileNm('[fn_total_vaccinations_2]')
*/
GO

