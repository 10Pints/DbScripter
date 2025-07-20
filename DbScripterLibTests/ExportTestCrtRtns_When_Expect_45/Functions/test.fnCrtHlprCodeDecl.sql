SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================
-- Author:      Terry Watts
-- Create date: 03-MAY-2024
-- Description:
-- Creates the helper decl bloc
-- -- ==================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeDecl]()
RETURNS @t TABLE
(
    id    INT IDENTITY(1,1)
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
     @tab1              NCHAR(3) = '   '
    ,@ad_stp            BIT

    SELECT
      @ad_stp           = ad_stp
    FROM test.RtnDetails

IF @ad_stp = 1
      INSERT INTO @t (line) VALUES
      (CONCAT(@tab1, '-- fnCrtHlprCodeDecl'))

   INSERT INTO @t (line)
   SELECT line
   FROM test.fnCrtHlprCodeDeclCoreParams();

   INSERT INTO @t (line)
   SELECT line
   FROM test.fnCrtHlprCodeDeclActParams();

   RETURN;
END
/*
SELECT line from test.fnCrtHlprCodeDecl();
*/



GO
