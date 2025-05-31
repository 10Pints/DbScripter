SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================
-- Author:		 Terry Watts
-- Create date: 03-AUG-2023
-- Description: returns the different matches and
--    the match counts for the given criteria
--    caller must add THE %_ wild cards as necessary
--
-- Forms a query with the were clause like:
--    where (a [or b][ or c]) ([and not d] [and not e] [and not f])
--
-- CHANGES:
-- 230812: remove book,sht,row as these are no longer used
-- 231006: updated with staging id field name convention change
-- ==================================================================
ALTER PROCEDURE [dbo].[sp_investigate_s2_crops]
    @where_subclause1   NVARCHAR(MAX)                -- must have characters
   ,@where_subclause2   NVARCHAR(MAX)  = NULL
   ,@where_subclause3   NVARCHAR(MAX)  = NULL
   ,@not_clause1        NVARCHAR(MAX)  = NULL
   ,@not_clause2        NVARCHAR(MAX)  = NULL
   ,@not_clause3        NVARCHAR(MAX)  = NULL
   ,@case_sensitve      BIT            = 0 -- case insensitve
   ,@crop               NVARCHAR(30)   = NULL
AS
BEGIN
   DECLARE 
       @fn                       NVARCHAR(35)  = N'INVESTIGATE S2 CROPS'
      ,@sql                      NVARCHAR(MAX)
      ,@where_clause             NVARCHAR(MAX)
      ,@ids                      NVARCHAR(MAX)
      ,@msg                      NVARCHAR(MAX)
      ,@nl                       NVARCHAR(2) = /*NCHAR(0x0a) + */NCHAR(0x0d)
      ,@collate_clause           NVARCHAR(200)
      ,@len                      INT
      ,@len1                     INT
      ,@len2                     INT

   --SET XACT_ABORT ON;

   EXEC sp_log 1, @fn,'01: starting: 
