SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  04-AUG-2023
-- Description:  sp_fixup_s1_mrl row helper
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s1_mrl_hlpr]
       @search_clause   NVARCHAR(100)
      ,@replace_clause  NVARCHAR(100)
      ,@fixup_cnt       INT OUT
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(30)  = N'FIXUP S1 MRL HLPR'
      ,@delta     INT
   SET NOCOUNT ON
   UPDATE staging1 SET mrl = @replace_clause WHERE mrl LIKE @search_clause;
   SET @delta =  @@ROWCOUNT;
   SET @fixup_cnt = @fixup_cnt + @delta;
   EXEC sp_log 2, @fn, 'fixup count: ',@fixup_cnt, ' SRC: ',@search_clause, ' REP: ', @replace_clause;
END
/*
EXEC sp_copy_s1_bak_s1;
EXEC dbo.sp_fixup_s1;
---------------------------------------
DECLARE  @fixup_cnt    INT = 0;
EXEC dbo.sp_fixup_s1_mrl @fixup_cnt OUT;
PRINT CONCAT('fixup_cnt: ',@fixup_cnt);
SELECT DISTINCT mrl FROM staging1 ORDER BY mrl;
---------------------------------------
SELECT id, mrl from staging1 where mrl like CONCAT('%',NCHAR(10),'%');
*/

GO
