SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 03-APR-2020
-- Description: Inserts a log row in the app log
--
--              Splits into column based on tabs in the the message or 
   -- set @tmp = LEFT(CONCAT(REPLICATE( '  ', @sf), REPLACE(LEFT( @tmp, 500), @NL, '--')), 500);
   -- set @tmp = LEFT(CONCAT( REPLACE(LEFT( @tmp, 500), @NL, '--')), 500);
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_log_display]
          @dir   BIT          = 1 -- ASC
         ,@fn    NVARCHAR(60) = NULL
         ,@level INT          = NULL
AS
BEGIN
   DECLARE
       @sql             NVARCHAR(4000)
   SET @sql = CONCAT(
'SELECT
  id
,[level]
,fn    AS ''fn',   REPLICATE('_',16), '''
,SUBSTRING(msg, 1  , 128) AS ''msg1', REPLICATE('_',50), '''
,SUBSTRING(msg, 129, 128) AS ''msg2', REPLICATE('_',50), '''
,SUBSTRING(msg, 257, 128) AS ''msg3', REPLICATE('_',100), '''
,SUBSTRING(msg, 385, 128) AS ''log4', REPLICATE('_',100), '''
FROM AppLog
', iif(@fn is not NULL OR @level IS NOT NULL, 'WHERE ', '')
, iif(@fn is NULL, '', CONCAT(' fn = ''', @fn, '''')),'
',iif(@level is NULL, '', CONCAT(IIF(@fn is NULL,'', ' AND '),'level = ', @level)),'
ORDER BY ID ', iif(@dir=1, 'ASC','DESC'), ';'
);
   PRINT @sql;
   EXEC (@sql);
END
/*
   EXEC sp_app_log_display 1;
   EXEC sp_app_log_display 1, @fn='sp_assert_not_null_or_empty';
   EXEC sp_app_log_display 1, @level=0;
   EXEC sp_app_log_display 1, @fn='sp_assert_not_null_or_empty', @level=0;
   EXEC tSQLt.RunAll;
*/
GO

