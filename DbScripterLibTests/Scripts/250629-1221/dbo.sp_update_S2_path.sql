SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =======================================================
-- Author:      Terry Watts
-- Create date: 06-NOV-2024
-- Description: Updates the S2 pathogens field
--
-- Exception handling: logs error and rethrows exception
--
-- Called by:
--    sp_S2_fixup_row <- sp_S2_fixup <-- sp__main_import
-- =======================================================
CREATE   PROCEDURE [dbo].[sp_update_S2_path]
    @search_clause   NVARCHAR(500)
   ,@filter_field_nm NVARCHAR(40)
   ,@filter_op       NVARCHAR(8)
   ,@filter_clause   NVARCHAR(400) --=  NULL -- comma separated list use ' ' - do not wrap items like 'Fred',Bill'
   ,@not_clause      NVARCHAR(400) -- = NULL
   ,@exact_match     BIT           -- = 0
   ,@cs              BIT
   ,@replace_clause  NVARCHAR(500) --
   ,@note_clause     NVARCHAR(500) -- = NULL -- appends to notes
   ,@comments        NVARCHAR(1000)
   ,@fixup_cnt       INT            = NULL OUT
   ,@select_sql      NVARCHAR(4000) = NULL OUT
   ,@update_sql      NVARCHAR(4000) = NULL OUT
   ,@execute         BIT             = 1     -- if clr then just return the sqls dont actually update
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35)   = 'UPDATE_S2_PATH'

   EXEC sp_log 1, @fn, '000: starting, @exact_match: ', @exact_match;

   EXEC sp_update_s2
       @field          = 'pathogens'
      ,@search_clause  = @search_clause
      ,@filter_field_nm= @filter_field_nm
      ,@filter_op      = @filter_op
      ,@filter_clause  = @filter_clause
      ,@not_clause     = @not_clause
      ,@exact_match    = @exact_match
      ,@cs             = @cs
      ,@replace_clause = @replace_clause
      ,@note_clause    = @note_clause     -- appends to notes
      ,@comments       = @comments
      ,@fixup_cnt      = @fixup_cnt       OUT
      ,@select_sql     = @select_sql      OUT
      ,@update_sql     = @update_sql      OUT
      ,@execute        = @execute   -- if clr then just return the sqls dont actually update
   ;

   EXEC sp_log 1, @fn, '999: leaving';
END
/*
DECLARE @fixup_cnt INT = 0
EXEC sp_update_S2_path 'Selective And Systemic Post-','Selective,Systemic,Post-emergent', NULL, NULL, @fixup_cnt OUT;
EXEC sp__main_import  @start_stage=4, @start_row=255, @stop_row=255, @restore_s3_s2=1, @import_file='D:\Dev\Farming\Data\LRAP-221018.txt' ,@cor_file = 'D:\Dev\Farming\Data\ImportCorrections 221018.txt'; -- stage 4 pre S2 fixup  the old 221018 import
*/


GO
