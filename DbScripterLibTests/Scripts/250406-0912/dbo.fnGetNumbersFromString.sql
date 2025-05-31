SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 6-AUG-2023
-- Description: extracts numeric values 
-- but not nn-mm pairs
-- =============================================
ALTER   FUNCTION [dbo].[fnGetNumbersFromString]( @s VARCHAR(MAX))
RETURNS @t TABLE
(
   value VARCHAR(MAX)
)
AS
BEGIN
   -- tokenise s 
  INSERT INTO @t SELECT value FROM string_split(@s, ' ')
  WHERE ISNUMERIC(value)=1
  RETURN;
END

 /*
 SELECT * FROM dbo.fnGetNumbersFromString('some other text 14 days before harvest fpr potato. 7 days before 8-15 harvest for onion')
 SELECT * FROM string_split('some other text 14 days before harvest fpr potato. 7 days before harvest for onion', ' ')
 WHERE ISNUMERIC(value)=1;
 
 SELECT id, dbo.fnGetFirstNumberFromString(phi), phi 
 FROM staging2
 WHERE phi like '%[0-9]-[0-9]%'
 
 SELECT * FROM dbo.fnGetNumbersFromString('Harvest is generally 4-7 days');
 SELECT * FROM dbo.fnGetNumbersFromString('Harvest is generally 45-72 days');
 SELECT * FROM dbo.fnGetNumbersFromString('Harvest is generally 450-721 days');
 SELECT value FROM dbo.fnGetNumbersFromString('Harvest is generally 4506-7213 days')
 WHERE value like '%[0-9]-[0-9]%';

 */
 /*
 UPDATE staging2 set phi_resolved = value
 FROM
 (
    SELECT phi, value from Staging2
    CROSS APPLY [dbo].[fnGetNumbersFromString](phi)
    WHERE value like '%[0-9]-[0-9]%'
 ) X JOIN staging2 s2 ON X.phi = s2.phi

 SELECT id, phi, phi_resolved from Staging2
 */


GO
