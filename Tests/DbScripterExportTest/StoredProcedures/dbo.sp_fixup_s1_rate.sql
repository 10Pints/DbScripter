SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 03-AUG-2023
-- Description: Fixup for the rate column 
-- =============================================
CREATE PROCEDURE [dbo].[sp_fixup_s1_rate]
      @fixup_cnt     INT OUT --- = NULL 
AS
BEGIN
   DECLARE
       @fn           VARCHAR(35) = 'FIXUP STG1 RATE'
      ,@fixup_delta  INT = 0

   SET NOCOUNT OFF;

   BEGIN TRY
      EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt;
      --EXEC sp_register_call @fn;

      UPDATE staging1 SET rate = NULL where rate in ('-','_');
      SET @fixup_delta = @fixup_delta + @@ROWCOUNT;
   END TRY
   BEGIN CATCH
      DECLARE @error_msg VARCHAR(MAX);
      SET @error_msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fn, ' caught exception: ', @error_msg, ' , @fixup_cnt: ',@fixup_cnt;
      THROW;
   END CATCH

   SET  @fixup_cnt = @fixup_cnt + @fixup_delta ;
   EXEC sp_log 2, @fn, '99: leaving OK, @fixup_cnt: ',@fixup_cnt;
END
/*
SELECT distinct rate from staging1 ORDER BY rate
EXEC sp_fixup_s1
SELECT id, product, rate FROM staging1 where rate LIKE  '%tbsp./3-5 L water%' ORDER by rate, id
SELECT id, product, rate FROM staging1 where id in
(581,601,840,1004,1256,1446,1633,2518,3261,3829,4070,4292,4767,5676,5825,6245,7857,7918,7933
,8980,9209,9411,9745,10014,10174,11915,12573,13142,13254,13491,14178,14250,14749,14760,15194
,15406,17254,17669,18107,18247,18762,19128,19277,20238,21240,21247,22107,22362,22820,23130,23494
,23573,23732,24077,24263,24478,24486,24840,25283,25563)

SELECT id, product, rate FROM staging1 where rate LIKE  '%-1¢%Tbsp/16 L of water%'
*/

GO
