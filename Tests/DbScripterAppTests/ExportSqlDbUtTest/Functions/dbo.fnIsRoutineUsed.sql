SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- determines if a ROUTINE is used ny another routine
-- i.e. it exists in the  definition of another routine
-- =============================================
CREATE FUNCTION [dbo].[fnIsRoutineUsed]
(
   @rtn_nm NVARCHAR(100)
)
RETURNS BIT
AS
BEGIN
   DECLARE
        @fn  NVARCHAR(35)   = N'hlpr_002_fnDequalifyName'
       ,@n  INT
   -- chk rtn exists first if not throw div by zero error
   IF NOT EXISTS (SELECT 1 FROM SysRtns2_vw WHERE rtn_nm = @rtn_nm) SET @n = 1/0;
   RETURN
      CASE 
         WHEN EXISTS(
            SELECT 1
            FROM SysRtns2_vw
            WHERE
               [def] like CONCAT('%',@rtn_nm, '%')
               AND rtn_nm <> @rtn_nm) THEN 1 
         ELSE 0
         END;
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_024_fnIsRoutineUsed'
SELECT TOP 200 * FROM SysRtns2_vw
*/
GO

