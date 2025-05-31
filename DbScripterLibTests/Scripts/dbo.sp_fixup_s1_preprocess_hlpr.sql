SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================================
-- Author:      Terry Watts
-- Create date: 15-OCT-2023
-- Description: helper rtn to update s1 and record the update count
--              Handles errors from sp_executesql by chk the ret
--              Doubles up single quotes
-- =========================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s1_preprocess_hlpr]
    @field     NVARCHAR(60)
   ,@key       NVARCHAR(200)
   ,@value     NVARCHAR(200)
   ,@ndx       INT    = NULL        OUTPUT
   ,@fixup_cnt INT    = NULL        OUTPUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn        NVARCHAR(35)   = 'FIXUP S1 PREPROC HLPR:'
   ,@sql       NVARCHAR(MAX)
   ,@row_count INT
   ,@ret       INT
   ,@ndx_str   NVARCHAR(35)
   ,@msg       NVARCHAR(200)

   EXEC sp_log 1, @fn,'01: starting
   @field    : [',@field, ']
   @key      : [',@key, ']
   @value    : [',@value, ']
   @ndx      : [',@ndx, ']
   @fixup_cnt: [',@fixup_cnt, ']
   '
   ;

   -- Double up single quotes
   SET @value = REPLACE(@value, '''', '''''')

   SET @sql = CONCAT('UPDATE staging1 SET [',@field,'] = REPLACE([', @field, '],''',@key,''',''',@value, ''') WHERE ',@field, ' LIKE ''%', @key, '%''');
   PRINT @sql;
   EXEC @ret = sp_executesql @sql;

   IF @ret <> 0
   BEGIN
      SET @msg = CONCAT('sp_executesql threw exception: ', Ut.dbo.fnGetErrorMsg());
      THROW 64541, @msg, 1;
   END

   SET @row_count =  @@ROWCOUNT;
   SET @ndx_str = CONCAT(Ut.dbo.fnPadLeft2(@ndx, 2, '0'),' ');
   SET @msg = CONCAT(@field, ': replaced ''',@key,''' with ''', @value, '''');
   EXEC sp_log 1, @fn, @ndx_str, @msg, @row_count = @row_count;
   SET @ndx = @ndx +1
   EXEC sp_log 1, @fn,'99: leaving'
END
/*
EXEC sp_fixup_s1_preprocess;
EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' and & ', ','
EXEC sp_fixup_s1_preprocess_hlpr  'company', '"', ''''
EXEC sp_fixup_s1_preprocess_hlpr 'product', 'á', ' '
*/

GO
