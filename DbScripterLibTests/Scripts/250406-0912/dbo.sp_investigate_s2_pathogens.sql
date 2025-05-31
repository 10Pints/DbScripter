SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================
-- Author:      Terry Watts
-- Create date: 05-MaAY-2023
-- Description: returns the different matches and
--    the match counts for the given criteria
--    caller must add THE %_ wild cards as necessary
--
-- Forms a query with the were clause like:
--    where (a [or b][ or c]) ([and not d] [and not e] [and not f])
--
-- CHANGES:
-- 231010: added validation @where_subclause1 must have characters
--         maintainance: fixed breaking changes
-- 231019: general tidyup of commented out code
-- ==================================================================
ALTER   PROCEDURE [dbo].[sp_investigate_s2_pathogens]
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
       @fn                       VARCHAR(20)  = N'INV S2 PATHOGENS'
      ,@sql                      NVARCHAR(MAX)
      ,@sql2                     VARCHAR(MAX)
      ,@where_clause             NVARCHAR(MAX)
      ,@ids                      VARCHAR(MAX)
      ,@msg                      VARCHAR(MAX)
      ,@nl                       NVARCHAR(2) = /*NCHAR(0x0a) + */NCHAR(0x0d)
      ,@collate_clause           NVARCHAR(200)
      ,@len                      INT
      ,@len1                     INT
      ,@len2                     INT

   --SET XACT_ABORT ON;

   EXEC sp_log 2, @fn,'01: starting: 