@where_subclause1 : [', @where_subclause1 , ']
@where_subclause2 : [', @where_subclause2 , ']
@where_subclause3 : [', @where_subclause3 , ']
@not_clause1      : [', @not_clause1 , ']
@not_clause2      : [', @not_clause2 , ']
@not_clause3      : [', @not_clause3 , ']
@case_sensitve    : [', @case_sensitve    , ']';

   BEGIN TRY
      -- Tidy parameters  EXEC sp_log 2, @fn,'';
      EXEC sp_log 2, @fn,'02: Tidy parameters';
      SET @where_subclause1= dbo.fnScrubParameter(@where_subclause1);
      SET @where_subclause2= dbo.fnScrubParameter(@where_subclause2);
      SET @where_subclause3= dbo.fnScrubParameter(@where_subclause3);
      SET @not_clause1     = dbo.fnScrubParameter(@not_clause1 );
      SET @not_clause2     = dbo.fnScrubParameter(@not_clause2 );
      SET @not_clause3     = dbo.fnScrubParameter(@not_clause3 );
      SET @collate_clause  = iif(@case_sensitve = 0, 'COLLATE Latin1_General_CI_AI', 'COLLATE Latin1_General_CS_AI');

      -- Validating:
      EXEC sp_log 1, @fn,'03: Validating';
      IF Ut.dbo.fnLen(@where_subclause1) = 0 THROW 53478, 'sp_list_occurence_counts: @where_subclause1 must be specified', 1;

      -- Get max field lens
      EXEC sp_log 1, @fn,'04: Get max field lens';
      SELECT @len1 = MAX(ut.dbo.fnLen(crops))
      FROM
      (
      SELECT DISTINCT [crops]
         FROM [Staging2]
         WHERE crops LIKE @where_clause
      ) R;

      SELECT @len2 = MAX(ut.dbo.fnLen(crops))
      FROM
      (
      SELECT DISTINCT crops
         FROM staging2
         WHERE crops LIKE @where_clause
      ) R;

      SET @len = iif(@len1>@len2,@len1,@len2);

      ------------------------------------------------------------------
      -- Build the where clause:
      ------------------------------------------------------------------
      EXEC sp_log 1, @fn,'05: Build the where clause';
      SET @where_clause = CONCAT( '([#field#] LIKE     ''',  @where_subclause1, ''' ', @collate_clause);
      IF @where_subclause2 IS NOT NULL SET @where_clause = CONCAT(@where_clause,  @nl, '   OR [#field#] LIKE     ''', @where_subclause2, ''' ', @collate_clause);
      IF @where_subclause3 IS NOT NULL SET @where_clause = CONCAT(@where_clause,  @nl, '   OR [#field#] LIKE     ''', @where_subclause3, ''' ', @collate_clause);
   
      -- Close off the OR bracket
      EXEC sp_log 1, @fn,'06: Close off the OR bracket';
      SET @where_clause = CONCAT( @where_clause,' )');
      IF @not_clause1  IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND [#field#] NOT LIKE ''', @not_clause1, ''' ', @collate_clause);
      IF @not_clause2  IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND [#field#] NOT LIKE ''', @not_clause2, ''' ', @collate_clause);
      IF @not_clause2  IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND [#field#] NOT LIKE ''', @not_clause3, ''' ', @collate_clause);
 
      IF @crop IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND crops like ''%', @crop, '%''');
      ------------------------------------------------------------------

      EXEC sp_log 1, @fn,'07: where clause  :', @where_clause;
      EXEC sp_log 1, @fn,'08: creating SQL  : the count sql for the staging 2 table';
      --SET @sql = dbo.fnCrtSqlForListOccurencesOld('staging2', @field, @where_clause);
      EXEC sp_log 2, @fn,'08.1: fnCrtSqlForListOccurences params: (''staging2'', ''crops'' @where_clause:[', @where_clause, '], @len: ',@len, ')';
      SET @sql = dbo.fnCrtSqlForListOccurences('staging2', 'crops', @where_clause, @len);
      EXEC sp_log 1, @fn,'9: executing sql ', @nl, @sql;
      EXEC (@sql);
      EXEC sp_log 1, @fn,'10: executed sql ';
      EXEC sp_log 1, @fn,'11:  creating SQL 2: the count sql for the staging 1 table';

      SET @sql = dbo.fnCrtSqlForListOccurences('staging1', 'crops', @where_clause, @len);
      EXEC sp_log 1, @fn,'12: executing sql 2', @nl, @sql;
      EXEC (@sql);
      EXEC sp_log 1, @fn,'13: executed sql ';
      SET @where_clause = REPLACE(@where_clause, '#field#', 'crops');
      EXEC sp_log 1, @fn,'14: creating SQL 3: agg ids sql, where clause: ', @where_clause;
      -- agg ids
      SET @sql = dbo.fnGetIdsInTablesForCriteriaSql('staging1', 'stg1_id', 'staging2', 'stg2_id', @where_clause);
      EXEC sp_log 1, @fn,'15: executing sql (agg ids)', @nl, @sql;
      EXEC sp_executesql @sql, N'@ids NVARCHAR(MAX) OUT', @ids OUT
      EXEC sp_log 1, @fn,'16: executed sql @ids:(', @ids, ')';

      EXEC sp_log 1, @fn,'17: creating SQL 4: the S12_vew on the ids';
      IF @ids IS not NULL
      BEGIN
         SET @sql = CONCAT(
            'SELECT s2.stg2_id , s1.stg1_id',@nl
            ,', CONCAT(''['',s2.[','crops],'']'') as s2_crops'
            ,', s2.uses as s2_uses'
            ,', s2.ingredient'
            ,', CONCAT(''['',s1.[','crops','],'']'') as s1_crops'
            ,', s1.uses as s1_uses'
            ,', S1.ingredient, s2.notes 
            FROM staging2 S2 
            FULL JOIN staging1 S1 on (S2.stg2_id=s1.stg1_id)
            WHERE s1.stg1_id in (',@ids,')
            AND   s2.stg2_id in (',@ids,')
            ORDER BY S1.stg1_id;');

         EXEC sp_log 1, @fn,'18: executing sql (agg ids)', @nl, @sql;
         EXEC(@sql)
      END
      ELSE
      BEGIN
         EXEC sp_log 1, @fn,'19: No ids were found';
      END
   END TRY
   BEGIN CATCH
      SET @msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn,'20: *** caught exception: ', @msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn,'21: leaving OK' 
END
/*
EXEC sp_investigate_s2_crops '%Banana (Cavendish) as bunch spray%'
Cucurbits (Cucumbermelon,squash,
Rice (Direct Seeded PreGerminated)
*/

GO
