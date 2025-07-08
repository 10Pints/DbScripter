SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Author:      Terry watts
-- Create date: 12-NOV-2024
-- Description: Creates a table from the header of a tsv file
--
-- Algorithm:
-- Get the header row from the tsv-> csl
-- Create a new staging table named {@table} from the CSV with a text column for each field in the header
-- split the csl into a list of {, [<field_name>] VARCHAR(500) lines
-- ====================================================================
CREATE PROCEDURE [dbo].[sp_crt_tbl_frm_file]
    @table           VARCHAR(60)
   ,@file            VARCHAR(500)
   ,@sql             VARCHAR(3950) OUT
   ,@sep             NCHAR                = '\t'
   ,@display_tables  BIT                  = 0
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35) = 'crt_tbl_frm_file'
   ,@nl        VARCHAR(2) = NCHAR(13) + NCHAR(10)
   ,@fields    VARCHAR(3950)
   ,@file_type BIT
   ,@max_len   INT

   SET NOCOUNT ON;
   EXEC sp_get_flds_frm_hdr_txt
       @file          = @file
      ,@fields        = @fields OUT
      ,@file_type     = @file_type OUT
      ,@display_tables= @display_tables
    ;

   ------------------------------------------------------------
   -- Start the Create Table statement
   ------------------------------------------------------------
   SET @sql = CONCAT('CREATE TABLE [', @table, ']', @nl,'(', @nl);
   SELECT @max_len = MAX(dbo.fnLen(value)) + 2 FROM STRING_SPLIT(@fields, ',');

   ------------------------------------------------------------
   -- Add the fields
   ------------------------------------------------------------
   SELECT @sql = CONCAT(@sql, iif(ordinal=1, ' ',','), '[' ,dbo.fnPadRight(CONCAT(value, ']'), @max_len),'VARCHAR(MAX)', @nl) FROM STRING_SPLIT(@fields, @sep, 1);

         ------------------------------------------------------------
   -- Close the statement
         ------------------------------------------------------------
   SET @sql = CONCAT(@sql, ');', @nl);
END
/*
EXEC tSQLt.Run 'test.test_019_crt_tbl_frm_file';
DECLARE @sql       VARCHAR(3950)
EXEC dbo.crt_tbl_frm_file 'gafgroup', 'D:\Dev\Farming\Data\EPPO.bayer\gafgroup.txt',@sql OUT;
PRINT @sql;
EXEC dbo.crt_tbl_frm_file 'gaflink', 'D:\Dev\Farming\Data\EPPO.bayer\gaflink.txt' ,@sql OUT;
PRINT @sql;
EXEC dbo.crt_tbl_frm_file 'gafname', 'D:\Dev\Farming\Data\EPPO.bayer\gafname.txt' ,@sql OUT;
PRINT @sql;
EXEC dbo.crt_tbl_frm_file 'gaigroup', 'D:\Dev\Farming\Data\EPPO.bayer\gaigroup.txt',@sql OUT;
PRINT @sql;
EXEC dbo.crt_tbl_frm_file 'gailink', 'D:\Dev\Farming\Data\EPPO.bayer\gailink.txt' ,@sql OUT;
PRINT @sql;
EXEC dbo.crt_tbl_frm_file 'gainame', 'D:\Dev\Farming\Data\EPPO.bayer\gainame.txt' ,@sql OUT;
PRINT @sql;
EXEC dbo.crt_tbl_frm_file 'ntxlink', 'D:\Dev\Farming\Data\EPPO.bayer\ntxlink.txt' ,@sql OUT;
PRINT @sql;
EXEC dbo.crt_tbl_frm_file 'ntxname', 'D:\Dev\Farming\Data\EPPO.bayer\ntxname.txt' ,@sql OUT;
PRINT @sql;
EXEC dbo.crt_tbl_frm_file 'pflgroup', 'D:\Dev\Farming\Data\EPPO.bayer\pflgroup.txt',@sql OUT;
PRINT @sql;
EXEC dbo.crt_tbl_frm_file 'pfllink', 'D:\Dev\Farming\Data\EPPO.bayer\pfllink.txt' ,@sql OUT;
PRINT @sql;
EXEC dbo.crt_tbl_frm_file 'pflname', 'D:\Dev\Farming\Data\EPPO.bayer\pflname.txt' ,@sql OUT;
PRINT @sql;
EXEC dbo.crt_tbl_frm_file 'repco', 'D:\Dev\Farming\Data\EPPO.bayer\repco.txt'   ,@sql OUT;
PRINT @sql;
*/

GO
