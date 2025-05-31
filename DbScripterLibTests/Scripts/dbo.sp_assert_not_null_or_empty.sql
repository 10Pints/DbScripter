SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if @a is null or empty
-- =============================================
ALTER PROCEDURE [dbo].[sp_assert_not_null_or_empty]
       @val       NVARCHAR(3999)
      ,@msg1      NVARCHAR(200)   = NULL
      ,@msg2      NVARCHAR(200)   = NULL
      ,@msg3      NVARCHAR(200)   = NULL
      ,@msg4      NVARCHAR(200)   = NULL
      ,@msg5      NVARCHAR(200)   = NULL
      ,@msg6      NVARCHAR(200)   = NULL
      ,@msg7      NVARCHAR(200)   = NULL
      ,@msg8      NVARCHAR(200)   = NULL
      ,@msg9      NVARCHAR(200)   = NULL
      ,@msg10     NVARCHAR(200)   = NULL
      ,@msg11     NVARCHAR(200)   = NULL
      ,@msg12     NVARCHAR(200)   = NULL
      ,@msg13     NVARCHAR(200)   = NULL
      ,@msg14     NVARCHAR(200)   = NULL
      ,@msg15     NVARCHAR(200)   = NULL
      ,@msg16     NVARCHAR(200)   = NULL
      ,@msg17     NVARCHAR(200)   = NULL
      ,@msg18     NVARCHAR(200)   = NULL
      ,@msg19     NVARCHAR(200)   = NULL
      ,@msg20     NVARCHAR(200)   = NULL
      ,@ex_num    INT             = 50001
      ,@state     INT             = 1
      ,@st_empty  INT             = NULL
AS
BEGIN
   DECLARE @fn NVARCHAR(35)    = N'sp_assert_not_null_or_empty';
   EXEC sp_log 0, @fn, '000 starting';

   IF @st_empty IS NULL
      SET @st_empty = @state + 1;

   EXEC sp_log 0, @fn, '005 calling sp_assert_not_null';
   EXEC [dbo].[sp_assert_not_null]
          @val    = @val
         ,@msg1   = @msg1
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@ex_num = @ex_num
         ,@state  = @state

   --EXEC sp_log 0, @fnThis,'02 : starting calling sp_assert_not_empty'
   EXEC [dbo].[sp_assert_not_empty]
          @val    = @val
         ,@msg1   = @msg1
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@ex_num = @ex_num
         ,@state  = @state

   EXEC sp_log 0, @fn, '999: OK';
   RETURN 0;
END
/*
EXEC tSQLt.Run 'test.test_049_sp_assert_not_null_or_empty';
EXEC tSQLt.RunAll;
EXEC sp_assert_not_null_or_empty NULL
EXEC sp_assert_not_null_or_empty ''
EXEC sp_assert_not_null_or_empty 'Fred'
*/

GO
