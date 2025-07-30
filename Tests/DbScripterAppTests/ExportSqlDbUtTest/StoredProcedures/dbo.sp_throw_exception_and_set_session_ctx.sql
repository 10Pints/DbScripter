SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 21-NOV-2023
-- Description: raises an exception and sets 
-- and sets the session ctx: @exception
-- =============================================
CREATE PROCEDURE [dbo].[sp_throw_exception_and_set_session_ctx]
    @ex_num  INT
   ,@ex_msg  NVARCHAR(500)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
    @fn              NVARCHAR(35)   = 'ThrowExceptionAndSetSessionCtx'
   DECLARE @msg NVARCHAR(520) = CONCAT(@ex_num, ': ', @ex_msg);
   EXEC sp_log 2, @fn, '01: starting, params: 
@ex_num :[',@ex_num  ,']
@ex_msg :[',@ex_msg ,']'
   EXEC sp_set_session_context N'@exception'   , @msg;
   EXEC sp_log 2, @fn, 'Throwing exception ',@ex_num, ', ''[',@ex_msg, ']''';
   THROW @ex_num, @ex_msg, 1;
END
GO

