SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-MAR-2020
-- Description: standard error handling:
--              get the exception message, log messages
--              clear the log cache first
-- NB: this does not throw
--
-- CHANGES
-- 231221: added clear the log cache first
-- 240315: added ex num, ex msg as optional out parmeters
-- 241204: it is possible that ERROR_MESSAGE() or ERROR_NUMBER() are throwing exceptions 
--        -this can happen inside tranactions when low level errors like select * from non existant table
-- 241221: error proc and error line do not always work - for example when executing SQL statements that
--         return a low error number like the following: 207:Invalid column name    
-- ========================================================================================================
CREATE   PROCEDURE [dbo].[sp_log_exception]
       @fn        VARCHAR(35)
      ,@msg01     VARCHAR(4000) = NULL
      ,@msg02     VARCHAR(1000) = NULL
      ,@msg03     VARCHAR(1000) = NULL
      ,@msg04     VARCHAR(1000) = NULL
      ,@msg05     VARCHAR(1000) = NULL
      ,@msg06     VARCHAR(1000) = NULL
      ,@msg07     VARCHAR(1000) = NULL
      ,@msg08     VARCHAR(1000) = NULL
      ,@msg09     VARCHAR(1000) = NULL
      ,@msg10     VARCHAR(1000) = NULL
      ,@msg11     VARCHAR(1000) = NULL
      ,@msg12     VARCHAR(1000) = NULL
      ,@msg13     VARCHAR(1000) = NULL
      ,@msg14     VARCHAR(1000) = NULL
      ,@msg15     VARCHAR(1000) = NULL
      ,@msg16     VARCHAR(1000) = NULL
      ,@msg17     VARCHAR(1000) = NULL
      ,@msg18     VARCHAR(1000) = NULL
      ,@msg19     VARCHAR(1000) = NULL
      ,@ex_num    INT            = NULL OUT
      ,@ex_msg    VARCHAR(500)  = NULL OUT
      ,@ex_proc   VARCHAR(80)   = NULL OUT
      ,@ex_line   VARCHAR(20)   = NULL OUT
AS
BEGIN
   DECLARE 
       @fnThis    VARCHAR(35) = 'sp_log_exception'
      ,@NL        VARCHAR(2)  =  NCHAR(13) + NCHAR(10)
      ,@msg       VARCHAR(500)
      ,@fnHdr     VARCHAR(100)
      ,@isTrans   BIT = 0
      ,@line      VARCHAR(4000)

   SET @ex_num = -1; -- unknown
   SET @msg    = 'UNKNOWN MESSAGE';

   --EXEC sp_log 4, @fnThis, '510: starting';

   SELECT
       @ex_num = ERROR_NUMBER()
      ,@ex_proc= ERROR_PROCEDURE()
      ,@ex_line= CAST(ERROR_LINE() AS VARCHAR(20))
      ,@ex_msg = ERROR_MESSAGE();

   SET @fnHdr = CONCAT(@ex_proc, '(',@ex_line,'): ')

   BEGIN TRY
      SET @msg =
      CONCAT
      (
         '500: caught exception ', @ex_num, ': ', @ex_msg, ' ', 
          @msg01
         ,iif(@msg02 IS NOT NULL, CONCAT(' ', @msg02 ), '')
         ,iif(@msg03 IS NOT NULL, CONCAT(' ', @msg03 ), '')
         ,iif(@msg04 IS NOT NULL, CONCAT(' ', @msg04 ), '')
         ,iif(@msg05 IS NOT NULL, CONCAT(' ', @msg05 ), '')
         ,iif(@msg06 IS NOT NULL, CONCAT(' ', @msg06 ), '')
         ,iif(@msg07 IS NOT NULL, CONCAT(' ', @msg07 ), '')
         ,iif(@msg08 IS NOT NULL, CONCAT(' ', @msg08 ), '')
         ,iif(@msg09 IS NOT NULL, CONCAT(' ', @msg09 ), '')
         ,iif(@msg10 IS NOT NULL, CONCAT(' ', @msg10 ), '')
         ,iif(@msg11 IS NOT NULL, CONCAT(' ', @msg11 ), '')
         ,iif(@msg12 IS NOT NULL, CONCAT(' ', @msg12 ), '')
         ,iif(@msg13 IS NOT NULL, CONCAT(' ', @msg13 ), '')
         ,iif(@msg14 IS NOT NULL, CONCAT(' ', @msg14 ), '')
         ,iif(@msg15 IS NOT NULL, CONCAT(' ', @msg15 ), '')
         ,iif(@msg16 IS NOT NULL, CONCAT(' ', @msg16 ), '')
         ,iif(@msg17 IS NOT NULL, CONCAT(' ', @msg17 ), '')
         ,iif(@msg18 IS NOT NULL, CONCAT(' ', @msg18 ), '')
         ,iif(@msg19 IS NOT NULL, CONCAT(' ', @msg19 ), '')
      );

      SET @line = REPLICATE('*', dbo.fnMin(300, dbo.fnLen(@msg)+46));

      PRINT CONCAT(@nl, @line);
      EXEC sp_log 4, @fnHdr, @msg;
      PRINT CONCAT(@line, @nl);
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fnThis, '590: failed. exception was: ', @ex_num, ': ', @ex_msg;
      SET @ex_num = ERROR_NUMBER();
      SET @ex_msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fnThis,  '580: sp_log failed, exception: ',@ex_num, ': @ex_msg';
      SET @ex_msg ='*** system error: failed to get error msg ***';
   END CATCH
END


GO
