SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 05-JUL-2023
-- Description: runs the EXP/ACT checks 
--       if mismatch
-- PRECONDITIONS - all inputs valid
-- =============================================
ALTER PROCEDURE [dbo].[sp_update_if_exists_chk_state]
       @rc           INT            = 0
      ,@sql          NVARCHAR(MAX)
--    ,@exp_cnt      INT            
      ,@act_cnt      INT            = NULL
      ,@must_update  BIT            = NULL
      ,@msg          NVARCHAR(500)  OUTPUT
AS
BEGIN
   IF @rc <> 0
   BEGIN
      SET @msg = CONCAT('sp_update caught error ', @rc, ' sql:[', @sql, ']');
      THROW 55555, @msg, 1;
   END   

   -- Check updated if @must_update flag set
   IF (@must_update=1) AND (@act_cnt = 0 )
   BEGIN
      SET @msg = 'ERROR: 0 rows updated but @must_update is TRUE';
      RETURN -1;
   END
   
   RETURN 0;
END
/*

*/

GO
