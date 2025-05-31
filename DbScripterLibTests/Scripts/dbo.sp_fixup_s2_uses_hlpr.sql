SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 07-OCT-2023
-- Description: helper for sp_fixup_s2_uses
--
-- PRECONDITIONS: 
--    PRE01: @where_clause must be specified
--    PRE02: @new_uses must be specified
--    PRE03: @where_field must be specified
--
-- CHANGES:
-- 231024: @fixup_cnt param is now optional
-- =============================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_uses_hlpr]
    @where_field  NVARCHAR(30) -- '=' or LIKE
   ,@where_op     NVARCHAR(20) -- '=' or LIKE
   ,@where_clause NVARCHAR(500)-- e.g. 'Pgr' (for =) or '%insecticide%/%nematicide%' for like
   ,@new_uses     NVARCHAR(100)-- uses replacement
   ,@fixup_cnt    INT = NULL OUT
AS
BEGIN
   DECLARE 
       @fn NVARCHAR(35) = 'FIXUP_S2_USES_HLPR'
      ,@sql    NVARCHAR(MAX)
      ,@rowcnt INT = 0
      ,@rc    INT = 0;

	SET NOCOUNT OFF;
   SET @sql = CONCAT('UPDATE staging2 SET uses = ''', @new_uses,''' WHERE ', @where_field, ' ', @where_op, ' ''', @where_clause, '''');

   -- Validation: PRE01, PRE02, PRE03
   IF @where_clause IS NULL OR ut.dbo.fnLen(@where_clause) = 0 THROW 53214, '@where_clause must be specified', 1;
   IF @new_uses     IS NULL OR ut.dbo.fnLen(@new_uses)     = 0 THROW 53215, '@new_uses must be specified'    , 1;
   IF @where_field  IS NULL OR ut.dbo.fnLen(@where_field)  = 0 THROW 53215, '@where_field must be specified'    , 1;

   -- Execute
   EXEC @rc = sp_executesql @sql;
   SET @rowcnt = @@ROWCOUNT;

   IF @rc <> 0 
   BEGIN
      DECLARE @msg NVARCHAR(500);
      SET @msg = CONCAT( 'sp_executesql failed: SQL: ', @sql, ' rc: ', @rc);
      EXEC sp_Log 4, @fn, @msg;
      THROW 65487, 'sp_fixup_s2_uses_hlpr: failed', 1;
   END

   IF @fixup_cnt IS NOT NULL
      SET @fixup_cnt = @fixup_cnt + @rowcnt;
END
/*
DECLARE @delta        INT = 0
--EXEC sp_fixup_s2_uses_hlpr 'uses', 'LIKE', '%insecticide%/%nematicide%', @new_uses ='Insecticide,Nematicide', @delta=@delta OUT
EXEC sp_fixup_s2_uses_hlpr 'ingredient', 'LIKE', '%Ethephon%', @new_uses ='Growth Regulator', @delta=@delta OUT
PRINT CONCAT('@delta: ', @delta, ' rows updated')
*/

GO
