SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  21-DEC-2023
-- Description:  Dumps the held log 
--               call this in the event of an exception
-- ======================================================================================================
CREATE PROCEDURE [dbo].[sp_clr_log_cache]
AS
BEGIN
   DECLARE @was_hold BIT = COALESCE(CONVERT(BIT, SESSION_CONTEXT(N'HOLD LOG')), 0)
   IF @was_hold = 1 EXEC sp_log 2, 'dump_log', '';
END
/*
*/
GO

