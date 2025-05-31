SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Function SC: <fn_nm>
-- Description: 
-- Design:      
-- Tests:       
-- Author:      
-- Create date: 
-- =============================================
ALTER FUNCTION [dbo].[FkExists](@fk VARCHAR(128))
RETURNS BIT
AS
BEGIN
   RETURN iif(EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = @fk), 1, 0);
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_000_FkExists';
*/

GO
