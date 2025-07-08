SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================
-- Author:      Terry Watts
-- Create date: 24-DEC-2024
-- Description: s ets the log to file ctx
--
-- Changes:
-- =====================================================
CREATE PROC [dbo].[SetCtxLogToFile] @flg BIT
AS
BEGIN
   EXEC sp_set_session_context N'Log to file', @flg;
END

GO
