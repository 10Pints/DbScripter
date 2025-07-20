SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- ===============================================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: fnLen deals with the trailing spaces bug in Len
-- ===============================================================
CREATE  FUNCTION [dbo].[fnLen]( @v VARCHAR(8000))
RETURNS INT
AS
BEGIN
   RETURN CASE
            WHEN @v IS NULL THEN 0
            ELSE Len(@v+'x')-1
            END;
END
/*
EXEC test.sp__crt_tst_rtns 'dbo].[fnLen]', 43;
*/



GO
