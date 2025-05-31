SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================================================================================
-- Author:      Terry Watts
-- Create date: 05-JUL-2023
-- Description: Creates the update SQL
--
-- PRECONDITIONS - all inputs valid
-- @search_clause will be wrapped with % % 
--  do not make a search clause like '%abcd%'
--
-- POSTCONDITIONS and RET CODES:
-- PO1: returns 0 SUCCESS, and @updt_sql and @search_sql populated or throws exception 56427 or 56428
--
-- Changes:
-- 230819: removing the expected count get and check
-- 231014: in the exception handler: rollback txn before logging
-- 231015: removed the cor_id, search_clause, replace_clause, not_clause insertions from the update table sql
-- 231015: removed the try catch block and the TRANSACTION
-- 231106: added postcondition chk
-- 231106: removed the search sql
-- 240211: added @srch_sql_clause out param to use to select the rows or count that should like 'FOM Staging2 Where ...
-- =========================================================================================================================
ALTER PROCEDURE [dbo].[sp_update_if_exists_crt_updt_sql]
    @search_clause   NVARCHAR(MAX)
   ,@replace_clause  NVARCHAR(MAX)
   ,@not_clause      NVARCHAR(MAX)
   ,@note_clause     NVARCHAR(MAX)
   ,@field           NVARCHAR(60)
   ,@table           NVARCHAR(60)
   ,@case_sensitive  BIT = 0
   ,@crops           NVARCHAR(MAX)
   ,@id              INT
   ,@updt_sql        NVARCHAR(MAX)                 OUTPUT
   ,@srch_sql_clause NVARCHAR(MAX)                 OUTPUT
 AS
BEGIN
   DECLARE 
       @fn                 NVARCHAR(30)   = N'UPDT_IFEXSTS_CRTSQL'
      ,@set_clause         NVARCHAR(MAX)  = N'SET'
      ,@msg                NVARCHAR(MAX)
      ,@where_clause       NVARCHAR(MAX)
      ,@tgt_clause         NVARCHAR(MAX)
      ,@collation_clause   NVARCHAR(30)   = NULL
      ,@nl                 NVARCHAR(1)    = NCHAR(0x0d)

   BEGIN TRY
      EXEC sp_log 0, @fn, '01: starting';
      SET @set_clause = 'SET' + @nl + '    ';

      -- Validate params
      IF SUBSTRING( @search_clause, 1, 1) = '%' OR SUBSTRING( @search_clause, Ut.dbo.fnLen(@search_clause), 1) = '%'
      BEGIN
         SET @msg = 'sp_update_if_exists expects @search_clause not to be wrapped in %%';
         EXEC sp_log 4, @fn, '02: ',@msg;
         THROW 51871, @msg, 1;
      END

      SET @tgt_clause = @search_clause;
      SET @search_clause = CONCAT('%', @tgt_clause,'%');

      IF @case_sensitive <> 0
         SET @collation_clause = dbo.fnGetCollation(@case_sensitive);

      -- ASSERTION: if here then validation ok

      -- set clauses
      -- log the action in the comment
      IF ((@note_clause IS NOT NULL) AND (@note_clause <> ''))
      BEGIN
         SET @set_clause = CONCAT(@set_clause, ' notes = CONCAT( notes, ''', ' ', @note_clause, ''')', @nl, ',');
      END

      -- Set where clause
      EXEC sp_update_if_exists_crt_where_clause @search_clause, @not_clause, @crops, @field, @table, @collation_clause, @where_clause OUTPUT;

      SET @set_clause = CONCAT
      (
          @set_clause 
         ,' [', @field, ']=Replace(', @field, ', ''', @tgt_clause, ''', ''', @replace_clause, ''') ' -- , '''  ', @collation_clause, ') '
      );

      -- Create the main update query
      SET @updt_sql = CONCAT('UPDATE ', @table, @nl, @set_clause, @nl, @where_clause, @nl);
      SET @srch_sql_clause = CONCAT('FROM ', @table, ' ', @where_clause);

      --EXEC sp_log 1, @fn, '10: update sql:', @nl, @updt_sql;

      -- PO1: returns 0 SUCCESS, and @updt_sql and @search_sql populated or throws exception 56427 or 56428
      IF @updt_sql IS NULL OR Ut.dbo.fnLen(@updt_sql) = 0 THROW 56427, 'update sql not populated', 1;
   END TRY
   BEGIN CATCH
      EXEC Ut.dbo.sp_log_exception @fn
      ,'@search_clause [',@search_clause , ']
@replace_clause[',@replace_clause, ']
@not_clause    [',@not_clause    , ']
@note_clause   [',@note_clause   , ']
@field         [',@field         , ']
@table         [',@table         , ']
@case_sensitive[',@case_sensitive, ']
@crops         [',@crops         , ']
@id            [',@id            , ']';

      THROW;
   END CATCH

   EXEC sp_log 0, @fn, '99: leaving, OK';
   RETURN 0;
END

GO
