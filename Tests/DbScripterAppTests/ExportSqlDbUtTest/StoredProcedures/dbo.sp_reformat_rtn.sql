SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 07-JAN-2020
-- Description: produces a set of reformatted rows
-- from a routine (stored procedure or function in which
-- the tabs are replaced by the correct number of spaces.
--
-- USAGE like exec ut.dbo.sp_reformat_rtn 'ut.dbo.sp_assert_gtr_than_or_equal';
-- ========================================================
CREATE PROCEDURE [dbo].[sp_reformat_rtn]
       @qlfd_rtn_nm  NVARCHAR(100)
      ,@tab_sz       INT = 3
AS
BEGIN
   DECLARE
       @sql NVARCHAR(4000)
      ,@NL  NVARCHAR(2)   = NCHAR(13)+NCHAR(10)
   SET @sql = CONCAT( [dbo].[fnCreateRoutineLinesTableAndPopulateScript]( @qlfd_rtn_nm, 'tmp_rfr') 
   ,'ut.dbo.fnRTrim(ut.dbo.fnReplaceCreateWithAlter(ut.dbo.fnReplaceTabsAndReformat(txt, ', @tab_sz, '))) 
   FROM tmp_rfr ORDER BY id;');
   PRINT CONCAT('SQL:', @NL, @sql);
   EXEC sp_executesql @sql
END
/*
   exec ut.dbo.sp_reformat_rtn 'ut.dbo.sp_assert_gtr_than_or_equal'
*/
GO

