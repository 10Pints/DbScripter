SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 22-OCT-2022
-- Description: fixup the entry mode in staging2
-- ===============================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_action_general_hlpr]
       @index           NVARCHAR(10)
      ,@search_clause   NVARCHAR(80)
      ,@replace_clause  NVARCHAR(80)
      ,@fixup_cnt       INT OUT
      ,@must_update     BIT   = 0
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn        NVARCHAR(35)   = 'SP_FIXUP_S2_ACTION_GEN_HPR'
      ,@sql       NVARCHAR(MAX)
      ,@delta     INT            = 0
      ,@error_msg NVARCHAR(2000)

   EXEC sp_log 1, @fn, '00: starting
 @index         :[',@index         ,']
,@search_clause :[',@search_clause ,']
,@replace_clause:[',@replace_clause,']
,@fixup_cnt     :[',@fixup_cnt     ,']
,@must_update   :[',@must_update   ,']
   ';

   SET @sql= CONCAT(
   'UPDATE staging2 SET entry_mode = REPLACE(entry_mode, ''', @search_clause, ''',''',@replace_clause,''')
   WHERE entry_mode LIKE ''%', @search_clause,'%'';'
   );

   BEGIN TRY
      PRINT @sql;
      EXEC (@sql);
      SET @delta = @@rowcount;
      SET @fixup_cnt   = @fixup_cnt + @delta;
      EXEC sp_log 1, @fn, @index,': @sql: ', @sql, @row_count = @delta;

      IF @must_update = 1 AND @delta = 0
      BEGIN
         DECLARE @msg NVARCHAR(500)
         SET @msg = CONCAT('Error: ', @fn, ' ', @sql, ' updated no rows');
         EXEC sp_log 4, @fn, @msg;
         THROW 53487, @msg, 1;
      END
      END TRY
      BEGIN CATCH
         SET @error_msg = Ut.dbo.fnGetErrorMsg();
         EXEC sp_log 4, @fn, '50: caught exception
   exception:      [', @error_msg     , ']'
   ;

         THROW;
      END CATCH
   EXEC sp_log 1, @fn, 'leaving, @row_cnt: ',@delta, ' @fixup_cnt: ',@fixup_cnt, @row_count = @delta;
END

/*
DECLARE @delta INT = 0
EXEC sp_fixup_s2_mode_hlpr '01', 'Contact/selective', 'Contact',@delta OUT;
PRINT CONCAT('@delta: ', @delta, ' rows');

SELECT stg2_id, entry_mode from Staging2 WHERE entry_mode LIKE '%Early post-emergent%';

UPDATE staging2 SET entry_mode = REPLACE(entry_mode, 'Early post-emergent','Post-emergent')
   WHERE entry_mode LIKE '%Early post-emergent%';

SELECT * FROM dbo.fnRptGetChemicalForPathogenCrop('Sigatoka', 'Banana');
SELECT * FROM dbo.fnRptGetChemicalForPathogenCrop(NULL, NULL);
SELECT * FROM chemical_pathogen_crop_vw where pathogen_nm = 'Sigatoka'
*/

GO
