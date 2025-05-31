SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================================
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Logs to output and to the AppLog table

-- Level: 0 DEBUG
--        1 INFO
--        2 NOTE
--        3 WARNING (CONTINUE)
--        4 ERROR   (STOP)
--
-- Changes:
-- 231014: Added support of table logging: add a row to table for each log 
--            Level and msg
-- 231016: Added fn and optional row count columns
-- 231017: @fn no longer needs the trailing ' :'
-- 231018: @fn, @row_count are stored as separate fields
-- 231115: added Level
-- 231116: always append to the AppLog table - bit print is conditional on level
-- 240309: Trimmed the  @fn paameter as it is left padded
-- 240314: Logic Change: now if less than min log level do not log or print msg
-- 231221: added hold, values:
--          0: print cache first then this msg on same line immediatly
--          1: cache msg for later - dont print it now 
--          2: dump cache first then print this msg on a new line immediatly
-- 240422: separate lines into a separate display line if msg contains \r\n
-- =================================================================================
ALTER PROCEDURE [dbo].[sp_log]
 @level  INT = 1
,@fn     NVARCHAR(100)=NULL
,@msg00  NVARCHAR(MAX)=NULL,@msg01  NVARCHAR(MAX)=NULL,@msg02  NVARCHAR(MAX)=NULL,@msg03  NVARCHAR(MAX)=NULL,@msg04  NVARCHAR(MAX)=NULL,@msg05  NVARCHAR(MAX)=NULL,@msg06  NVARCHAR(MAX)=NULL,@msg07  NVARCHAR(MAX)=NULL,@msg08  NVARCHAR(MAX)=NULL,@msg09  NVARCHAR(MAX)=NULL
,@msg10  NVARCHAR(MAX)=NULL,@msg11  NVARCHAR(MAX)=NULL,@msg12  NVARCHAR(MAX)=NULL,@msg13  NVARCHAR(MAX)=NULL,@msg14  NVARCHAR(MAX)=NULL,@msg15  NVARCHAR(MAX)=NULL,@msg16  NVARCHAR(MAX)=NULL,@msg17  NVARCHAR(MAX)=NULL,@msg18  NVARCHAR(MAX)=NULL,@msg19  NVARCHAR(MAX)=NULL
,@msg20  NVARCHAR(MAX)=NULL,@msg21  NVARCHAR(MAX)=NULL,@msg22  NVARCHAR(MAX)=NULL,@msg23  NVARCHAR(MAX)=NULL,@msg24  NVARCHAR(MAX)=NULL,@msg25  NVARCHAR(MAX)=NULL,@msg26  NVARCHAR(MAX)=NULL,@msg27  NVARCHAR(MAX)=NULL,@msg28  NVARCHAR(MAX)=NULL,@msg29  NVARCHAR(MAX)=NULL
,@msg30  NVARCHAR(MAX)=NULL,@msg31  NVARCHAR(MAX)=NULL,@msg32  NVARCHAR(MAX)=NULL,@msg33  NVARCHAR(MAX)=NULL,@msg34  NVARCHAR(MAX)=NULL,@msg35  NVARCHAR(MAX)=NULL,@msg36  NVARCHAR(MAX)=NULL,@msg37  NVARCHAR(MAX)=NULL,@msg38  NVARCHAR(MAX)=NULL,@msg39  NVARCHAR(MAX)=NULL
,@msg40  NVARCHAR(MAX)=NULL,@msg41  NVARCHAR(MAX)=NULL,@msg42  NVARCHAR(MAX)=NULL,@msg43  NVARCHAR(MAX)=NULL,@msg44  NVARCHAR(MAX)=NULL,@msg45  NVARCHAR(MAX)=NULL,@msg46  NVARCHAR(MAX)=NULL,@msg47  NVARCHAR(MAX)=NULL,@msg48  NVARCHAR(MAX)=NULL,@msg49  NVARCHAR(MAX)=NULL
,@msg50  NVARCHAR(MAX)=NULL,@msg51  NVARCHAR(MAX)=NULL,@msg52  NVARCHAR(MAX)=NULL,@msg53  NVARCHAR(MAX)=NULL,@msg54  NVARCHAR(MAX)=NULL,@msg55  NVARCHAR(MAX)=NULL,@msg56  NVARCHAR(MAX)=NULL,@msg57  NVARCHAR(MAX)=NULL,@msg58  NVARCHAR(MAX)=NULL,@msg59  NVARCHAR(MAX)=NULL
,@msg60  NVARCHAR(MAX)=NULL,@msg61  NVARCHAR(MAX)=NULL,@msg62  NVARCHAR(MAX)=NULL,@msg63  NVARCHAR(MAX)=NULL,@msg64  NVARCHAR(MAX)=NULL,@msg65  NVARCHAR(MAX)=NULL,@msg66  NVARCHAR(MAX)=NULL,@msg67  NVARCHAR(MAX)=NULL,@msg68  NVARCHAR(MAX)=NULL,@msg69  NVARCHAR(MAX)=NULL
,@msg70  NVARCHAR(MAX)=NULL,@msg71  NVARCHAR(MAX)=NULL,@msg72  NVARCHAR(MAX)=NULL,@msg73  NVARCHAR(MAX)=NULL,@msg74  NVARCHAR(MAX)=NULL,@msg75  NVARCHAR(MAX)=NULL,@msg76  NVARCHAR(MAX)=NULL,@msg77  NVARCHAR(MAX)=NULL,@msg78  NVARCHAR(MAX)=NULL,@msg79  NVARCHAR(MAX)=NULL
,@msg80  NVARCHAR(MAX)=NULL,@msg81  NVARCHAR(MAX)=NULL,@msg82  NVARCHAR(MAX)=NULL,@msg83  NVARCHAR(MAX)=NULL,@msg84  NVARCHAR(MAX)=NULL,@msg85  NVARCHAR(MAX)=NULL,@msg86  NVARCHAR(MAX)=NULL,@msg87  NVARCHAR(MAX)=NULL,@msg88  NVARCHAR(MAX)=NULL,@msg89  NVARCHAR(MAX)=NULL
,@msg90  NVARCHAR(MAX)=NULL,@msg91  NVARCHAR(MAX)=NULL,@msg92  NVARCHAR(MAX)=NULL,@msg93  NVARCHAR(MAX)=NULL,@msg94  NVARCHAR(MAX)=NULL,@msg95  NVARCHAR(MAX)=NULL,@msg96  NVARCHAR(MAX)=NULL,@msg97  NVARCHAR(MAX)=NULL,@msg98  NVARCHAR(MAX)=NULL,@msg99  NVARCHAR(MAX)=NULL
,@msg100 NVARCHAR(MAX)=NULL,@msg101 NVARCHAR(MAX)=NULL,@msg102 NVARCHAR(MAX)=NULL,@msg103 NVARCHAR(MAX)=NULL,@msg104 NVARCHAR(MAX)=NULL,@msg105 NVARCHAR(MAX)=NULL,@msg106 NVARCHAR(MAX)=NULL,@msg107 NVARCHAR(MAX)=NULL,@msg108 NVARCHAR(MAX)=NULL,@msg109 NVARCHAR(MAX)=NULL
,@msg110 NVARCHAR(MAX)=NULL,@msg111 NVARCHAR(MAX)=NULL,@msg112 NVARCHAR(MAX)=NULL,@msg113 NVARCHAR(MAX)=NULL,@msg114 NVARCHAR(MAX)=NULL,@msg115 NVARCHAR(MAX)=NULL,@msg116 NVARCHAR(MAX)=NULL,@msg117 NVARCHAR(MAX)=NULL,@msg118 NVARCHAR(MAX)=NULL,@msg119 NVARCHAR(MAX)=NULL
,@msg120 NVARCHAR(MAX)=NULL,@msg121 NVARCHAR(MAX)=NULL,@msg122 NVARCHAR(MAX)=NULL,@msg123 NVARCHAR(MAX)=NULL,@msg124 NVARCHAR(MAX)=NULL,@msg125 NVARCHAR(MAX)=NULL,@msg126 NVARCHAR(MAX)=NULL,@msg127 NVARCHAR(MAX)=NULL,@msg128 NVARCHAR(MAX)=NULL,@msg129 NVARCHAR(MAX)=NULL
,@msg130 NVARCHAR(MAX)=NULL,@msg131 NVARCHAR(MAX)=NULL,@msg132 NVARCHAR(MAX)=NULL,@msg133 NVARCHAR(MAX)=NULL,@msg134 NVARCHAR(MAX)=NULL,@msg135 NVARCHAR(MAX)=NULL,@msg136 NVARCHAR(MAX)=NULL,@msg137 NVARCHAR(MAX)=NULL,@msg138 NVARCHAR(MAX)=NULL,@msg139 NVARCHAR(MAX)=NULL
,@msg140 NVARCHAR(MAX)=NULL,@msg141 NVARCHAR(MAX)=NULL,@msg142 NVARCHAR(MAX)=NULL,@msg143 NVARCHAR(MAX)=NULL,@msg144 NVARCHAR(MAX)=NULL,@msg145 NVARCHAR(MAX)=NULL,@msg146 NVARCHAR(MAX)=NULL,@msg147 NVARCHAR(MAX)=NULL,@msg148 NVARCHAR(MAX)=NULL,@msg149 NVARCHAR(MAX)=NULL
,@msg150 NVARCHAR(MAX)=NULL,@msg151 NVARCHAR(MAX)=NULL,@msg152 NVARCHAR(MAX)=NULL,@msg153 NVARCHAR(MAX)=NULL,@msg154 NVARCHAR(MAX)=NULL,@msg155 NVARCHAR(MAX)=NULL,@msg156 NVARCHAR(MAX)=NULL,@msg157 NVARCHAR(MAX)=NULL,@msg158 NVARCHAR(MAX)=NULL,@msg159 NVARCHAR(MAX)=NULL
,@msg160 NVARCHAR(MAX)=NULL,@msg161 NVARCHAR(MAX)=NULL,@msg162 NVARCHAR(MAX)=NULL,@msg163 NVARCHAR(MAX)=NULL,@msg164 NVARCHAR(MAX)=NULL,@msg165 NVARCHAR(MAX)=NULL,@msg166 NVARCHAR(MAX)=NULL,@msg167 NVARCHAR(MAX)=NULL,@msg168 NVARCHAR(MAX)=NULL,@msg169 NVARCHAR(MAX)=NULL
,@msg170 NVARCHAR(MAX)=NULL,@msg171 NVARCHAR(MAX)=NULL,@msg172 NVARCHAR(MAX)=NULL,@msg173 NVARCHAR(MAX)=NULL,@msg174 NVARCHAR(MAX)=NULL,@msg175 NVARCHAR(MAX)=NULL,@msg176 NVARCHAR(MAX)=NULL,@msg177 NVARCHAR(MAX)=NULL,@msg178 NVARCHAR(MAX)=NULL,@msg179 NVARCHAR(MAX)=NULL
,@msg180 NVARCHAR(MAX)=NULL,@msg181 NVARCHAR(MAX)=NULL,@msg182 NVARCHAR(MAX)=NULL,@msg183 NVARCHAR(MAX)=NULL,@msg184 NVARCHAR(MAX)=NULL,@msg185 NVARCHAR(MAX)=NULL,@msg186 NVARCHAR(MAX)=NULL,@msg187 NVARCHAR(MAX)=NULL,@msg188 NVARCHAR(MAX)=NULL,@msg189 NVARCHAR(MAX)=NULL
,@msg190 NVARCHAR(MAX)=NULL,@msg191 NVARCHAR(MAX)=NULL,@msg192 NVARCHAR(MAX)=NULL,@msg193 NVARCHAR(MAX)=NULL,@msg194 NVARCHAR(MAX)=NULL,@msg195 NVARCHAR(MAX)=NULL,@msg196 NVARCHAR(MAX)=NULL,@msg197 NVARCHAR(MAX)=NULL,@msg198 NVARCHAR(MAX)=NULL,@msg199 NVARCHAR(MAX)=NULL
,@msg200 NVARCHAR(MAX)=NULL,@msg201 NVARCHAR(MAX)=NULL,@msg202 NVARCHAR(MAX)=NULL,@msg203 NVARCHAR(MAX)=NULL,@msg204 NVARCHAR(MAX)=NULL,@msg205 NVARCHAR(MAX)=NULL,@msg206 NVARCHAR(MAX)=NULL,@msg207 NVARCHAR(MAX)=NULL,@msg208 NVARCHAR(MAX)=NULL,@msg209 NVARCHAR(MAX)=NULL
,@msg210 NVARCHAR(MAX)=NULL,@msg211 NVARCHAR(MAX)=NULL,@msg212 NVARCHAR(MAX)=NULL,@msg213 NVARCHAR(MAX)=NULL,@msg214 NVARCHAR(MAX)=NULL,@msg215 NVARCHAR(MAX)=NULL,@msg216 NVARCHAR(MAX)=NULL,@msg217 NVARCHAR(MAX)=NULL,@msg218 NVARCHAR(MAX)=NULL,@msg219 NVARCHAR(MAX)=NULL
,@msg220 NVARCHAR(MAX)=NULL,@msg221 NVARCHAR(MAX)=NULL,@msg222 NVARCHAR(MAX)=NULL,@msg223 NVARCHAR(MAX)=NULL,@msg224 NVARCHAR(MAX)=NULL,@msg225 NVARCHAR(MAX)=NULL,@msg226 NVARCHAR(MAX)=NULL,@msg227 NVARCHAR(MAX)=NULL,@msg228 NVARCHAR(MAX)=NULL,@msg229 NVARCHAR(MAX)=NULL
,@msg230 NVARCHAR(MAX)=NULL,@msg231 NVARCHAR(MAX)=NULL,@msg232 NVARCHAR(MAX)=NULL,@msg233 NVARCHAR(MAX)=NULL,@msg234 NVARCHAR(MAX)=NULL,@msg235 NVARCHAR(MAX)=NULL,@msg236 NVARCHAR(MAX)=NULL,@msg237 NVARCHAR(MAX)=NULL,@msg238 NVARCHAR(MAX)=NULL,@msg239 NVARCHAR(MAX)=NULL
,@msg240 NVARCHAR(MAX)=NULL,@msg241 NVARCHAR(MAX)=NULL,@msg242 NVARCHAR(MAX)=NULL,@msg243 NVARCHAR(MAX)=NULL,@msg244 NVARCHAR(MAX)=NULL,@msg245 NVARCHAR(MAX)=NULL,@msg246 NVARCHAR(MAX)=NULL,@msg247 NVARCHAR(MAX)=NULL,@msg248 NVARCHAR(MAX)=NULL,@msg249 NVARCHAR(MAX)=NULL
,@row_count INT = NULL
AS
BEGIN
   DECLARE
       @min_log_level   INT
      ,@lvl_msg         NVARCHAR(MAX)
      ,@log_msg         NVARCHAR(4000)
      ,@row_count_str   NVARCHAR(30) = NULL

   SET NOCOUNT ON
   SET @min_log_level = COALESCE(ut.dbo.fnGetSessionContextAsInt(N'LOG_LEVEL'), 1); -- Default: INFO

   SET @lvl_msg = 
   CASE
      WHEN @level = 0 THEN 'DEBUG  '
      WHEN @level = 1 THEN 'INFO   '
      WHEN @level = 2 THEN 'NOTE   '
      WHEN @level = 3 THEN 'WARNING'
      WHEN @level = 4 THEN 'ERROR  '
      ELSE '????'
   END;

   SET @fn= ut.dbo.fnPadRight(@fn, 31);

   IF @row_count IS NOT NULL SET @row_count_str = CONCAT(' rowcount: ', @row_count)

   SET @log_msg = CONCAT
   (
       @msg00 ,@msg01 ,@msg02 ,@msg03, @msg04, @msg05, @msg06 ,@msg07 ,@msg08 ,@msg09 
      ,@msg10 ,@msg11 ,@msg12 ,@msg13, @msg14, @msg15, @msg16 ,@msg18 ,@msg18 ,@msg19
      ,@msg20 ,@msg21 ,@msg22 ,@msg23, @msg24, @msg25, @msg26 ,@msg27 ,@msg28 ,@msg29
      ,@msg30 ,@msg31 ,@msg32 ,@msg33, @msg34, @msg35, @msg36 ,@msg37 ,@msg38 ,@msg39
      ,@msg40 ,@msg41 ,@msg42 ,@msg43, @msg44, @msg45, @msg46 ,@msg47 ,@msg48 ,@msg49
      ,@msg50 ,@msg51 ,@msg52 ,@msg53, @msg54, @msg55, @msg56 ,@msg57 ,@msg58 ,@msg59
      ,@msg60 ,@msg61 ,@msg62 ,@msg63, @msg64, @msg65, @msg66 ,@msg67 ,@msg68 ,@msg69
      ,@msg70 ,@msg71 ,@msg72 ,@msg73, @msg74, @msg75, @msg76 ,@msg77 ,@msg78 ,@msg79
      ,@msg80 ,@msg81 ,@msg82 ,@msg83, @msg84, @msg85, @msg86 ,@msg87 ,@msg88 ,@msg89
      ,@msg90 ,@msg91 ,@msg92 ,@msg93, @msg94, @msg95, @msg96 ,@msg97 ,@msg98 ,@msg99
      ,@msg100,@msg101,@msg102,@msg103,@msg104,@msg105,@msg106,@msg107,@msg108,@msg109 
      ,@msg110,@msg111,@msg112,@msg113,@msg114,@msg115,@msg116,@msg117,@msg118,@msg119 
      ,@msg120,@msg121,@msg122,@msg123,@msg124,@msg125,@msg126,@msg127,@msg128,@msg129 
      ,@msg130,@msg131,@msg132,@msg133,@msg134,@msg135,@msg136,@msg137,@msg138,@msg139 
      ,@msg140,@msg141,@msg142,@msg143,@msg144,@msg145,@msg146,@msg147,@msg148,@msg149 
      ,@msg150,@msg151,@msg152,@msg153,@msg154,@msg155,@msg156,@msg157,@msg158,@msg159 
      ,@msg160,@msg161,@msg162,@msg163,@msg164,@msg165,@msg166,@msg167,@msg168,@msg169 
      ,@msg170,@msg171,@msg172,@msg173,@msg174,@msg175,@msg176,@msg177,@msg178,@msg179 
      ,@msg180,@msg181,@msg182,@msg183,@msg184,@msg185,@msg186,@msg187,@msg188,@msg189 
      ,@msg190,@msg191,@msg192,@msg193,@msg194,@msg195,@msg196,@msg197,@msg198,@msg199 
      ,@msg200,@msg201,@msg202,@msg203,@msg204,@msg205,@msg206,@msg207,@msg208,@msg209 
      ,@msg210,@msg211,@msg212,@msg213,@msg214,@msg215,@msg216,@msg217,@msg218,@msg219 
      ,@msg220,@msg221,@msg222,@msg223,@msg224,@msg225,@msg226,@msg227,@msg228,@msg229 
      ,@msg230,@msg231,@msg232,@msg233,@msg234,@msg235,@msg236,@msg237,@msg238,@msg239 
      ,@msg240,@msg241,@msg242,@msg243,@msg244,@msg245,@msg246,@msg247,@msg248,@msg249 
      ,@row_count_str
   );

   -- Always log to log table
   INSERT INTO AppLog (fn, msg, [level], row_count) VALUES (ut.dbo.fnTrim(@fn), @log_msg, @level, @row_count);

   -- Only display if required
   IF @level >=@min_log_level
   BEGIN

         PRINT CONCAT(@lvl_msg, ' ',@fn, ': ', @log_msg);
      --END
   END -- IF @level >=@min_log_level
END

GO
