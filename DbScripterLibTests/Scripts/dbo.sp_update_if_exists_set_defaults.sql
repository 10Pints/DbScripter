SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:		 Terry Watts
-- Create date: 04-JUL-2023
-- Description: part of the factorisation of sp_update_if_exists
--
-- IF fatal error then triws exception to stop processing
--
-- RULES:
--    @search_clause must exist and not be empty else exception
-- DEFAULTS:
-------------------------------------------
--    field           default
-------------------------------------------
--    @replace_clause ''
--    @and_not_clause NULL
--    @notes          NULL
--    @field          'pathogens'
--    @table          'Staging2'
--    @doit           1
--    @must_update    1
--    @id            -1
--    @result_msg     NULL
--    @exp_cnt       -1
--    @row_count     0
--    @case_sensitive 0  i.e. case -nsensitive
-------------------------------------------
--
-- Changes:
-- 231015:  changed ,@act_cn nm to @row_count for consistency
-- ===============================================================
ALTER PROCEDURE [dbo].[sp_update_if_exists_set_defaults]
    @search_clause   NVARCHAR(MAX)   OUTPUT
   ,@replace_clause  NVARCHAR(MAX)   OUTPUT
   ,@field           NVARCHAR(60)    OUTPUT
   ,@table           NVARCHAR(60)    OUTPUT
   ,@doit            BIT             OUTPUT
   ,@must_update     BIT             OUTPUT
   ,@id              NVARCHAR(60)    OUTPUT
   ,@result_msg      NVARCHAR(MAX)   OUTPUT
   ,@row_count       INT             OUTPUT
   ,@case_sensitive  INT             OUTPUT
AS
BEGIN
   DECLARE 
       @msg          NVARCHAR(MAX)  = NULL
      ,@nl           NVARCHAR(2)    = NCHAR(13)

   -- Validation
   IF (@search_clause IS NULL) OR (ut.dbo.fnLen(@search_clause) = 0) 
   BEGIN 
      SET @msg = CONCAT('sp_update_if_exists search_clause must be specified id: ', @id);
      THROW 53200, @msg, 1;
   END
 
   IF substring( @search_clause, 1, 1) = '%' OR substring( @search_clause, Ut.dbo.fnLen(@search_clause), 1) = '%'
      THROW 51871, 'sp_update_if_exists expects @search_clause not to be wrapped in %%', 1;

   IF (@replace_clause IS NULL) 
   BEGIN 
      SET @replace_clause = '';
   END

   -- Set defaults
   IF (@doit IS NULL)
   BEGIN 
      SET @doit = 1;
   END

   IF (@must_update IS NULL) 
   BEGIN 
      SET @must_update =1;
   END

   IF (@id IS NULL) 
   BEGIN 
      SET @id = -1;
   END

/*   IF (@exp_cnt IS NULL) 
   BEGIN 
      SET @exp_cnt = -1;
   END */

   IF (@row_count IS NULL) 
   BEGIN 
      SET @row_count = -1;
   END

   IF (@case_sensitive IS NULL) 
   BEGIN 
      SET @case_sensitive = 0;
   END

   IF (@field IS NULL)  OR (@field = '') 
   BEGIN 
      SET @field = 'pathogens';
   END
   
   IF (@table IS NULL)  OR (@table = '') 
   BEGIN 
      SET @table = 'Staging2';
   END

   --PRINT 'sp_update_if_exists_set_defaults: leaving';
END
/*

SELECT id, pathogens FROM Staging2
DECLARE 
       @msg          NVARCHAR(500)  = NULL
      ,@nl           NVARCHAR(2)    = NCHAR(13)

   , @search_clause  NVARCHAR(1000) = 'fred'
   , @replace_clause NVARCHAR(1000) = NULL
   , @not_clause NVARCHAR(1000) = NULL
   , @notes          NVARCHAR(100)  = NULL
   , @field          NVARCHAR(60)   = NULL
   , @table          NVARCHAR(60)   = NULL
   , @doit           BIT            = NULL
   , @must_update    BIT            = NULL
   , @id             NVARCHAR(60)   = NULL
   , @result_msg     NVARCHAR(150)  = NULL 
   , @exp_cnt        INT            = NULL 
   , @act_cnt        INT            = NULL 

EXEC sp_update_if_exists_set_defaults
     @search_clause  = @search_clause   OUTPUT
   , @replace_clause = @replace_clause  OUTPUT
   , @not_clause = @not_clause  OUTPUT
   , @notes          = @notes           OUTPUT
   , @field          = @field           OUTPUT
   , @table          = @table           OUTPUT
   , @doit           = @doit            OUTPUT
   , @must_update    = @must_update     OUTPUT
   , @id             = @id              OUTPUT
   , @result_msg     = @result_msg      OUTPUT
   , @exp_cnt        = @exp_cnt         OUTPUT
   , @act_cnt        = @act_cnt         OUTPUT

PRINT CONCAT
(
   '@search_clause  =[',COALESCE (@search_clause , 'NULL'),']',@nl
 , '@replace_clause =[',COALESCE (iif(@replace_clause='','''''' ,@replace_clause), 'NULL'),']',@nl
 , '@not_clause =[',COALESCE (@not_clause, 'NULL'),']',@nl
 , '@notes          =[',COALESCE (@notes         , 'NULL'),']',@nl
 , '@field          =[',COALESCE (@field         , 'NULL'),']',@nl
 , '@table          =[',COALESCE (@table         , 'NULL'),']',@nl
 , '@doit           =[',COALESCE (@doit          , 'NULL'),']',@nl
 , '@must_update    =[',COALESCE (@must_update   , 'NULL'),']',@nl
 , '@id             =[',COALESCE (CONVERT(NVARCHAR(20),@id)            , 'NULL'),']',@nl
 , '@result_msg     =[',COALESCE (@result_msg    , 'NULL'),']',@nl
 , '@exp_cnt        =[',COALESCE (CONVERT(NVARCHAR(20),@exp_cnt)       , 'NULL'),']',@nl
 , '@act_cnt        =[',COALESCE (CONVERT(NVARCHAR(20),@act_cnt)       , 'NULL'),']',@nl
);


GO
*/

GO
