SET ANSI_NULLS ON

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
CREATE PROCEDURE [dbo].[sp_appLog_display]
    @rtns   VARCHAR(MAX) = NULL -- like 'dbo.fnA,test.sp_b'
   ,@msg    VARCHAR(4000)= NULL     -- no %%
   ,@level  INT          = NULL
   ,@id     INT          = NULL -- starting id
   ,@dir    BIT          = 1 -- ASC
AS
BEGIN
DECLARE
    @fn                 VARCHAR(35)   = N'sp_appLog_display '
   ,@sql                VARCHAR(4000)
   ,@need_where         BIT = 0
   ,@nl                 VARCHAR(2)   = CHAR(13) + CHAR(10)
   ,@fns                IdNmTbl
   ,@s                  VARCHAR(4000)
   ;

   SET NOCOUNT ON;

   INSERT into @fns(val) SELECT value FROM string_split(@rtns,',');
   SELECT @s = string_agg(CONCAT('''', val, ''''),',') FROM @fns;
--   PRINT(@s);
   SET @need_where = 
      IIF(    @rtns  IS NOT NULL
           OR @level IS NOT NULL
           OR @id    IS NOT NULL
           OR @msg   IS NOT NULL
           ,1, 0);

   SET @sql = CONCAT(
'SELECT
  id
,[level]
,rtn AS [rtn',   REPLICATE('_',20), ']
,SUBSTRING(msg, 1  , 128) AS ''msg1', REPLICATE('_',100), '''
,SUBSTRING(msg, 129, 128) AS ''msg2', REPLICATE('_',100), '''
,SUBSTRING(msg, 257, 128) AS ''msg3', REPLICATE('_',100), '''
,SUBSTRING(msg, 385, 128) AS ''log4', REPLICATE('_',100), '''
FROM AppLog
'
,iif(@need_where= 0, '', CONCAT('WHERE '                                                            , @nl))
,iif(@rtns  IS NULL, '', CONCAT(' rtn IN (', @s, ')'                                                , @nl))
,iif(@msg   IS NULL, '', CONCAT(IIF(@rtns IS NULL                   ,'', ' AND'),' msg LIKE (''%', @msg, '%'')'         , @nl))
,iif(@level IS NULL, '', CONCAT(IIF(@rtns IS NULL                   ,'', ' AND'),' level = ', @level, @nl))
,iif(@id    IS NULL, '', CONCAT(IIF(@rtns IS NULL AND @level IS NULL,'', ' AND'),' id >= '  , @id   , @nl))
,'ORDER BY ID ', iif(@dir=1, 'ASC','DESC'), ';'
);

 --  PRINT CONCAT(@fn, '100: executing sql:', @sql);
   EXEC (@sql);

/*   IF dbo.fnGetLogLevel() = 0
      PRINT CONCAT( @fn,'999: leaving:');*/
END
/*
EXEC tSQLt.RunAll;

EXEC sp_appLog_display;
EXEC sp_appLog_display @rtns='S2_UPDATE_TRIGGER',@msg='@fixup_row_id: 4'
EXEC sp_appLog_display @id=140;
000: starting @fixup_row_id: 4, @imp_file_nm: [ImportCorrections_221018-Crops.txt], @fixup_stg_id: 4, @search_clause: [ agricult
*/

GO
