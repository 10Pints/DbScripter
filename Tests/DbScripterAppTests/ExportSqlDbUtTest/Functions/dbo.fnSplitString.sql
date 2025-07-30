SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 11-MAY-2024
-- Description: splits a string of items separated
-- by a character into a list (table)
-- =============================================
CREATE FUNCTION [dbo].[fnSplitString]
(
   @input_str  NVARCHAR(4000),
   @sep        NVARCHAR(2)
)
RETURNS @t TABLE
(
    id   INT IDENTITY(1,1)
   ,val  NVARCHAR(4000)
)
AS
BEGIN
   INSERT INTO @t(val) SELECT value FROM STRING_SPLIT(@input_str, @sep);
   RETURN;
END
/*
SELECT * FROM dbo.fnSplitString('ab,cde,fghij,,k,lmn', ',');
SELECT * FROM dbo.fnSplit('ab,cde,fghij,,k,lmn', ',');
*/
GO

