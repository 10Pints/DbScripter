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
ALTER   PROCEDURE [dbo].[sp_pre_fixup_s2_uses_hlpr]
    @where_field  VARCHAR(30) -- '=' or LIKE
   ,@where_op     VARCHAR(20) -- '=' or LIKE
   ,@where_clause VARCHAR(500)-- e.g. 'Pgr' (for =) or '%insecticide%/%nematicide%' for like
   ,@new_uses     VARCHAR(100)-- uses replacement
   ,@fixup_cnt    INT OUT
AS
BEGIN
   DECLARE 
       @fn VARCHAR(35) = 'FIXUP_S2_USES_HLPR'
      ,@sql    VARCHAR(MAX)
      ,@rowcnt INT = 0
      ,@rc    INT = 0;

   SET NOCOUNT OFF;
   SET @sql = CONCAT('UPDATE staging2 SET uses = ''', @new_uses,''' WHERE ', @where_field, ' ', @where_op, ' ''', @where_clause, '''');

   -- Validation: PRE01, PRE02, PRE03
   IF @where_clause IS NULL OR dbo.fnLen(@where_clause) = 0 THROW 53214, '@where_clause must be specified', 1;
   IF @new_uses     IS NULL OR dbo.fnLen(@new_uses)     = 0 THROW 53215, '@new_uses must be specified'    , 1;
   IF @where_field  IS NULL OR dbo.fnLen(@where_field)  = 0 THROW 53215, '@where_field must be specified'    , 1;

   -- Execute
   EXEC @rc = sp_executesql @sql;
   SET @rowcnt = @@ROWCOUNT;
   SET @fixup_cnt = @fixup_cnt + @rowcnt;

   IF @rc <> 0 
   BEGIN
      DECLARE @msg VARCHAR(500);
      SET @msg = CONCAT( 'sp_executesql failed: SQL: ', @sql, ' rc: ', @rc);
      EXEC sp_Log 4, @fn, @msg;
      THROW 65487, 'sp_fixup_s2_uses_hlpr: failed', 1;
   END
END


GO
