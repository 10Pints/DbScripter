SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================================
-- Author:      Terry Watts
-- Create date: 06-AUG-2023
-- Description: returns a table of single characters and their ascii code - 1 character per row
-- Reference:   https://stackoverflow.com/questions/59407743/sql-query-to-print-each-character-of-a-string-sql-server
-- ======================================================================================================================
CREATE   FUNCTION [dbo].[fnGetChars] (@String VARCHAR(4000))
RETURNS table
AS RETURN
    WITH N AS(
        SELECT N
        FROM(VALUES(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL))N(N)),
    Tally AS(
        SELECT TOP (LEN(@String)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS I
        FROM N N1, N N2, N N3, N N4)
    SELECT SUBSTRING(@String, T.I, 1) AS C, T.I
    FROM Tally T;

/*
SELECT * FROM dbo.fnGetChars('Corn ( sweet corn )');
SELECT c, ASCII(c) as code FROM Staging2
CROSS APPLY dbo.fnGetChars (crops) WHERE crops LIKE '%Direct-seeded%Pre-germinated%rice';

SELECT c, ASCII(c) as code FROM Staging2
CROSS APPLY dbo.fnGetChars (crops) WHERE crops LIKE '%Dry-seeded%Upland%rice%';
;
SET NOCOUNT OFF;
UPDATE staging2 SET crops = 'Rice' WHERE crops LIKE '%Direct-seeded%Pre-germinated%rice';
*/


GO