@where_subclause1 : [', @where_subclause1 , ']
@where_subclause2 : [', @where_subclause2 , ']
@where_subclause3 : [', @where_subclause3 , ']
@where_subclause1 : [', @where_subclause1 , ']
@where_subclause2 : [', @where_subclause2 , ']
@where_subclause3 : [', @where_subclause3 , ']
@case_sensitve    : [', @case_sensitve    , ']';
--@field            : [', @field            , ']

   BEGIN TRY
      -- VALIDATION:
      -- 231010: added validation @where_subclause1 must have characters
      IF @where_subclause1 IS NULL OR dbo.fnLen(@where_subclause1) = 0 THROW 52314, '@where_subclause1 must be defined', 1;

      -- Tidy parameters  EXEC sp_log 2, @fn,'';
      EXEC sp_log 2, @fn,'02: Tidy parameters';
      SET @where_subclause1= dbo.fnScrubParameter(@where_subclause1);
      SET @where_subclause2= dbo.fnScrubParameter(@where_subclause2);
      SET @where_subclause3= dbo.fnScrubParameter(@where_subclause3);
      SET @not_clause1     = dbo.fnScrubParameter(@not_clause1 );
      SET @not_clause2     = dbo.fnScrubParameter(@not_clause2 );
      SET @not_clause3     = dbo.fnScrubParameter(@not_clause3 );
      SET @collate_clause  = iif(@case_sensitve = 0, N'COLLATE Latin1_General_CI_AI', N'COLLATE Latin1_General_CS_AI');

      -- Validating:
      EXEC sp_log 2, @fn,'03: Validating';
      IF dbo.fnLen(@where_subclause1) = 0 THROW 53478, 'sp_list_occurence_counts: @where_subclause1 must be specified', 1;

      SELECT S2.id as [s2_id (sub clause 1)], s2.pathogens as s2_pathogens, pathogen as s2_pathogen, s2.crops
      FROM dbo.fnListPathogens2() F 
      JOIN staging2 s2 on s2.id = F.id 
      JOIN staging1 s1 on s1.id  = S2.id 
      WHERE pathogen like @where_subclause1;

      If @where_subclause2 IS NOT NULL
         SELECT S2.id as [s2_id (sub clause 2)], s2.pathogens as s2_pathogens, pathogen as s2_pathogen, s2.crops
         FROM dbo.fnListPathogens2() F 
         JOIN staging2 s2 on s2.id = F.id 
         JOIN staging1 s1 on s1.id  = S2.id 
         WHERE pathogen like @where_subclause2;

      If @where_subclause3 IS NOT NULL
         SELECT S2.id as [2_id (sub clause 3)], s2.pathogens as s2_pathogens, pathogen, s2.crops
         FROM dbo.fnListPathogens2() F
         JOIN staging2 s2 on s2.id = F.id 
         JOIN staging1 s1 on s1.id = S2.id 
         WHERE pathogen like @where_subclause3;

      ------------------------------------------------------------------
      -- Build the where clause:
      ------------------------------------------------------------------
      EXEC sp_log 2, @fn,'04: Build the where clause';
      SET @where_clause = CONCAT( N'(pathogens LIKE     ''',  @where_subclause1, N''' ', @collate_clause);
      IF @where_subclause2 IS NOT NULL SET @where_clause = CONCAT(@where_clause,  @nl, N'   OR pathogens LIKE     ''', @where_subclause2, N''' ', @collate_clause);
      IF @where_subclause3 IS NOT NULL SET @where_clause = CONCAT(@where_clause,  @nl, N'   OR pathogens LIKE     ''', @where_subclause3, N''' ', @collate_clause);
   
      -- Close off the OR bracket
      EXEC sp_log 2, @fn,'05: Close off the OR bracket';
      SET @where_clause = CONCAT( @where_clause,' )');
      EXEC sp_log 2, @fn,'05.1: where clause:', @nl, @where_clause;

      IF @not_clause1 IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, N'   AND pathogens NOT LIKE ''', @not_clause1, N''' ', @collate_clause);
      IF @not_clause2 IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, N'   AND pathogens NOT LIKE ''', @not_clause2, N''' ', @collate_clause);
      IF @not_clause2 IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, N'   AND pathogens NOT LIKE ''', @not_clause3, N''' ', @collate_clause);
 
      EXEC sp_log 2, @fn,'05.2: where clause:', @nl, @where_clause;
      IF @crop IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, N'   AND crops like ''%', @crop, '%''');
      ------------------------------------------------------------------

      EXEC sp_log 2, @fn,'06: where clause:', @nl, @where_clause;

      -- Get max field lens
      EXEC sp_log 2, @fn,'07: Get max field length';
      SET @sql = CONCAT(N'  SELECT @len1 = MAX(dbo.fnLen(pathogens))
      FROM
      (
      SELECT DISTINCT pathogens
         FROM staging1
         WHERE ',@where_clause,N'
      ) R;'
      );

      EXEC sp_log 2, @fn,'08: executing sql ', @nl, @sql;
      EXEC sp_executesql @sql, N'@len1 INT OUT', @len1 OUT

      SET @sql = CONCAT( N' SELECT @len2 = MAX(dbo.fnLen(pathogens))
      FROM
      (
      SELECT DISTINCT pathogens
         FROM staging2
         WHERE ', @where_clause, N'
      ) R;'
      );

      EXEC sp_log 2, @fn,'09: executing sql ', @nl, @sql;
      EXEC sp_executesql @sql, N'@where_clause VARCHAR(MAX), @len2 INT OUT', @where_clause, @len2 OUT
      SET @len = iif(@len1>@len2,@len1,@len2);
      EXEC sp_log 2, @fn,'10: calling fnCrtSqlForListOccurences(''staging2'')';
      SET @sql = dbo.fnCrtSqlForListOccurences('staging2', 'pathogens', @where_clause, @len);
      EXEC sp_log 2, @fn,'11: executing sql ', @nl, @sql;
      EXEC (@sql);
      EXEC sp_log 2, @fn,'12: executed sql ';

      SET @sql = dbo.fnCrtSqlForListOccurences(N'staging1', N'pathogens', @where_clause, @len);
      EXEC sp_log 2, @fn,'13: executing sql ', @nl, @sql;
      EXEC (@sql);
      EXEC sp_log 2, @fn,'14: executed sql ';
      -- agg ids
      SET @where_clause = REPLACE(@where_clause, N'#field#', N'pathogens');

      SET @sql = dbo.fnGetIdsInTablesForCriteriaSql(N'staging1', N'id', N'staging2', N'id',  @where_clause);
      EXEC sp_log 2, @fn,'15: executing sql (agg ids)', @nl, @sql;
      EXEC sp_executesql @sql, N'@ids VARCHAR(MAX) OUT', @ids OUT
      EXEC sp_log 2, @fn,'16: executed sql @ids:(', @ids, ')';

      IF @ids IS not NULL
      BEGIN
         SET @sql2 = CONCAT(
            N'SELECT 
    s2.id as s2_id, s1.id as s1_id
   , s2.pathogens as s2_pathogens
   , s1.pathogens as s1_pathogens
   , S1.ingredient, S1.crops, s2.notes
FROM staging2 S2 
FULL JOIN staging1 S1 on (S2.id=s1.id)
WHERE s1.id in (',@ids, N')
AND   s2.id in (',@ids, N')
ORDER BY S1.id;');

         EXEC sp_log 2, @fn,'17: executing sql (agg ids)';
         PRINT @sql2;
         EXEC(@sql2)
      END
      ELSE
      BEGIN
         EXEC sp_log 2, @fn,'18: No Rows were found in either table for the given criteria';
      END
   END TRY
   BEGIN CATCH
      SET @msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fn,'50: *** caught exception: ', @msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn,'99: leaving' 
END
/*
EXEC sp_investigate_s2_pathogens 'Worm',@not_clause1=' Worm'
*/


GO
