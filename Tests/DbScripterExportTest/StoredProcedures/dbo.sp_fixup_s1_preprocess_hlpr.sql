SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================
-- Author:      Terry Watts
-- Create date: 15-OCT-2023
-- Description: helper rtn to update s1 and record the update count
--              Handles errors from sp_executesql by chk the ret
--              Doubles up single quotes
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_fixup_s1_preprocess_hlpr]
    @field     VARCHAR(60)
   ,@key       VARCHAR(200)
   ,@value     VARCHAR(200)
   ,@ndx       INT    = NULL        OUTPUT
   ,@fixup_cnt INT    = NULL        OUTPUT
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
    @fn        VARCHAR(35)   = 'sp_s1_fixup_preprocess_hlpr'
   ,@sql       NVARCHAR(MAX)
   ,@row_count INT
   ,@ret       INT
   ,@ndx_str   VARCHAR(35)
   ,@msg       VARCHAR(200)
   EXEC sp_log 1, @fn,'000: starting
   @field    : [',@field, ']
   @key      : [',@key, ']
   @value    : [',@value, ']
   @ndx      : [',@ndx, ']
   @fixup_cnt: [',@fixup_cnt, ']
   '
   ;
   -- Double up single quotes
   SET @value = REPLACE(@value, '''', '''''')
   SET @ndx_str = CONCAT(dbo.fnPadLeft2(@ndx, 2, '0'),' ');
   SET @sql = CONCAT('UPDATE staging1 SET [',@field,'] = REPLACE([', @field, '],''',@key,''',''',@value, ''') WHERE ',@field, ' LIKE ''%', @key, '%''');
   EXEC sp_log 1, @fn, 'sql:
', @sql;
   EXEC @ret = sp_executesql @sql;
   SET @row_count = @@ROWCOUNT;
   IF @ret <> 0
   BEGIN
      SET @msg = CONCAT('sp_executesql returned error code: ',@ret);
      EXEC sp_log 4, @fn, '010:',@ndx_str, @msg;
      THROW 64541, @msg, 1;
   END
   SET @fixup_cnt = @fixup_cnt + @row_count;
   SET @msg = CONCAT(@field, ': replaced ''',@key,''' with ''', @value, '''');
   EXEC sp_log 1, @fn, @ndx_str, @msg, @row_count = @row_count;
   SET @ndx = @ndx +1
   EXEC sp_log 1, @fn,'999: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
EXEC sp_fixup_s1_preprocess;
EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' and & ', ','
EXEC sp_fixup_s1_preprocess_hlpr  'company', '"', ''''
EXEC sp_fixup_s1_preprocess_hlpr 'product', 'á', ' '
*/
GO

