SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================================
-- Author:      Terry Watts
-- Create date: 03-APR-2020
-- Description: Inserts a log row in the app log
-- logs a VARCHAR(800000 full mesage and also spits it down into column dispal max chunks
-- The Grid display has a column width limit of 128 characters
-- Splits into column based on tabs in the the message or 
-- ========================================================================================
CREATE PROCEDURE [dbo].[sp_app_log_insert]
             @fn                        NVARCHAR(100)
         ,@msg                       VARCHAR(MAX)
         ,@sf                        INT = 0
         ,@hit                       INT = 0
AS
BEGIN
	SET NOCOUNT ON;
   DECLARE
         @msg1                       NVARCHAR(128)
           ,@msg2                       NVARCHAR(128)
           ,@msg3                       NVARCHAR(128)
           ,@len                        INT     = LEN(@msg)
           ,@ndx1                       INT     = 0
           ,@ndx2                       INT     = 0
           ,@n                          INT
           ,@TAB                        NCHAR(1) = NCHAR(9)
   -- Check if there are any tabs first
   SET @ndx1 = CHARINDEX( @TAB, @msg, 0);
   SET @ndx2 = iif( @ndx1>0, CHARINDEX(@TAB, @msg, @ndx1 + 1), 0);
   IF @ndx1 = 0
      SET @ndx1 = iif(@len<=128, @len, 128)
   IF @ndx2 = 0
      SET @ndx2 = iif(@len<=256, 
                    iif(@len<=@ndx1, 0, @len),
                        256)
   SET @msg1 = SUBSTRING(@msg, 1 , @ndx1);
   SET @n = @ndx2- @ndx1 + 1;
   IF @n >0
      SET @msg2 = iif(@ndx2 > 0,   SUBSTRING(@msg, @ndx1,@n), '');
   SET @n = @len - @ndx2 + 1;
   IF @n >0
      SET @msg3 = iif(@len  > 256, SUBSTRING(@msg, @ndx2, @n), '');
   INSERT INTO AppLog ( fn,  sf,  hit,  msg,  log1,  log2,  log3)
   VALUES                 (@fn, @sf, @hit, @msg, @msg1, @msg2, @msg3);
END
/*
   EXEC tSQLt.RunAll;
*/
GO

