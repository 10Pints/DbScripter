SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 16-MAY-2024
-- Description: Create a script to creaet the 2 test rtns 
--   for each untested rtn in dbo
-- =============================================
CREATE FUNCTION [test].[fnCrtTstRtnsScrpt]
(
)
RETURNS @t TABLE
(
    id   INT IDENTITY(1,1)
   ,line NVARCHAR(200)
)
AS
BEGIN
   DECLARE @t1 TABLE
   (
       id      INT IDENTITY(1,1)
      ,number  INT
   )
   DECLARE @t2 TABLE
   (
       id      INT IDENTITY(1,1)
      ,number  INT
   )
   DECLARE @t3 TABLE
   (
       id      INT IDENTITY(1,1)
      ,number  INT
   )
DECLARE @n INT;
   INSERT INTO @t1(number)
   SELECT unused_trn FROM [test].[GetUnusedTRNs_vw] WHERE type = 'UNUSED';
   SELECT @n = test.fnGetNxtTstRtnNum()-1;
-- correct to this point
-- SELECT * FROM @t1;
--   PRINT @n;
   INSERT INTO @t2(number)
   SELECT row_number() over (order by X.rtn_nm) as number
FROM 
(
   SELECT rtn_nm FROM [dbo].[list_rtns_vw] where schema_nm='dbo' AND rtn_ty IN ('procedure', 'function')
) AS X
--   SELECT * FROM @t2;
   UPDATE @t2 SET number  = number + @n;
--   SELECT * FROM @t2;
   INSERT INTO @t1(number) SELECT number FROM @t2;
-- SELECT * FROM @t1;
   INSERT INTO @t(line)
   SELECT CONCAT('EXEC test.sp__crt_tst_rtns @qrn = ''',schema_nm, '.', rtn_nm, ''', @trn = ', number)
   FROM test.fnGetUntestedRtns('dbo') A LEFT JOIN @t1 B ON A.id = B.id;
   RETURN
END
/*
SELECT * FROM test.fnCrtTstRtnsScrpt();
SELECT * FROM test.fnGetUntestedRtns('dbo')
*/
GO

