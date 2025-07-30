SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 27-DEC-2021
-- Description: Sets the debug mode (for testing)
-- =============================================
CREATE PROCEDURE [dbo].[sp_set_debug_mode] @mode BIT = 1
AS
BEGIN
   EXEC sp_set_session_context N'DEBUG', @mode;
   --PRINT CONCAT('Debug mode set to:[',dbo.fnGetDebugMode(), ']');
END
/*
EXEC dbo.sp_set_debug_mode
EXEC dbo.sp_set_debug_mode 1
EXEC dbo.sp_set_debug_mode 0
*/
GO

