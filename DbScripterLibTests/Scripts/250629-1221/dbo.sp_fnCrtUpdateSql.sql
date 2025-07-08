SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--========================================================================================================================
-- Author:      Terry Watts
-- Create date: 07-NOV-2024
-- Description: creates the update SQL for sp_update
--
-- Notes:
-- 1: beware replacing a short srch clause with a longer one that contains the 
--    srch clause as this if repeated will produce unwanted repitition
--
-- 2: beware replacing empty or null srch cls like '' - in this case d not use replace
-- 3: not like clause must not be a subset of the search clause - if so - dont use not like cls
-- TEST: T006 not like cls subset of srch cls
--
-- Tests: test_018_fnCrtUpdateSql see sp_gen_tst_dta_S2_tst and fnGetUnregisteredPathogensFromS3
-- xls order:
-- id, command, table, field, search_clause, filter_field, filter_clause, not_clause, replace_clause
--, field2_nm, field2_val, must_update, comments, exact_match
--
-- Preconditions:
-- PRE 01: @filter_op must be IN ('EQUALS'  OR 'IN')  OR Exception 56741, '@filter_op must be IN ('EQUALS'  OR 'IN') '
-- PRE 02: @field2_op must be IN ('REPLACE' OR 'ADD') OR Exception 56741, '@field2_op must be IN ('REPLACE' OR 'ADD')'
--
-- CHANGES:
-- 241205: updated @filter_op prm to one of {'LIKE' =, 'EQUALS', 'IN'}
-- 241213: re added case sensitive searches @cs=1, default: 0 (case insensitive search)
-- 241221: added the @extras prm to set 1 or more extra field values
-- 250107: @ not_clause: not like '' should not be scripted as NOT LIKE'%%' BUT like NOT LIKE''''
-- 250107: field2: if null or empty and ADD dont add comma only
-- ==============================================================================================
CREATE PROCEDURE [dbo].[sp_fnCrtUpdateSql]
(
    @table_nm        NVARCHAR(60)
   ,@field_nm        NVARCHAR(60)
   ,@search_clause   NVARCHAR(500)
   ,@filter_field_nm NVARCHAR(60) 
   ,@filter_op       NVARCHAR(6)    -- One of 'LIKE' 'EQUALS' 'IN'
   ,@filter_clause   NVARCHAR(500)  -- comma separated list do not wrap the comma separated values in  ' '
   ,@not_clause      NVARCHAR(400)
   ,@exact_match     BIT            -- Used to flag when to use UPDATE tbl set field = rplce cls or REPLACE(field, srch cls, rplce cls)
   ,@cs              BIT
   ,@replace_clause  NVARCHAR(500)
   ,@field2_nm       NVARCHAR(60)
   ,@field2_op       NVARCHAR(8)    -- 0 replace(default), 1 add
   ,@field2_clause   NVARCHAR(500)
   ,@extras          NVARCHAR(2000) -- sql clause to add one or more extra field values e,g 'comments=''some comment'' '
   ,@select_sql      NVARCHAR(4000) OUT
   ,@update_sql      NVARCHAR(4000) OUT
)
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)= 'sp_fnCrtUpdateSql'
   ,@cs_s            NVARCHAR(8)
   ,@nl              NCHAR(2)    = NCHAR(13) + NCHAR(10)
   ,@single_quote    NCHAR       = NCHAR(39) -- ASCII(39) is ' the single qote character
   ,@is_exact        BIT -- used to flag where to use UPDATE tbl set field =  val or UPDATE tbl set field = REPLACE(field, drch cls, replace cls)
   ,@Line1           VARCHAR(120) = REPLICATE('-', 100)
   ,@Line2           VARCHAR(120) = REPLICATE('*', 100)
   ,@filter_sql      NVARCHAR(MAX)
   ,@sql             NVARCHAR(MAX)
   ,@set_cls         NVARCHAR(MAX)
   ,@tab             NCHAR(3)=' '
   ,@where_cls       NVARCHAR(MAX)
   ;
   SET @cs_s = iif(@cs IS NULL, '<NULL>', CONVERT(NVARCHAR(8), @cs));
   EXEC sp_log 1, @fn, '000: starting
filter_op:[',@filter_op,']
field2_op:[',@field2_op,']
cs       :[',@cs_s     ,']
';
   -------------------------------------------------
   -- Defaults:
   -------------------------------------------------
   IF @filter_op IS NULL SET @filter_op = 'EQUALS';
   IF @field2_op IS NULL SET @field2_op = 'REPLACE';
   IF @cs        IS NULL SET @cs        = 0; -- case insensitve search
   IF @filter_op =  ''   SET @filter_op = '<EMPTY>';
   IF @field2_op =  ''   SET @field2_op = '<EMPTY>';

   EXEC sp_log 1, @fn, '005: params after setting defaults
filter_op:[',@filter_op,']
field2_op:[',@field2_op,']';

   -------------------------------------------------
   -- Validating Preconditions
   -------------------------------------------------
   EXEC sp_log 1, @fn, '010: validating preconditions';

   -- PRE 01: @filter_op must be IN ('EQUALS'  OR 'IN')  OR Exception 56741, '@filter_op must be IN ('EQUALS'  OR 'IN') '
   IF @filter_field_nm IS NOT NULL AND @filter_op NOT IN ('EQUALS', 'IN')
      EXEC sp_raise_exception 56741, '@filter_op must be IN (''EQUALS'' OR ''IN'') but was:[',@filter_op,']',@fn=@fn;

   -- PRE 02: @field2_op must be IN ('REPLACE' OR 'ADD') OR Exception 56741, '@field2_op must be IN ('REPLACE' OR 'ADD')'
   IF @field2_nm IS NOT NULL AND @field2_op NOT IN ('REPLACE', 'ADD') exec sp_raise_exception 56741, 'field2_op must be IN (''REPLACE'' OR ''ADD'') but was:[',@field2_op,']';

   EXEC sp_log 1, @fn, '020: validated  preconditions OK';

   WHILE 1=1
   BEGIN

      -------------------------------------------------
      -- Stage 1: set sql: UPDATE @table SET @field =
      -------------------------------------------------
      SET @set_cls = CONCAT
      (
          'SET', @nl,@tab
         ,' [',@field_nm,']='
      )

      -----------------------------------------------
      -- Assertion: sql: UPDATE @table SET @field = Replace clause
      -----------------------------------------------

      -------------------------------------------------------------------------------
      -- Stage 2: set sql = UPDATE @table SET @field = exact clause or Replace clause
         --  depending on if ( NUL or MT or EXACT) or not
      -------------------------------------------------------------------------------
      SET @is_exact = iif((@search_clause IS NULL) OR (dbo.fnLen(@search_clause) = 0) OR (@exact_match = 1), 1, 0);

      IF (@is_exact = 1)
      BEGIN
         -- Create exact clause
         SET @set_cls = CONCAT(@set_cls, '''', @replace_clause, '''');
      END
      ELSE
      BEGIN
         -- Create replace clause
          SET @set_cls = CONCAT(@set_cls, 'REPLACE([', @field_nm, '], ''', @search_clause, ''', ''',@replace_clause, ''')');
      END

      --------------------------------------------------------------------------------------------------------------------
      -- Assertion: sql: UPDATE @table SET @field = @replace_clause or =REPLACE(field, @search_clause, @replace_clause) NL
      --------------------------------------------------------------------------------------------------------------------

      ----------------------------------------------------------------
      -- Stage 3: add other set field clauses
      -- 250107: field2: if null or empty and ADD dont add comma only
      ----------------------------------------------------------------
      IF @field2_nm IS NOT NULL AND @field2_nm <> '' AND @field2_clause IS NOT NULL AND @field2_clause <> ''
      BEGIN
         SET @set_cls = 
         CONCAT
         (
             @set_cls, @NL, @tab,',[', @field2_nm, ']='
            ,iif( @field2_op='REPLACE'
                  ,CONCAT('''', @field2_clause, '''')                               -- REPLACE
                  ,CONCAT('CONCAT([', @field2_nm
                  , '], IIF(',@field2_nm,' IS NULL OR ',@field2_nm,'='''','''','','')',',''', @field2_clause, ''')')-- ADD
                )
         );

         ----------------------------------------------------
         -- Assertion: sql: contains all required set fields
         ----------------------------------------------------
      END

      -- Set any extra field values
      -- sql clause to add one or more extra field values e,g 'comments=''some comment'' '
      IF @extras IS NOT NULL
      BEGIN
         SET @set_cls =
         CONCAT
         (
             @set_cls, @NL, @tab, ',', @extras
         );
      END

      --======================================
      -- Stage 4 Add WHERE clauses
      --======================================
      -- EXEC sp_log 1, @fn, '040: Stage 4 starting - add WHERE clauses';
      SET @where_cls = CONCAT('WHERE', @NL, @tab,' [',@field_nm,']')
      -- EXEC sp_log 1, @fn, '051: is act: ', @is_exact;

      IF @is_exact = 1
      BEGIN
         -- EXEC sp_log 1, @fn, '053: in if @is_exact = 1 TRU brnch';
         SET @where_cls = CONCAT( @where_cls, '=''',@search_clause, '''');
      END
      ELSE
      BEGIN
         -- EXEC sp_log 1, @fn, '057: in if @is_exact = 1 FLS brnch';
         SET @where_cls = CONCAT( @where_cls, ' LIKE ''%', @search_clause,'%''');
      END

      ---------------------------------------------------------------
      -- Case sensitive
      ---------------------------------------------------------------
      if(@cs=1)
         SET @where_cls = CONCAT(@where_cls, ' COLLATE Latin1_General_CS_AS');

      ----------------------------------------------------------------------
      -- Stage 5 Add 'and search field not like clause'
      -- Only add this if @replace_clause is not a subset of @search_clause
      ----------------------------------------------------------------------
      IF CHARINDEX(@replace_clause, @search_clause) = 0
      BEGIN
         SET @where_cls = CONCAT( @where_cls, @NL
         ,'AND [',@field_nm,'] NOT LIKE ''%', @replace_clause, '%''');

         if(@cs=1)
            SET @where_cls = CONCAT(@where_cls, ' COLLATE Latin1_General_CS_AS');
      END

      ---------------------------------------------------------------
      -- Stage 6: If filter field is specified
      ---------------------------------------------------------------
      If @filter_field_nm IS NOT NULL AND @filter_field_nm IS NOT NULL
      BEGIN
         -- Depending on the filter_op: {'=' OR 'IN'}

         IF @filter_op = 'EQUALS'
         BEGIN
            -- EXEC sp_log 1, @fn, '160 filter op is ''EQUALS''';
            SET @filter_sql = CONCAT('=''', @filter_clause, '''');
         END
         ELSE
         BEGIN
            -- Wrap both the entire in clause in single quotes and the comma separated values in the list
            SELECT @filter_clause = string_agg( CONCAT('''', TRIM(value),''''), ',') FROM string_split(@filter_clause, ',')
            SET @filter_sql    = CONCAT(' IN (', @filter_clause,')' );
         END

         SET @where_cls = CONCAT(@where_cls, @nl, 'AND [', @filter_field_nm, ']', @filter_sql);
      END

      ---------------------------------------------------------------
      -- Stage 7: If not clause is specified
      -- 250107: not like '' should not be scripted as NOT LIKE'%%' BUT like NOT LIKE''''
      ---------------------------------------------------------------
      IF @not_clause Is NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '300 ******** adding not clause';
         IF @not_clause = ''
         BEGIN
            SET @where_cls = CONCAT( @where_cls, @NL
            ,'AND [',@field_nm,'] NOT LIKE ''''');
         END
         ELSE
         BEGIN
            SET @where_cls = CONCAT( @where_cls, @NL
            ,'AND [',@field_nm,'] NOT LIKE ''%', @not_clause, '%''');
         END
      END

     -- Terminate the statement
      SET @where_cls = CONCAT( @where_cls, @NL,';');

      SET @select_sql = CONCAT('SELECT * FROM ', @table_nm, @NL, @where_cls);
      SET @update_sql = CONCAT('UPDATE ', @table_nm, @NL, @set_cls, @NL, @where_cls);

      ---------------------------------------------------------------
      -- Completed SQL
      ---------------------------------------------------------------
      EXEC sp_log 1, @fn, '400 completed';
      PRINT @Line2;
      EXEC sp_log 1, @fn, '410: ',@nl,'Select SQL:',@nl, @select_sql;
      PRINT @Line1;
      EXEC sp_log 1, @fn, '420: ',@nl,'Update SQL:',@nl, @update_sql;
      PRINT @Line2;
      BREAK

   END -- WHILE 1=1
   EXEC sp_log 1, @fn, '999: leaving';
END
/*
EXEC tSQLt.Run 'test.test_018_fnCrtUpdateSql';
EXEC dbo.sp_appLog_display @dir = 0;
EXEC dbo.sp_appLog_display @fn='sp_fnCrtUpdateSql';
*/

GO
