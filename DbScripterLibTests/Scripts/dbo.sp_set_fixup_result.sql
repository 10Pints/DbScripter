SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================
-- Author:      Terry Watts
-- Create date: 27-JUN-2023
-- Description: sets the result of the fixup for the row
--              in the ImportCorrections table.
-- ======================================================
ALTER PROCEDURE [dbo].[sp_set_fixup_result]
      @id               INT
     ,@act_cnt          INT
     ,@result_msg       NVARCHAR(150)
--     ,@cursor           CURSOR VARYING OUTPUT
AS
BEGIN
   DECLARE @fn NVARCHAR(35)='SET_FXUP_RESLT'
   SET NOCOUNT ON;

   BEGIN TRY
      UPDATE ImportCorrections
      SET 
          act_cnt          = @act_cnt
         ,results          = @result_msg
      WHERE 
         id=@id --CURRENT OF @cursor
      ;

      IF @@ROWCOUNT = 0
      BEGIN
         DECLARE @msg NVARCHAR(200);
         SET @msg = CONCAT
         ('sp_setFixupResult failed to update corrections table, 
id        :[', @id,']
act_cnt   :[', @act_cnt,']
result_msg:[', @result_msg,']'
         );

         THROW 51500, @msg, 1;
      END
   END TRY
   BEGIN CATCH
      EXEC Ut.dbo.sp_log_exception @fn;
      THROW;
   END CATCH
END

GO
