SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON


CREATE PROC [dbo].[sp_chk_comma_replace_staging2_pathogens]
AS
BEGIN
   DECLARE @cnt INT = 0;
   SELECT @cnt = COUNT(*)  FROM staging2 WHERE pathogens LIKE CONCAT('%', NCHAR(44), NCHAR(32), '%');

   IF @cnt > 0
   BEGIN
      SELECT stg2_id, pathogens FROM staging2;
      SELECT stg1_id, pathogens FROM staging1;
      THROW 50132, '**** 1: pathogens still has comma space ****', 1;
   END

   SELECT @cnt = COUNT(*)  FROM staging2 WHERE pathogens LIKE CONCAT('%', NCHAR(32), NCHAR(44), '%')
   IF @cnt > 0 
   BEGIN
      SELECT stg2_id, pathogens FROM staging2;
      THROW 50133, '**** 2: pathogens still has space comma ******', 1;
   END
END

/*
EXEC sp_chk_comma_replace_staging2_pathogens
*/

GO
