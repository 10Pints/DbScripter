SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================
-- Author:      Terry Watts
-- Create date: 16-JUN-2025
-- Description: delimits identifier  if necessary
-- Design:      
-- Tests:       
-- ===============================================
CREATE FUNCTION [dbo].[fnDeLimitIdentifier](@q_id VARCHAR(120))
RETURNS VARCHAR(120)
AS
BEGIN
   DECLARE @v VARCHAR(120)
   DECLARE @vals IdNmTbl
   INSERT INTO @vals (val) select value from string_split(@q_id, '.');
   UPDATE @vals SET val = iif((dbo.IsReservedWord(val)=1 OR CHARINDEX(' ', val)>0), CONCAT('[', val, ']'), val)

   SELECT @v = string_agg(val, '.') FROM @vals;
   RETURN @v;
END
/*
EXEC tSQLt.Run 'test.test_073_fnDeLimitIdentifier';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/

GO
