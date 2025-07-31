SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 03-JUN-2020
-- Description: Test close
--
-- =============================================
CREATE PROCEDURE [test].[TCLS 031 fnContainsWhitespace]
AS
BEGIN
   -- remove the log switches
   -- DROP/REVERT any 1 off test setup data
   DROP TABLE IF EXISTS test.TSU1_031_table;
   -- wrap up
   EXEC test.sp_tst_mn_cls
END
GO

