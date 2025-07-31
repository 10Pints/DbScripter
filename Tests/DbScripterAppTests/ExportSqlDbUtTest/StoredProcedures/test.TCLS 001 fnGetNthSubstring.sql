SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 01-JUN-2020
-- Description: Test close
--    performs teh test wrap up:
--       1: drops the  temp table
-- PARAMS:
--    @success pass 1 if ok, 0 if error during the tests
-- =============================================
CREATE PROCEDURE [test].[TCLS 001 fnGetNthSubstring]
AS
BEGIN
   -- remove the log switches tables etc,
   DROP TABLE IF EXISTS temp_sys_rtn_vw;
   -- wrap up
   EXEC test.sp_tst_mn_cls
END
GO

