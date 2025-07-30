SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [test].[fnGetTestNum]
(
    @test_num     NVARCHAR(100)
   ,@test_sub_num NVARCHAR(50)
)
RETURNS  NVARCHAR(100)
AS
BEGIN
   RETURN CONCAT(ut.dbo.fnPadRight(CONCAT(@test_num, '.',@test_sub_num), 50), ': ');
END
GO

