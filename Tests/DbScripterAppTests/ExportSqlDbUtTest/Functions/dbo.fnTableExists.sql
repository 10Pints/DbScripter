SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: returns true (1) if table exxists else false (0)
-- schema default is dbo
-- =============================================
CREATE FUNCTION [dbo].[fnTableExists]
(
   @table_spec NVARCHAR(60)
)
RETURNS BIT
AS
BEGIN
   DECLARE
       @schema                    NVARCHAR(10)
      ,@table_nm                  NVARCHAR(60)
      ,@n                         INT
   SELECT
       @schema   = schema_nm
      ,@table_nm = rtn_nm
   FROM test.fnSplitQualifiedName(@table_spec);
   RETURN 
      CASE 
         WHEN EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_nm AND TABLE_SCHEMA = @schema) 
         THEN 1 
         ELSE 0 
      END
END
/*
PRINT dbo.fnChkRtnExists('Test.fnGetCrntTstClsFn')
PRINT dbo.fnChkRtnExists('dbo.sp_assert_not_null_or_empty')
PRINT dbo.fnChkRtnExists('sp_assert_not_null_or_empty')
PRINT dbo.fnChkRtnExists('dbo.sp_assert_n')
*/
GO

