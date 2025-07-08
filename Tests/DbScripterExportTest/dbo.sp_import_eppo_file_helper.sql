SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =======================================================================
-- Author:      Terry Watts
-- Create date: 11-Nov-2024
-- Description: helper rtn
--
-- Algorithm
-- Import the following tables from the directory
-- gafgroup, gaflink, gafname, gaigroup, gailink, gainame, ntxlink, ntxname
-- ,pflgroup, pfllink, pflname, repco
--
-- PRECONDITIONS:
-- PRE01: all params valid
-- =======================================================================
CREATE   PROCEDURE [dbo].[sp_import_eppo_file_helper]
    @table              VARCHAR(70)
   ,@file               VARCHAR(70)  = NULL   -- defaults to <table>.txt
   ,@field_terminator   NCHAR(1)      = ','
   ,@folder             VARCHAR(500) = NULL   -- defaults to D:\Dev\Farming\Data\EPPO.bayer
   ,@non_null_flds      VARCHAR(500) = NULL
   ,@display_table      BIT           = 0
   ,@first_row          INT           = 2
   ,@last_row           INT           = NULL
   ,@exp_row_cnt        INT           = NULL
   ,@row_cnt            INT           = NULL      OUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn                 VARCHAR(35)   = 'import_eppo_helper'
   ,@path               VARCHAR(600)
   ,@bckslsh            VARCHAR(1)    = NCHAR(92)
   ,@tab                VARCHAR(1)    = NCHAR(9)
   ,@nl                 VARCHAR(2)    = NCHAR(13) + NCHAR(10)

   IF @file             IS NULL SET @file = CONCAT(REPLACE(@table, 'Staging',''), '.txt');
   IF @field_terminator IS NULL SET @field_terminator = ',';
   IF @folder           IS NULL SET @folder = 'D:\Dev\Farming\Data\EPPO.bayer';

   SET @path = CONCAT(@folder, @bckslsh, @file);
   EXEC sp_log 1, @fn, 'starting
table           :[',@table           ,']
file            :[',@file            ,']
field_terminator:[',@field_terminator,']
folder          :[',@folder          ,']
non_null_flds   :[',@non_null_flds   ,']
display_table   :[',@display_table   ,']
first_row       :[',@first_row       ,']
last_row        :[',@last_row        ,']
exp_row_cnt     :[',@exp_row_cnt     ,']
row_cnt         :[',@row_cnt         ,']
   ';

   EXEC sp_import_txt_file
       @table           = @table
      ,@view            = NULL
      ,@file            = @path
      ,@field_terminator= @field_terminator
      ,@display_table   = @display_table
      ,@first_row       = @first_row
      ,@last_row        = @last_row
      ,@exp_row_cnt     = @exp_row_cnt
      ,@non_null_flds   = @non_null_flds
      ,@row_cnt         = @row_cnt OUT
      ;

   IF @exp_row_cnt IS NOT NULL EXEC sp_assert_equal @exp_row_cnt, @row_cnt, 'exp/act row count'
   EXEC sp_log 1, @fn, 'leaving';
END
/*
EXEC tSQLt.Run 'test.test_022_sp_import_eppo_file_helper';
EXEC sp_import_eppo_file_helper 'EPPO_GafGroupStaging'
*/


GO
