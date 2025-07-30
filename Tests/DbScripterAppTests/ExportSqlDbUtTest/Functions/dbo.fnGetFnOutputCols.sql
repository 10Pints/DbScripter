SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 05-APR-2024
-- Description: gets the output columns from a table function
--
-- Usage SELECT def FROM dbo.[fnGrepSchema]('test', '%name%', '%content filter%') 
-- =============================================
CREATE FUNCTION [dbo].[fnGetFnOutputCols]
(
    @q_rtn_nm     NVARCHAR(60)
)
RETURNS @t TABLE
(
    name          NVARCHAR(50)
   ,ordinal       INT
   ,ty_nm         NVARCHAR(40)
   ,[len]         INT
   ,is_nullable   BIT
)
AS
BEGIN
      INSERT INTO @t (name, ordinal, ty_nm, [len], is_nullable) 
      SELECT name, column_id as ordinal, TYPE_NAME(user_type_id) as ty_nm, max_length, is_nullable
      FROM sys.columns
      WHERE object_id=object_id(@q_rtn_nm)
      ORDER BY column_id;
   RETURN;
END
/*
  SELECT * FROM dbo.fnGetFnOutputCols('test.fnCrtHlprCodeTstSpecificPrms');
*/
GO

