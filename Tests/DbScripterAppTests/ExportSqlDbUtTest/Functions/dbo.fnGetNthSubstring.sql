SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================================================
-- Author:      Terry Watts
-- Create date: 11-MAY-2024
-- Description: gets the n-th substring in str separated by sep
--              1 based numbering but [0] and [1] return 
--                the first element in the sequence
-- if there are double quotes in the string then the seps in the double quotes section should be ignored
--
-- Preconditions: none
--
-- Postconditions
-- POST 00: @sub returns the @ndx substring from @input_str using sep to separate the items
--          or 
-- =====================================================================================================
CREATE FUNCTION [dbo].[fnGetNthSubstring]
(
    @input_str NVARCHAR(4000)
   ,@sep       NVARCHAR(100)
   ,@ndx       INT
)
returns NVARCHAR(4000)
AS
BEGIN
   DECLARE 
     @sub_str  NVARCHAR(4000)
    ,@n1       INT = 0
    ,@n2       INT = 0
    ,@old_dqs  NVARCHAR(4000)
    ,@new_dqs  NVARCHAR(4000)
   SET @n1 = CHARINDEX( '"', @input_str);
   IF @n1 > 0
   BEGIN
      SET @n2 = CHARINDEX( '"', @input_str, @n1+1);
      IF @n2 > 0
      BEGIN
         -- replace the quoted section seps with a special seq to be replaced later
         SET @n2 = CHARINDEX( '"', @input_str, @n1+1);
         SET @old_dqs = SUBSTRING(@input_str, @n1, @n2-@n1+1);
         SET @new_dqs = REPLACE(@old_dqs, @sep, '{~£}');
         -- Replace the new quoted section over the old quoted section
         SET @input_str = REPLACE(@input_str, @old_dqs, @new_dqs);
      END
   END
   SELECT @sub_str = val FROM dbo.fnSplitString(@input_str, @sep)
   WHERE id = @ndx;
   -- Replace the old quoted section over the new quoted section
   IF @n2 > 0
      SET @sub_str = REPLACE(@sub_str, @new_dqs, @old_dqs);
   /*
   SET @sub_str = 
   CONCAT
   (
    @sub_str, ' tst: ', @input_str, 'tst: @n1:', @n1, ' @n2: ', @n2
   , ' @old_dqs:[', @old_dqs, '] @new_dqs:[', @new_dqs, ']'
   );
   */
   return @sub_str;
END
/*
EXEC tSQLt.Run 'test.test_094_fnGetNthSubstring';
*/
GO

