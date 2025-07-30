SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:      Terry Watts
-- Create date: 28-MAR-2020
-- Description: standard error handling:
--              get the exception message, log messages
--              clear the log cache first
--    NB: this does not throw
--
-- CHANGES
--    231221: added clear the log cache first
--    240315: added ex num, ex msg as optional out parmeters
-- ==================================================================
CREATE PROCEDURE [dbo].[sp_log_exception]
       @fn        NVARCHAR(35)
      ,@msg01     NVARCHAR(4000) = NULL
      ,@msg02     NVARCHAR(1000) = NULL
      ,@msg03     NVARCHAR(1000) = NULL
      ,@msg04     NVARCHAR(1000) = NULL
      ,@msg05     NVARCHAR(1000) = NULL
      ,@msg06     NVARCHAR(1000) = NULL
      ,@msg07     NVARCHAR(1000) = NULL
      ,@msg08     NVARCHAR(1000) = NULL
      ,@msg09     NVARCHAR(1000) = NULL
      ,@msg10     NVARCHAR(1000) = NULL
      ,@msg11     NVARCHAR(1000) = NULL
      ,@msg12     NVARCHAR(1000) = NULL
      ,@msg13     NVARCHAR(1000) = NULL
      ,@msg14     NVARCHAR(1000) = NULL
      ,@msg15     NVARCHAR(1000) = NULL
      ,@msg16     NVARCHAR(1000) = NULL
      ,@msg17     NVARCHAR(1000) = NULL
      ,@msg18     NVARCHAR(1000) = NULL
      ,@msg19     NVARCHAR(1000) = NULL
      ,@ex_num    INT            = NULL OUT
      ,@ex_msg    NVARCHAR(500)  = NULL OUT
AS
BEGIN
   DECLARE 
       @NL       NVARCHAR(2)    =  NCHAR(13) + NCHAR(10)
      ,@msg      NVARCHAR(500)
   SET @ex_num = ERROR_NUMBER();
   SET @ex_msg = ut.dbo.fnTrim(ERROR_MESSAGE());
   EXEC dbo.sp_clr_log_cache;
   SET @msg = 
      CONCAT
      (
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
         ,@NL
         ,@NL
      );
   EXEC sp_log 4, @fn, 'caught exception: ', @ex_num, ': ', @ex_msg, @msg;
END
/*
EXEC [dbo].[sp_log_exception] @fn='fn'
      ,@msg01 = 'msg01'
      ,@msg02 = 'msg02'
      ,@msg03 = 'msg03'
      ,@msg04 = 'msg04'
      ,@msg05 = 'msg05'
      ,@msg06 = 'msg06'
      ,@msg07 = 'msg07'
      ,@msg08 = 'msg08'
      ,@msg09 = 'msg09'
      ,@msg10 = 'msg10'
      ,@msg11 = 'msg11'
      ,@msg12 = 'msg12'
      ,@msg13 = 'msg13'
      ,@msg14 = 'msg14'
      ,@msg15 = 'msg15'
      ,@msg16 = 'msg16'
      ,@msg17 = 'msg17'
      ,@msg18 = 'msg18'
      ,@msg19 = 'msg19'
*/
GO

