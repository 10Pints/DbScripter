SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Author:      Terry Watts
-- Create date: 20-NOV-2024
-- Description: returns test hdr or footer line
-- =========================================================
CREATE FUNCTION [test].[fnGetTstHdrFooterLine]
(
    @is_mn_tst BIT
   ,@is_Hdr    BIT            -- 1:hdr, 0 = footer
   ,@tst_num   VARCHAR(100)
   ,@msg       VARCHAR(100)
)
RETURNS VARCHAR(500)
AS
BEGIN
   DECLARE
       @len  INT
      ,@line VARCHAR(160)
      ,@NL   VARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@len2 INT
   ;

   SET @line = REPLICATE(iif(@is_mn_tst=1, '*','+'), 160);
   SET @len = dbo.fnLen(@tst_num);
   SET @len2 = 120;

   IF @is_mn_tst = 0 SET @len2 = @len2 +1;
   IF @is_Hdr = 0 SET @len2 = @len2 +2;

   RETURN
      CONCAT
      (
          @NL
         ,SUBSTRING(@line,1,30)
         ,iif(@is_mn_tst=1, ' Main Test',' Sub-test')
         ,' ', @tst_num, ' '
         ,@msg, ' '
         ,SUBSTRING(@line,1,dbo.fnMax(5, @len2 - @len)) -- + iif(@is_mn_tst=0, 1, 0)
         ,@NL
         ,@NL
      );
END
/*
*/


GO
