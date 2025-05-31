SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================
-- Author:      Terry Watts
-- Create date: 08-NOV-2023
-- Description: helper for sp_merge_normalised_tables
-- ==========================================================
ALTER PROCEDURE [dbo].[sp_merge_normalised_tables_hlpr]
    @id        INT            OUTPUT
   ,@table_nm  NVARCHAR(50)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        NVARCHAR(30)  = N'MRG_NORM_TBLS'
      ,@msg       NVARCHAR(100)

   SET @msg = CONCAT('PRE', FORMAT(@id, '00'),': checking ',@table_nm);
   EXEC sp_log 2, @fn, @msg; 
   EXEC sp_chk_tbl_populated @table_nm;
   SET @id = @id+1;
END

GO
