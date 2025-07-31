SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Terry Watts
-- Create date: 26-Jul-2025
-- Description: lists the rnts and their count
-- types: {'function', 'procedure','table','view'}
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:
-- Tests:
-- =============================================
CREATE PROCEDURE [test].[sp_GetRoutineCounts] @schema VARCHAR(50)
AS
BEGIN
   SET NOCOUNT ON;
   SELECT *
   FROM
       (SELECT COUNT(*) as functions  FROM dbo.fnListRtns( @schema ,'function'))  A
      ,(SELECT COUNT(*) as procedures FROM dbo.fnListRtns( @schema ,'procedure')) B
      ,(SELECT COUNT(*) as tables     FROM dbo.fnListRtns( @schema ,'table'))     C
      ,(SELECT COUNT(*) as views      FROM dbo.fnListRtns( @schema ,'view'))      D
   SELECT * FROM  dbo.fnListRtns( @schema ,'function');
   SELECT * FROM  dbo.fnListRtns( @schema ,'procedure');
   SELECT * FROM  dbo.fnListRtns( @schema ,'table');
   SELECT * FROM  dbo.fnListRtns( @schema ,'view');
END
/*
EXEC test.sp_GetRoutineCounts 'test'
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
select * FROM dbo.fnListRtns( 'dbo' ,NULL);
*/
GO

