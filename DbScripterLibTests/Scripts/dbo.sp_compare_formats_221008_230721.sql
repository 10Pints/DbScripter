SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:		  Terry Watts
-- Create date:  02-UG-2023
-- Description:  Compares different LRAP formats
--
-- Process:
--    1. Compare staging 1
--       1.1: compare companies
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_compare_formats_221008_230721] 
AS
BEGIN
   DECLARE 
       @fn NVARCHAR(35)='COMP FMTS 221008_230721'
      ,@cnt_221008 INT
      ,@cnt_230721 INT
      ,@msg        NVARCHAR(MAX)
   --SET NOCOUNT ON
   EXEC sp_log 2, @fn, '01 starting'
   EXEC sp_log 2, @fn, '01 comparing s1 company counts'
   SELECT @cnt_221008 = count(*) FROM (SELECT distinct company from staging1_bak_221008) AS X;
   SELECT @cnt_230721 = count(*) FROM (SELECT distinct company from staging1) AS X;

   SET @msg = IIF(@cnt_221008=@cnt_230721, 'same', 'different');
   EXEC sp_log 2, @fn, 's1 company counts: s1 230721: ', @cnt_230721, ' s1 221008: ', @cnt_221008, '  ', @msg;

   SELECT @cnt_221008 = count(*) FROM (SELECT distinct product from staging1_bak_221008) AS X;
   SELECT @cnt_230721 = count(*) FROM (SELECT distinct product from staging1) AS X;
   SET @msg = IIF(@cnt_221008=@cnt_230721, 'same', 'different');
   EXEC sp_log 2, @fn, 's1 product counts: s1 230721: ', @cnt_230721, ' s1 221008: ', @cnt_221008, '  ', @msg;

   SELECT @cnt_221008 = count(*) FROM (SELECT distinct ingredient from staging1_bak_221008) AS X;
   SELECT @cnt_230721 = count(*) FROM (SELECT distinct ingredient from staging1) AS X;
   SET @msg = IIF(@cnt_221008=@cnt_230721, 'same', 'different');
   EXEC sp_log 2, @fn, 's1 ingredient counts: s1 230721: ', @cnt_230721, ' s1 221008: ', @cnt_221008, '  ', @msg;

   SELECT @cnt_221008 = count(*) FROM staging1_bak_221008;
   SELECT @cnt_230721 = count(*) FROM staging1;
   SET @msg = IIF(@cnt_221008=@cnt_230721, 'same', 'different');
   EXEC sp_log 2, @fn, 's1 total counts: s1 230721: ', @cnt_230721, ' s1 221008: ', @cnt_221008, '  ', @msg;

   SELECT * FROM staging1
   SELECT * FROM staging1_bak_221008

   EXEC sp_log 2, @fn, '99 leaving'
END
/*
EXEC sp_compare_formats_221008_230721
*/

GO
