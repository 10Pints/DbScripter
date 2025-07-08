SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================================
-- Description: handles the loggong and cjecks during the S2 fixup process
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 08-FEB-2025
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_update_trigger_s2_crops]
    @inserted staging2_tbl READONLY
   ,@deleted  staging2_tbl READONLY
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
    @fn               VARCHAR(35) = N'S2_UPDATE_TRIGGER'
   ,@fixup_row_id     INT       -- xl row id
   ,@imp_file_nm      VARCHAR(400)
   ,@msg              VARCHAR(4000)
   ,@nl               VARCHAR(2) = CHAR(13) + CHAR(10)
   ,@new_crops        VARCHAR(4000)
   ,@old_crops        VARCHAR(4000)
   ,@replace_clause   VARCHAR(4000)
   ,@row_cnt          INT
   ,@search_clause    VARCHAR(4000)
   ,@xl_row           INT       -- xl row id
   ;

   SELECT @row_cnt = COUNT(*) FROM @inserted;

   SET @fixup_row_id   = dbo.fnGetCtxFixupRowId();
   SET @search_clause  = dbo.fnGetCtxFixupSrchCls();
   SET @replace_clause = dbo.fnGetCtxFixupRepCls();
   SET @xl_row         = dbo.fnGetCtxFixupStgId();
   SET @imp_file_nm    = dbo.fnGetCtxFixupFile();

   EXEC sp_log 1, @fn, '000: starting @fixup_row_id: ',@fixup_row_id, ', @imp_file_nm: [',@imp_file_nm, '], @fixup_stg_id: ', @xl_row, ', @search_clause: [',@search_clause,']';

   ---------------------------------------------------------------------------------------
   -- Log update summary
   ---------------------------------------------------------------------------------------
   INSERT INTO S2UpdateSummary 
          (fixup_row_id, xl_row, row_cnt, search_clause, replace_clause, imp_file_nm)
   SELECT @fixup_row_id,@xl_row,@row_cnt,@search_clause,@replace_clause,@imp_file_nm;

   EXEC sp_log 1, @fn, '010: @fixup_row_id: ',@fixup_row_id;

   ---------------------------------------------------------------------------------------
   -- Log update details
   ---------------------------------------------------------------------------------------
   INSERT INTO S2UpdateLog (fixup_id, id, old_pathogens, new_pathogens, old_crops, new_crops, old_entry_mode, new_entry_mode, old_chemical, new_chemical)
   SELECT @fixup_row_id, d.id, d.pathogens, i.pathogens,d.crops, i.crops,d.entry_mode, i.entry_mode,d.ingredient,i.ingredient
   FROM @inserted i JOIN @deleted d ON i.id=d.id
   WHERE i.pathogens <> d.pathogens OR i.crops<> d.crops;

   -- Once inserted in to the log tables run invariant chks
   IF @imp_file_nm LIKE '%Crops%'
   BEGIN
      
      IF EXISTS 
      (
         SELECT 1 FROM @inserted i JOIN @deleted d ON i.id = d.id
         WHERE i.crops LIKE '%beanbean%' AND d.crops NOT LIKE '%beanbean%'
      )
      BEGIN
         SELECT @imp_file_nm AS [file], @fixup_row_id AS fixup_row, @xl_row, i.id
         ,i.entry_mode AS i_entry_mode, d.entry_mode AS d_entry_mode
         ,i.crops AS i_crops, d.crops AS d_crops
         FROM @inserted i JOIN @deleted d ON i.id = d.id
         ;

         SELECT TOP  1
          @new_crops = i.crops
         ,@old_crops = d.crops
         FROM @inserted i JOIN @deleted d ON i.id = d.id
         ;

         SET @msg = CONCAT(
          'update error beanbean'                , @nl
         ,'file:          ' ,@imp_file_nm        , @nl
         ,'row:           ' ,@xl_row             , @nl
         ,'search_clause  [',@search_clause, ']' , @nl
         ,'replace_clause:[',@replace_clause,']' , @nl
         ,'old crops:     [',@old_crops,']'      , @nl
         ,'new crops:     [',@new_crops,']'      , @nl
         );

         print CONCAT('019: *** ERROR:', @msg);
         EXEC sp_log 4, @fn, '020: ',@msg;
         EXEC sp_log 4, @fn, '021: '      , @nl
         ,'new crops:     [',@new_crops,']'      , @nl
         ;

         EXEC sp_raise_exception 53152, @msg, @fn=@fn;
      END
   END
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/

GO
