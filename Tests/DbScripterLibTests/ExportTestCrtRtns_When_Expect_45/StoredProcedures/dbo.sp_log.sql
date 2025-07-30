SET ANSI_NULLS ON
GO
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
CREATE PROCEDURE [dbo].[sp_log]
 @level  INT = 1
,@fn     VARCHAR(45)=NULL
,@msg00  VARCHAR(MAX)=NULL,@msg01  VARCHAR(MAX)=NULL,@msg02  VARCHAR(MAX)=NULL,@msg03  VARCHAR(MAX)=NULL,@msg04  VARCHAR(MAX)=NULL,@msg05  VARCHAR(MAX)=NULL,@msg06  VARCHAR(MAX)=NULL,@msg07  VARCHAR(MAX)=NULL,@msg08  VARCHAR(MAX)=NULL,@msg09  VARCHAR(MAX)=NULL
,@msg10  VARCHAR(MAX)=NULL,@msg11  VARCHAR(MAX)=NULL,@msg12  VARCHAR(MAX)=NULL,@msg13  VARCHAR(MAX)=NULL,@msg14  VARCHAR(MAX)=NULL,@msg15  VARCHAR(MAX)=NULL,@msg16  VARCHAR(MAX)=NULL,@msg17  VARCHAR(MAX)=NULL,@msg18  VARCHAR(MAX)=NULL,@msg19  VARCHAR(MAX)=NULL
,@msg20  VARCHAR(MAX)=NULL,@msg21  VARCHAR(MAX)=NULL,@msg22  VARCHAR(MAX)=NULL,@msg23  VARCHAR(MAX)=NULL,@msg24  VARCHAR(MAX)=NULL,@msg25  VARCHAR(MAX)=NULL,@msg26  VARCHAR(MAX)=NULL,@msg27  VARCHAR(MAX)=NULL,@msg28  VARCHAR(MAX)=NULL,@msg29  VARCHAR(MAX)=NULL
,@msg30  VARCHAR(MAX)=NULL,@msg31  VARCHAR(MAX)=NULL,@msg32  VARCHAR(MAX)=NULL,@msg33  VARCHAR(MAX)=NULL,@msg34  VARCHAR(MAX)=NULL,@msg35  VARCHAR(MAX)=NULL,@msg36  VARCHAR(MAX)=NULL,@msg37  VARCHAR(MAX)=NULL,@msg38  VARCHAR(MAX)=NULL,@msg39  VARCHAR(MAX)=NULL
,@msg40  VARCHAR(MAX)=NULL,@msg41  VARCHAR(MAX)=NULL,@msg42  VARCHAR(MAX)=NULL,@msg43  VARCHAR(MAX)=NULL,@msg44  VARCHAR(MAX)=NULL,@msg45  VARCHAR(MAX)=NULL,@msg46  VARCHAR(MAX)=NULL,@msg47  VARCHAR(MAX)=NULL,@msg48  VARCHAR(MAX)=NULL,@msg49  VARCHAR(MAX)=NULL
,@msg50  VARCHAR(MAX)=NULL,@msg51  VARCHAR(MAX)=NULL,@msg52  VARCHAR(MAX)=NULL,@msg53  VARCHAR(MAX)=NULL,@msg54  VARCHAR(MAX)=NULL,@msg55  VARCHAR(MAX)=NULL,@msg56  VARCHAR(MAX)=NULL,@msg57  VARCHAR(MAX)=NULL,@msg58  VARCHAR(MAX)=NULL,@msg59  VARCHAR(MAX)=NULL
,@msg60  VARCHAR(MAX)=NULL,@msg61  VARCHAR(MAX)=NULL,@msg62  VARCHAR(MAX)=NULL,@msg63  VARCHAR(MAX)=NULL,@msg64  VARCHAR(MAX)=NULL,@msg65  VARCHAR(MAX)=NULL,@msg66  VARCHAR(MAX)=NULL,@msg67  VARCHAR(MAX)=NULL,@msg68  VARCHAR(MAX)=NULL,@msg69  VARCHAR(MAX)=NULL
,@msg70  VARCHAR(MAX)=NULL,@msg71  VARCHAR(MAX)=NULL,@msg72  VARCHAR(MAX)=NULL,@msg73  VARCHAR(MAX)=NULL,@msg74  VARCHAR(MAX)=NULL,@msg75  VARCHAR(MAX)=NULL,@msg76  VARCHAR(MAX)=NULL,@msg77  VARCHAR(MAX)=NULL,@msg78  VARCHAR(MAX)=NULL,@msg79  VARCHAR(MAX)=NULL
,@msg80  VARCHAR(MAX)=NULL,@msg81  VARCHAR(MAX)=NULL,@msg82  VARCHAR(MAX)=NULL,@msg83  VARCHAR(MAX)=NULL,@msg84  VARCHAR(MAX)=NULL,@msg85  VARCHAR(MAX)=NULL,@msg86  VARCHAR(MAX)=NULL,@msg87  VARCHAR(MAX)=NULL,@msg88  VARCHAR(MAX)=NULL,@msg89  VARCHAR(MAX)=NULL
,@msg90  VARCHAR(MAX)=NULL,@msg91  VARCHAR(MAX)=NULL,@msg92  VARCHAR(MAX)=NULL,@msg93  VARCHAR(MAX)=NULL,@msg94  VARCHAR(MAX)=NULL,@msg95  VARCHAR(MAX)=NULL,@msg96  VARCHAR(MAX)=NULL,@msg97  VARCHAR(MAX)=NULL,@msg98  VARCHAR(MAX)=NULL,@msg99  VARCHAR(MAX)=NULL
,@msg100 VARCHAR(MAX)=NULL,@msg101 VARCHAR(MAX)=NULL,@msg102 VARCHAR(MAX)=NULL,@msg103 VARCHAR(MAX)=NULL,@msg104 VARCHAR(MAX)=NULL,@msg105 VARCHAR(MAX)=NULL,@msg106 VARCHAR(MAX)=NULL,@msg107 VARCHAR(MAX)=NULL,@msg108 VARCHAR(MAX)=NULL,@msg109 VARCHAR(MAX)=NULL
,@msg110 VARCHAR(MAX)=NULL,@msg111 VARCHAR(MAX)=NULL,@msg112 VARCHAR(MAX)=NULL,@msg113 VARCHAR(MAX)=NULL,@msg114 VARCHAR(MAX)=NULL,@msg115 VARCHAR(MAX)=NULL,@msg116 VARCHAR(MAX)=NULL,@msg117 VARCHAR(MAX)=NULL,@msg118 VARCHAR(MAX)=NULL,@msg119 VARCHAR(MAX)=NULL
,@msg120 VARCHAR(MAX)=NULL,@msg121 VARCHAR(MAX)=NULL,@msg122 VARCHAR(MAX)=NULL,@msg123 VARCHAR(MAX)=NULL,@msg124 VARCHAR(MAX)=NULL,@msg125 VARCHAR(MAX)=NULL,@msg126 VARCHAR(MAX)=NULL,@msg127 VARCHAR(MAX)=NULL,@msg128 VARCHAR(MAX)=NULL,@msg129 VARCHAR(MAX)=NULL
,@msg130 VARCHAR(MAX)=NULL,@msg131 VARCHAR(MAX)=NULL,@msg132 VARCHAR(MAX)=NULL,@msg133 VARCHAR(MAX)=NULL,@msg134 VARCHAR(MAX)=NULL,@msg135 VARCHAR(MAX)=NULL,@msg136 VARCHAR(MAX)=NULL,@msg137 VARCHAR(MAX)=NULL,@msg138 VARCHAR(MAX)=NULL,@msg139 VARCHAR(MAX)=NULL
,@msg140 VARCHAR(MAX)=NULL,@msg141 VARCHAR(MAX)=NULL,@msg142 VARCHAR(MAX)=NULL,@msg143 VARCHAR(MAX)=NULL,@msg144 VARCHAR(MAX)=NULL,@msg145 VARCHAR(MAX)=NULL,@msg146 VARCHAR(MAX)=NULL,@msg147 VARCHAR(MAX)=NULL,@msg148 VARCHAR(MAX)=NULL,@msg149 VARCHAR(MAX)=NULL
,@msg150 VARCHAR(MAX)=NULL,@msg151 VARCHAR(MAX)=NULL,@msg152 VARCHAR(MAX)=NULL,@msg153 VARCHAR(MAX)=NULL,@msg154 VARCHAR(MAX)=NULL,@msg155 VARCHAR(MAX)=NULL,@msg156 VARCHAR(MAX)=NULL,@msg157 VARCHAR(MAX)=NULL,@msg158 VARCHAR(MAX)=NULL,@msg159 VARCHAR(MAX)=NULL
,@msg160 VARCHAR(MAX)=NULL,@msg161 VARCHAR(MAX)=NULL,@msg162 VARCHAR(MAX)=NULL,@msg163 VARCHAR(MAX)=NULL,@msg164 VARCHAR(MAX)=NULL,@msg165 VARCHAR(MAX)=NULL,@msg166 VARCHAR(MAX)=NULL,@msg167 VARCHAR(MAX)=NULL,@msg168 VARCHAR(MAX)=NULL,@msg169 VARCHAR(MAX)=NULL
,@msg170 VARCHAR(MAX)=NULL,@msg171 VARCHAR(MAX)=NULL,@msg172 VARCHAR(MAX)=NULL,@msg173 VARCHAR(MAX)=NULL,@msg174 VARCHAR(MAX)=NULL,@msg175 VARCHAR(MAX)=NULL,@msg176 VARCHAR(MAX)=NULL,@msg177 VARCHAR(MAX)=NULL,@msg178 VARCHAR(MAX)=NULL,@msg179 VARCHAR(MAX)=NULL
,@msg180 VARCHAR(MAX)=NULL,@msg181 VARCHAR(MAX)=NULL,@msg182 VARCHAR(MAX)=NULL,@msg183 VARCHAR(MAX)=NULL,@msg184 VARCHAR(MAX)=NULL,@msg185 VARCHAR(MAX)=NULL,@msg186 VARCHAR(MAX)=NULL,@msg187 VARCHAR(MAX)=NULL,@msg188 VARCHAR(MAX)=NULL,@msg189 VARCHAR(MAX)=NULL
,@msg190 VARCHAR(MAX)=NULL,@msg191 VARCHAR(MAX)=NULL,@msg192 VARCHAR(MAX)=NULL,@msg193 VARCHAR(MAX)=NULL,@msg194 VARCHAR(MAX)=NULL,@msg195 VARCHAR(MAX)=NULL,@msg196 VARCHAR(MAX)=NULL,@msg197 VARCHAR(MAX)=NULL,@msg198 VARCHAR(MAX)=NULL,@msg199 VARCHAR(MAX)=NULL
,@msg200 VARCHAR(MAX)=NULL,@msg201 VARCHAR(MAX)=NULL,@msg202 VARCHAR(MAX)=NULL,@msg203 VARCHAR(MAX)=NULL,@msg204 VARCHAR(MAX)=NULL,@msg205 VARCHAR(MAX)=NULL,@msg206 VARCHAR(MAX)=NULL,@msg207 VARCHAR(MAX)=NULL,@msg208 VARCHAR(MAX)=NULL,@msg209 VARCHAR(MAX)=NULL
,@msg210 VARCHAR(MAX)=NULL,@msg211 VARCHAR(MAX)=NULL,@msg212 VARCHAR(MAX)=NULL,@msg213 VARCHAR(MAX)=NULL,@msg214 VARCHAR(MAX)=NULL,@msg215 VARCHAR(MAX)=NULL,@msg216 VARCHAR(MAX)=NULL,@msg217 VARCHAR(MAX)=NULL,@msg218 VARCHAR(MAX)=NULL,@msg219 VARCHAR(MAX)=NULL
,@msg220 VARCHAR(MAX)=NULL,@msg221 VARCHAR(MAX)=NULL,@msg222 VARCHAR(MAX)=NULL,@msg223 VARCHAR(MAX)=NULL,@msg224 VARCHAR(MAX)=NULL,@msg225 VARCHAR(MAX)=NULL,@msg226 VARCHAR(MAX)=NULL,@msg227 VARCHAR(MAX)=NULL,@msg228 VARCHAR(MAX)=NULL,@msg229 VARCHAR(MAX)=NULL
,@msg230 VARCHAR(MAX)=NULL,@msg231 VARCHAR(MAX)=NULL,@msg232 VARCHAR(MAX)=NULL,@msg233 VARCHAR(MAX)=NULL,@msg234 VARCHAR(MAX)=NULL,@msg235 VARCHAR(MAX)=NULL,@msg236 VARCHAR(MAX)=NULL,@msg237 VARCHAR(MAX)=NULL,@msg238 VARCHAR(MAX)=NULL,@msg239 VARCHAR(MAX)=NULL
,@msg240 VARCHAR(MAX)=NULL,@msg241 VARCHAR(MAX)=NULL,@msg242 VARCHAR(MAX)=NULL,@msg243 VARCHAR(MAX)=NULL,@msg244 VARCHAR(MAX)=NULL,@msg245 VARCHAR(MAX)=NULL,@msg246 VARCHAR(MAX)=NULL,@msg247 VARCHAR(MAX)=NULL,@msg248 VARCHAR(MAX)=NULL,@msg249 VARCHAR(MAX)=NULL
,@row_count INT = NULL
,@short_msg BIT = 0
AS
BEGIN
   DECLARE
       @fnThis          VARCHAR(35) = 'sp_log'
      ,@min_log_level   INT
      ,@lvl_msg         VARCHAR(MAX)
      ,@log_msg         VARCHAR(4000)
      ,@display_msg     VARCHAR(4000)
      ,@row_count_str   VARCHAR(30) = NULL
   SET NOCOUNT ON
   SET @min_log_level = COALESCE(dbo.fnGetLogLevel(), 1); -- Default: INFO
   SET @lvl_msg = 
   CASE
      WHEN @level = 0 THEN 'DEBUG'
      WHEN @level = 1 THEN 'INFO '
      WHEN @level = 2 THEN 'NOTE '
      WHEN @level = 3 THEN 'WARN '
      WHEN @level = 4 THEN 'ERROR'
      ELSE '???? '
   END;
   SET @fn= dbo.fnPadRight(@fn, 45);
   IF @row_count IS NOT NULL SET @row_count_str = CONCAT(' rowcount: ', @row_count)
   SET @log_msg = CONCAT
   (
       @msg00 ,@msg01 ,@msg02 ,@msg03, @msg04, @msg05, @msg06 ,@msg07 ,@msg08 ,@msg09 
      ,@msg10 ,@msg11 ,@msg12 ,@msg13, @msg14, @msg15, @msg16 ,@msg17 ,@msg18 ,@msg19
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
   INSERT INTO AppLog (rtn, msg, [level], row_count)
   VALUES (dbo.fnTrim(@fn), @log_msg, @level, @row_count);
   -- Only display if required
   IF @level >= @min_log_level
   BEGIN
      IF @short_msg = 0
         SET @display_msg =  CONCAT(@lvl_msg, ' ',@fn, ': ', @log_msg);
      ELSE
         SET @display_msg =  CONCAT(@lvl_msg, ' ', @log_msg);
      PRINT @display_msg;
   END
END
/*
EXEC tSQLt.RunAll;
SELECT * From AppLog
*/
GO

