SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================================
-- Author:       Terry Watts
-- Create date:  06-AUG-2023
-- Description:  Fixup the Stage 1 phi field@replace_clause
--    @replace_all means if any part of the field matches the @search_clause then replace all the field with 
--    @exact       means whle field must match teh search clause
-- ==============================================================================================================
CREATE   PROCEDURE [dbo].[sp_pre_fixup_s2_phi_hlpr] 
    @search_clause   VARCHAR(150)
   ,@replace_clause  VARCHAR(150)
   ,@not_clause      VARCHAR(150)  = NULL
   ,@replace_all     BIT            = 0
   ,@exact           BIT            = 0
   ,@case_sensitive  BIT            = 0
   ,@fixup_cnt       INT            OUT
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE 
       @fn              VARCHAR(35)  = N'FIXUP S2 PHI HLPR'
      ,@delta           INT = 0
      ,@sql             VARCHAR(MAX)
      ,@nl              VARCHAR(1) = NCHAR(13)
      ,@collate_clause  VARCHAR(150)

   EXEC sp_log 0, @fn, '000 starting'

   SET @collate_clause = CONCAT('COLLATE ', IIF(@case_sensitive=1, 'Latin1_General_CS_AI', ' Latin1_General_CI_AI'), @nl)

   If @replace_all = 1
   BEGIN
      -- replace all
      SET @sql = CONCAT
      (
         'UPDATE staging2 SET phi = ''', @replace_clause, ''' WHERE phi LIKE ''%',@search_clause,'%'' ', @collate_clause
         , 'AND phi NOT like ''%',@replace_clause,'%'' '                                               , @collate_clause
         , IIF(@not_clause IS NOT NULL
            , CONCAT
            (
                'AND phi NOT like ''%'
               ,@not_clause,'%'''
               ,@collate_clause), ''
            )
      );
  END
   ELSE
   BEGIN
      SET @sql = CONCAT
      (
           'UPDATE staging2 SET phi = REPLACE(phi, ''', @search_clause, ''',''', @replace_clause, ''') ' ,@nl
         , 'WHERE phi LIKE '
         , IIF
           (
              @exact = 0
            , CONCAT
            (
                '''%'
               , @search_clause
               , '%'''
            )
            , CONCAT
            (
                ''''
               ,@search_clause
               ,''' '
            )
          ) -- iif
          ,  @collate_clause
         , 'AND phi NOT like ''%',@replace_clause,'%'' '                                                                   , @collate_clause
         , IIF
           (
             @not_clause IS NOT NULL
            ,CONCAT
             (
                'AND phi NOT like ''%'
               ,@not_clause,'%'' '
               ,@collate_clause
             )
            , ''
           ) -- iif
      ); -- main concat
   END

   --PRINT @sql;
   EXEC (@sql);

   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_log 0, @fn,'099: leaving, @fixup_cnt: ', @fixup_cnt,' @exact_filter:', @exact;
END
/*
EXEC sp_copy_s3_s2
------------------------------------------------------------------------------------------------------------
DECLARE @fixup_cnt INT = 0
EXEC sp_fixup_s2_phi_hlpr  'No PHI', 'No PHI necessary', @replace_all=1, @case_sensitive=0;
SELECT id, phi from staging2 order by phi
*/


GO
