SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================================================
-- Author:      Terry Watts
-- Create date: 24-DEC-2023
-- Description: logs a sub test and sets the sub num context
-- ================================================================================================================================
CREATE PROCEDURE [dbo].[sp_log_sub_tst]
    @fn              NVARCHAR(35)
   ,@sub_num         NVARCHAR(35)
   ,@msg             NVARCHAR(200)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
    @txt             NVARCHAR(500)
   SET @txt = CONCAT(@sub_num, ': ', @msg);
   EXEC test.sp_tst_set_crnt_tst_sub_num @sub_num
   EXEC sp_log 2, @fn, @txt;
END
/*
*/
GO

