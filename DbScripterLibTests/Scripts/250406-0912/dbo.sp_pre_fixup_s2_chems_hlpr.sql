SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================================================
-- Author:      Terry Watts
-- Create date: 28-JUL-2023
-- Description: sp_fixup_staging2_chemicals helper
--
-- Changes:
-- 03-AUG-2023: Amtryn -> Amtryne OK Amtryne -> Amtryn NOT OK 
--                IF len(replace) < (len search) do not include the the not like clause
-- 231104: addede a must_update param
-- ======================================================================================================
ALTER   PROCEDURE [dbo].[sp_pre_fixup_s2_chems_hlpr]
    @search_clause   VARCHAR(150)
   ,@replace_clause  VARCHAR(150)
   ,@not_clause      VARCHAR(150) = NULL
   ,@case_sensitive  BIT = 0
   ,@fixup_cnt       INT OUT
   ,@must_update     BIT = 0
AS
BEGIN
   DECLARE
      @fn            VARCHAR(30)=N'PRE_FIXUP_S2_CHEMS_HLPR'
     ,@nl            VARCHAR(1)=NCHAR(13)
     ,@sql           VARCHAR(MAX)
     ,@not_clause2   VARCHAR(150)
     ,@len_search    INT
     ,@len_replace   INT
     ,@rowcnt        INT = 0

   EXEC sp_log 1, @fn, '000: Starting,@search_clause:[', @search_clause, '] @replace_clause:[', @replace_clause,'] @not_clause:[',@not_clause, '] cs:', @case_sensitive;
   SET @len_search  = dbo.fnLen(@search_clause);
   SET @len_replace = dbo.fnLen(@replace_clause);
   --PRINT CONCAT('@len_search: ',@len_search, ' @len_replace: ',@len_replace);

   SET @not_clause2 = iif(@not_clause IS NULL, '', CONCAT(@nl, 'AND ingredient NOT LIKE ''%', @not_clause, '%''',iif(@case_sensitive=1, ' COLLATE Latin1_General_CS_AI','')));

   SET @sql = CONCAT
   (
    'UPDATE staging2 set ingredient = REPLACE(ingredient, ''',@search_clause, ''',', '''',@replace_clause, ''')',@nl
   ,'WHERE ingredient     LIKE CONCAT(''%'',''', @search_clause, ''',''%'')'
   -- IF len(replace) < (len search) do not include the the not like clause
   --  'Ametryne','Ametryn'  
   ,iif(@len_search <= @len_replace, CONCAT('AND   ingredient NOT LIKE CONCAT(''%'',''', @replace_clause, ''',''%'')'), '')
   ,iif(@case_sensitive=1, ' COLLATE Latin1_General_CS_AI','')
   ,@not_clause2
   , ';'
   );

   EXEC sp_log 1, @fn,'101: sql:', @nl,  @sql;
   EXEC (@sql);
   SET @rowcnt = @@ROWCOUNT;

   IF @must_update = 1 AND @rowcnt = 0
   BEGIN
      DECLARE @error_msg VARCHAR(500)
      SET @error_msg = 'sp_fixup_s2_chems_hlpr did not update any rows when @must_update set'
      EXEC sp_log 4, @fn, @error_msg;
      THROW 51050, @error_msg, 1;
   END

   SET @fixup_cnt = @fixup_cnt + @rowcnt;
   EXEC sp_log 1, @fn, '99: leaving @fixup_cnt: ',@fixup_cnt, @row_count=@rowcnt;
END
/*
EXEC sp_copy_staging3_staging2; 
EXEC sp_fixup_s2_chems
EXEC sp_fixup_s2_chems_hlpr 'Ametryne','Ametryn'  
SELECT distinct ingredient FROM staging2 WHERE ingredient LIKE '%Ametryn%'-- COLLATE Latin1_General_CS_AI
-- Ametryne+Atrazine  Ametryn+Atrazine     Ametryn
-- UPDATE staging2 set ingredient = REPLACE(ingredient, 'Ametryne','Ametryn') WHERE ingredient     LIKE CONCAT('%','Ametryne','%')
*/


GO
