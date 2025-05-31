SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =======================================================
-- Procedure:   sp_fndUnregPathogens
-- Description: lists the unregistered pathogens in S2
-- EXEC tSQLt.Run 'test.test_<nnn>_sp_fndUnregPathogens';
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 10-JAN-2024
-- =======================================================
ALTER PROCEDURE [dbo].[sp_fndUnregPathogens]
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35) = N'sp_fndUnregPathogens'
   ,@sql       NVARCHAR(MAX)
   ,@sql_body  NVARCHAR(MAX)
   ;

   SET NOCOUNT ON;
   EXEC sp_log 2, @fn,'000: starting';
   SET @sql_body = dbo.fnCrtFndUnregisterdItemsSql(1, 'pathogens', 'staging2', 'Pathogen', 'pathogen_nm', ',');
   SET @sql = CONCAT('SELECT * FROM ', @sql_body);
   EXEC(@sql);
   RETURN @@ROWCOUNT;
END
/*
DECLARE @tot_cnt   INT = 0
EXEC @tot_cnt = sp_fndUnregPathogens;
PRINT @tot_cnt

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<nnn>_sp_fndUnregPathogens';
*/

GO
