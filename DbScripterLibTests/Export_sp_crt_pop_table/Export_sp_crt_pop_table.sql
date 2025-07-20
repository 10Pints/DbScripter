/*
Parameters:

--------------------------------------------------------------------------------
 Type            : Params
--------------------------------------------------------------------------------
 CreateMode      : Create
 Database        : Dorsu_dev
 DisplayLog      : True
 DisplayScript   : True
 IndividualFiles              : False
 Instance                     : 
 IsExprtngData                : False
 LogFile                      : D:\Logs\Export_sp_crt_pop_table.log
 LogLevel                     : Info
 Name                         : AppSettings.01
 RequiredAssemblies           : System.Collections.Generic.List`1[System.String]
 RequiredSchemas              : System.Collections.Generic.List`1[System.String]
 RequiredFunctions            : System.Collections.Generic.List`1[System.String]
 RequiredProcedures           : System.Collections.Generic.List`1[System.String]
 RequiredTables               : System.Collections.Generic.List`1[System.String]
 RequiredViews                : System.Collections.Generic.List`1[System.String]
 RequiredUserDefinedTypes     : System.Collections.Generic.List`1[System.String]
 RequiredUserDefinedDataTypes : System.Collections.Generic.List`1[System.String]
 RequiredUserDefinedTableTypes: System.Collections.Generic.List`1[System.String]
 Want All:                  : Assembly
 Want All:                  : Database
 Want All:                  : Function
 Want All:                  : Procedure
 Want All:                  : Schema
 Want All:                  : Table
 Want All:                  : View
 Want All:                  : UserDefinedType
 Want All:                  : UserDefinedDataType
 Want All:                  : UserDefinedTableType
 Script Dir                   : D:\Dev\DbScripter\DbScripterLibTests\Export_sp_crt_pop_table
 Script File                  : D:\Dev\DbScripter\DbScripterLibTests\Export_sp_crt_pop_table\Export_sp_crt_pop_table.sql
 ScriptUseDb                  : True
 Server                       : DevI9
 AddTimestamp                 : False
 Timestamp                    : 250720-0750

 RequiredSchemas : 2
	dbo
	test

*/

USE [Dorsu_dev]
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- ===============================================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: fnLen deals with the trailing spaces bug in Len
-- ===============================================================
CREATE  FUNCTION [dbo].[fnLen]( @v VARCHAR(8000))
RETURNS INT
AS
BEGIN
   RETURN CASE
            WHEN @v IS NULL THEN 0
            ELSE Len(@v+'x')-1
            END;
END
/*
EXEC test.sp__crt_tst_rtns 'dbo].[fnLen]', 43;
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- ==========================================================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: Removes specific characters from the right end of a string
-- 23-JUN-2023: Fix handle all wspc like spc, tab, \n \r CHAR(160)
-- ==========================================================================
CREATE FUNCTION [dbo].[fnRTrim]
(
   @s VARCHAR(MAX)
)
RETURNS  VARCHAR(MAX)
AS
BEGIN
   DECLARE  
       @tcs    VARCHAR(20)

   IF (@s IS NULL ) OR (LEN(@s) = 0)
      RETURN @s;

   SET @tcs = CONCAT( NCHAR(9), NCHAR(10), NCHAR(13), NCHAR(32), NCHAR(160))

   WHILE CHARINDEX(Right(@s, 1) , @tcs) > 0 AND dbo.fnLen(@s) > 0 -- SUBSTRING(@s,  dbo.fnLen(@s)-1, 1) or Right(@s, 1)
      SET @s = SUBSTRING(@s, 1, dbo.fnLen(@s)-1); -- SUBSTRING(@s, 1, dbo.fnLen(@s)-1) or Left(@s, dbo.fnLen(@s)-1)

   RETURN @s;
END




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- ================================================================
-- Author:      Terry Watts
-- Create date: 23-JUN-2023
-- Description: Removes specific characters from 
--              the beginning of a string
-- 23-JUN-2023: Fix handle all wspc like spc, tab, \n \r CHAR(160)
-- ==================================================================
CREATE FUNCTION [dbo].[fnLTrim]
(
    @s VARCHAR(MAX)
)
RETURNS  VARCHAR(MAX)
AS
BEGIN
   DECLARE  
       @tcs    VARCHAR(20)

   IF (@s IS NULL ) OR (dbo.fnLen(@s) = 0)
      RETURN @s;

   SET @tcs = CONCAT( NCHAR(9), NCHAR(10), NCHAR(13), NCHAR(32), NCHAR(160))

   WHILE CHARINDEX(SUBSTRING(@s, 1, 1), @tcs) > 0 AND dbo.fnLen(@s) > 0
      SET @s = SUBSTRING(@s, 2, dbo.fnLen(@s)-1);

   RETURN @s;
END
/*
PRINT CONCAT('[', fnTrim(' '), ']')
PRINT CONCAT('[', fnLTrim(' '), ']')
PRINT CONCAT('[', fnLTrim2(' ', ' '), ']')
PRINT CONCAT('[', fnLTrim(CONCAT(0x20, 0x09, 0x0a, 0x0d, 0x20,'a', 0x20, 0x09, 0x0a, 0x0d, 0x20,' #cd# ')), ']');
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================================
-- Author:      Terry Watts
-- Create date: 10-OCT-2019
-- Description: Trims leading and trailing whitesace including the 
--                normally untrimmable CHAR(160)
-- 23-JUN-2023: Fix handle all wspc like spc, tab, \n \r CHAR(160)
-- ================================================================
CREATE FUNCTION [dbo].[fnTrim]( @s VARCHAR(4000)
)
RETURNS VARCHAR(4000)
AS
BEGIN
  RETURN dbo.fnRTrim( dbo.fnLTrim(@s));
END
/*
PRINT CONCAT('[', dbo.fnTrim(CONCAT(0x20, 0x09, 0x0a, 0x0d, 0xA0, '  a  #cd# ', 0x20, 0x09, 0x0a, 0x0d, 0x0d,0xA0)), ']');
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--===========================================================
-- Author:      Terry watts
-- Create date: 18-MAY-2020
-- Description: lists routine details
-- ===========================================================
CREATE VIEW [dbo].[SysRtns_vw]
AS
SELECT TOP 2000
    SCHEMA_NAME([schema_id])              AS schema_nm
   ,[name]                                AS rtn_nm
   ,IIF([type] IN ('P','PC'), 'P', 'F')   AS rtn_ty
   ,dbo.fnTrim([type])                    AS ty_code
   ,[type_desc]                           AS ty_nm
   ,IIF([type] IN ('FS','FT','PC'),1,0)   AS is_clr
   ,is_ms_shipped
   ,DATEFROMPARTS(YEAR(create_date), MONTH(create_date), Day(create_date)) AS created
   ,DATEFROMPARTS(YEAR(modify_date), MONTH(modify_date), Day(modify_date)) AS modified
FROM sys.objects
    WHERE
     [type] IN ('P', 'FN', 'TF', 'IF', 'AF', 'FT', 'IS', 'PC', 'FS')
ORDER BY [schema_nm], [type], [name]
;
/*
SELECT * FROM SysRtns_vw WHERE ty_code = 'P' AND schema_nm IN ('dbo','test')
SELECt top 500 * from sys.objects WHERE name like 'sp_%'
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- =================================================
-- Author:      Terry Watts
-- Create date: 24-NOV-2023
--
-- Description: removes square brackets from string
-- in any position in the string
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    [ ] brackets removed
--
-- Tests:
-- =============================================
CREATE FUNCTION [dbo].[fnDeSquareBracket](@s VARCHAR(4000))
RETURNS VARCHAR(4000)
AS
BEGIN
   RETURN REPLACE(REPLACE(@s, '[', ''), ']', '');
END
/*
   EXEC test.sp_crt_tst_rtns 'dbo.fnDeSquareBracket', 69
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 12-NOV-2023
--
-- Description: splits a qualified rtn name 
-- into a row containing the schema_nm and the rtn_nm
-- removes square brackets
--
-- RULES:
-- @qrn  schema   rtn
-- a.b   a        b
-- a     dbo      a
-- NULL  null     null
-- ''    null     null
--
-- Preconditions
-- PRE 02: if schema is not specifed in @qrn and there are more than 1 rtn with the rtn nm
--          but differnt schema then raise div by zero exception

-- Postconditions:
-- Post 01: if schema is not specifed then get it from the sys rtns PROVIDED ONLY ONE rtn named the @rtn_nm
-- 
-- Changes:
-- 231117: handle [ ] wrappers
-- 240403: handle errors like null @qual_rtn_nm softly as per rules above
-- 241207: changed schema from test to dbo
-- 241227: default schema is now the schema found in the sys rtns for the given rtn in @qrn
--         will throw a div by zero error if PRE 02 violated
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnSplitQualifiedName]
(
   @qrn VARCHAR(150) -- qualified routine name
)
RETURNS @t TABLE
(
    schema_nm  VARCHAR(50)
   ,rtn_nm     VARCHAR(100)
)
AS
BEGIN
   DECLARE
    @n          INT
   ,@schema_nm  VARCHAR(50)
   ,@rtn_nm     VARCHAR(100)

   -- Remove [ ] wrappers
   SET @qrn = dbo.fnDeSquareBracket(@qrn);

   IF @qrn IS NOT NULL AND @qrn <> ''
   BEGIN
      SET @n = CHARINDEX('.',@qrn);

      -- if rtn nm not qualified then assume schema = dbo
      SET @schema_nm = iif(@n=0, 'dbo',SUBSTRING( @qrn, 1   , @n-1));
      SET @rtn_nm    = iif(@n=0,  @qrn,SUBSTRING( @qrn, @n+1, dbo.fnLen(@qrn)-@n))

      -- PRE 02: if schema is not specifed in @qrn and there are more than 1 rtn with the rtn nm
      --          but differnt schema then raise div by zero exception
      IF( CHARINDEX('.', @qrn) = 0)
      BEGIN
         DECLARE @cnt INT;
         SELECT @cnt = COUNT(*) FROM dbo.SysRtns_vw WHERE rtn_nm = @qrn;

         -- Raise div by zero exception
         IF @cnt > 1 SET @cnt = @cnt/0;
      END
   END

   INSERT INTO @t (schema_nm, rtn_nm)
   VALUES( @schema_nm,@rtn_nm);
   RETURN;
END
/*
SELECT * FROM fnSplitQualifiedName('test.fnGetRtnNmBits')
SELECT * FROM fnSplitQualifiedName('a.b')
SELECT * FROM fnSplitQualifiedName('a.b.c')
SELECT * FROM fnSplitQualifiedName('a')
SELECT * FROM fnSplitQualifiedName(null)
SELECT * FROM fnSplitQualifiedName('')
EXEC test.sp__crt_tst_rtns '[dbo].[fnSplitQualifiedName]';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: returns true (1) if table exists else false (0)
-- schema default is dbo
-- Parameters:  @q_table_nm can be qualified
-- Returns      1 if exists, 0 otherwise
-- =============================================================
CREATE FUNCTION [dbo].[fnTableExists](@q_table_nm VARCHAR(100))
RETURNS BIT
AS
BEGIN
   DECLARE
       @schema    VARCHAR(28)
      ,@table_nm  VARCHAR(60)
   ;

   SELECT
       @schema    = schema_nm
      ,@table_nm  = rtn_nm
   FROM fnSplitQualifiedName(@q_table_nm);

   RETURN iif(EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_nm AND TABLE_SCHEMA = @schema), 1, 0);
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- =============================================    
-- Author:      Terry Watts
-- Create date: 23-JUN-2023
-- Description: Pads Right with specified padding character
-- =============================================    
CREATE FUNCTION [dbo].[fnPadRight2]
(
    @s      VARCHAR(MAX)
   ,@width  INT
   ,@pad    VARCHAR(1)
)
RETURNS VARCHAR (1000)
AS
BEGIN
   DECLARE 
      @ret  VARCHAR(1000)
     ,@len  INT

   IF @s IS null
      SET @s = '';

   SET @len = ut.dbo.fnLen(@s)
   RETURN LEFT( CONCAT( @s, REPLICATE( @pad, @width-@len)), @width)
END
/*
SELECT CONCAT('[', dbo.fnPadRight2('a very long string indeed - its about time we had a beer', 25, '.'), ']  ');
SELECT CONCAT('[', dbo.fnPadRight2('', 25, '.'), ']  ');
SELECT CONCAT('[', dbo.fnPadRight2(NULL, 25, '.'), ']  ');
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =============================================    
-- Author:  Terry Watts
-- Create date: 04-OCT-2019
-- Description: Pads Right
-- =============================================    
CREATE FUNCTION [dbo].[fnPadRight]( @s VARCHAR(500), @width INT)
RETURNS VARCHAR (1000)
AS
BEGIN
   RETURN dbo.fnPadRight2( @s, @width, ' ' )
END
/*
SELECT CONCAT(', ]', dbo.fnPadRight([name], 25), ']  ', [type])
FROM [tg].[test].[fnCrtPrmMap]( '          @table_nm                  VARCHAR(50)  
         ,@folder                    VARCHAR(260)  
         ,@workbook_nm               VARCHAR(260)   OUTPUT  
         ,@sheet_nm                  VARCHAR(50)    OUTPUT  
         ,@view_nm                   VARCHAR(50)    OUTPUT  
         ,@error_msg                 VARCHAR(200)   OUTPUT  ')
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: returns the log level key
-- =============================================
CREATE FUNCTION [dbo].[fnGetLogLevelKey] ()
RETURNS NVARCHAR(50)
AS
BEGIN
   RETURN N'LOG_LEVEL';
END
/*
EXEC test.sp_crt_tst_rtns 'dbo.fnGetLogLevelKey', 
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ===============================================================
-- Author:      Terry Watts
-- Create date: 25-MAY-2020
-- Description: Get session context as int - default = -1
-- RETURNS      if    key/value present returns value as INT
--              if no key/value present returns NULL
--
-- See Also: fnGetSessionContextAsString, sp_set_session_context
--
-- CHANGES:
-- 14-JUL-2023: default = -1 (not found) was 0 before
-- 06-FEB-2024: simply returns value if key found else NULL
-- ===============================================================
CREATE FUNCTION [dbo].[fnGetSessionContextAsInt](@key NVARCHAR(100))
RETURNS INT
BEGIN
   RETURN CONVERT(INT, SESSION_CONTEXT(@key));
END
/*
PRINT CONCAT('[',dbo.fnGetSessionContextAsInt(N'cor_id'),']')
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: returns the log level
-- =============================================
CREATE FUNCTION [dbo].[fnGetLogLevel]()
RETURNS INT
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsInt(dbo.fnGetLogLevelKey());
END
/*
EXEC test.sp_crt_tst_rtns 'dbo.fnGetLogLevel', 80;
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AppLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[timestamp] [varchar](30) NOT NULL,
	[schema_nm] [varbinary](20) NULL,
	[rtn] [varchar](60) NULL,
	[hit] [int] NULL,
	[log] [varchar](max) NULL,
	[msg] [varchar](max) NULL,
	[level] [int] NULL,
	[row_count] [int] NULL,
 CONSTRAINT [PK_AppLog] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[AppLog] ADD  CONSTRAINT [DF_AppLog_timestamp]  DEFAULT (getdate()) FOR [timestamp]

GO
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
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author:      Terry Watts
-- Create date: 19-JUL-2025
-- Description: Aggregates messages and separates with a space
-- Design:      
-- Tests:       
-- ============================================================
CREATE FUNCTION [dbo].[fnAggregateMsgs]
(
    @msg0  VARCHAR(MAX) = NULL,
    @msg1  VARCHAR(MAX) = NULL,
    @msg2  VARCHAR(MAX) = NULL,
    @msg3  VARCHAR(MAX) = NULL,
    @msg4  VARCHAR(MAX) = NULL,
    @msg5  VARCHAR(MAX) = NULL,
    @msg6  VARCHAR(MAX) = NULL,
    @msg7  VARCHAR(MAX) = NULL,
    @msg8  VARCHAR(MAX) = NULL,
    @msg9  VARCHAR(MAX) = NULL,
    @msg10 VARCHAR(MAX) = NULL,
    @msg11 VARCHAR(MAX) = NULL,
    @msg12 VARCHAR(MAX) = NULL,
    @msg13 VARCHAR(MAX) = NULL,
    @msg14 VARCHAR(MAX) = NULL,
    @msg15 VARCHAR(MAX) = NULL,
    @msg16 VARCHAR(MAX) = NULL,
    @msg17 VARCHAR(MAX) = NULL,
    @msg18 VARCHAR(MAX) = NULL,
    @msg19 VARCHAR(MAX) = NULL
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @result VARCHAR(MAX);

    DECLARE @msgs TABLE (txt VARCHAR(MAX));

    INSERT INTO @msgs (txt)
    SELECT TRIM(value)
    FROM (VALUES
        (@msg0), (@msg1), (@msg2), (@msg3), (@msg4),
        (@msg5), (@msg6), (@msg7), (@msg8), (@msg9),
        (@msg10), (@msg11), (@msg12), (@msg13), (@msg14),
        (@msg15), (@msg16), (@msg17), (@msg18), (@msg19)
    ) AS V(value)
    WHERE value IS NOT NULL AND LTRIM(RTRIM(value)) <> '';

    SELECT @result = STRING_AGG(txt, ' ') FROM @msgs;

    RETURN @result;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ================================================================
-- Author:      Terry Watts
-- Create date: 25-MAR-2020
-- Description: Raises an exception coallescing the error messages
-- with a space between the messages
--
-- Ensures @state is positive
-- if @ex_num < 50000 message and raise to 50K+ @ex_num
-- ================================================================
CREATE PROCEDURE [dbo].[sp_raise_exception]
       @ex_num    INT           = 53000
      ,@msg0      VARCHAR(MAX)  = NULL
      ,@msg1      VARCHAR(MAX)  = NULL
      ,@msg2      VARCHAR(MAX)  = NULL
      ,@msg3      VARCHAR(MAX)  = NULL
      ,@msg4      VARCHAR(MAX)  = NULL
      ,@msg5      VARCHAR(MAX)  = NULL
      ,@msg6      VARCHAR(MAX)  = NULL
      ,@msg7      VARCHAR(MAX)  = NULL
      ,@msg8      VARCHAR(MAX)  = NULL
      ,@msg9      VARCHAR(MAX)  = NULL
      ,@msg10     VARCHAR(MAX)  = NULL
      ,@msg11     VARCHAR(MAX)  = NULL
      ,@msg12     VARCHAR(MAX)  = NULL
      ,@msg13     VARCHAR(MAX)  = NULL
      ,@msg14     VARCHAR(MAX)  = NULL
      ,@msg15     VARCHAR(MAX)  = NULL
      ,@msg16     VARCHAR(MAX)  = NULL
      ,@msg17     VARCHAR(MAX)  = NULL
      ,@msg18     VARCHAR(MAX)  = NULL
      ,@msg19     VARCHAR(MAX)  = NULL
      ,@fn        VARCHAR(35)   = NULL
AS
BEGIN
   DECLARE
       @fnThis    VARCHAR(35) = 'sp_raise_exception'
      ,@msg       VARCHAR(max)
   ;

   DECLARE @msgs TABLE (txt VARCHAR(MAX));

   SELECT @msg =  dbo.fnAggregateMsgs
   (
       @msg0,  @msg1,  @msg2,  @msg3,  @msg4
      ,@msg5 , @msg6,  @msg7,  @msg8,  @msg9
      ,@msg10, @msg11, @msg12, @msg13, @msg14
      ,@msg15, @msg16, @msg17, @msg18, @msg19
   );

   IF @ex_num IS NULL SET @ex_num = 53000; -- default
      EXEC sp_log 4, @fnThis, '000: throwing exception ', @ex_num, ' ', @msg, ' st: 1';

   ------------------------------------------------------------------------------------------------
   -- Validate
   ------------------------------------------------------------------------------------------------
   -- check ex num >= 50000 if not add 50000 to it
   IF @ex_num < 50000
   BEGIN
      SET @ex_num = abs(@ex_num) + 50000;
      EXEC sp_log 3, @fnThis, '010: supplied exception number is too low changing to ', @ex_num;
   END

   ------------------------------------------------------------------------------------------------
   -- Throw the exception
   ------------------------------------------------------------------------------------------------
   ;THROW @ex_num, @msg, 1;
END
/*
EXEC tSQLt.Run 'test.test_076_sp_raise_exception';
*/





GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================================
-- Author:      Terry Watts
-- Create Date: 14-JUN-2025
-- Description: assert the table exists
-- Parameters:
--    @table to check if existscan be qualified
--    @exp_exists if 1 asserts @table exists else asserts @table does not exist
-- Returns      1 if exists
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_assert_tbl_exists]
    @table_nm        VARCHAR(100)
   ,@exp_exists      BIT            = 1
   ,@msg0            VARCHAR(MAX)   = NULL
   ,@msg1            VARCHAR(MAX)   = NULL
   ,@msg2            VARCHAR(MAX)   = NULL
   ,@msg3            VARCHAR(MAX)   = NULL
   ,@msg4            VARCHAR(MAX)   = NULL
   ,@msg5            VARCHAR(MAX)   = NULL
   ,@msg6            VARCHAR(MAX)   = NULL
   ,@msg7            VARCHAR(MAX)   = NULL
   ,@msg8            VARCHAR(MAX)   = NULL
   ,@msg9            VARCHAR(MAX)   = NULL
   ,@msg10           VARCHAR(MAX)   = NULL
   ,@msg11           VARCHAR(MAX)   = NULL
   ,@msg12           VARCHAR(MAX)   = NULL
   ,@msg13           VARCHAR(MAX)   = NULL
   ,@msg14           VARCHAR(MAX)   = NULL
   ,@msg15           VARCHAR(MAX)   = NULL
   ,@msg16           VARCHAR(MAX)   = NULL
   ,@msg17           VARCHAR(MAX)   = NULL
   ,@msg18           VARCHAR(MAX)   = NULL
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)   = N'sp_assert_tbl_exists'
   ,@sql             NVARCHAR(MAX)
   ,@act_exists      BIT
   ,@schema_nm       VARCHAR(50)
   ,@msg             VARCHAR(100)
   ,@nm_has_spcs     BIT
   ;

   SET NOCOUNT ON;
   SET @act_exists =dbo.fnTableExists(@table_nm);
   SET @nm_has_spcs = CHARINDEX(' ', @table_nm);

   IF @act_exists = @exp_exists
   BEGIN
      SET @msg = CONCAT('table ', iif(@nm_has_spcs=1, '[', ''), @table_nm, iif(@nm_has_spcs=1, ']', ''), iif(@exp_exists = 1, ' exists ', 'does not exist'), ' as expected');
      EXEC sp_log 1, @fn, @msg;
   END
   ELSE
   BEGIN -- Failed test
      SET @msg = CONCAT('table [', @table_nm, iif(@exp_exists = 1, '] does not exist but should', 'exists but should not'));

      EXEC sp_raise_exception
          @ex_num = 50001
         ,@msg0   = @msg
         ,@msg1   = @msg0
         ,@msg2   = @msg1
         ,@msg3   = @msg2
         ,@msg4   = @msg3
         ,@msg5   = @msg4
         ,@msg6   = @msg5
         ,@msg7   = @msg6
         ,@msg8   = @msg7
         ,@msg9   = @msg8
         ,@msg10  = @msg9
         ,@msg11  = @msg10
         ,@msg12  = @msg11
         ,@msg13  = @msg12
         ,@msg14  = @msg13
         ,@msg15  = @msg14
         ,@msg16  = @msg15
         ,@msg17  = @msg16
         ,@msg18  = @msg17
         ,@msg19  = @msg18
         ,@fn     = @fn
         ;
   END

   RETURN 1;
END
/*
EXEC test.test_070_sp_assert_tbl_exists;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if @a is null or empty
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_null_or_empty]
    @val       VARCHAR(3999)
   ,@msg1      VARCHAR(200)   = NULL
   ,@msg2      VARCHAR(200)   = NULL
   ,@msg3      VARCHAR(200)   = NULL
   ,@msg4      VARCHAR(200)   = NULL
   ,@msg5      VARCHAR(200)   = NULL
   ,@msg6      VARCHAR(200)   = NULL
   ,@msg7      VARCHAR(200)   = NULL
   ,@msg8      VARCHAR(200)   = NULL
   ,@msg9      VARCHAR(200)   = NULL
   ,@msg10     VARCHAR(200)   = NULL
   ,@msg11     VARCHAR(200)   = NULL
   ,@msg12     VARCHAR(200)   = NULL
   ,@msg13     VARCHAR(200)   = NULL
   ,@msg14     VARCHAR(200)   = NULL
   ,@msg15     VARCHAR(200)   = NULL
   ,@msg16     VARCHAR(200)   = NULL
   ,@msg17     VARCHAR(200)   = NULL
   ,@msg18     VARCHAR(200)   = NULL
   ,@ex_num    INT            = NULL
   ,@fn        VARCHAR(35)    = '*'
   ,@log_level INT            = 0
AS
BEGIN
   DECLARE 
       @fnThis    VARCHAR(35) = N'sp_assert_not_null_or_empty'
      ,@valTxt    VARCHAR(20)= @val
   ;

   EXEC sp_log @log_level, @fnThis, '000: starting,' ,@msg1,': @val:[',@val,']';

   IF dbo.fnLen(@val) > 0
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
       IF dbo.fnLen(@valTxt) < 20 SET @valTxt= CONCAT(@valTxt, '   ');
      EXEC sp_log @log_level, @fnThis, '010: OK, ASSERTION: val: [',@valTxt, '] IS NOT NULL';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   EXEC sp_log 3, @fn, '020: @val IS NULL OR EMPTY, raising exception';
   IF @ex_num IS NULL SET @ex_num = 50005;
   DECLARE @msg0 VARCHAR(20)= 'val is NULL or empty'

   EXEC sp_raise_exception
       @ex_num = @ex_num
      ,@msg0   = 'sp_assert_not_null_or_empty'
      ,@msg1   = @msg0
      ,@msg2   = @msg1
      ,@msg3   = @msg2
      ,@msg4   = @msg3
      ,@msg5   = @msg4
      ,@msg6   = @msg5
      ,@msg7   = @msg6
      ,@msg8   = @msg7
      ,@msg9   = @msg8
      ,@msg10  = @msg9
      ,@msg11  = @msg10
      ,@msg12  = @msg11
      ,@msg13  = @msg12
      ,@msg14  = @msg13
      ,@msg15  = @msg14
      ,@msg16  = @msg15
      ,@msg17  = @msg16
      ,@msg18  = @msg17
      ,@msg19  = @msg18
      ,@fn     = @fn
      ;
END
/*
EXEC tSQLt.Run 'test.test_049_sp_assert_not_null_or_empty';
EXEC tSQLt.RunAll;
EXEC sp_assert_not_null_or_empty NULL
EXEC sp_assert_not_null_or_empty ''
EXEC sp_assert_not_null_or_empty 'Fred'
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




CREATE FUNCTION [dbo].[fnMin] (@p1 INT, @p2 INT)
RETURNS INT
AS
BEGIN
   RETURN CASE WHEN @p1 > @p2 THEN @p2 ELSE @p1 END;
END




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- ========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-MAR-2020
-- Description: standard error handling:
--              get the exception message, log messages
--              clear the log cache first
-- NB: this does not throw
--
-- CHANGES
-- 231221: added clear the log cache first
-- 240315: added ex num, ex msg as optional out parmeters
-- 241204: it is possible that ERROR_MESSAGE() or ERROR_NUMBER() are throwing exceptions 
--        -this can happen inside tranactions when low level errors like select * from non existant table
-- 241221: error proc and error line do not always work - for example when executing SQL statements that
--         return a low error number like the following: 207:Invalid column name    
-- ========================================================================================================
CREATE PROCEDURE [dbo].[sp_log_exception]
       @fn        VARCHAR(35)
      ,@msg01     VARCHAR(4000) = NULL
      ,@msg02     VARCHAR(1000) = NULL
      ,@msg03     VARCHAR(1000) = NULL
      ,@msg04     VARCHAR(1000) = NULL
      ,@msg05     VARCHAR(1000) = NULL
      ,@msg06     VARCHAR(1000) = NULL
      ,@msg07     VARCHAR(1000) = NULL
      ,@msg08     VARCHAR(1000) = NULL
      ,@msg09     VARCHAR(1000) = NULL
      ,@msg10     VARCHAR(1000) = NULL
      ,@msg11     VARCHAR(1000) = NULL
      ,@msg12     VARCHAR(1000) = NULL
      ,@msg13     VARCHAR(1000) = NULL
      ,@msg14     VARCHAR(1000) = NULL
      ,@msg15     VARCHAR(1000) = NULL
      ,@msg16     VARCHAR(1000) = NULL
      ,@msg17     VARCHAR(1000) = NULL
      ,@msg18     VARCHAR(1000) = NULL
      ,@msg19     VARCHAR(1000) = NULL
      ,@ex_num    INT            = NULL OUT
      ,@ex_msg    VARCHAR(500)  = NULL OUT
      ,@ex_proc   VARCHAR(80)   = NULL OUT
      ,@ex_line   VARCHAR(20)   = NULL OUT
AS
BEGIN
   DECLARE 
       @fnThis    VARCHAR(35) = 'sp_log_exception'
      ,@NL        VARCHAR(2)  =  NCHAR(13) + NCHAR(10)
      ,@msg       VARCHAR(500)
      ,@fnHdr     VARCHAR(100)
      ,@isTrans   BIT = 0
      ,@line      VARCHAR(4000)

   SET @ex_num = -1; -- unknown
   SET @msg    = 'UNKNOWN MESSAGE';

   --EXEC sp_log 4, @fnThis, '510: starting';

   SELECT
       @ex_num = ERROR_NUMBER()
      ,@ex_proc= ERROR_PROCEDURE()
      ,@ex_line= CAST(ERROR_LINE() AS VARCHAR(20))
      ,@ex_msg = ERROR_MESSAGE();

   SET @fnHdr = CONCAT(@ex_proc, '(',@ex_line,'): ')

   BEGIN TRY
      SET @msg =
      CONCAT
      (
         '500: caught exception ', @ex_num, ': ', @ex_msg, ' ', 
          @msg01
         ,iif(@msg02 IS NOT NULL, CONCAT(' ', @msg02 ), '')
         ,iif(@msg03 IS NOT NULL, CONCAT(' ', @msg03 ), '')
         ,iif(@msg04 IS NOT NULL, CONCAT(' ', @msg04 ), '')
         ,iif(@msg05 IS NOT NULL, CONCAT(' ', @msg05 ), '')
         ,iif(@msg06 IS NOT NULL, CONCAT(' ', @msg06 ), '')
         ,iif(@msg07 IS NOT NULL, CONCAT(' ', @msg07 ), '')
         ,iif(@msg08 IS NOT NULL, CONCAT(' ', @msg08 ), '')
         ,iif(@msg09 IS NOT NULL, CONCAT(' ', @msg09 ), '')
         ,iif(@msg10 IS NOT NULL, CONCAT(' ', @msg10 ), '')
         ,iif(@msg11 IS NOT NULL, CONCAT(' ', @msg11 ), '')
         ,iif(@msg12 IS NOT NULL, CONCAT(' ', @msg12 ), '')
         ,iif(@msg13 IS NOT NULL, CONCAT(' ', @msg13 ), '')
         ,iif(@msg14 IS NOT NULL, CONCAT(' ', @msg14 ), '')
         ,iif(@msg15 IS NOT NULL, CONCAT(' ', @msg15 ), '')
         ,iif(@msg16 IS NOT NULL, CONCAT(' ', @msg16 ), '')
         ,iif(@msg17 IS NOT NULL, CONCAT(' ', @msg17 ), '')
         ,iif(@msg18 IS NOT NULL, CONCAT(' ', @msg18 ), '')
         ,iif(@msg19 IS NOT NULL, CONCAT(' ', @msg19 ), '')
      );

      SET @line = REPLICATE('*', dbo.fnMin(300, dbo.fnLen(@msg)+46));

      PRINT CONCAT(@nl, @line);
      EXEC sp_log 4, @fnThis, @fnHdr, @msg;
      PRINT CONCAT(@line, @nl);
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fnThis, '590: failed. exception was: ', @ex_num, ': ', @ex_msg;
      SET @ex_num = ERROR_NUMBER();
      SET @ex_msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fnThis,  '580: sp_log failed, exception: ',@ex_num, ': @ex_msg';
      SET @ex_msg ='*** system error: failed to get error msg ***';
   END CATCH
END




GO
GO

CREATE TYPE [dbo].[IdNmTbl] AS TABLE(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[val] [varchar](4000) NULL,
	PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================
-- Author:      Terry Watts
-- Create date: 16-JUN-2025
-- Description: checks if a word is a reserved word
--
-- Design:      Deepseek
-- Tests:       test.test_071_IsReservedWord
-- ==================================================================
CREATE FUNCTION [dbo].[IsReservedWord](@word NVARCHAR(128))
RETURNS BIT
AS
BEGIN
    DECLARE @isReserved BIT = 0;
    -- We do UPPER incase we're working in a SQL 
    SET @word = UPPER(LTRIM(RTRIM(@word)));

    SET @isReserved = 
      CASE 
         WHEN @word IN
(
  'ABS', 'ADD', 'ALL', 'ALTER', 'AND', 'ANY', 'AS', 'ASC', 'AUTHORIZATION'
, 'BACKUP', 'BEGIN', 'BETWEEN', 'BIY', 'BREAK', 'BROWSE', 'BULK', 'BY'
, 'CASCADE', 'CASE', 'CAST', 'CHAR', 'CHARINDEX', 'CHAR_LENGTH', 'CHECK', 'CHECKPOINT'
, 'CEILING', 'CLOSE', 'CLUSTERED'
, 'COALESCE', 'COLLATE', 'COL_LENGTH', 'COL_NAME', 'COLUMN', 'COMMIT', 'COMPUTE', 'CONSTRAINT'
, 'CONTAINS', 'CONTAINSTABLE', 'CONTINUE', 'CONVERT', 'CREATE'
, 'CROSS', 'CURRENT', 'CURRENT_DATE', 'CURRENT_TIME'
, 'CURRENT_TIMESTAMP', 'CURRENT_USER', 'CURSOR', 'DATABASE', 'DBCC'
, 'DEALLOCATE', 'DECLARE', 'DEFAULT', 'DELETE', 'DENY', 'DESC'
, 'DISK', 'DISTINCT', 'DISTRIBUTED', 'DOUBLE', 'DROP', 'DUMMY'
, 'DUMP', 'ELSE', 'END', 'ERRLVL', 'ESCAPE', 'EXCEPT', 'EXEC'
, 'EXECUTE', 'EXISTS', 'EXIT'
 , 'FETCH', 'FILE', 'FILLFACTOR', 'FLOAT', 'FOR'
, 'FOREIGN', 'FREETEXT', 'FREETEXTTABLE', 'FROM', 'FULL', 'FUNCTION'
, 'GOTO', 'GRANT', 'GROUP', 'HAVING', 'HOLDLOCK', 'IDENTITY'
, 'IDENTITY_INSERT', 'IDENTITYCOL', 'IF', 'IN', 'INDEX', 'INNER'
, 'INSERT', 'INT','INTERSECT', 'INTO', 'IS', 'JOIN', 'KEY', 'KILL', 'LEFT'
, 'LIKE', 'LINENO', 'LOAD', 'NATIONAL', 'NOCHECK', 'NONCLUSTERED'
, 'NOT', 'NULL', 'NULLIF', 'OF', 'OFF', 'OFFSETS', 'ON', 'OPEN'
, 'OPENDATASOURCE', 'OPENQUERY', 'OPENROWSET', 'OPENXML', 'OPTION'
, 'OR', 'ORDER', 'OUTER', 'OVER', 'PERCENT', 'PLAN', 'PRECISION'
, 'PRIMARY', 'PRINT', 'PROC', 'PROCEDURE', 'PUBLIC', 'RAISERROR'
, 'READ', 'READTEXT', 'RECONFIGURE', 'REFERENCES', 'REPLICATION'
, 'RESTORE', 'RESTRICT', 'RETURN', 'REVOKE', 'RIGHT', 'ROLLBACK'
, 'ROWCOUNT', 'ROWGUIDCOL', 'RULE', 'SAVE', 'SCHEMA', 'SELECT'
, 'SESSION_USER', 'SET', 'SETUSER', 'SHUTDOWN', 'SOME', 'STATISTICS'
, 'SYSTEM_USER', 'TABLE', 'TEXTSIZE', 'THEN', 'TO', 'TOP', 'TRANSACTION'
, 'TRIGGER', 'TRUNCATE', 'TSEQUAL', 'UNION', 'UNIQUE', 'UPDATE'
, 'UPDATETEXT', 'USE', 'USER', 'VALUES', 'VARYING', 'VIEW'
, 'WAITFOR', 'WHEN', 'WHERE', 'WHILE', 'WITH', 'WRITETEXT'
)
      THEN 1
      ELSE 0
   END
    RETURN @isReserved;
END
/*
EXEC test.test_071_IsReservedWord;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================
-- Author:      Terry Watts
-- Create date: 16-JUN-2025
-- Description: delimits identifier  if necessary
-- Design:      
-- Tests:       
-- ===============================================
CREATE FUNCTION [dbo].[fnDeLimitIdentifier](@q_id VARCHAR(120))
RETURNS VARCHAR(120)
AS
BEGIN
   DECLARE @v VARCHAR(120)
   DECLARE @vals IdNmTbl
   INSERT INTO @vals (val) select value from string_split(@q_id, '.');
   UPDATE @vals SET val = iif((dbo.IsReservedWord(val)=1 OR CHARINDEX(' ', val)>0), CONCAT('[', val, ']'), val)

   SELECT @v = string_agg(val, '.') FROM @vals;
   RETURN @v;
END
/*
EXEC tSQLt.Run 'test.test_073_fnDeLimitIdentifier';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================
-- Author:      Terry Watts
-- Create date: 16-JUN-2025
-- Description: Drops a table if it exists
-- Design:      
-- Tests:       
--
-- PRECONDITIONS:
-- PRE 01 @tbl_nm must be specified NOT NULL or EMPTY Checked
--
-- POSTCONDITIONS:
-- POST01: table does not exist
-- ==============================================================
CREATE PROCEDURE [dbo].[sp_drop_table]
    @q_table_nm        VARCHAR(80)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
     @fn          VARCHAR(35) = 'sp_drop_table'
    ,@sql         NVARCHAR(MAX)
    ,@ret         INT
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000 dropping table [', @q_table_nm, ']';

      -----------------------------------------------------------------
      -- Validation
      -----------------------------------------------------------------
      -- PRE 01 @fk_nm NOT NULL or EMPTY  Checked
      EXEC sp_log 1, @fn, '010 validating checked preconditions';
      SET @q_table_nm = dbo.fnDeLimitIdentifier(@q_table_nm);
      EXEC sp_assert_not_null_or_empty @q_table_nm, '@q_table_nm must be specified', @fn=@fn;

      -- delimit [ brkt name if necessary
      SET @q_table_nm = dbo.fnDeLimitIdentifier(@q_table_nm);
      -- chk if the table existed initially
      SET @ret = dbo.fnTableExists(@q_table_nm);

      SET @sql = CONCAT('DROP table if exists ', @q_table_nm);
      EXEC sp_log 1, @fn, '030 executing the drop Table SQL:
',@sql;

      EXEC (@sql);

      EXEC sp_log 1, @fn, '040 checking postconditions'
      ---------------------------------------------------------
      --- ASSERTION: POST01: table does not exist
      ---------------------------------------------------------
      EXEC sp_assert_tbl_exists @q_table_nm, 0;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: successfully dropped table ', @q_table_nm;
   return @ret; -- table did exist
END
/*
EXEC test.sp__crt_tst_rtns '[dbo].[sp_drop_table]';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ======================================================================
-- Author:      Terry Watts
-- Create Date: 06-AUG-2023
-- Description: Checks that the given table is populated    or not
-- Normal mode: this checks to see if the table has atleast 1 row
--
-- However it can be use to Checks that the given table is NOT populated
-- by setting @exp_cnt to 0
--
-- Called by sp_chk_tbl_not_pop
-- ======================================================================
CREATE PROCEDURE [dbo].[sp_assert_tbl_pop]
    @table           VARCHAR(60)
   ,@msg0            VARCHAR(MAX)   = NULL
   ,@msg1            VARCHAR(MAX)   = NULL
   ,@msg2            VARCHAR(MAX)   = NULL
   ,@msg3            VARCHAR(MAX)   = NULL
   ,@msg4            VARCHAR(MAX)   = NULL
   ,@msg5            VARCHAR(MAX)   = NULL
   ,@msg6            VARCHAR(MAX)   = NULL
   ,@msg7            VARCHAR(MAX)   = NULL
   ,@msg8            VARCHAR(MAX)   = NULL
   ,@msg9            VARCHAR(MAX)   = NULL
   ,@msg10           VARCHAR(MAX)   = NULL
   ,@msg11           VARCHAR(MAX)   = NULL
   ,@msg12           VARCHAR(MAX)   = NULL
   ,@msg13           VARCHAR(MAX)   = NULL
   ,@msg14           VARCHAR(MAX)   = NULL
   ,@msg15           VARCHAR(MAX)   = NULL
   ,@msg16           VARCHAR(MAX)   = NULL
   ,@msg17           VARCHAR(MAX)   = NULL
   ,@msg18           VARCHAR(MAX)   = NULL
   ,@display_msgs    BIT            = 0
   ,@exp_cnt         INT            = NULL
   ,@ex_num          INT            = 56687
   ,@ex_msg          VARCHAR(500)   = NULL
   ,@fn              VARCHAR(35)    = N'*'
   ,@log_level       INT            = 0
   ,@display_row_cnt BIT            = 1
AS
BEGIN
   DECLARE 
    @fnThis          VARCHAR(35)   = N'sp_assert_tbl_pop'
   ,@sql             NVARCHAR(MAX)
   ,@act_cnt         INT           = -1
   ,@schema_nm       VARCHAR(50)
   ;

   SET NOCOUNT ON;

   SELECT 
       @table     = rtn_nm 
      ,@schema_nm = schema_nm
   FROM dbo.fnSplitQualifiedName(@table)
   ;

   SET @sql = CONCAT('SELECT @act_cnt = COUNT(*) FROM [', @schema_nm, '].[', @table, ']');
   EXEC sp_executesql @sql, N'@act_cnt INT OUT', @act_cnt OUT

   IF @display_row_cnt = 1
   BEGIN
      EXEC sp_log 1, @fnThis, @msg0, 'table:[', @table, '] has ', @act_cnt, ' rows';
   END

   IF @exp_cnt IS NOT null
   BEGIN
      IF @exp_cnt <> @act_cnt
      BEGIN
         IF @ex_msg IS NULL
            SET @ex_msg = CONCAT('Table: ', @table, ' row count: exp ',@exp_cnt,'  act:', @act_cnt);

         EXEC sp_log 4, @fnThis ,'040: @exp_cnt (', @exp_cnt, ')<> @act_cnt (', @act_cnt, ') raising exception: ',@ex_msg;
       --EXEC sp_raise_exception @ex_num, @ex_msg, 1, @fn=@fn;
         EXEC sp_raise_exception
             @ex_num = @ex_num
            ,@msg0   = @ex_msg
            ,@msg1   = @msg0
            ,@msg2   = @msg1
            ,@msg3   = @msg2
            ,@msg4   = @msg3
            ,@msg5   = @msg4
            ,@msg6   = @msg5
            ,@msg7   = @msg6
            ,@msg8   = @msg7
            ,@msg9   = @msg8
            ,@msg10  = @msg9
            ,@msg11  = @msg10
            ,@msg12  = @msg11
            ,@msg13  = @msg12
            ,@msg14  = @msg13
            ,@msg15  = @msg14
            ,@msg16  = @msg15
            ,@msg17  = @msg16
            ,@msg18  = @msg17
            ,@msg19  = @msg18
            ,@fn     = @fn
            ;
      END
   END
   ELSE
   BEGIN -- Check at least 1 row
      IF @act_cnt = 0
      BEGIN
         IF @ex_msg IS NULL
            SET @ex_msg = CONCAT('Table: ', @table, ' does not have any rows');

         EXEC sp_log 4, '070: table ',@table,' has no rows: ', @ex_msg;
         THROW @ex_num, @ex_msg, 1;
      END
   END
END
/*
   -- This should not create an exception as dummytable has rows
   EXEC dbo.sp_assert_tbl_po 'use'
   EXEC dbo.sp_assert_tbl_po 'dummytable'
   
   -- This should create the following exception:
   -- Msg 56687, Level 16, State 1, Procedure dbo.sp_assert_tbl_po, Line 27 [Batch Start Line 37]
   -- Table: [AppLog] does not have any rows
    
   EXEC dbo.sp_assert_tbl_po 'AppLog'
   IF EXISTS (SELECT 1 FROM [dummytable]) PRINT '1' ELSE PRINT '0'
*/


GO
GO

CREATE TYPE [dbo].[ChkFldsNotNullDataType] AS TABLE(
	[ordinal] [int] NOT NULL,
	[col] [varchar](120) NOT NULL,
	[sql] [varchar](4000) NOT NULL
)

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--================================================================================================
-- Author:        Terry Watts
-- Create date:   15-Nov-2024
-- Description:   check there are no NULL entries supplied columns
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01: returns 0 and no inccurrences in any of the specified fields in the specified table 
-- OR throws exception 56321, msg: 'mandatory field:['<@table?'].'<field> has Null value
--================================================================================================
CREATE PROCEDURE [dbo].[sp_chk_flds_not_null]
    @table            VARCHAR(60)
   ,@non_null_flds    VARCHAR(MAX) = NULL
   ,@display_results  BIT           = 0
   ,@msg              VARCHAR(100) = ''
AS
BEGIN
   DECLARE
    @fn           VARCHAR(35)   = N'sp_chk_flds_not_null'
   ,@max_len_fld  INT
   ,@col          VARCHAR(32)
--   ,@msg          VARCHAR(200)
   ,@sql          NVARCHAR(MAX)
   ,@ndx          INT = 1
   ,@end          INT
   ,@nl           NCHAR(2) = NCHAR(13) + NCHAR(10)
   ,@flds         ChkFldsNotNullDataType
    ;

   EXEC sp_log 1, @fn, '000: starting:
table           :[', @table          , ']
non_null_flds   :[', @non_null_flds  , ']
display_results :[', @display_results, ']'
   ;

   IF @non_null_flds IS NULL
      RETURN;

   BEGIN TRY
      SET @sql = CONCAT('SELECT @max_len_fld = MAX(dbo.fnLen(column_name)) FROM list_table_columns_vw WHERE table_name = ''', @table, ''';');
      EXEC sp_log 0, @fn, '010: getting max field len: @sql:', @sql;
      EXEC sp_executesql @sql, N'@max_len_fld INT OUT', @max_len_fld OUT;
      EXEC sp_log 1, @fn, '020: @max_len_fld: ', @max_len_fld;

      ----------------------------------------------------------------
      -- Create script to run non null chks on a set of fields
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: Creating script to run non null chks on a set of fields';
      INSERT INTO @flds (ordinal, col, sql) 
      SELECT
          ordinal
         ,value
         ,CONCAT
         (
            'IF EXISTS (SELECT 1 FROM ['
            , @table,'] WHERE ',CONCAT('[',value,']'), ' IS NULL) EXEC sp_raise_exception 56321, ''mandatory field:['
            , @table,'].',CONCAT('[',value,'] has Null value'';')
         ) as sql
         FROM
         (
            SELECT ordinal, TRIM(dbo.fnDeSquareBracket(value)) as value FROM string_split( @non_null_flds, ',', 1)
         ) X

      IF @display_results = 1 SELECT * FROM @flds;
      --THROW 51000, 'debug',20;

      ----------------------------------------------------------------
      -- Execute script: run non null chks on each required field
      ----------------------------------------------------------------
      SELECT @end = COUNT(*) FROM @flds;

      WHILE @ndx < = @end
      BEGIN
         SELECT 
             @sql = sql
            ,@col = col
         FROM @flds
         WHERE ordinal = @ndx;

         --SET @msg = CONCAT('040: checking col: ', dbo.fnPadRight( CONCAT( '[', @col, ']'), @max_len_fld +1), ' has no NULL values');
         --SET @msg = CONCAT('050: check sql: ', @sql);
         --EXEC sp_log 1, @fn, @msg;
         EXEC (@sql);
         SET @ndx = @ndx + 1
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, 'table: ', @table, ' col ', @col,'has a null value. ', @msg;
      SELECT * FROM @flds;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: there are no null values in the checked columns';
END
/*
EXEC tSQLt.Run 'test.test_030_sp_chk_flds_not_null';
SELECT * FROM @flds
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry Watts
-- Create date: 30-MAR-2020
-- Description: returns true if the file exists, false otherwise
-- ===============================================================
CREATE FUNCTION [dbo].[fnFileExists](@path varchar(512))
RETURNS BIT
AS
BEGIN
     DECLARE @result INT
     EXEC master.dbo.xp_fileexist @path, @result OUTPUT
     RETURN cast(@result as bit)
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =============================================
-- Author:      Terry watts
-- Create date: 30-MAR-2020
-- Description: assert the given file exists or throws exception @ex_num* 'the file[<@file>] does not exist', @state
-- * if @ex_num default: 53200, state=1
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_file_exists]
    @file      VARCHAR(500)
   ,@msg1      VARCHAR(200)   = NULL
   ,@msg2      VARCHAR(200)   = NULL
   ,@msg3      VARCHAR(200)   = NULL
   ,@msg4      VARCHAR(200)   = NULL
   ,@msg5      VARCHAR(200)   = NULL
   ,@msg6      VARCHAR(200)   = NULL
   ,@msg7      VARCHAR(200)   = NULL
   ,@msg8      VARCHAR(200)   = NULL
   ,@msg9      VARCHAR(200)   = NULL
   ,@msg10     VARCHAR(200)   = NULL
   ,@msg11     VARCHAR(200)   = NULL
   ,@msg12     VARCHAR(200)   = NULL
   ,@msg13     VARCHAR(200)   = NULL
   ,@msg14     VARCHAR(200)   = NULL
   ,@msg15     VARCHAR(200)   = NULL
   ,@msg16     VARCHAR(200)   = NULL
   ,@msg17     VARCHAR(200)   = NULL
   ,@msg18     VARCHAR(200)   = NULL
   ,@msg19     VARCHAR(200)   = NULL
   ,@ex_num    INT             = 53200
   ,@fn        VARCHAR(60)    = N'*'
   ,@log_level INT            = 0
AS
BEGIN
   DECLARE
       @fn_       VARCHAR(35)   = N'ASSERT_FILE_EXISTS'
      ,@msg       VARCHAR(MAX)

   EXEC sp_log @log_level, @fn_, '000: checking file [', @file, '] exists';

   IF dbo.fnFileExists( @file) = 1
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fn, '010: OK,File [',@file,'] exists';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   SET @msg = CONCAT('File [',@file,'] does not exist');
   EXEC sp_log 3, @fn, '020:', @msg, ' raising exception';

   EXEC sp_raise_exception
       @ex_num = @ex_num
      ,@msg1   = @msg
      ,@msg2   = @msg1
      ,@msg3   = @msg2 
      ,@msg4   = @msg3 
      ,@msg5   = @msg4 
      ,@msg6   = @msg5 
      ,@msg7   = @msg6 
      ,@msg8   = @msg7 
      ,@msg9   = @msg8 
      ,@msg10  = @msg9 
      ,@msg11  = @msg10
      ,@msg12  = @msg11
      ,@msg13  = @msg12
      ,@msg14  = @msg13
      ,@msg15  = @msg14
      ,@msg16  = @msg15
      ,@msg17  = @msg16
      ,@msg18  = @msg17
      ,@msg19  = @msg18
      ,@fn     = @fn
   ;
END
/*
EXEC sp_assert_file_exists 'non existant file', ' second msg',@fn='test fn', @state=5  -- expect ex: 53200, 'the file [non existant file] does not exist', ' extra detail: none', @state=1, @fn='test fn';
EXEC sp_assert_file_exists 'C:\bin\grep.exe'   -- expect OK
*/




GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ===========================================================
-- Author:      Terry watts
-- Create date: 20-SEP-2024
-- Description: Deletes the file on disk
--
-- Postconditions:
-- POST 01 raise exception if failed to delete the file
-- ===========================================================
CREATE PROCEDURE [dbo].[sp_delete_file]
    @file_path    VARCHAR(500)   = NULL
   ,@chk_exists   BIT = 0 -- chk exists in the first place
   ,@fn           VARCHAR(35)    = N'*'
AS
BEGIN
   DECLARE
    @fnThis       VARCHAR(35)   = N'SP DELETE_FILE'
   ,@cmd          VARCHAR(MAX)
   ,@msg          VARCHAR(1000)
   ;

   EXEC sp_log 1, @fnThis,'000: starting, deleting file:[',@file_path,']';
   DROP TABLE IF EXISTS #tmp;
   CREATE table #tmp (id INT identity(1,1), [output] NVARCHAR(4000))

   IF (dbo.fnFileExists(@file_path) <> 0)
   BEGIN
      --SET @cmd = CONCAT('INSERT INTO #tmp  EXEC xp_cmdshell ''del "', @file_path, '"'' ,NO_OUTPUT');
      SET @cmd = CONCAT('INSERT INTO #tmp  EXEC xp_cmdshell '' del "', @file_path, '"''');
      --PRINT @cmd;
      EXEC sp_log 1, @fnThis,'010: sql:[',@cmd,']';
      EXEC (@cmd);

      --IF EXISTS (SELECT TOP 2 1 FROM #tmp) SELECT * FROM #tmp;
   END
   ELSE -- file does not exist
      IF (@chk_exists = 1) -- POST 01 raise exception if failed to delete the file
         EXEC sp_raise_exception 58147, ' 020: file [',@file_path,'] does not exist but chk_exists specified', @fn=@fnThis;

   IF dbo.fnFileExists(@file_path) <> 0
   BEGIN
      IF EXISTS (SELECT TOP 2 1 FROM #tmp)
         SELECT @msg = [output] FROM #tmp where id = 1;

      EXEC sp_raise_exception 63500, '030: failed to delete file [', @file_path, '], reason: ',@msg, @fn=@fnThis;
   END

   EXEC sp_log 0, @fnThis,'999: leaving';
END
/*
EXEC sp_delete_file 'D:\Logs\a.txt';
EXEC sp_delete_file 'non exist file';
EXEC sp_delete_file 'D:\Logs\Farming.log';

EXEC xp_cmdshell 'del "D:\Logs\Farming.log"'


*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author     : Terry Watts
-- Create date: 12-APR-2025
-- Description: removes double quotes an Line feeds from data
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:     EA
-- Tests:      test_018_fnCrtRemoveDoubleQuotesSql
--             test_037_sp_import_txt_file
-- ============================================================
CREATE FUNCTION [dbo].[fnCrtRemoveDoubleQuotesSql]
(
    @table              VARCHAR(60)
   ,@max_len_fld        INT
)
RETURNS VARCHAR(8000)

AS
BEGIN
   DECLARE
    @fn                 VARCHAR(35)       = N'sp_import_txt_file'
   ,@table_no_brkts     VARCHAR(60)
   ,@nl                 CHAR(2)           = CHAR(13)+CHAR(10)
   ,@sql                VARCHAR(8000)
   ,@empty_str          VARCHAR(2)=''''
   ,@double_quote       VARCHAR(5)='"'
   ;

   SET @table_no_brkts = REPLACE(REPLACE(@table, '[',''),  ']','');

   --    SELECT dbo.fnPadRight(CONCAT(''['', column_name, '']''), ', @max_len_fld+2, ') AS column_name

SET @sql = CONCAT
(
'DECLARE
    @nl             CHAR(2) = CHAR(13)+CHAR(10)
   ,@Lf             CHAR(1) = CHAR(10)
   ,@empty_str      VARCHAR(1)=''''
   ,@double_quote   VARCHAR(1)=''"''
   ,@sql            VARCHAR(8000)
;

WITH cte AS
(
   SELECT CONCAT(''['', column_name, '']'') AS column_name
      ,ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION) AS row_num
      ,ordinal_position
      ,DATA_TYPE
      ,is_txt
   FROM list_table_columns_vw
   WHERE table_name = ''',@table_no_brkts, ''' AND is_txt = 1
)
,cte2 AS
(
   SELECT ''UPDATE ',@table,' SET '' AS sql
   UNION ALL
   SELECT
      CONCAT
      (  iif(row_num=1, '' '','','')
        ,column_name, '' = 
        TRIM(REPLACE(REPLACE('',column_name',','',CHAR(34),''',@empty_str,''''')
        ,CHAR(10),''',@empty_str,'''''
            )
         )''
      )
   FROM cte
   UNION ALL
   SELECT ''FROM ',@table,';''
)
SELECT @sql = 
string_agg(sql, ''', @NL, ''')
FROM cte2;'
);

   RETURN @sql;
END
/*
EXEC tSQLt.Run 'test.test_018_fnCrtRemoveDoubleQuotesSql';
EXEC tSQLt.Run 'test.test_037_sp_import_txt_file';
------------------------------------------------
DECLARE @sql VARCHAR(8000)
SELECT @sql = dbo.fnCrtRemoveDoubleQuotesSql('[User]', 12);
PRINT @sql
------------------------------------------------
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================================================================
-- Author:      Terry Watts
-- Create date: 20-OCT-2024
-- Description: Imports a txt file into @table
-- Returns the count of rows imported
-- Design: EA?
-- Responsibilities:
-- R00: delete the log files beefore importing if they exist
-- R01: Import the table from the tsv file
-- R02: Remove double quotes
-- R03: Trim leading/trailing whitespace
-- R04: Remove in-field line feeds
-- R05: check the list of @non_null_flds fields do not have any nulls - if @non_null_flds supplied
--
-- Tests: test_037_sp_import_txt_file
--
-- Preconditions:
-- PRE01: File must be specified: chkd
-- PRE02: Filpath must exist : chkd
--
-- Postconditions:
-- POST01 ret: the count of rows imported
--
-- Changes:
-- 20-OCT-2024: increased @spreadsheet_file parameter len from 60 to 500 as the file path was being truncated
-- 31-OCT-2024: cleans each imported text field for double quotes and leading/trailing white space
-- 05-NOV-2024: optionally display imported table: sometimes we need to do more fixup before data is ready
--              so when this is the case then dont display the table here, but do post import fixup in the 
--              calling sp first and then display the table
-- 11-NOV-2024: added an optional view to control field mapping
-- 06-APR-2025  @table may be qualified with the schema - sort out bracketing
-- =============================================================================================================
CREATE PROCEDURE [dbo].[sp_import_txt_file]
    @table            VARCHAR(60)
   ,@file             VARCHAR(500)
   ,@folder           VARCHAR(600)  = NULL
   ,@field_terminator VARCHAR(4)    = NULL -- tab 0x09
   ,@row_terminator   VARCHAR(10)   = NULL -- '0x0d0a'
   ,@codepage         INT           = 65001 -- Claude: Note that if your text file has a BOM (Byte Order Mark), SQL Server should automatically detect it when using codepage 65001.
   ,@first_row        INT           = 2
   ,@last_row         INT           = NULL
   ,@clr_first        BIT           = 1
   ,@view             VARCHAR(120)  = NULL
   ,@format_file      VARCHAR(500)  = NULL
   ,@expect_rows      BIT           = 1
   ,@exp_row_cnt      INT           = NULL
   ,@non_null_flds    VARCHAR(1000) = NULL
   ,@display_table    BIT           = 0
AS
BEGIN
   DECLARE
    @fn                 VARCHAR(35)       = N'sp_import_txt_file'
   ,@cmd                NVARCHAR(MAX)
   ,@sql                VARCHAR(MAX)
   ,@CR                 CHAR(1)           = CHAR(13)
   ,@LF                 CHAR(2)           = CHAR(10)
   ,@NL                 CHAR(2)           = CHAR(13)+CHAR(10)
   ,@line_feed          CHAR(1)           = CHAR(10)
   ,@bkslsh             CHAR(1)           = CHAR(92)
   ,@tab                CHAR(1)           = CHAR(9)
   ,@max_len_fld        INT
   ,@del_file           VARCHAR(1000)
   ,@error_file         VARCHAR(1000)
   ,@ndx                INT = 1
   ,@end                INT
   ,@line               VARCHAR(128) = REPLICATE('-', 100)
   ,@file_path          VARCHAR(600)
   ,@row_cnt            INT
   ,@schema_nm          VARCHAR(28)
   ,@table_nm           VARCHAR(40)
   ,@table_nm_no_brkts  VARCHAR(40)
   ,@ex_num             INT
   ,@ex_msg             INT
   ;

   --SET @row_terminator_str = iif(@row_terminator='0x0d0a', '0x0d0a',@row_terminator);

   EXEC sp_log 1, @fn, '000: starting:
table           :[',@table             ,']
file            :[',@file              ,']
folder          :[',@folder            ,']
row_terminator  :[',@row_terminator    ,']
field_terminator:[',@field_terminator  ,']
first_row       :[',@first_row         ,']
last_row        :[',@last_row          ,']
clr_first       :[',@clr_first         ,']
view            :[',@view              ,']
format_file     :[',@format_file       ,']
expect_rows     :[',@expect_rows       ,']
exp_row_cnt     :[',@exp_row_cnt       ,']
non_null_flds   :[',@non_null_flds     ,']
display_table   :[',@display_table     ,']'
;

   BEGIN TRY
      ---------------------------------------------------
      -- Set defaults
      ---------------------------------------------------
      IF @field_terminator IS NULL SET @field_terminator = @tab;
      IF @field_terminator IN (0x09, '0x09', '\t') SET @field_terminator = @tab;

      --IF @field_terminator NOT IN ( @tab,',',@CR, @LF, @NL)
      --   EXEC sp_raise_exception 53051, @fn, '005: error: field terminator must be one of comma, tab, NL';

      IF @row_terminator   IS NULL OR @row_terminator='' SET @row_terminator = @nl;

      ---------------------------------------------------
      -- Validate parameters
      ---------------------------------------------------
      EXEC sp_log 1, @fn, '010: Validate parameters';

      -- PRE01: File must be specified
      EXEC sp_assert_not_null_or_empty @file, 50001, 'File must be specified';
      ---------------------------------------------------
      -- Set defaults
      ---------------------------------------------------
      EXEC sp_log 1, @fn, '020: Set defaults';

      IF @codepage IS NULL SET @codepage = 1252;

      SET @file_path = iif( @folder IS NOT NULL,  CONCAT(@folder, @bkslsh, @file), @file);

      -- sort out double \\
      SET @file_path = REPLACE(@file_path, @bkslsh+@bkslsh, @bkslsh);

      -- ASSERTION 

      -- 06-APR-2025  @table may be qualified with the schema - sort out bracketing
      SET @ndx = CHARINDEX('.', @table);

      IF @ndx>0
      BEGIN
         SELECT
             @schema_nm = schema_nm
            ,@table_nm  = rtn_nm
         FROM dbo.fnSplitQualifiedName(@table);

         SET @table = CONCAT('[',@schema_nm,'].[',@table_nm, ']');
      END
      ELSE
      BEGIN
         SET @table = CONCAT('[',@table, ']');
      END

      SET @table_nm_no_brkts = REPLACE(REPLACE(@table, '[', ''),']', '');
      EXEC sp_log 1, @fn, '030: table:',@table, ' @table_nm_no_brkts: ', @table_nm_no_brkts;

      ---------------------------------------------------
      -- Validate inputs
      ---------------------------------------------------
      EXEC sp_log 1, @fn, '040: validating inputs, @file_path: [',@file_path,']';

      -- PRE02: Filpath must exist : chkd
      EXEC sp_assert_file_exists @file_path
      -------------------------------------------------------------
      -- ASSERTION: @table is now like [table] or [schema].[table]
      -------------------------------------------------------------

      IF @table IS NULL OR @table =''
         EXEC sp_raise_exception 53050, @fn, '050: error: table must be specified';

      IF @first_row IS NULL OR @first_row < 1
         SET @first_row = 2;

      IF @last_row IS NULL OR @last_row < 1
         SET @last_row = 1000000;

      -- View is optional - defaults to the table stru
      IF @view IS NULL
         SET @view = @table;

      IF @clr_first = 1
      BEGIN
         SET @cmd = CONCAT('TRUNCATE TABLE ', @table,';');
         EXEC sp_log 1, @fn, '060: clearing table first: EXEC SQL:',@NL, @cmd;

         EXEC (@cmd);
      END

      ----------------------------------------------------------------------------------
      -- R00: delete the log files before importing if they exist
      ----------------------------------------------------------------------------------

      SET @error_file = CONCAT('D:',NCHAR(92),'logs',NCHAR(92),@table_nm_no_brkts,'import.log');
      SET @del_file = @error_file;
      EXEC sp_log 1, @fn, '070: deleting log file ', @del_file;
      EXEC sp_delete_file @del_file;
      SET @del_file = CONCAT(@del_file, '.Error.Txt');
      EXEC sp_log 1, @fn, '080: deleting log file ',@del_file;
      EXEC sp_delete_file @del_file;

      ----------------------------------------------------------------------------------
      -- R01: Import the table from the tsv file
      ----------------------------------------------------------------------------------

      SET @cmd = 
         CONCAT('BULK INSERT ',@view,' FROM ''',@file_path,''' 
WITH
(
    DATAFILETYPE    = ''Char''
   ,FIRSTROW        = ',@first_row, @nl
);

      IF @last_row         IS NOT NULL 
      BEGIN
         EXEC sp_log 1, @fn, '090: @last_row is not null, =[',@last_row, ']';
         SET @cmd = CONCAT( @cmd, '   ,LASTROW        =   ', @last_row        , @nl);
      END

      IF @format_file      IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '100: @last_row is not null, =[',@last_row, ']';
         SET @cmd = CONCAT( @cmd, '   ,FORMATFILE     = ''', @format_file, '''', @nl);
      END

      IF @field_terminator IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '110: @field_terminator is not null, =[',@field_terminator, ']';
         If @field_terminator = 't' SET @field_terminator = '\t';
         SET @cmd = CONCAT( @cmd, '   ,FIELDTERMINATOR= ''', @field_terminator, '''', @nl);
      END

      if @row_terminator IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '120: @row_terminator is not null, =[',@row_terminator, ']';
         SET @cmd = CONCAT( @cmd, '   ,ROWTERMINATOR= ''', @row_terminator, '''', @nl);
      END

      SET @cmd = CONCAT( @cmd, '  ,ERRORFILE      = ''',@error_file,'''', @nl
         ,'  ,MAXERRORS      = 20', @nl
         ,'  ,CODEPAGE       = ',@codepage, @nl
         ,');'
      );

      PRINT CONCAT( @nl, @line);
      EXEC sp_log 1, @fn, '130: importing file: SQL: 
', @cmd;

      PRINT CONCAT( @line, @nl);

      EXEC (@cmd);
      SET @row_cnt = @@ROWCOUNT;

      EXEC sp_log 1, @fn, '140: imported ', @row_cnt, ' rows';

      ----------------------------------------------------------------------------------------------------
      -- 05-NOV-2024: optionally display imported table
      ----------------------------------------------------------------------------------------------------
      IF @display_table = 1
      BEGIN
         EXEC sp_log 1, @fn, '150: displaying table: ', @table;
         SET @cmd = CONCAT('SELECT * FROM ', @table,';');
         EXEC (@cmd);
      END

      IF @expect_rows = 1
      BEGIN
         EXEC sp_log 1, @fn, '160: checking resulting row count';
         EXEC sp_assert_tbl_pop @table;
      END

      IF  @exp_row_cnt IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '170: checking resulting row count';
         EXEC sp_assert_tbl_pop @table, @exp_cnt = @exp_row_cnt;
      END

      ----------------------------------------------------------------------------------------------------
      -- 31-OCT-2024: cleans each imported text field for double quotes and leading/trailing white space
      ----------------------------------------------------------------------------------------------------
      SET @cmd = CONCAT('SELECT @max_len_fld = MAX(dbo.fnLen(column_name)) FROM list_table_columns_vw WHERE table_name = ''', @table, ''' AND is_txt = 1;');
      EXEC sp_log 1, @fn, '180: getting max field len: @cmd:', @cmd;
      EXEC sp_executesql @cmd, N'@max_len_fld INT OUT', @max_len_fld OUT;
      EXEC sp_log 1, @fn, '190: @max_len_fld: '       , @max_len_fld;
      EXEC sp_log 1, @fn, '200: @table_nm_no_brkts: ' , @table_nm_no_brkts;
      EXEC sp_log 1, @fn, '210: @table            : ' , @table ;

      ----------------------------------------------------------------------------------
      -- R02: Remove double quotes
      -- R03: Trim leading/trailing whitespace
      -- R04: Remove line feeds
      ----------------------------------------------------------------------------------
      SET @sql = dbo.fnCrtRemoveDoubleQuotesSql( @table_nm_no_brkts, @max_len_fld);
      PRINT @sql;
      EXEC sp_log 1, @fn, '220: trim replacing double quotes, @sql:', @NL, @sql;
      EXEC (@sql);

     ----------------------------------------------------------------------------------------------------
      -- R05: check the list of @non_null_flds fields do not have any nulls - if @non_null_flds supplied
      ----------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '230: check mandatory fields for null values';
      EXEC sp_chk_flds_not_null @table_nm_no_brkts, @non_null_flds ;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;--, ' launching notepad++ to display the error files';
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ',@row_cnt,' rows from: ', @file_path;
   -- POST01 ret: the count of rows imported
   RETURN @row_cnt;
END
/*
EXEC test.test_037_sp_import_txt_file;
EXEC tSQLt.Run 'test.test_037_sp_import_txt_file';
EXEC sp_AppLog_display

EXEC tSQLt.RunAll;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 11-APR-2025
--
-- Description: splits a composoite string of 2 parts separated by a separator 
-- into a row containing the first part (a), and the second part (b)
--
--
-- Postconditions:
-- Post 01: if @composit contains sep then returns a 1 row table wher col a = first part 
--             and b  contains the second part when @composit is split using @sep
-- Changes:
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnSplitPair2]
(
    @composit VARCHAR(1000) -- qualified routine name
   ,@sep CHAR(1)
)
RETURNS @t TABLE
(
    a  VARCHAR(1000)
   ,b  VARCHAR(1000)
)
AS
BEGIN
   DECLARE
    @n   INT
   ,@a   VARCHAR(50)
   ,@b   VARCHAR(100)

   IF @composit IS NOT NULL AND @composit <> '' AND @sep IS NOT NULL AND @sep <> ''
   BEGIN
      SET @n = CHARINDEX(@sep, @composit);

      IF @n = 0
      BEGIN
         INSERT INTO @t(a) VALUES( @composit);
         RETURN;
      END

      SET @a = SUBSTRING( @composit, 1   , @n-1);
      SET @b = SUBSTRING( @composit, @n+1, dbo.fnLen(@composit)-@n+1);

      INSERT INTO @t(a, b) VALUES( @a, @b);
   END
   --ELSE INSERT INTO @t(a) VALUES( 'IF @composit: false');

   RETURN;
END
/*
SELECT a, b FROM dbo.fnSplitPair2('a.b', '.');
EXEC tSQLt.Run 'test.test_024_fnSplitPair2';
SELECT * FROM fnSplitQualifiedName('test.fnGetRtnNmBits')
SELECT * FROM fnSplitQualifiedName('a.b')
SELECT * FROM fnSplitQualifiedName('a.b.c')
SELECT * FROM fnSplitQualifiedName('a')
SELECT * FROM fnSplitQualifiedName(null)
SELECT * FROM fnSplitQualifiedName('')
EXEC test.sp__crt_tst_rtns 'dbo].[fnSplitPair2';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 17-JUN-2025
-- Description: generates the sql to check if every value 
--    in field @fld_nm of the table @q_table_nm
--    can be cast to the type @ty
-- Tests      : test_075_fnCrtFldNotNullSql
--
-- Postconditions: returns the check SQL for the given parameters
-- ===============================================================
CREATE FUNCTION [dbo].[fnCrtFldNotNullSql]
(
    @q_table_nm VARCHAR(60)
   ,@fld_nm     VARCHAR(40)
   ,@ty         VARCHAR(25)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
     DECLARE @sql NVARCHAR(4000)
     ;

     SET @sql =
     CONCAT
     (
'IF NOT EXISTS
(
   SELECT 1 FROM ',@q_table_nm,'
   WHERE TRY_CAST([',@fld_nm,'] AS ',@ty,') IS NULL
)
   SET @fld_ty = ''',@ty,'''
ELSE
   SET @fld_ty = NULL
;'
     );

     RETURN @sql;
END
/*
EXEC test.sp__crt_tst_rtns '[dbo].[fnCrtFldNotNullSql]'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FieldInfo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[nm] [varchar](50) NULL,
	[ty] [varchar](15) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JUN-2025
-- Description: infers the field types froma staging table
--    based on its data
--    pops the FieldInfo table
--
-- Design:      EA: Dorsu Model.Use Case Model.Create and populate a table from a data file.Infer the field types from the staged data
-- Tests:       test_074_sp_infer_field_types
--
-- Postconditions: POST01: pops the FieldInfo table
-- =============================================
CREATE PROCEDURE [dbo].[sp_infer_field_types]
   @q_table_nm VARCHAR(60)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn           VARCHAR(35)   = N'sp_infer_field_types'
      ,@sql          NVARCHAR(4000)
      ,@schema       VARCHAR(60)
      ,@table_nm     VARCHAR(60)
      ,@fld_ty       VARCHAR(25)
      ,@fld_id       INT
      ,@fld_nm       VARCHAR(50)
      ,@len          INT
  ;

   EXEC sp_log 1, @fn, '000: starting:
@q_table_nm:[',@q_table_nm,']
';

   BEGIN TRY
      SELECT
          @schema = a
         ,@table_nm = b
      FROM dbo.fnSplitPair2(@q_table_nm, '.');

      IF @table_nm IS NULL
      BEGIN
         EXEC sp_log 1, @fn, '005: schema not specified - defaulting to dbo';
         SELECT
             @table_nm = @schema
            ,@schema   = 'dbo'
         ;
      END

      EXEC sp_log 1, @fn, '010: starting:
   @schema:  [',@schema,']
   @table_nm:[',@table_nm,']
   ';

      -- Clear the field info table
      TRUNCATE TABLE FieldInfo;

      -- Get the field info for the table
      SET @sql = CONCAT('INSERT INTO FieldInfo(nm) SELECT COLUMN_NAME
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_NAME = '''  , @table_nm, '''
     AND TABLE_SCHEMA = ''', @schema, ''';'
     );

      EXEC sp_log 1, @fn, '020: @sql:
', @sql;

      EXEC (@sql);
      EXEC sp_log 1, @fn, '030:';
      --SELECT * FROM FieldInfo;

      -- For each field in the staged data
      DECLARE _cursor CURSOR FOR SELECT id, nm  FROM FieldInfo;
      OPEN _cursor;
      FETCH NEXT FROM _cursor INTO @fld_id, @fld_nm;
      EXEC sp_log 1, @fn, '035:';

      -- For each fields
      WHILE @@FETCH_STATUS = 0
      BEGIN
         EXEC sp_log 1, @fn, '040: @fld_id: ',@fld_id, ' @fld_nm[',@fld_nm,']';

         -- For each field type we are interested in:
         -- Chk if all data item in that field are:
         WHILE 1=1
         BEGIN
            SET @fld_ty = NULL;
            EXEC sp_log 1, @fn, '050: trying BIT';

            -- Bit?	Set field type = bit
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'BIT');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            -- Int?	Set field type = int
            EXEC sp_log 1, @fn, '060: trying INT';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'INT');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            EXEC sp_log 1, @fn, '070: trying REAL';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'REAL');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

         -- Floating point?	Set field type = double
            EXEC sp_log 1, @fn, '080: trying FLOAT';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'FLOAT');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            -- GUID ?	Set field type = GUID
            EXEC sp_log 1, @fn, '090: trying GUID';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'UNIQUEIDENTIFIER');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            -- Assume text field
            EXEC sp_log 1, @fn, '100: Assume text field';
            -- Set len = max len of the field
            SET @sql =
            CONCAT
            (
               'SELECT @len = MAX(dbo.fnLen(',@fld_nm,')) FROM 
            ', @q_table_nm, ';'
            )

            EXEC sp_log 1, @fn, '110:sql:
',@sql;
            EXEC sp_executesql @sql, N'@len INT OUT', @len OUT;
            EXEC sp_log 1, @fn, '120:@len:
',@len;
            SET @fld_ty = CONCAT('VARCHAR(', @len, ')')
            BREAK;
         END -- for each wanted field ty

         EXEC sp_log 1, @fn, '110: field ty is ',@fld_ty;
         -- Add the field info to the FieldInfo table
         UPDATE FieldInfo SET ty = @fld_ty WHERE id = @fld_id;
         FETCH NEXT FROM _cursor INTO @fld_id, @fld_nm;
      END -- outer while - for each row in FieldInfo

      CLOSE _cursor;
      DEALLOCATE _cursor;
      EXEC sp_log 1, @fn, '200: checking postconditions';

      -- Postconditions: POST01: pops the FieldInfo table
      EXEC sp_log 1, @fn, '210: checking POST01: pops the FieldInfo table';
      EXEC sp_assert_tbl_pop 'FieldInfo';
      EXEC sp_log 1, @fn, '299: completed processing loop';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';

      IF CURSOR_STATUS('global','_cursor')>=-1 
      BEGIN
         CLOSE _cursor;
         DEALLOCATE _cursor;
      END
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving ok';
END
/*
EXEC test.test_074_sp_infer_field_types;
SELECT * FROM FileActivityStaging

EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================
-- Author:      Terry Watts
-- Create date: 13-JUN-2025
--
-- Description: 
-- creates the SQL to create a table
-- based on the input string.
-- All fields are VARCHAR(MAX)
-- Delimits the qualified @tbl_nm if necessary
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    returns creat table SQL
--
-- Tests:
-- =============================================
CREATE FUNCTION [dbo].[fnCrtTblSql]
(
    @tbl_nm VARCHAR(60)
   ,@fields VARCHAR(8000))
RETURNS VARCHAR(8000)
AS
BEGIN
   DECLARE
       @sql      VARCHAR(8000)
      ,@joiner   VARCHAR(40)=' VARCHAR(8000)
   ,'
      ,@snippet  VARCHAR(400)
      ,@NL       CHAR(2)     = CHAR(13) + CHAR(10)
      ,@tab      CHAR        = CHAR(9)
      ,@sep      CHAR        = CHAR(9)
;

   SET @sep = IIF(CHARINDEX( @tab,@fields)>0, @tab, ',');

   -- split the fields and add them as VARCHAR(8000)
SELECT @snippet =string_agg(TRIM(value), @joiner)
FROM   STRING_SPLIT(@fields, @sep);

   SET @sql =
   CONCAT
   ('CREATE TABLE ', dbo.fnDelimitIdentifier(@tbl_nm),'
(
    '
, @snippet
, ' VARCHAR(8000)', @NL
,');'
);

   RETURN @sql;
END
/*
EXEC test.test_069_fnCrtTblSql;
PRINT dbo.fnCrtTblSql('TestTable','id, name,description, location');

EXEC tSQLt.Run 'test.test_069_fnCrtTblSql';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2025
-- Description: returns Last Index of a str in a str
-- or 0 if not found
--
-- Tests: test.test_065_fnFindLastIndexOf
-- ==================================================
CREATE FUNCTION [dbo].[fnFindLastIndexOf]
(
    @searchFor VARCHAR(MAX)
   ,@searchIn  VARCHAR(MAX)
)
RETURNS INT
AS
BEGIN
   IF @searchFor IS NULL OR @searchIn IS NULL
      RETURN 0;

   IF dbo.fnLen(@searchFor) = 0 OR dbo.fnLen(@searchIn) = 0
      RETURN 0;

   IF LEN(@searchfor) > LEN(@searchin)
      RETURN 0;

   DECLARE
       @r   VARCHAR(500)
      ,@rsp VARCHAR(100)
      ,@pos INT

   SELECT @r   = REVERSE(@searchin);
   SELECT @rsp = REVERSE(@searchfor);
   SET @pos = CHARINDEX(@rsp, @r);

   IF(@pos = 0)
      return 0;

   RETURN len(@searchin) - @pos - dbo.fnLen(@searchfor)+2;
END
/*
EXEC tSQLt.Run 'test.test_065_fnFindLastIndexOf';

EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GenericStaging](
	[staging] [varchar](8000) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_GenericStaging] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================================================
-- Author:      Terry Watts
-- Create date: 12-JUN-2025
-- Description: Create and populate a table from a data file
--
-- REQUIREMENTS:
-- R06.01: the table with the same name as the file is created:
-- R06.02: the table has the same column names as the column names in the file
-- R06.03: table is populated exactly from the rows and columns from the file
-- R06.04: if a column name contains spaces (any whitespace) then replace each sequence
--         of whitespace with a single underscore
--
-- Design:      EA: Dorsu .eap: Use Case Model.Create and populate a table from a data file
-- Define the import data file path
-- Table name = file name
-- Reads the header for the column names
-- if column names contain spaces (any whitespace) then replace it with a single undescore
-- Create a table with table name, columns = field names, type = text
-- Create a staging table 
-- Create a format file using BCP and the table
-- Generate the import routine using the table and the format file
--
-- Parameters:
--    @file_path     VARCHAR(500) -- the import data file path
-- Tests:       test_068_sp_crt_pop_table
--
-- Preconditions:
-- PRE01: @file_path populated
--
-- Postconditions:
-- POST01: main table has the same row cnt as the  staging
-- =====================================================================================
CREATE PROCEDURE [dbo].[sp_crt_pop_table]
    @file_path       VARCHAR(500) -- the import data file path
   ,@sep             VARCHAR(6)  = NULL
   ,@codepage        INT         = NULL
   ,@display_tables  BIT         = 0AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
       @fn           VARCHAR(35)   = N'sp_crt_pop_table'
      ,@fields       VARCHAR(8000)
      ,@file         VARCHAR(500)
      ,@folder       VARCHAR(500)= NULL
      ,@format_file  VARCHAR(500)= NULL
      ,@NL           CHAR = CHAR(13)
      ,@tab          CHAR = CHAR(9)
      ,@ndx          INT
      ,@table_nm     VARCHAR(50)
      ,@stg_table_nm VARCHAR(50)
      ,@row_cnt      INT
      ,@cmd          VARCHAR(8000)
      ,@sql          VARCHAR(8000)

   BEGIN TRY

      IF @codepage IS NULL
         SET @codepage = 65001;

      EXEC sp_log 1, @fn, '000: starting:
@file_path:       [',@file_path,']
@sep:             [',@sep,']
@codepage:        [',@codepage,']
@display_tables:  [',@display_tables,']
';

      ---------------------------------------------------------------
      -- Setup
      ---------------------------------------------------------------

      IF @sep IS NULL OR @sep IN('',0x09,'0x09', '\t') SET @sep = @tab; -- default
      SET @ndx = dbo.fnFindLastIndexOf('\', @file_path);
      -- Table name = file name less the extension
      SET @file   = SUBSTRING(@file_path, @ndx+1, dbo.fnLen(@file_path)-@ndx);
      SET @folder = iif(@ndx = 0, NULL, SUBSTRING(@file_path, 1, @ndx));
      SELECT @table_nm = a FROM dbo.fnSplitPair2(@file, '.');

      EXEC sp_log 1, @fn, '010:
@ndx:     [', @ndx     , ']
@file:    [', @file    , ']
@table_nm:[', @table_nm, ']
@folder:  [', @folder  , ']
';
      -- Table name = file name  less the extension
      -- Import the header into a single column generic text table
      -- Reads the header for the column names
      -- Read the header for the column names
         EXEC sp_log 1, @fn, '020: importing the file header for the column names';
         EXEC @row_cnt = sp_import_txt_file
             @table           = 'GenericStaging'
            ,@file            = @file
            ,@folder          = @folder
            ,@first_row       = 1
            ,@last_row        = 1
            ,@field_terminator= @NL
            ,@view            = 'ImportGenericStaging_vw'
            ,@codepage        = @codepage
            ,@display_table   = 1
         ;

      -- Create the staging table,  columns = field names, type = text
      -- Create a staging table
      SET @stg_table_nm = CONCAT(@table_nm, 'Staging');
      EXEC sp_drop_table @stg_table_nm;

      -- Create a table with table name, columns = field names, type = text
      EXEC sp_log 1, @fn, '030: creating the staging table, cmd: ', @NL, @cmd;
      SELECT @fields = staging FROM GenericStaging;
      EXEC sp_log 1, @fn, '040: @fields: ', @fields, ' @stg_table_nm: ',@stg_table_nm;

      SET @cmd = dbo.fnCrtTblSql(@stg_table_nm, @fields); -- delimits the qualified @stg_table_nm if necessary
      EXEC sp_log 1, @fn, '050: executing @cmd: ', @cmd;
      EXEC (@cmd);
      -- Bracket table name as necessary
      -- Bracket field names as necessary
      -- Create a format file using BCP and the table
      --SET @cmd = dbo.fnCrtTblSql(@table_nm, @fields);
      --EXEC sp_log 1, @fn, '060: creating the main table, sql: ', @NL, @cmd;
      --EXEC (@cmd);

   -- Create and populate the table from data file : Create and populate a table from a data file_ActivityGraph
   -- Infer the field types from the staged data
   -- Merge the staging table to the main table

      -- Create a format file using BCP and the table
      SET @format_file = CONCAT(@folder, '\',@table_nm,'_fmt.xml');
      --SET @cmd = CONCAT('bcp ',DB_NAME(),'.dbo.',@table_nm,' format nul -c -x -f ',@format_file, ' -t, -T');
      SET @cmd = 
         CONCAT
         (
            'bcp '
           ,DB_NAME()
           ,'.dbo.',@table_nm
           ,' format nul -c -x -f ',@format_file
           ,iif(@sep=@tab, '', ' -t, '),' -T'
         );

      EXEC sp_log 1, @fn, '060: creating format file: ', @NL, @cmd;
      EXEC xp_cmdshell @cmd;

      -- Import the staging table data
      -- Import staging table using the table and the format file
      EXEC sp_log 1, @fn, '070: importing ', @file_path, ' to staging: ', @stg_table_nm;

      EXEC @row_cnt = sp_import_txt_file
          @table            = @stg_table_nm
         ,@file             = @file_path
         ,@folder           = NULL
         ,@field_terminator = @sep
         ,@codepage         = @codepage
         ,@first_row        = 2
         ,@format_file      = @format_file
         ,@display_table    = @display_tables
      ;

      -- Infer the field types from the staged data
      EXEC sp_log 1, @fn, '080: Infer the field types from the staged data';

      -- Infer field types: pops the FieldInfo table
      EXEC sp_infer_field_types @stg_table_nm;
      EXEC sp_log 1, @fn, '090: Drop the main  if it exists';

      -- Drop table if it exists
      EXEC sp_drop_table @table_nm;

      -- Create the main table with table name, columns = field names, type = inferred type
      EXEC sp_log 1, @fn, '100: Create the main table with table name, columns = field names, type = inferred type';

      SELECT @sql = 
      CONCAT
      (
      'CREATE TABLE ', @table_nm, '
(
'
,STRING_AGG(CONCAT('   ', lower(nm), ' ', ty), ',
'
),'
);'
      )
      FROM FieldInfo
      ;

      EXEC sp_log 1, @fn, '110: Creating the main table, sql:
', @sql;

      EXEC(@sql);

      -- Migrating the staging data to the main table
      SET @sql = CONCAT('INSERT INTO ', @table_nm,' SELECT * FROM ',@stg_table_nm,';')
      EXEC sp_log 1, @fn, '120: Migrating the staging data to the main table, @sql:
', @sql;

      EXEC(@sql);

      SELECT @table_nm as [main table];
      SET @sql = CONCAT('SELECT * FROM ',@table_nm,';')
      EXEC sp_log 1, @fn, '130: displaying the main table';
      EXEC(@sql);

      -- POST: chk main table has the correct row cnt
      EXEC sp_assert_tbl_pop @table_nm, @exp_cnt = @row_cnt;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: Caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: completed processing imnported ',@row_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC sp_appLog_display 'hlpr_068_sp_crt_pop_table,sp_crt_pop_table';
EXEC test.test_068_sp_crt_pop_table;

EXEC tSQLt.Run 'test.test_068_sp_crt_pop_table';
EXEC sp_AppLog_display 'sp_crt_pop_table';

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC test.sp__crt_tst_rtns 'dbo.sp_crt_pop_table'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================
-- Description: Gets a text file line count
-- Author:      Terry Watts
-- Create date: 11-JUL-2025
-- Design:      
-- Tests:       
-- ====================================================
CREATE PROCEDURE [dbo].[sp_GetTxtFileLineCount]
    @file_path          NVARCHAR(4000)
AS
BEGIN
   DECLARE
       @fn              VARCHAR(35) = 'sp_GetTxtFileLineCount'
      ,@cnt             INT
      ,@sql             NVARCHAR(4000)
      ,@sep             CHAR = '\0'
      ,@row_terminator  CHAR(2) = '\r\n'
   ;

   SET NOCOUNT ON;
   EXEC sp_log 1, @fn, '000: starting:
    @file_path:[', @file_path, ']';

   -- Step 1: Create a temporary table to hold the file content
   CREATE TABLE #TempFileLines (LineText NVARCHAR(MAX));

   -- Step 2: Use BULK INSERT to read the text file
   SET @sql = CONCAT('
   BULK INSERT #TempFileLines
   FROM ''', @file_path, '''
   WITH (
       ROWTERMINATOR   = ''',@row_terminator,''', 
       FIELDTERMINATOR = ''',@sep,''',
       CODEPAGE = ''65001''
   );'
   );

   EXEC (@sql);

         EXEC @cnt = sp_import_txt_file
          @table            = '#TempFileLines'
         ,@file             = @file_path
         ,@folder           = NULL
         ,@field_terminator = @sep
         ,@codepage         = 65001
         ,@first_row        = 2
 --        ,@format_file      = @format_file
 --        ,@display_table    = @display_tables
      ;

      EXEC sp_log 1, '050: raw cnt: ', @cnt;

   -- Step 3: Count the number of lines
SELECT COUNT(*) AS LineCount
FROM #TempFileLines
WHERE PATINDEX('%[A-Za-z0-9]%', REPLACE(REPLACE(LineText, CHAR(9), ''), CHAR(10), '')) > 0;

-- Debug: Inspect all rows
SELECT 
    LineText,
    LEN(LineText) AS LineLength,
    ASCII(LEFT(LineText, 1)) AS FirstCharASCII,
    ASCII(RIGHT(LineText, 1)) AS LastCharASCII
FROM #TempFileLines
WHERE PATINDEX('%[A-Za-z0-9]%', REPLACE(REPLACE(LineText, CHAR(9), ''), CHAR(10), '')) > 0
;

   -- Step 4: Clean up the temporary table
   DROP TABLE #TempFileLines;
   EXEC sp_log 1, @fn, '999: leaving @cnt: ',@cnt , ' rows';
   RETURN @cnt;
END
/*
EXEC sp_GetTxtFileLineCount 'D:\Dev\Property\Data\PropertySales.Resort.txt';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 03-DEC-2024
-- Description: gets the current sub test id key
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntSubTstKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Current sub test';
END
/*
PRINT test.fnGetCrntSubTstKey()
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================================
-- Author:      Terry watts
-- Create date: 03-DEC-2024
-- Description: sets the current sub test id
-- Tests:       test_049_SetGetCrntTstValue
-- =================================================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_sub_tst] @sub_tst VARCHAR(100)
AS
BEGIN
   DECLARE
      @fn   VARCHAR(35) = 'sp_tst_set_crnt_sub_tst'
     ,@key  VARCHAR(40) = test.fnGetCrntSubTstKey();
   ;

   EXEC sp_log 0, @fn, 'starting, @sub_tst:[',@sub_tst,']';
   EXEC sp_set_session_context @key, @sub_tst;
END
/*
EXEC tSQLt.Run 'test.test_049_SetGetCrntTstValue'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===========================================================================
-- Author:      Terry
-- Create date: 20-NOV-2024
-- Description: gets the settings key for the current test number like T001
-- Tests: [test].[test 030 chkTestConfig]
-- ===========================================================================
CREATE FUNCTION [test].[fnGetCrntTstNum2Key]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Test num2';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 20-NOV-2024
-- Description: Sets the @tst_num2 ctx this is the numeirc part of the sub test name
--              Key: fnGetCrntTstNum2Key()->N'Test num2'
-- Tests:       test.test_049_SetGetCrntTstValue
-- Oppo         test.fnGetCrntTstNum()
-- ==================================================================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_num2] @tst_num VARCHAR(3)
AS
BEGIN
   DECLARE
    @fn     VARCHAR(35) = 'sp_tst_set_crnt_tst_num2'
   ,@key    NVARCHAR(60);

   SET @key = test.fnGetCrntTstNum2Key();
   EXEC sp_log 0, @fn,'000: starting, fn: ', @fn, ' key:[', @key,'] @tst_num:[',@tst_num,']';
   EXEC sp_set_session_context @key, @tst_num;
   EXEC sp_log 0, @fn,'999: leaving';
END
/*
EXEC tSQLt.Run 'test.test_049_SetGetCrntTstValue'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



CREATE FUNCTION [dbo].[fnMax] (@p1 INT, @p2 INT)
RETURNS INT
AS
BEGIN
   RETURN CASE WHEN @p1 > @p2 THEN @p1 ELSE @p2 END 
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Author:      Terry Watts
-- Create date: 20-NOV-2024
-- Description: returns test hdr or footer line
-- =========================================================
CREATE FUNCTION [test].[fnGetTstHdrFooterLine]
(
    @is_mn_tst BIT
   ,@is_Hdr    BIT            -- 1:hdr, 0 = footer
   ,@tst_num   VARCHAR(100)
   ,@msg       VARCHAR(100)
)
RETURNS VARCHAR(500)
AS
BEGIN
   DECLARE
       @len       INT
      ,@output    VARCHAR(500)
      ,@line      VARCHAR(160)
      ,@NL        VARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@len2      INT
      ,@tst_ty    VARCHAR(160)
      ,@log_level INT
   ;

   SET @tst_ty = iif(@is_mn_tst = 1, ' Main Test',' Sub-test');
   SET @line = REPLICATE(iif(@is_mn_tst=1, '*','+'), 160);
   SET @len = dbo.fnLen(@tst_num);
   SET @len2 = 120;
   SET @log_level = dbo.fnGetLogLevel();

   IF @is_mn_tst = 0 SET @len2 = @len2 +1;
   IF @is_Hdr = 0 SET @len2 = @len2 +2;

   SET @output = 
      iif
      (
         @log_level <= 1
         ,CONCAT -- verbose if log level 0,1
         (
             @NL
            ,SUBSTRING(@line,1,30)
            ,iif(@is_mn_tst=1, ' Main Test',' Sub-test')
            ,' ', @tst_num, ' '
            ,@msg, ' '
            ,SUBSTRING(@line,1,dbo.fnMax(5, @len2 - @len)) -- + iif(@is_mn_tst=0, 1, 0)
            ,@NL
            ,@NL
         )
         ,CONCAT( @tst_num, ' ', @msg, ' ')
      );

   RETURN @output;
END
/*
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: settings key for the failes test sub number
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntFailedTstNumKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Failed test num';
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry watts
-- Create date: 05-FEB-2021
-- Description: Setter
-- Tests: test.test_049_fnGetCrntTstValue
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_failed_tst_num] @val VARCHAR(60)
AS
BEGIN
   DECLARE @key NVARCHAR(60);
   SET @key = test.fnGetCrntFailedTstNumKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: settings key for the current failed test number
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntFailedTstSubNumKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Failed test sub num';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================
-- Author:      Terry watts
-- Create date: 05-FEB-2021
-- Description: Setter
-- Tests: test_049_SetGetCrntTstValue
-- ====================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_failed_tst_sub_num] @val VARCHAR(60)
AS
BEGIN
   DECLARE @key NVARCHAR(40);
   SET @key = test.fnGetCrntFailedTstSubNumKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: Gets the current ErrorStateKey key
-- Tests: test_049_SetGetCrntTstValue
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstErrStKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Error state';
END
/*
EXEC tSQLt.Run 'test_049_SetGetCrntTstValue'
EXEC tSQLt.RunAll
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================================
-- Author:      Terry watts
-- Create date: 05-FEB-2021
-- Description: setter: error_state
-- Tests: [test].[test 030 chkTestConfig]
-- =================================================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_err_st] @val INT
AS
BEGIN
   DECLARE @key VARCHAR(80) = test.fnGetCrntTstErrStKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current test fn name from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstFnKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Test fn';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current test fn name from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstFn]()
RETURNS VARCHAR(60)
AS
BEGIN
   RETURN CONVERT(VARCHAR(60), SESSION_CONTEXT(test.fnGetCrntTstFnKey()));
END

/*
PRINT [test].[fnGetCurrentTestFnName]()

EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current close fn name from settings
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstHlprFnKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Hlpr fn';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 20-NOV-2024
-- Description: Gets the current test hlpr fn name from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstHlprFn]()
RETURNS VARCHAR(60)
AS
BEGIN
   RETURN CONVERT(VARCHAR(60), SESSION_CONTEXT(test.fnGetCrntTstHlprFnKey()));
END
/*
PRINT [test].[fnGetCrntTstHlprFn]()
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===================================================
-- Author:      Terry Watts
-- Create date: 05-APR-2020
-- Description:
--  Encapsulates the test helper startup:
--  Prints a line to separate test output
--  Prints the EXEC sp_log 2, @fn, '01: starting msg
--  Sets the current test num context
--
--  Clears previous test state context:
--    crnt_tst_err_st         = 0
--    crnt_failed_tst_num     = NULL
--    crnt_failed_tst_sub_num = NULL
-- ===================================================
CREATE PROCEDURE [test].[sp_tst_hlpr_st]
    @sub_tst   VARCHAR(50) -- Like '010: Chk Rule 1' OR 'T010: Chk Rule 1'
   ,@params    VARCHAR(MAX) = NULL
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35)   = N'sp_tst_hlpr_st'
   ,@fnHlrSt   VARCHAR(35)
   ,@NL        VARCHAR(2)    = NCHAR(13) + NCHAR(10)
   ,@line      VARCHAR(100)  = REPLICATE(N'=', 100)
   ,@prms_msg  VARCHAR(MAX)
   ,@tstRtn    VARCHAR(60)
   ,@subTstNum VARCHAR(10) --  = test.fnGetCrntTstNum2()
   ,@msg       VARCHAR(500)
   ,@ndx       INT
   ;

   SET @tstRtn = test.fnGetCrntTstFn();
   SET @ndx = iif(IsNumeric(SUBSTRING(@sub_tst, 1,1))=1, 1,2);
   SET @subTstNum = SUBSTRING(@sub_tst, @ndx, 3);
   EXEC test.sp_tst_set_crnt_tst_num2 @subTstNum;    -- Just the 3 digit test number
   SET @fnHlrSt = test.fnGetCrntTstHlprFn();
   SET @msg = CONCAT(@tstRtn,'.',@subTstNum);
   DELETE FROM AppLog;

   --------------------------------------------------
   -- Validate preconditions:
   --------------------------------------------------
   EXEC sp_assert_not_null_or_empty @sub_tst;

   --------------------------------------------------
   -- Process
   --------------------------------------------------
   SET @prms_msg = IIF(@params IS NOT NULL, CONCAT('params: ', @params), '');

   PRINT test.fnGetTstHdrFooterLine(1, 1, @msg, 'starting');

   EXEC sp_log 1, @fn,@fnHlrSt, '.', @tstRtn,'.',@subTstNum,': 000: starting', @nl, @params;

   EXEC test.sp_tst_set_crnt_sub_tst            @sub_tst;
   EXEC test.sp_tst_set_crnt_tst_err_st         0;
   EXEC test.sp_tst_set_crnt_failed_tst_num     NULL;
   EXEC test.sp_tst_set_crnt_failed_tst_sub_num NULL;

   --------------------------------------------------
   -- Process complete
   --------------------------------------------------
   EXEC sp_log 1, @fn,'999: leaving';
END
/*
*/


GO
GO

CREATE TYPE [test].[CompareStringsTbl] AS TABLE(
	[A] [varchar](max) NULL,
	[B] [varchar](max) NULL,
	[SA] [varchar](max) NULL,
	[SB] [varchar](max) NULL,
	[CA] [varchar](max) NULL,
	[CB] [varchar](max) NULL,
	[msg] [varchar](max) NULL,
	[match] [bit] NULL,
	[status_msg] [varchar](120) NULL,
	[code] [int] NULL,
	[ndx] [int] NULL,
	[log] [varchar](max) NULL
)

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 19-NOV-2024
-- Description: function to compare 2 strings
-- Returns TABLE with 3 rows,[A as chars, B as chars, A as ascii codes, B as ASCII codes]
-- Stops at first mismatch
--
-- Tests: test_037_fnCompareStrings
-- ======================================================================================
CREATE PROC [dbo].[sp_fnCompareStrings]( @a VARCHAR(MAX), @b VARCHAR(MAX))
/*
RETURNS @t TABLE
(
    SA            VARCHAR(MAX) -- STRING characters             for A
   ,SB            VARCHAR(MAX) -- STRING characters             for B
   ,CA            VARCHAR(MAX) -- SEQ ASCII codes formattd 00N  for A
   ,CB            VARCHAR(MAX) -- SEQ ASCII codes formattd 00N  for B
   ,msg           VARCHAR(MAX) -- match results
   ,[match]       BIT
   ,status_msg    VARCHAR(120)
   ,code          INT
   ,ndx           INT
   ,[log]         VARCHAR(MAX)
)
*/
AS
BEGIN
   DECLARE
       @fn           VARCHAR(35) = N'sp_fnCompareStrings'
      ,@charA        CHAR
      ,@charB        CHAR
      ,@asciA        CHAR(3)
      ,@asciB        CHAR(3)
      ,@CA           VARCHAR(MAX) -- Ascii codes in hex/spx
      ,@CB           VARCHAR(MAX) -- Ascii codes in hex/spc
      ,@SA           VARCHAR(MAX) -- Characters matching Ascii codes/spx
      ,@SB           VARCHAR(MAX) -- Characters matching Ascii codes/spx
      ,@first_time   BIT = 1
      ,@i            INT
      ,@lenMax       INT
      ,@lenA         INT
      ,@lenB         INT
      ,@match        BIT = 1
      ,@msg          VARCHAR(MAX)
      ,@nl           VARCHAR(2) = CHAR(13) + CHAR(10)
      ,@status_msg   VARCHAR(50)
      ,@code         INT
      ,@log          VARCHAR(MAX)
      ,@t            test.CompareStringsTbl
      ,@params       VARCHAR(MAX)
   ;

   WHILE(1=1)
   BEGIN
      SET @params = CONCAT
      (
'a:[', iif(@a IS NULL, '<NULL>', iif( LEN(@a)=0,'<empty string>',@a)), ']', @nl,
'b:[', iif(@a IS NULL, '<NULL>', iif( LEN(@b)=0,'<empty string>',@b)), ']', @nl
      );

      EXEC sp_log 1, @fn, '000: starting, params:',@nl, @params;
      IF (@a IS NULL OR @b IS NULL) -- But not both
      BEGIN
         -----------------------------------------------------------------
         -- ASSERTION: @a IS NULL OR @b IS NULL may be both
         -----------------------------------------------------------------
         EXEC sp_log 0, @fn, '010: ASSERTION: @a IS NULL OR @b IS NULL maybe both';

         IF(@a IS NULL AND @b IS NULL)
         BEGIN
            SELECT
                @msg   = 'both a or b are NULL'
               ,@match = 1
               ,@status_msg= 'OK'
               ,@code  = 1
            ;

            EXEC sp_log 1, @fn, '020: match: both inputs are NULL'
            BREAK;
         END

      ------------------------------------------------------
      -- ASSERTION: one or other input is null but not both
      ------------------------------------------------------
       EXEC sp_log 1, @fn, '030: ASSERTION: one or other input is null but not both'

         SELECT
             @msg       = 'one of a or b is NULL but not both '
            ,@match     = 0
            ,@status_msg= 'OK'
            ,@code      = 2 -- 'one of a or b is NULL but not both '

         EXEC sp_log 1, @fn, '040: mismatch, one of a or b is NULL but not both';
         BREAK;
      END

      -----------------------------------------------------------------
      -- ASSERTION: both are not null
      -----------------------------------------------------------------
      SET @lenA = dbo.fnLen(@a);
      SET @lenB = dbo.fnLen(@b);
      EXEC sp_log 1, @fn, '050: len(a): ', @lenA, ' len(b): ', @lenB;

      -- Check length of both strings <=1000 (need 4 chars per char compared
      EXEC sp_log 1, @fn, '060: check string length <=1333';
      SET @lenMax = dbo.fnMax(@lenA, @lenb);

      IF @lenA <> @lenb
      BEGIN
         SELECT
             @msg       = CONCAT('strings differ in length a: ', @lenA, ' b: ', @lenb)
            ,@match     = 0
            ,@status_msg= 'OK'
            ,@code      = 5 -- length mismatch

         EXEC sp_log 1, @fn, '070: mismatch, string lengths differ, @lenA: ', @lenA, ' @lenB: ', @lenB;
         --BREAK;
      END

      -- Need 3 chars like [ xx] for each char checked so limit is 8000/3 = 2666
      IF @lenA > 1000 OR @lenB > 2666
      BEGIN
         SELECT
             @msg       = 'a or b is too long to store the results of a detailed comparison, it has more than 2666 characters whih means the formatted output is more than MAX size of string'
            ,@match     = 0
            ,@status_msg= 'TOO LONG TO STORE DETAILED RESULTS'
            ,@code      = -1 -- one of a or b is too long to compare

         EXEC sp_log 3, @fn, '050:', @msg;
         --BREAK;
      END

      -----------------------------------------------------------------
      -- ASSERTION: No previous check failed, strings are same length
      -----------------------------------------------------------------

      EXEC sp_log 1, @fn, '080: detailed check, @lenMax: ', @lenMax;
      SET @i = 0;

      WHILE(@i<=@lenMax)
      BEGIN
         SET @charA = iif(@i<=@lenA, SUBSTRING(@a, @i,1), '_');
         SET @charB = iif(@i<=@lenB, SUBSTRING(@b, @i,1), '_');

         SET @asciA = iif(@i<=@lenA, FORMAT(ASCII(@charA), 'x2'), '  ')
         SET @asciB = iif(@i<=@lenB, FORMAT(ASCII(@charB), 'x2'), 'xx')

      -----------------------------------------------------------------
      -- Only do the HEX thing if have room to store result
      -----------------------------------------------------------------
         if(@i < 2667)
         BEGIN
            SET @CA = CONCAT(@CA, ' ', @asciA);
            SET @CB = CONCAT(@CB, ' ', @asciB);

            
            SET @SA = CONCAT(@SA,
            CASE
               WHEN @charA = CHAR(09) THEN '\t'
               WHEN @charA = CHAR(13) THEN '\r'
               WHEN @charA = CHAR(10) THEN '\n'
               ELSE @charA
            END
            )
            ;

            SET @SB = CONCAT(@SB,
            CASE
               WHEN @charB = CHAR(09) THEN '\t'
               WHEN @charB = CHAR(13) THEN '\r'
               WHEN @charB = CHAR(10) THEN '\n'
               ELSE @charB
            END
            );
         END

         SET @i = @i + 1;

         IF @asciA <> @asciB
         BEGIN
            SELECT 
                @msg       = CONCAT('mismatch at pos: ', @i, ' @lenMax: ',@lenMax,' char: [',@charA,']/[',@charB,'], ASCII: [',@asciA,']/[',@asciB,']')
               ,@code      = 4
               ,@status_msg= 'OK'
               ,@code      = 5 -- length mismatch

            IF @first_time = 1
            BEGIN
               EXEC sp_log 1, @fn, '090: ASCII code mismatch at pos ', @i, ', ASCII codes differ  ASCII: [',@asciA,']/[',@asciB,']';
               SET @first_time = 0;
               SET @match      = 0;
            END
            --BREAK;
         END
      END

      -----------------------------------------------------------------
      -- ASSERTION: if here match already set
      -----------------------------------------------------------------
      SELECT
          @msg       = 'strings match'
         ,@status_msg= 'OK'
         ,@code      = 0 -- match

      --SET @log = CONCAT(@log, '|', '100: strings match');
      BREAK;
   END -- while 1=1 main do loop

   -----------------------------------------------------------------
   -- ASSERTION: @a, @b, @CA, @CB, @msg ARE SET
   -----------------------------------------------------------------
   EXEC sp_log 1, @fn, '100: match:',@match,' status_msg:[', @status_msg, '] code:[', @code, '} @i:', @i,' max len: ', @lenMax;

   INSERT INTO @t( A,  B,  SA,  SB,  CA,  CB,  msg, [match], status_msg,  code, ndx, [log])
   VALUES        (@a, @b, @SA, @SB, @CA, @CB, @msg, @match, @status_msg, @code, @i,  @log);
   --RETURN;
   SELECT * FROM @t;

   if(@match = 0)
   BEGIN
      EXEC sp_log 1, @fn, '025: mismatch:', @nl
,'a:',@SA, @nl
,'b:',@SB, @nl
,'a:',@CA, @nl
,'b:',@CB;
   END
END
/*
EXEC tSQLt.Run 'test.test_037_sp_fnCompareStrings';
EXEC tSQLt.Run 'test.test_018_fnCrtUpdateSql';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: settigns key for the current test number
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstNumKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Test num';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: Gets the current test helper fn name from settings
-- Key:         N'Test num'
-- Tests:       test.test 030 chkTestConfig
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstNum]()
RETURNS VARCHAR(60)
AS
BEGIN
   RETURN CONVERT(VARCHAR(60), SESSION_CONTEXT(test.fnGetCrntTstNumKey()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test_030_chkTestConfig'
EXEC tSQLt.RunAll
PRINT test.fnGetCrntTstNumKey();
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================================================
-- Author:      Terry Watts
-- Create date: 20-NOV-2024
-- Description: Gets the current tst_num2 from the session context
--              This is the 3 digit int number only part of the sub test identifier
-- Key:         N'Test num'
-- Tests:       test.test 030 chkTestConfig
-- =================================================================================
CREATE FUNCTION [test].[fnGetCrntTstNum2]()
RETURNS VARCHAR(3)
AS
BEGIN
   RETURN CONVERT(VARCHAR(3), SESSION_CONTEXT(test.fnGetCrntTstNum2Key()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test_030_chkTestConfig'
EXEC tSQLt.RunAll
PRINT test.fnGetCrntTstNumKey();
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [tSQLt].[TestResult](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Class] [nvarchar](max) NOT NULL,
	[TestCase] [nvarchar](max) NOT NULL,
	[Name]  AS ((quotename([Class])+'.')+quotename([TestCase])),
	[TranName] [nvarchar](max) NULL,
	[Result] [nvarchar](max) NULL,
	[Msg] [nvarchar](max) NULL,
	[TestStartTime] [datetime2](7) NOT NULL,
	[TestEndTime] [datetime2](7) NULL,
 CONSTRAINT [PK:tSQLt.TestResult] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [tSQLt].[TestResult] ADD  CONSTRAINT [DF:TestResult(TestStartTime)]  DEFAULT (sysdatetime()) FOR [TestStartTime]

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE PROCEDURE [tSQLt].[Fail]
    @Message0 NVARCHAR(MAX) = '',
    @Message1 NVARCHAR(MAX) = '',
    @Message2 NVARCHAR(MAX) = '',
    @Message3 NVARCHAR(MAX) = '',
    @Message4 NVARCHAR(MAX) = '',
    @Message5 NVARCHAR(MAX) = '',
    @Message6 NVARCHAR(MAX) = '',
    @Message7 NVARCHAR(MAX) = '',
    @Message8 NVARCHAR(MAX) = '',
    @Message9 NVARCHAR(MAX) = ''
AS
BEGIN
   DECLARE @WarningMessage NVARCHAR(MAX);
   SET @WarningMessage = '';

   IF XACT_STATE() = -1
   BEGIN
     SET @WarningMessage = CHAR(13)+CHAR(10)+'Warning: Uncommitable transaction detected!';

     DECLARE @TranName NVARCHAR(MAX);
     SELECT @TranName = TranName
       FROM tSQLt.TestResult
      WHERE Id = (SELECT MAX(Id) FROM tSQLt.TestResult);

     DECLARE @TranCount INT;
     SET @TranCount = @@TRANCOUNT;
     ROLLBACK;
     WHILE(@TranCount>0)
     BEGIN
       BEGIN TRAN;
       SET @TranCount = @TranCount -1;
     END;
     SAVE TRAN @TranName;
   END;

   INSERT INTO #TestMessage(Msg)
   SELECT COALESCE(@Message0, '!NULL!')
        + COALESCE(@Message1, '!NULL!')
        + COALESCE(@Message2, '!NULL!')
        + COALESCE(@Message3, '!NULL!')
        + COALESCE(@Message4, '!NULL!')
        + COALESCE(@Message5, '!NULL!')
        + COALESCE(@Message6, '!NULL!')
        + COALESCE(@Message7, '!NULL!')
        + COALESCE(@Message8, '!NULL!')
        + COALESCE(@Message9, '!NULL!')
        + @WarningMessage;
        
   RAISERROR('tSQLt.Failure',16,10);
END;



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 18-DEC-2019
-- Description: case sensitive compare helper function
-- Returns:     1 if match false 0
-- =============================================
CREATE FUNCTION [dbo].[fnCaseSensistiveCompare]
(
    @exp        VARCHAR(MAX)
   ,@act        VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
   IF @exp IS NULL AND @act IS NULL
      RETURN 1;

   IF (@exp IS NULL     AND @act IS NOT NULL) OR
      (@exp IS NOT NULL AND @act IS NULL)
      RETURN 0;

   RETURN IIF( @exp COLLATE Latin1_General_CS_AS  = @act COLLATE Latin1_General_CS_AS
   , 1, 0);
END
/*
   
   IF (@expected IS NULL)
      SET @exp_is_null = 1;

   IF (@actual IS NULL)
      SET @act_is_null = 1;

   IF (@exp_is_null = 1) AND (@act_is_null = 1)
      RETURN 1;

   IF (@exp_is_null = 1) AND (@act_is_null = 1)
      RETURN 1;

   IF ( dbo.fnLEN(@expected) = 0) AND ( dbo.fnLEN(@actual) = 0)
      RETURN 1;

   SET @exp = CONVERT(VARBINARY(8000), @expected);
   SET @act = CONVERT(VARBINARY(8000), @actual);

   IF (@exp = 0x) AND (@act = 0x)
   BEGIN
      SET @res = 1;
   END
   ELSE
   BEGIN
      IF @exp = @act
         SET @res = 1;
      ELSE
         SET @res = 0;
   END

   -- ASSERTION @res is never NULL
   RETURN @res;
END
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE PROCEDURE [tSQLt].[AssertEquals]
    @exp          SQL_VARIANT
   ,@act          SQL_VARIANT
   ,@unit_tst     VARCHAR(30)  = NULL
   ,@msg1         VARCHAR(MAX) = NULL
   ,@msg2         VARCHAR(MAX) = NULL
   ,@msg3         VARCHAR(MAX) = NULL
   ,@msg4         VARCHAR(MAX) = NULL
   ,@msg5         VARCHAR(MAX) = NULL
   ,@msg6         VARCHAR(MAX) = NULL
   ,@msg7         VARCHAR(MAX) = NULL
   ,@detailed_tst BIT           = 0   -- detailed comparison
   ,@cs_sens_cmp  BIT           = 0
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35) = N'tSQLt.AssertEquals'
   ,@nl        VARCHAR(2)= CHAR(13) + CHAR(10)
   ,@test_msg  VARCHAR(500)
   ,@error_msg VARCHAR(MAX)
   ,@exp_str   VARCHAR(MAX)
   ,@act_str   VARCHAR(MAX)
   ,@line      VARCHAR(180)  =REPLICATE(N'*', 180)
   ,@Msg       VARCHAR(MAX)
   ,@subtest   VARCHAR(200)
   ,@testFn    VARCHAR(100)
   ,@testNum   VARCHAR(100)
   ,@testTd    VARCHAR(100)
   ;

   SET @testNum = test.fnGetCrntTstNum()
   SET @subtest = test.fnGetCrntTstNum2() -- The 3 digit numeric part of the subtest name
   SET @testTd  = CONCAT(@testNum,'.', @subtest,'.',@unit_tst);
   SET @exp_str = ISNULL(CONVERT( VARCHAR(MAX), @exp), 'NULL');
   SET @act_str = ISNULL(CONVERT( VARCHAR(MAX), @act), 'NULL');
   IF @subtest IS NULL SET @subtest = '<UNSPECIFIED>'

   SET @test_msg = 
   CONCAT
   (
       @testTd
      ,iif(@msg1 IS NULL, '', CONCAT(' ',@msg1))
      ,iif(@msg2 IS NULL, '', CONCAT(' ',@msg2))
      ,iif(@msg3 IS NULL, '', CONCAT(' ',@msg3))
      ,iif(@msg4 IS NULL, '', CONCAT(' ',@msg4))
      ,iif(@msg5 IS NULL, '', CONCAT(' ',@msg5))
      ,iif(@msg6 IS NULL, '', CONCAT(' ',@msg6))
      ,iif(@msg7 IS NULL, '', CONCAT(' ',@msg7))
   );

   IF @act IS NULL AND @exp IS NULL
   BEGIN
       -----------------------------------------------------
       -- Assertion: NULL NULL pass
       -----------------------------------------------------
      EXEC sp_log 1, @fn, '010: ',@test_msg, ' NULL NULL cmp passed'
      RETURN 0;
   END

   IF @cs_sens_cmp = 1
   BEGIN
      IF 1 = dbo.fnCaseSensistiveCompare(@exp_str, @act_str)
      BEGIN
         EXEC sp_log 1, @fn, '020: case sensistive compare ',@test_msg, ' passed'
      RETURN 0;
      END
      -- ASSERTION case sensistive compare failed
       EXEC sp_log 3, @fn, '030: case sensistive compare failed'
   END
   ELSE
   IF ((@exp = @act))
   BEGIN
       -----------------------------------------------------
       -- Assertion: if here then passed
       -----------------------------------------------------
      EXEC sp_log 1, @fn, '040: ',@test_msg, ' passed'
      RETURN 0;
   END

   -----------------------------------------------------
   -- Assertion: if here then failed
   -----------------------------------------------------

   EXEC sp_log 3, @fn, '050: ',@test_msg, ' failed'
   SET @testFn  = test.fnGetCrntTstFn();
   SET @testNum = test.fnGetCrntTstNum();

   IF @detailed_tst = 1
   BEGIN
      EXEC sp_log 1, @fn, '060: detailed string comparison'
      IF @exp_str <> @act_str EXEC sp_log 4, @fn,'040: string comparison mismatch';

      DECLARE
          @lenExp    INT = dbo.fnLen(@exp_str)
         ,@lenAct    INT = dbo.fnLen(@act_str)
         ,@bin_mtch  INT = dbo.fnCaseSensistiveCompare(@exp_str, @act_str)

      EXEC sp_log 1, @fn,
      '050: @lenExp   : ', @lenExp, @NL,
      '060: @lenAct   : ', @lenAct, @NL,
      '070: binary Cmp: ', @bin_mtch, ' (1 = match)', @NL
      ;

      EXEC sp_log 1, @fn,'070: calling sp_fnCompareStrings: a:@exp_str:[', @exp_str, '], b:@act_str:[',@act_str,']';
      EXEC sp_fnCompareStrings @exp_str, @act_str;
      EXEC sp_log 1, @fn,'080: ret frm sp_fnCompareStrings';
   END -- detailed test

/*   SELECT @Msg = CONCAT
   (
      'failed, Exp/Act '
      ,@NL,'<', @exp_str,'>'
      ,@NL,'<', @act_str,'>'
      ,@NL
   );
*/
   SET @error_msg = 
      CONCAT
      (
          @msg1
         ,iif(@msg1 IS NULL,'',' ')
         ,@msg2
         ,iif(dbo.fnLen(@exp_str) < 4000,
             CONCAT(@NL, 'exp: <', @exp_str,'>,', @NL,'act: <', @act_str,'>')
            ,CONCAT(@NL, 'exp: <', SUBSTRING(@exp_str, 1, 4000),'>,', @NL,'act: <', SUBSTRING(@act_str, 1 , 4000),'>'))
         --, ' '
      );

   PRINT CONCAT( @NL, @line, @NL);
   EXEC sp_log 4, @fn,'900: ', @testTd, ' failed ', @error_msg
   PRINT CONCAT( @line, @NL);
   EXEC tSQLt.Fail @error_msg;--, @Msg;
END;

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry Watts
-- Create date: 03-DEC-2024
-- Description: gets the current sub test identifier
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntSubTst]()
RETURNS VARCHAR(100)
AS
BEGIN
   RETURN CONVERT(VARCHAR(100), SESSION_CONTEXT(test.fnGetCrntSubTstKey()));
END
/*
PRINT test.fnGetCrntSubTst();
EXEC tSQLt.RunAll;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE PROCEDURE [tSQLt].[AssertIsSubString]
    @a    NVARCHAR(4000)
   ,@b    NVARCHAR(4000)
   ,@msg1 NVARCHAR(2000) = NULL
   ,@msg2 NVARCHAR(2000) = NULL
   ,@msg3 NVARCHAR(2000) = NULL
   ,@msg4 NVARCHAR(2000) = NULL
AS
BEGIN
   DECLARE
    @fn        NVARCHAR(35)  = N'AssertIsSubString'
   ,@error_msg NVARCHAR(MAX)
   ,@Msg       NVARCHAR(MAX)
   ,@nl        NCHAR(2)      = NCHAR(13)+CHAR(10)
   ,@subtest   NVARCHAR(200) = test.fnGetCrntSubTst()
   PRINT N'AssertIsSubString starting';
   PRINT CONCAT(@fn, ' loglevel: ', dbo.fnGetLogLevel());
   EXEC sp_log 1, @fn, '000: starting', @nl
, '@a:[', @a, ']', @nl
, '@b:[', @b, ']';

   IF ((@a = @b) OR (@a IS NULL AND @b IS NULL) OR (CHARINDEX(@a, @b) > 0))
   BEGIN
      EXEC sp_log 1, @fn, '010: OK passed'
      RETURN 0;
   END

    -----------------------------------------------------
    -- Assertion: ERROR: a is not a substring of b
    -----------------------------------------------------
   DECLARE
    @line      NVARCHAR(100) =REPLICATE(N'*', 100)
   ,@testFn    NVARCHAR(100)
   ,@testNum   NVARCHAR(100)

   SET @testFn  = test.fnGetCrntTstFn();
   SET @testNum = test.fnGetCrntTstNum();

   SELECT @Msg = CONCAT
    (
       'Failed, Exp/Act '
       ,@NL,'<', @a,'>'
       ,@NL,'<', @b,'>'
       ,@NL
    );

   SET @msg = 
      CONCAT
      (
        test.fnGetCrntTstFn(), '.', test.fnGetCrntSubTst()
       , @msg1
       ,iif(@msg1 IS NULL, '', CONCAT(' ', @msg2))
       ,iif(@msg2 IS NULL, '', CONCAT(' ', @msg3))
       ,iif(@msg3 IS NULL, '', CONCAT(' ', @msg4))
       );

   SELECT @Msg = CONCAT
                 (
                   @nl, '@a:<', ISNULL(@a, 'NULL'), '>'
                  ,@nl, ' is not in'
                  ,@nl, '@b:<', ISNULL(@b, 'NULL'), '>'
                  ,@nl
                 );

--*********************************************************************************************
   PRINT CONCAT( @NL, @line);
   EXEC sp_log 4, @fn,'**** ', @testFn, '.', @testNum, '.', @subtest, '. failed ****', @Msg;
   PRINT CONCAT( @line, @NL);
--*********************************************************************************************

    EXEC tSQLt.Fail '**** ', @testFn, '.', @testNum, '.', @subtest, '. failed ****', @Msg;
END;

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 03-APR-2020
-- Description: Inserts a log row in the app log
--
--              Splits into column based on tabs in the the message or 

   -- set @tmp = LEFT(CONCAT(REPLICATE( '  ', @sf), REPLACE(LEFT( @tmp, 500), @NL, '--')), 500);
   -- set @tmp = LEFT(CONCAT( REPLACE(LEFT( @tmp, 500), @NL, '--')), 500);
-- =============================================
CREATE PROCEDURE [dbo].[sp_appLog_display]
    @rtns   VARCHAR(MAX) = NULL -- like 'dbo.fnA,test.sp_b'
   ,@msg    VARCHAR(4000)= NULL     -- no %%
   ,@level  INT          = NULL
   ,@id     INT          = NULL -- starting id
   ,@dir    BIT          = 1 -- ASC
AS
BEGIN
DECLARE
    @fn                 VARCHAR(35)   = N'sp_appLog_display '
   ,@sql                VARCHAR(4000)
   ,@need_where         BIT = 0
   ,@nl                 VARCHAR(2)   = CHAR(13) + CHAR(10)
   ,@fns                IdNmTbl
   ,@s                  VARCHAR(4000)
   ;

   SET NOCOUNT ON;

   INSERT into @fns(val) SELECT value FROM string_split(@rtns,',');
   SELECT @s = string_agg(CONCAT('''', val, ''''),',') FROM @fns;
--   PRINT(@s);
   SET @need_where = 
      IIF(    @rtns  IS NOT NULL
           OR @level IS NOT NULL
           OR @id    IS NOT NULL
           OR @msg   IS NOT NULL
           ,1, 0);

   SET @sql = CONCAT(
'SELECT
  id
,[level]
,rtn AS [rtn',   REPLICATE('_',20), ']
,SUBSTRING(msg, 1  , 128) AS ''msg1', REPLICATE('_',100), '''
,SUBSTRING(msg, 129, 128) AS ''msg2', REPLICATE('_',100), '''
,SUBSTRING(msg, 257, 128) AS ''msg3', REPLICATE('_',100), '''
,SUBSTRING(msg, 385, 128) AS ''log4', REPLICATE('_',100), '''
FROM AppLog
'
,iif(@need_where= 0, '', CONCAT('WHERE '                                                            , @nl))
,iif(@rtns  IS NULL, '', CONCAT(' rtn IN (', @s, ')'                                                , @nl))
,iif(@msg   IS NULL, '', CONCAT(IIF(@rtns IS NULL                   ,'', ' AND'),' msg LIKE (''%', @msg, '%'')'         , @nl))
,iif(@level IS NULL, '', CONCAT(IIF(@rtns IS NULL                   ,'', ' AND'),' level = ', @level, @nl))
,iif(@id    IS NULL, '', CONCAT(IIF(@rtns IS NULL AND @level IS NULL,'', ' AND'),' id >= '  , @id   , @nl))
,'ORDER BY ID ', iif(@dir=1, 'ASC','DESC'), ';'
);

 --  PRINT CONCAT(@fn, '100: executing sql:', @sql);
   EXEC (@sql);

/*   IF dbo.fnGetLogLevel() = 0
      PRINT CONCAT( @fn,'999: leaving:');*/
END
/*
EXEC tSQLt.RunAll;

EXEC sp_appLog_display;
EXEC sp_appLog_display @rtns='S2_UPDATE_TRIGGER',@msg='@fixup_row_id: 4'
EXEC sp_appLog_display @id=140;
000: starting @fixup_row_id: 4, @imp_file_nm: [ImportCorrections_221018-Crops.txt], @fixup_stg_id: 4, @search_clause: [ agricult
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ================================================
-- Author:      Terry Watts
-- Create date: 13-FEB-2021
-- Description: handles test failure
--
-- TESTS:
-- ================================================
CREATE PROCEDURE [test].[sp_tst_hlpr_hndl_failure]
 @msg1 VARCHAR(2000) = NULL
,@msg2 VARCHAR(2000) = NULL
,@msg3 VARCHAR(2000) = NULL
,@msg4 VARCHAR(2000) = NULL
AS
BEGIN
   DECLARE
      @fn       VARCHAR(35) = 'sp_tst_hlpr_hndl_failure'
     ,@tst_num2 VARCHAR(6) = test.fnGetCrntTstNum2()
     ,@msg      VARCHAR(500)
   ;

   SET NOCOUNT ON;
   -- Display applog up and down
   EXEC sp_log 0, @fn, '000: starting';
   EXEC sp_appLog_display;-- 0;
   --EXEC sp_appLog_display 1;

   SET @msg = 
      CONCAT
      (
        test.fnGetCrntTstFn(), '.', test.fnGetCrntSubTst()
       , @msg1
       ,iif(@msg1 IS NULL, '', CONCAT(' ', @msg2))
       ,iif(@msg2 IS NULL, '', CONCAT(' ', @msg3))
       ,iif(@msg3 IS NULL, '', CONCAT(' ', @msg4))
       );

   PRINT test.fnGetTstHdrFooterLine(1, 0, @msg, 'failed');
   EXEC sp_log 1, @fn, '900: leaving';
END
/*
EXEC tSQLt.Run 'test.test_013_sp_pop_AttendanceDates';

EXEC [test].[sp_tst_hlpr_st] 'MyFn', 'T010: MyFn'
EXEC test.sp_tst_hlpr_hndl_failure
PRINT test.fnGetCrntTstFn()
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 06-FEB-2021
-- Description: settings key for the failes test sub number
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetTstPassCntKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Passed test count';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 06-FEB-2021
-- Description: Gets the failed test number  from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetTstPassCnt]()
RETURNS INT
AS
BEGIN
   DECLARE @cnt INT;
   SET @cnt = CONVERT(INT, SESSION_CONTEXT(test.[fnGetTstPassCntKey]()));

   IF @cnt IS NULL  -- handle null as we are incrmenting this
      SET @cnt = 0;

   RETURN @cnt
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =============================================
-- Author:      Terry Watts
-- Create date: 06-FEB-2021
-- Description: Setter, clears the test pass count
-- Tests: [test].[test 030 chkTestConfig]
-- Returns: the cremented test count
-- =============================================
CREATE PROCEDURE [test].[sp_tst_incr_pass_cnt]
AS
BEGIN
   DECLARE @key NVARCHAR(60)
         , @cnt INT;

   SET @key = test.fnGetTstPassCntKey();
   SET @cnt = test.fnGetTstPassCnt() + 1;

   EXEC sp_set_session_context @key, @cnt;
   RETURN @cnt;
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================================
-- Author:      Terry Watts
-- Create date: 13-FEB-2021
-- Description: handles test success 
--                increments the test passed counter, logs (force) msg
--
-- CALLED BY:   sp_tst_gen_chk
-- TESTS:       hlpr_015_fnGetErrorMsg
-- =========================================================================
CREATE PROCEDURE [test].[sp_tst_hlpr_hndl_success]
AS
BEGIN
   DECLARE
       @fn            VARCHAR(35)   = N'sp_tst_hlpr_hndl_success'
      ,@test_pass_cnt INT
      ,@msg           VARCHAR(500)
   ;

 -- Passed so increment the test count
   EXEC @test_pass_cnt = test.sp_tst_incr_pass_cnt;
   SET @msg = CONCAT(test.fnGetCrntTstFn(), '.', test.fnGetCrntTstNum2());

   PRINT test.fnGetTstHdrFooterLine(0, 0, @msg, 'passed');
END
/*
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[TableColumns_vw]
AS
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
;
/*
SELECT * FROM dbo.TableColumns;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE FUNCTION [dbo].[fnGetTableColumns]
(
    @name       VARCHAR(128)
   ,@schema_nm  VARCHAR(128)
)
RETURNS
@t TABLE
(
    TABLE_CATALOG    VARCHAR(128)
   ,TABLE_SCHEMA     VARCHAR(128)
   ,TABLE_NAME       VARCHAR(128)
   ,COLUMN_NAME      VARCHAR(128)
   ,ORDINAL_POSITION INT
   ,IS_NULLABLE      BIT
   ,DATA_TYPE        VARCHAR(128)
)
AS
BEGIN
   INSERT INTO @t(
    TABLE_CATALOG
   ,TABLE_SCHEMA
   ,TABLE_NAME
   ,COLUMN_NAME
   ,ORDINAL_POSITION
   ,IS_NULLABLE
   ,DATA_TYPE
)
   SELECT
    TABLE_CATALOG
   ,TABLE_SCHEMA
   ,TABLE_NAME
   ,COLUMN_NAME
   ,ORDINAL_POSITION
   ,iif(IS_NULLABLE = 'YES', 1, 0)
   ,DATA_TYPE
   FROM TableColumns_vw
   WHERE
          (TABLE_SCHEMA = @schema_nm OR @schema_nm IS NULL)
      AND TABLE_NAME   = @name
      ORDER BY ORDINAL_POSITION
   ;

   RETURN;
END
/*
   SELECT * FROM dbo.fnGetTableColumns('Attendance', NULL);
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 03-Nov-2023
--
-- Description: Gets the file name optionally with the extension from the supplied file path
--
-- Tests:
--
-- CHANGES:
-- 240307: added @with_ext flag parameter to signal to get either the file with or without the extension
-- ======================================================================================================
CREATE FUNCTION [dbo].[fnGetFileNameFromPath](@path VARCHAR(MAX), @with_ext BIT)
RETURNS VARCHAR(200)
AS
BEGIN
   DECLARE
    @t TABLE
    (
       id int IDENTITY(1,1) NOT NULL
      ,val VARCHAR(200)
    );

   DECLARE 
       @val VARCHAR(4000)
      ,@ndx INT = -1

   INSERT INTO @t(val)
   SELECT value from string_split(@path, NCHAR(92)); -- ASCII 92 = Backslash
   SET @val = (SELECT TOP 1 val FROM @t ORDER BY id DESC);

   IF @with_ext = 0
   BEGIN
      SET @ndx = CHARINDEX('.', @val);

      SET @val = IIF(@ndx=0, @val, SUBSTRING(@val, 1, @ndx-1));
   END

   RETURN @val;
END
/*
EXEC test.test_084_fnGetFileNameFromPath;
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--====================================================================================
-- Author:           Terry Watts in concert with ChapGPT
-- Create date:      10-Jul-2025
-- Rtn:              test.test_061_sp_aggregate_row_to_string
-- Description: main test routine for the dbo.sp_aggregate_row_to_string routine 
--====================================================================================
CREATE PROCEDURE [dbo].[sp_aggregate_row_to_string]
    @TableName   SYSNAME,
    @WhereClause NVARCHAR(MAX), -- e.g., 'ID = 1'
    @Sep         NVARCHAR(10) = ',',  -- separator between columns
    @Result      NVARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX) = '';
    DECLARE @colExpr NVARCHAR(MAX) = '';
    DECLARE @sepLiteral NVARCHAR(20) = QUOTENAME(@sep, ''''); -- e.g. ',' → "','"
    SET @sep = ISNULL(@Sep, ',');

    -- Cursor to loop over all columns
    DECLARE col_cursor CURSOR FOR
    SELECT name
    FROM sys.columns
    WHERE object_id = OBJECT_ID(@TableName);

    DECLARE @col SYSNAME;
    DECLARE @first BIT = 1;

    OPEN col_cursor;
    FETCH NEXT FROM col_cursor INTO @col;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @first = 1
        BEGIN
            SET @colExpr = CONCAT('ISNULL(CAST(', QUOTENAME(@col), ' AS NVARCHAR(MAX)), '''')');
            SET @first = 0;
        END
        ELSE
        BEGIN
            SET @colExpr = CONCAT(@colExpr, ' + ', @sepLiteral, ' + ISNULL(CAST(', QUOTENAME(@col), ' AS NVARCHAR(MAX)), '''')');
        END

        FETCH NEXT FROM col_cursor INTO @col;
    END

    CLOSE col_cursor;
    DEALLOCATE col_cursor;

    -- Build the final dynamic SQL
    SET @sql = '
        SELECT @ResultOut = ' + @colExpr + '
        FROM ' + QUOTENAME(@TableName) + '
        WHERE ' + @WhereClause;

    -- Execute it
    EXEC sp_executesql
        @sql,
        N'@ResultOut NVARCHAR(MAX) OUTPUT',
        @ResultOut = @Result OUTPUT;
END

/*
DECLARE @act_file_cols NVARCHAR(MAX);
EXEC sp_aggregate_row_to_string 'Enrollment','enrollment_id = 1',',', @act_file_cols OUTPUT;
PRINT @act_file_cols;

SELECT * FROM Enrollment WHERE enrollment_id = 1;
--> 12023-1908112

EXEC test.sp__crt_tst_rtns '[dbo].[sp_aggregate_row_to_string]';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--=======================================================================================
-- Author:           Terry Watts
-- Create date:      12-Jun-2025
-- Rtn:              test.hlpr_068_sp_crt_pop_table
-- Description: test helper for the dbo.sp_crt_pop_table routine tests 
--
-- Tested rtn description:
-- Create and populate a table from a data file
--
-- Design:      EA: Model.Use Case Model.Create and populate a table from a data file
-- Define the import data file path
-- Table name = file name
-- Reads the header for the column names
-- Create a table with table name, columns = field names, type = text
-- Create a staging table
-- Create a format file using BCP and the table
-- Generate the import routine using the table and the format file
--
-- Parameters:
--    @file_path     VARCHAR(500) -- the import data file path
--
-- Test strategy:
-- Test 01. Check no error occurred
-- Test 02: Check the table exists
-- Test 03: Check the columns match the file columns
-- Test 04: Check the data matches
-- Test 04.01: check the row count of the table matches that of the file
-- Test 04.02: check the first row all columns
-- Test 04.03: check the last row all columns
--=======================================================================================
CREATE PROCEDURE [test].[hlpr_068_sp_crt_pop_table]
    @tst_num            VARCHAR(50)
   ,@display_tables     BIT
   ,@inp_file_path      VARCHAR(250)
   ,@inp_sep            VARCHAR(6)
   ,@inp_codepage       INT
   ,@inp_display_tables BIT
   ,@exp_row_cnt        INT             = NULL
   ,@exp_ex_num         INT             = NULL
   ,@exp_ex_msg         VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn                 VARCHAR(35)    = N'hlpr_068_sp_crt_pop_table'
   ,@error_msg          VARCHAR(1000)
   ,@NL                 CHAR = CHAR(13)
   ,@tab                CHAR = CHAR(9)
   ,@act_row_cnt        INT
   ,@act_RC             INT
   ,@act_ex_num         INT
   ,@act_ex_msg         VARCHAR(500)
   ,@act_tbl_cols       VARCHAR(8000)
   ,@exp_file_cols      VARCHAR(8000)
   ,@act_file_cols      VARCHAR(8000)
   ,@exp_table_nm       VARCHAR(60 )    = NULL

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;
      SET @exp_table_nm = dbo.fnGetFileNameFromPath(@inp_file_path, 0); -- 0:ignore extension

      EXEC sp_log 1, @fn ,' starting
tst_num           :[', @tst_num           ,']
display_tables    :[', @display_tables    ,']
inp_file_path     :[', @inp_file_path     ,']
inp_sep           :[', @inp_sep           ,']
inp_codepage      :[', @inp_codepage      ,']
inp_display_tables:[', @inp_display_tables,']
@exp_table_nm     :[', @exp_table_nm      ,']
exp_row_cnt       :[', @exp_row_cnt       ,']
ex_num            :[', @exp_ex_num        ,']
ex_msg            :[', @exp_ex_msg        ,']
';

      -- SETUP: ??

      WHILE 1 = 1
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.sp_crt_pop_table';
            ------------------------------------------------------------
            EXEC @act_RC = dbo.sp_crt_pop_table
                @file_path       = @inp_file_path
               ,@sep             = @inp_sep
               ,@codepage        = @inp_codepage
               ,@display_tables  = @inp_display_tables
               ;
  
            SELECT @act_row_cnt = @@ROWCOUNT;
            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.sp_crt_pop_table';

            IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
            BEGIN
               EXEC sp_log 4, @fn, '030: oops! Expected exception was not thrown';
               THROW 51000, ' Expected exception was not thrown', 1;
            END
         END TRY
         BEGIN CATCH
            SET @act_ex_num = ERROR_NUMBER();
            SET @act_ex_msg = ERROR_MESSAGE();
            EXEC sp_log 1, @fn, '040: caught  exception: ', @act_ex_num, ' ',      @act_ex_msg;
            EXEC sp_log 1, @fn, '050: check ex num: exp: ', @exp_ex_num, ' act: ', @act_ex_num;

            IF @exp_ex_num IS NULL AND @exp_ex_msg IS NULL
            BEGIN
               EXEC sp_log 4, @fn, '060: an unexpected exception was raised';
               THROW;
            END

            ------------------------------------------------------------
            -- ASSERTION: if here then expected exception
            ------------------------------------------------------------
            IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals      @exp_ex_num, @act_ex_num, 'ex_num mismatch';
            IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertIsSubString @exp_ex_msg, @act_ex_msg, 'ex_msg mismatch';
            
            EXEC sp_log 2, @fn, '070 test# ',@tst_num, ': exception test PASSED;'
            BREAK
         END CATCH

         -- TEST:
         EXEC sp_log 2, @fn, '075: running tests   ';

         -- Test 01. Check no error occurred - implicit with the exception handler here
         -- Test 02: Check the table exists
         EXEC sp_assert_tbl_exists @exp_table_nm, 1, '080: expected table'

         -- Test 03: Check the columns match the file columns
         -- Get the table cols
         SELECT @act_tbl_cols = string_agg( column_name, ',') FROM dbo.fnGetTableColumns(@exp_table_nm, NULL);

         -- Get the file cols
         EXEC sp_log 2, @fn, '085: Get the file cols, @inp_file_path:[',@inp_file_path,']';
         TRUNCATE TABLE GenericStaging;
         --RETURN;

         EXEC @act_row_cnt = sp_import_txt_file
             @table           = 'GenericStaging'
            ,@file            = @inp_file_path
            ,@folder          = NULL
            ,@first_row       = 1
            ,@last_row        = 1
            ,@field_terminator= @NL
            ,@view            = 'ImportGenericStaging_vw'
            ,@codepage        = @inp_codepage
            ,@display_table   = 0
         ;

         EXEC tSQLt.AssertEquals 1, @act_row_cnt, '090 exp 1 hdr row';
         SELECT @act_file_cols = staging FROM GenericStaging;
         EXEC sp_log 2, @fn, '095: checking header cols in GenericStaging',@NL
               , '@act_file_cols:',@act_file_cols,@NL
               , '@act_file_cols:',@act_file_cols;

         SELECT @act_file_cols = REPLACE(@act_file_cols, @tab, ',');
         EXEC sp_log 2, @fn, '100: checking header cols in GenericStaging',@NL
               , '@act_file_cols:',@act_file_cols,@NL
               , '@act_tbl_cols :',@act_tbl_cols;

         EXEC tSQLt.AssertEquals @act_file_cols, @act_tbl_cols, '105: file/tbl col names match?', @detailed_tst=1;
         EXEC sp_log 2, @fn, '102: TRUNCATE TABLE GenericStaging';
         TRUNCATE TABLE GenericStaging;

         -- Test 04: Check the data matches
         -- Read the file data rows into GenericStaging (ex hdr row)
         EXEC sp_log 2, @fn, '105: Read the file data rows into GenericStaging file: ',sp_import_txt_file;
         EXEC @exp_row_cnt = sp_import_txt_file
             @table           = 'GenericStaging'
            ,@file            = @inp_file_path
            ,@folder          = NULL
            ,@first_row       = 2
--            ,@last_row        = 100
            ,@field_terminator= @NL
            ,@view            = 'ImportGenericStaging_vw'
            ,@codepage        = @inp_codepage
            ,@display_table   = 0
         ;

         -- Test 04.01: check the row count of the table matches that of the file

         EXEC @act_row_cnt = sp_GetTxtFileLineCount @inp_file_path;
         EXEC tSQLt.AssertEquals @exp_row_cnt, @act_row_cnt,'110 row_cnt';

         -- Test 04.02: check the first row all columns
         SELECT @exp_file_cols = staging FROM (SELECT TOP 1 staging FROM GenericStaging) A;
         EXEC sp_aggregate_row_to_string @exp_table_nm,'ID = 1',',', @act_file_cols OUTPUT;

         EXEC sp_log 2, @fn, '111: ', @NL, '@exp_file_cols:[', @exp_file_cols,']', @NL
         ,'@act_file_cols:[',@act_file_cols,']'
        ;

         EXEC tSQLt.AssertEquals @exp_file_cols, @act_file_cols, '115 first row exp/act';

         -- Test 04.03: check the last row all columns
         SELECT @exp_file_cols = staging FROM (SELECT TOP 1 staging FROM GenericStaging ORDER BY id DESC) A;
         EXEC sp_log 2, @fn, '120: @exp_file_cols:[', @exp_file_cols,'] before replace';
         SELECT @exp_file_cols = REPLACE(@exp_file_cols, @tab, ',');
         EXEC sp_log 2, @fn, '125: @exp_file_cols:[', @exp_file_cols,'] after replace ';
         EXEC sp_aggregate_row_to_string @exp_table_nm,'ID = 1',',',@act_file_cols OUTPUT;
         EXEC tSQLt.AssertEquals @exp_file_cols, @act_file_cols, '130 last row exp/act';

         ------------------------------------------------------------
         -- Passed tests
         ------------------------------------------------------------
         BREAK
      END --WHILE

      -- CLEANUP: ??

      EXEC sp_log 1, @fn, '990: all subtests PASSED';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, 'Caught exception';
      EXEC test.sp_tst_hlpr_hndl_failure;
      THROW;
   END CATCH

   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_068_sp_crt_pop_table';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if a sql_variant is an
-- approximate type: {float, real or numeric}
-- test: [test].[t 025 fnIsFloat]
-- ================================================
CREATE FUNCTION [dbo].[fnIsFloatType](@ty VARCHAR(20))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('float','real','numeric'), 1, 0);
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type GUID
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsGuidType](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   RETURN iif(CONVERT(VARCHAR(500), SQL_VARIANT_PROPERTY(@v, 'BaseType')) = 'uniqueidentifier', 1, 0);
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
--
-- Changes:
-- 241128: added optional check for non negative ints
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsIntType]( @ty VARCHAR(20))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('BIT','INT','SMALLINT','TINYINT','BIGINT','MONEY','SMALLMONEY'), 1, 0);
END
/*
SELECT dbo.fnIsInt('0',0) as [fnIsInt('0', 0)], dbo.fnIsInt('05',0) as [fnIsInt(05,0)]
SELECT dbo.fnIsInt('0',1) as [fnIsInt('0',1)], dbo.fnIsInt('05',1) as [dbo.fnIsInt('05',1)]
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =====================================================================
-- Author:      Terry Watts
-- Create date: 31-OCT-2024
-- Description: determines if @ty is a text datatype
-- e.g. 'VARCHAR' is a text type
-- 
-- PRECONDITIONS: @ty is just the datatype without ()
-- e.g. 'VARCHAR' is OK but 'VARCHAR(20)' the output is undefined
-- =====================================================================
CREATE FUNCTION [dbo].[fnIsTextType](@ty   VARCHAR(500))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('char','nchar','varchar','nvarchar'), 1, 0);
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_097_fnIsTextType';
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: Returns true if a time type
--              Handles single and array types like INT and VARCHAR(MAX)
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsTimeType](@ty VARCHAR(20))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('date','datetime','datetime2','datetimeoffset','smalldatetime','TIME'), 1, 0);
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: Gets the type category for a Sql Uerver datatype
-- e.g. Exact types : INT, MONEY 
-- Floating point types: float real
--
-- TESTS:
-- ===================================================================
CREATE FUNCTION [dbo].[fnGetTypeCat](@ty VARCHAR(25))
RETURNS VARCHAR(25)
AS
BEGIN
   DECLARE @type SQL_VARIANT
   ;

   RETURN
      CASE
         WHEN dbo.fnIsIntType (@ty)     = 1 THEN 'Int'
         WHEN dbo.fnIsTextType(@ty)     = 1 THEN 'Text'
         WHEN dbo.fnIsTimeType(@ty) = 1 THEN 'Time'
         WHEN dbo.fnIsFloatType(@ty)    = 1 THEN 'Float'
         WHEN dbo.fnIsGuidType(@ty)     = 1 THEN 'GUID'
         END;
END
/*
EXEC test.sp__crt_tst_rtns '[dbo].[fnGetTypeCat]';
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type BIT
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsBoolType](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   RETURN iif( @v = 'bit', 1,0);
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Author:      Terry Watts
-- Create date: 05-JAN-2021
-- Description: function to compare values - includes an
--              approx equal check for floating point types
-- Returns 1 if equal, 0 otherwise
-- =========================================================
CREATE FUNCTION [dbo].[fnChkEquals]( @a SQL_VARIANT, @b SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE
    @fn     VARCHAR(35)   = N'sp_fnChkEquals'
   ,@res    BIT
   ,@a_str  VARCHAR(4000) = CONVERT(VARCHAR(400), @a)
   ,@b_str  VARCHAR(4000) = CONVERT(VARCHAR(400), @b)
   ,@a_ty   VARCHAR(25)   = CONVERT(VARCHAR(25), SQL_VARIANT_PROPERTY(@a, 'BaseType'))
   ,@b_ty   VARCHAR(25)   = CONVERT(VARCHAR(25), SQL_VARIANT_PROPERTY(@b, 'BaseType'))
   ;

   -- NULL check
   IF @a IS NULL AND @b IS NULL
   BEGIN
      RETURN 1;
   END

   IF @a IS NULL AND @b IS NOT NULL
   BEGIN
      RETURN 0;
   END

   IF @a IS NOT NULL AND @b IS NULL
   BEGIN
      RETURN 0;
   END

   -- if both are floating point types, fnCompareFloats evaluates  fb comparison to accuracy +- epsilon
   -- any differnce less that epsilon is consider insignifacant so considers and b to =
   -- fnCompareFloats returns 1 if a>b, 0 if a==b, -1 if a<b
   IF (dbo.[fnIsFloatType](@a_ty) = 1) AND (dbo.[fnIsFloatType](@b_ty) = 1)
   BEGIN
      RETURN iif(dbo.[fnCompareFloats](CONVERT(FLOAT(24), @a), CONVERT(FLOAT(24), @b)) = 0, 1, 0);
   END

   -- if both are int types
   IF (dbo.fnIsIntType(@a_ty) = 1) AND (dbo.fnIsIntType(@b_ty) = 1)
      RETURN iif(CONVERT(BIGINT, @a) = CONVERT(BIGINT, @b), 1, 0);

   -- if both are string types
   IF (dbo.fnIsTextType(@a_ty) = 1) AND (dbo.fnIsTextType(@b_ty) = 1)
      RETURN iif(@a_str = @b_str, 1, 0);

   -- if both are boolean types
   IF (dbo.fnIsBoolType(@a_ty) = 1) AND (dbo.fnIsBoolType(@b_ty) = 1)
      RETURN iif(CONVERT(BIT, @a) = CONVERT(BIT, @b), 1, 0);

   -- if both are datetime types
   IF (dbo.fnIsTimeType(@a_ty) = 1) AND (dbo.fnIsTimeType(@b_ty) = 1)
      RETURN iif( CONVERT(DATETIME, @a) = CONVERT(DATETIME, @b), 1, 0);

   -- if both are guid types
   IF (dbo.fnIsGuidType(@a_ty) = 1) AND (dbo.fnIsGuidType(@b_ty) = 1)
      RETURN iif(CONVERT(UNIQUEIDENTIFIER, @a) = CONVERT(UNIQUEIDENTIFIER, @b), 1, 0);

   ----------------------------------------------------
   -- Compare by type cat
   ----------------------------------------------------

   DECLARE
    @a_cat  VARCHAR(25)
   ,@b_cat  VARCHAR(25)

   SET @a_cat = [dbo].[fnGetTypeCat](@a_ty);
   SET @b_cat = [dbo].[fnGetTypeCat](@b_ty);

   if(@a_cat = @b_cat)
   BEGIN
      IF @a_cat = 'Int'
      BEGIN
         SET @res = iif(CONVERT(BIGINT, @a) = CONVERT(BIGINT, @b), 1, 0);
      END
      ELSE IF @a_cat = 'Float'
      BEGIN
         SET @res = iif(CONVERT(FLOAT(24), @a) = CONVERT(FLOAT(24), @b), 1, 0);
      END
      ELSE IF @a_cat = 'Text'
      BEGIN
         SET @res = iif(CONVERT(VARCHAR(8000), @a) = CONVERT(VARCHAR(8000), @b), 1, 0);
      END
      ELSE IF @a_cat = 'Time'
      BEGIN
         SET @res = iif(CONVERT(DATETIME2, @a) = CONVERT(DATETIME2, @b), 1, 0);
      END
      ELSE IF @a_cat = 'GUID'
      BEGIN
         SET @res = iif(CONVERT(UNIQUEIDENTIFIER, @a) = CONVERT(UNIQUEIDENTIFIER, @b), 1, 0);
      END

      RETURN @res;
   END

   ----------------------------------------------------------------------
   -- Can compare Floats with integral types -> convert both to big float
   ----------------------------------------------------------------------
   IF (@a_cat='Int' AND @b_cat='Float') OR (@a_cat='Float' AND @b_cat='Int')
   BEGIN
      RETURN iif(CONVERT(FLOAT(24), @a) = CONVERT(FLOAT(24), @b), 1, 0);
   END

   ----------------------------------------------------
   -- Final option: compare by converting to text
   ----------------------------------------------------
   SET @res = iif(@a_str = @b_str, 1, 0)
   RETURN @res;
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry watts
-- Create date: 21-JAN-2020
-- Description: 1 line check null or mismatch and throw message
--              ASSUMES data types are the same
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_equal]
    @a         SQL_VARIANT
   ,@b         SQL_VARIANT
   ,@msg0      VARCHAR(MAX)   = NULL
   ,@msg1      VARCHAR(MAX)   = NULL
   ,@msg2      VARCHAR(MAX)   = NULL
   ,@msg3      VARCHAR(MAX)   = NULL
   ,@msg4      VARCHAR(MAX)   = NULL
   ,@msg5      VARCHAR(MAX)   = NULL
   ,@msg6      VARCHAR(MAX)   = NULL
   ,@msg7      VARCHAR(MAX)   = NULL
   ,@msg8      VARCHAR(MAX)   = NULL
   ,@msg9      VARCHAR(MAX)   = NULL
   ,@msg10     VARCHAR(MAX)   = NULL
   ,@msg11     VARCHAR(MAX)   = NULL
   ,@msg12     VARCHAR(MAX)   = NULL
   ,@msg13     VARCHAR(MAX)   = NULL
   ,@msg14     VARCHAR(MAX)   = NULL
   ,@msg15     VARCHAR(MAX)   = NULL
   ,@msg16     VARCHAR(MAX)   = NULL
   ,@msg17     VARCHAR(MAX)   = NULL
   ,@msg18     VARCHAR(MAX)   = NULL
   ,@msg19     VARCHAR(MAX)   = NULL
   ,@ex_num    INT             = 50001
   ,@fn        VARCHAR(35)    = N'*'
   ,@log_level INT            = 0
AS
BEGIN
DECLARE
    @fnThis VARCHAR(35) = 'sp_assert_equal'
   ,@aTxt   VARCHAR(100)= CONVERT(VARCHAR(20), @a)
   ,@bTxt   VARCHAR(100)= CONVERT(VARCHAR(20), @b)

   EXEC sp_log @log_level, @fnThis, '000: starting @a:[',@aTxt, '] @b:[', @bTxt, ']';

   IF dbo.fnChkEquals(@a ,@b) <> 0
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fnThis, '010: OK, @a:[',@aTxt, '] = @b:[', @bTxt, ']';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   EXEC sp_log 3, @fnThis, '020: @a:[',@aTxt, '] <> @b:[', @bTxt, '], raising exception';

   EXEC sp_raise_exception
       @msg0   = @msg0 
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
      ,@ex_num = @ex_num
      ,@fn     = @fn
END
/*
   EXEC tSQLt.RunAll;
   EXEC sp_assert_equal 1, 1;
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Author:      Terry Watts
-- Create date: 06-DEc-2024
-- Description: compares 2 SQL_VARIANTs
-- RULES:
-- R01: if a < b return 1, 0 otherwise
-- R02: if types are same then a normal comparison should be used
-- R03: NULL < NULL returns 0
-- R04: NULL < NON NULL returns 1
-- R05: NON NULL < NULL returns 0
-- R06: different types try to convert to strings and then compare
--
-- Postconditions
-- Post 01: if a < b return 1
-- Post 02: if types are same then a normal comparison should be used
-- Post 03: NULL < NULL returns 0
-- Post 04: NULL < NON NULL returns 1
-- Post 05: NON NULL < NULL returns 0
-- Post 06: different types try to convert to strings and then compare
-- =========================================================
CREATE FUNCTION [dbo].[fnIsLessThan]( @a SQL_VARIANT, @b SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE 
       @aTxt   VARCHAR(4000)
      ,@bTxt   VARCHAR(4000)
      ,@typeA  VARCHAR(50)
      ,@typeB  VARCHAR(50)
      ,@ret    BIT
      ,@res    INT

   ------------------------------------------------------
   -- Handle Null NULL
   ------------------------------------------------------
   IF @a IS NULL AND @b IS NULL RETURN 0;

   ------------------------------------------------------
   -- Handle Null not NULL scenarios
   ------------------------------------------------------
   IF @a IS NULL AND @b IS NOT NULL RETURN 1;
   IF @a IS NOT NULL AND @a IS NULL RETURN 0;

   ------------------------------------------------------
   -- ASSERTION: Both a and b are not NULL
   ------------------------------------------------------

   ------------------------------------------------------
   -- Handle different types
   ------------------------------------------------------
   SELECT @typeA = CONVERT(VARCHAR(500),SQL_VARIANT_PROPERTY(@a, 'BaseType'))
         ,@typeB = CONVERT(VARCHAR(500),SQL_VARIANT_PROPERTY(@b, 'BaseType'))
    ;

   IF @typeA <> @typeB
   BEGIN
      SELECT @aTxt = CONVERT(VARCHAR(500),@a)
            ,@bTxt = CONVERT(VARCHAR(500),@b);

      RETURN iif(@aTxt < @bTxt, 1, 0);
   END

   ------------------------------------------------------
   -- ASSERTION: Both a and b are the same type
   ------------------------------------------------------

   ------------------------------------------------------
   -- Handle types where the variant < operator
   -- does not return correct value
   ------------------------------------------------------

   ------------------------------------------------------
   -- Handle general case where variant < operator works
   ------------------------------------------------------

   RETURN iif(@a<@b, 1, 0);
END
/*
EXEC test.test_054_fnIsLT
EXEC tSQLt.Run 'test.test_054_fnIsLT';
EXEC tSQLt.RunAll;
PRINT DB_Name()

   DECLARE 
       @a      SQL_VARIANT = 2
      ,@b      SQL_VARIANT = '2'
      ,@aTxt   VARCHAR(4000) = CONVERT(VARCHAR(500),@a)
      ,@bTxt   VARCHAR(4000) = CONVERT(VARCHAR(500),@b)
      ;
   PRINT iif(@a<@b, 1, 0);

   DECLARE 
       @a      SQL_VARIANT =  2
      ,@b      SQL_VARIANT = 'abc'
      ,@aTxt   VARCHAR(4000)
      ,@bTxt   VARCHAR(4000)
      ;

   SELECT @aTxt = CONVERT(VARCHAR(500),@a)
         ,@bTxt = CONVERT(VARCHAR(500),@b)

   PRINT iif(@a<@b, 1, 0);
   PRINT iif(@b<@a, 1, 0);
   PRINT iif(@aTxt<@bTxt, 1, 0);
   PRINT iif(@bTxt<@aTxt, 1, 0);
   PRINT CONCAT('[',@aTxt, ']');
   PRINT CONCAT('[',@bTxt, ']');
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: asserts that a is greater than b
--              raises an exception if not
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_gtr_than]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       VARCHAR(200)  = NULL
      ,@msg2      VARCHAR(200)  = NULL
      ,@msg3      VARCHAR(200)  = NULL
      ,@msg4      VARCHAR(200)  = NULL
      ,@msg5      VARCHAR(200)  = NULL
      ,@msg6      VARCHAR(200)  = NULL
      ,@msg7      VARCHAR(200)  = NULL
      ,@msg8      VARCHAR(200)  = NULL
      ,@msg9      VARCHAR(200)  = NULL
      ,@msg10     VARCHAR(200)  = NULL
      ,@msg11     VARCHAR(200)  = NULL
      ,@msg12     VARCHAR(200)  = NULL
      ,@msg13     VARCHAR(200)  = NULL
      ,@msg14     VARCHAR(200)  = NULL
      ,@msg15     VARCHAR(200)  = NULL
      ,@msg16     VARCHAR(200)  = NULL
      ,@msg17     VARCHAR(200)  = NULL
      ,@msg18     VARCHAR(200)  = NULL
      ,@msg19     VARCHAR(200)  = NULL
      ,@ex_num    INT            = 53502
      ,@fn        VARCHAR(60)    = N'*'
   ,@log_level INT            = 0
AS
BEGIN
   DECLARE
       @fnThis VARCHAR(35) = 'sp_assert_gtr_than'
      ,@aTxt   VARCHAR(100)= CONVERT(VARCHAR(100), @a)
      ,@bTxt   VARCHAR(100)= CONVERT(VARCHAR(100), @b)

   EXEC sp_log @log_level, @fnThis, '000: starting @a:[',@aTxt, '] @b:[', @bTxt, ']';

   -- a>b -> b<a 
   IF dbo.fnIsLessThan(@b ,@a) = 1
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fnThis, '010: OK, @a:[',@aTxt, '] IS GTR THN @b:[', @bTxt, ']';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   EXEC sp_log 3, @fnThis, '020: [',@aTxt, '] IS GTR THN [', @bTxt, '] IS FALSE, raising exception';

   EXEC sp_raise_exception
          @msg1   = @msg
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
         ,@ex_num = @ex_num
         ,@fn     = @fn
   ;
END
/*
EXEC sp_assert_gtr_than 4, 5;
EXEC sp_assert_gtr_than 5, 4;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_055_sp_assert_gtr_than';
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry
-- Create date: 03-DEC-2024
-- Description: Gets the current failed test num from settings
-- Tests: test_049_SetGetCrntTstValue
-- =============================================================
CREATE FUNCTION [test].[fnGetCrntTst1OffSetupFnKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Tst1OffSetupFn';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests: test_049_SetGetCrntTstValue
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_1_off_setup_fn] @val VARCHAR(80)
AS
BEGIN
   DECLARE
      @fn   VARCHAR(35) = 'sp_tst_set_crnt_1_off_setup_fn'
     ,@key  NVARCHAR(40)= test.fnGetCrntTst1OffSetupFnKey()
     ;

   EXEC sp_log 0, @fn, 'starting, @val:[',@val,']';
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC tSQLt.Run 'test.test_049_SetGetCrntTstValue'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current close fn name from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstClsFnKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'TCLS fn';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests:       test_049_SetGetCrntTstValue
-- Oppo:        test.fnGetCrntTstClseFn
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_clse_fn] @val VARCHAR(80)
AS
BEGIN
   DECLARE
    @fn  VARCHAR(35) = N'sp_tst_set_crnt_tst_clse_fn'
   ,@key NVARCHAR(40);

   SET @key = test.fnGetCrntTstClsFnKey()
   EXEC sp_log 0, @fn,'000: starting, @val: ', @val;
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.test_049_SetGetCrntTstValue
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: Sets the @tst_num in the session context
--              Key: fnGetCrntTstNumKey()->N'Test num'
--
-- Tests:       test.test_049_SetGetCrntTstValue
-- Oppo         test.fnGetCrntTstNum()
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_num] @tst_num VARCHAR(60)
AS
BEGIN
DECLARE
    @fn     VARCHAR(35) = 'sp_tst_set_crnt_tst_num'
   ,@key    NVARCHAR(60);

   SET @key = test.fnGetCrntTstNumKey();
   EXEC sp_log 0, @fn,'000: starting, fn: ', @fn, ' key:[', @key,'] @tst_num:[',@tst_num,']';
   EXEC sp_set_session_context @key, @tst_num;
END
/*
EXEC tSQLt.Run 'test.test_030_chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current per test fn name from settings
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstSetupFnKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'TSU fn';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests:       test 030 chkTestConfig
-- Key:         N'TSU fn'
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_setup_fn] @val VARCHAR(80)
AS
BEGIN
   DECLARE @key NVARCHAR(40) = test.fnGetCrntTstSetupFnKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
PRINT test.fnGetCrntTstSetupFnKey()
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current tested fn name from settings
-- Key:         N'Tested fn'
-- Tests:       test.test 030 chkTestConfig
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstdFnKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Tested fn';
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests:       test_030_chkTestConfig
-- Key:         'Tested fn'
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tstd_fn] @val VARCHAR(80)
AS
BEGIN
   DECLARE @key NVARCHAR(40) = test.fnGetCrntTstdFnKey();
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC tSQLt.Run 'test.test_030_chkTestConfig';
EXEC tSQLt.RunAll;
PRINT test.fnGetCrntTstdFnKey();
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 06-FEB-2021
-- Description: Gets the display log flag key
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetDisplayLogFlgKey]()
RETURNS NVARCHAR(30)
AS
BEGIN
   RETURN N'Display Log Flag';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests:       test_030_chkTestConfig
-- Key:         Display Log Flag
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_display_log_flg] @val BIT
AS
BEGIN
   DECLARE @key NVARCHAR(6) = test.fnGetDisplayLogFlgKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
PRINT test.fnGetDisplayLogFlgKey()
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests: [test].[test 030 chkTestConfig]
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_fn] @val VARCHAR(80)
AS
BEGIN
   DECLARE @key NVARCHAR(40) = test.fnGetCrntTstFnKey();
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry watts
-- Create date: 05-FEB-2021
-- Description: Setter: for the test helper fn
-- Tests: [test].[test 030 chkTestConfig]
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_hlpr_fn] @val VARCHAR(100)
AS
BEGIN
   DECLARE @key NVARCHAR(60) = test.fnGetCrntTstHlprFnKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
PRINT test.fnGetCrntTstHlprFnNmKey()
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================
-- Author:      Terry watts
-- Create date: 06-FEB-2021
-- Description: Setter, clears the test pass count
-- Tests: test.test_030_chkTestConfig
-- ================================================
CREATE PROCEDURE [test].[sp_tst_clr_test_pass_cnt]
AS
BEGIN
   DECLARE @key NVARCHAR(40) = test.fnGetTstPassCntKey()
   EXEC sp_set_session_context @key, 0;
END
/*
EXEC test.test 030 chkTestConfig;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: determines if a character is whitespace
--
-- whitespace is: 
-- (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160))
--
-- RETURNS: 1 if is whitspace, 0 otherwise
-- ===============================================================================================
CREATE FUNCTION [dbo].[fnIsWhitespace]( @t NCHAR) 
RETURNS BIT
AS
BEGIN
   RETURN CASE WHEN  @t IN (NCHAR(9) , NCHAR(10), NCHAR(11), NCHAR(12)
                           ,NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160)) THEN 1 
              ELSE 0 END
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: determines if the string contains whitespace
--
-- whitespace is: 
-- (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160))
--
-- RETURNS: 1 if string contains whitspace, 0 otherwise
-- ==========================================================================================
CREATE FUNCTION [dbo].[fnContainsWhitespace]( @s VARCHAR(4000))
RETURNS BIT
AS
BEGIN
   DECLARE
       @res       BIT = 0
      ,@i         INT = 1
      ,@len       INT = dbo.fnLen(@s)

   WHILE @i <= @len
   BEGIN
      IF dbo.fnIswhitespace(SUBSTRING(@s, @i, 1))=1
      BEGIN
         SET @res = 1;
         break;
      END

      SET @i = @i + 1;
   END

   RETURN @res;
END



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
--
-- Changes:
-- 241128: added optional check for non negative ints
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsTxtInt]( @v VARCHAR(50), @must_be_positive BIT)
RETURNS BIT
AS
BEGIN
   DECLARE @val INT
   ,@ret BIT

   -- SETUP
   IF @must_be_positive IS NULL  SET @must_be_positive = 0;

   -- PROCESS
   SET @val = TRY_CONVERT(INT, @v);
   SET @ret = iif(@val IS NULL, 0, 1);

      IF @ret = 1 AND @must_be_positive = 1
      BEGIN
         SET @ret = iif(@val >=0, 1, 0);
      END

   RETURN @ret;
END

/*
   DECLARE
       @v_str  VARCHAR(4000)
      ,@ret    BIT = 0
      ,@val    INT

--   DECLARE @type SQL_VARIANT
--   DECLARE @ty   VARCHAR(500)
--   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
--   SET @ty = CONVERT(VARCHAR(20), @type);
   SET @v_str = CONVERT(VARCHAR(4000), @v);

   WHILE(1=1)
   BEGIN
      IF dbo.fnLen(@v_str) = 0
         BREAK;

      IF @must_be_positive IS NULL  SET @must_be_positive = 0;
      SET @val = TRY_CONVERT(INT, @v);

      SET @ret = iif(@val IS NULL, 0, 1);

      IF @ret = 1 AND @must_be_positive = 1
      BEGIN
         --SET @val =  CONVERT(INT, @v);
         SET @ret = iif(@val >=0, 1, 0);
      END

      BREAK;
   END
   RETURN @ret;
END
*/
/*
PRINT CONVERT(INT, NULL);
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_044_fnIsInt';
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: main start set up
--
-- Responsibilities:
--    clear  test_pass_cnt= 0,
--
--    pop  the following:
--    crnt_tstd_fn
--    crnt_tst_fn
--    crnt_tst_hlpr_fn
--    rnt_tst_1_off_setup_fn
--    crnt_tst_setup_fn
--    crnt_tst_clse_fn
--
-- Validated preconditions:
--    PRE 01: @tst_fn must have at least 11 characters and be like: like ''test_nnn_<tested rtn mn>chkTestConfig''
--    PRE 02: the nnn @tst_fn must be a positive integer
--    PRE 02: @tst_fn must have no spaces
--
-- Postconditions 
-- CHANGES:
-- 241128: added paramater validation
-- =============================================
CREATE PROCEDURE [test].[sp_tst_mn_st_su]
       @tst_fn    VARCHAR(80)   = NULL   -- test fn like 'test 030 chkTestConfig'
      ,@log       BIT            = 1
AS
BEGIN
   DECLARE
       @tested_fn VARCHAR(60)            -- the tested function name
      ,@fn_num    VARCHAR(3)             
      ,@hlpr_fn   VARCHAR(60)            -- helper fn
      ,@tsu_fn    VARCHAR(60)            -- tsu    fn
      ,@tsu1_fn   VARCHAR(60)            -- tsu    fn
      ,@tcls_fn   VARCHAR(60)            -- close  fn
      ,@key       VARCHAR(40)
      ,@fn        VARCHAR(60) = N'sp_tst_mn_st_su'
      ,@len       INT
      ,@msg       VARCHAR(150)
      ,@is_num    BIT

   BEGIN TRY
      --PRINT CONCAT(@fn, ': 1')
      EXEC sp_log 0, @fn,'000: starting, @tst_fn:[',@tst_fn,']';
      --PRINT CONCAT(@fn, ': 2')
      ----------------------------------------------------------------------------------
      -- Validate inputs
      ----------------------------------------------------------------------------------
      EXEC sp_log 0, @fn,'010: Validate inputs';
--      PRINT CONCAT(@fn, ': 3')
      -- test fn like 'test 030 chkTestConfig'
      SET @len = dbo.fnLen(@tst_fn);
      --EXEC sp_log 0, @fn,'020: @len: ', @len;
      SET @msg = CONCAT(' ',@fn, ' @tst_fn: [',@tst_fn,'] must have at least 11 characters and be like: like ''test_nnn_<tested rtn mn>chkTestConfig'' and have no spaces,
      nnn must be a positive integer like 015');

      -- PRE 01: @tst_fn must have at least 11 characters and be like: like ''test_nnn_<tested rtn mn>chkTestConfig''
      --EXEC sp_log 0, @fn,'030 calling sp_assert_gtr_than @len: ', @len;
      EXEC sp_assert_gtr_than @len, 11, '011:', @msg;
      --EXEC sp_log 0, @fn,'040';
      SET @fn_num = SUBSTRING( @tst_fn, 6, 3 );
      --EXEC sp_log 0, @fn,'010.15';
--      PRINT CONCAT(@fn, ': 10')
      EXEC dbo.sp_assert_not_null_or_empty @fn_num, '012: @fn_num must not be null @test_fn: ', @msg2 = @tst_fn;
      --EXEC sp_log 0, @fn,'050: calling dbo.fnIsInt(',@fn_num,', 1);';
      SET @is_num = dbo.fnIsTxtInt(@fn_num, 1);

      --EXEC sp_log 0, @fn,'010.2 checking that @tst_fn has a positive integer';
--    PRE 02: the nnn @tst_fn must be a positive integer
      EXEC sp_assert_equal 1, @is_num, '060: @fn_num: [', @fn_num, '] must be a positive integer like ''015''';

      EXEC sp_log 0, @fn,'070';
      SET @tested_fn = SUBSTRING( @tst_fn, 10, 100);
      --EXEC sp_log 0, @fn, '080: @tested_fn:[', @tested_fn, ']';
      EXEC dbo.sp_assert_not_null_or_empty @tested_fn, '013: tested_fn must be specified - chars 10-100 of @tst_fn psram';
      --EXEC sp_log 0, @fn,'010.4';
  --    PRINT CONCAT(@fn, ': 20')

      -- PRE 03: @tst_fn must have no spaces
      IF CHARINDEX(' ', @tst_fn) > 0
      BEGIN
         EXEC sp_log 4, @fn,'090: @tst_fn must have no spaces';
         EXEC sp_raise_exception 56010, @fn, ' PRE 03: @tst_fn must have no spaces';
      END

      EXEC sp_log 0, @fn,'100';

      IF CHARINDEX('test_', @tst_fn )<> 1
      BEGIN
         EXEC sp_log 4, @fn,'110: test rtn nam should start with ''TEST_''';
         EXEC sp_raise_exception 53602, '100: ', @msg;
      END

      EXEC sp_log 0, @fn,'120: Validate inputs - OK';
      ----------------------------------------------------------------------------------
      -- Calc the test fn names for this test
      ----------------------------------------------------------------------------------
      -- Set the logging flag
      EXEC test.sp_tst_set_display_log_flg @log;

      SET @hlpr_fn = CONCAT(N'hlpr_', @fn_num, N' ', @tested_fn);
      SET @tsu_fn  = CONCAT(N'TSU ' , @fn_num, N' ', @tested_fn);
      SET @tsu1_fn = CONCAT(N'TSU1 ', @fn_num, N' ', @tested_fn);
      SET @tcls_fn = CONCAT(N'TCLS ', @fn_num, N' ', @tested_fn);

      ----------------------------------------------------------------------------------
      -- Validate
      ----------------------------------------------------------------------------------
      --EXEC sp_log 0, @fn, '130: @tested_fn:[', @tested_fn, ']';
      --EXEC sp_log 0, @fn, '140: @fn_num:[', @fn_num, ']';
      EXEC dbo.sp_assert_not_null_or_empty @hlpr_fn  , @msg1 = '140: @hlpr_fn  must be specified';
      EXEC dbo.sp_assert_not_null_or_empty @tsu_fn   , @msg1 = '150: @tsu_fn   must be specified';

      EXEC dbo.sp_assert_not_null_or_empty @tsu1_fn  , @msg1 = '160: @tsu1_fnm must be specified';
      EXEC dbo.sp_assert_not_null_or_empty @tcls_fn  , @msg1 = '170: @tcls_fn  must be specified';
      --EXEC sp_log 0, @fn,'909';
      SET @len = dbo.fnLen(@fn_num);

      EXEC dbo.sp_assert_equal 3, @len ,'200: @fn_num len should be 3';
      SET @len = dbo.fnContainsWhiteSpace(@fn_num);
      EXEC dbo.sp_assert_equal 0, @len ,'210: @fn_num len should not contain spaces';

      ----------------------------------------------------------------------------------
      -- Set the state:
      ----------------------------------------------------------------------------------
      EXEC test.sp_tst_clr_test_pass_cnt;
      EXEC test.sp_tst_set_crnt_tst_num @fn_num;               --  oppo: fnGetCrntTstNum()         KEY: N'Test num'
      EXEC test.sp_tst_set_crnt_tst_num2           @fn_num;    -- Just the 3 digit test number
      EXEC test.sp_tst_set_crnt_tstd_fn @tested_fn;            --  oppo: fnGetCrntTstdFn()         KEY: N'Tested fn'
      EXEC test.sp_tst_set_crnt_tst_fn @tst_fn;                -- oppo: fnGetCrntTstFn()           KEY: N'Test fn'
      EXEC test.sp_tst_set_crnt_tst_hlpr_fn @hlpr_fn;          -- oppo: fnGetCrntTstHlprFn()       KEY: N'Hlpr fn'
      EXEC test.sp_tst_set_crnt_tst_1_off_setup_fn @tsu1_fn;   -- oppo: fnGetCrntTst1OffSetupFn()  KEY: N'TSU1 fn'
      EXEC test.sp_tst_set_crnt_tst_setup_fn @tsu_fn;          -- oppo: fnGetCrntTstSetupFn()      KEY: N'TSU fn'

      EXEC test.sp_tst_set_crnt_tst_clse_fn @tcls_fn;          -- oppo: fnGetCrntTstCloseFn()      KEY: N'TCLS fn'
      EXEC sp_log 0, @fn,'400: Processing complete';
   END TRY
   BEGIN CATCH
      PRINT CONCAT(@fn, ': 499: Caught exception')
      EXEC sp_log 4, @fn,'500: Caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

--      PRINT CONCAT(@fn, ': 999')
   EXEC sp_log 0, @fn,'999: leaving OK'
END
/*
EXEC sp_Set_log_level 0
EXEC test.sp_tst_mn_st_su 'test_049_SetGetCrntTstValue'

ECEC test.sp_tst_mn_st 'test_049_SetGetCrntTstValue'
EXEC tSQLt.Run 'test.test_050_sp_assert_not_null_or_zero';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===========================================================
-- Author:      Terry Watts
-- Create date: 06-APR-2020
-- Description: Encapsulates the main test routine startup
-- Parameters:  @tfn: the test function name
--
-- Session Keys:
--    Test fn           : 'Test fn'
--    Tested fn         : 'Tested fn'
--    Helper fn         : 'Helper fn'
--    per test setup fn : 'TSU fn'
--    1 off setup fn    : 'TSU1 fn'
--    per test close fn : 'TCLS fn'
--
-- POSTCONDITIONS:
-- POST 01: if @test_fn null or empty -> ex:
-- ===========================================================
CREATE PROCEDURE [test].[sp_tst_mn_st]
       @tst_fn VARCHAR(80)   = NULL   -- test fn
      ,@log    BIT            = 0      -- default not to display the log
AS
BEGIN
   DECLARE
       @fn                    VARCHAR(60) = N'sp_tst_mn_st'
      ,@fn_tst_pass_cnt_key   VARCHAR(50)
      ,@NL                    VARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@Line                  VARCHAR(100)  = REPLICATE('-', 100)
      ,@tested_fn             VARCHAR(60)      -- the tested function name
      ,@is_short_msg          BIT
      ,@tsu_fn                VARCHAR(60)      -- tsu    fn
      ,@tsu1_fn               VARCHAR(60)      -- tsu    fn
      ,@tcls_fn               VARCHAR(60)      -- close  fn

   BEGIN TRY
      SET NOCOUNT ON
      PRINT test.fnGetTstHdrFooterLine(1, 1, @tst_fn, 'starting');
      DELETE FROM AppLog;
      SET @is_short_msg = iif(dbo.fnGetLogLevel()>1, 1,0);
      EXEC sp_log 0, @fn, '000: starting (',@tst_fn,')';

      -- Validate Parameters
      EXEC dbo.sp_assert_not_null_or_empty @tst_fn, '@test_fn parameter must be specified';
      EXEC sp_log 0, @fn, '005';
      SET @tested_fn = SUBSTRING(@fn, 10, 99);
      EXEC sp_log 0, @fn, '006';

      -- Stop any more logging in this fn
      EXEC sp_set_session_context N'TST_MN_ST'        , 1;
      EXEC sp_log 0, @fn, '007';

      -- set up all test fn names and initial state
      EXEC sp_log 0, @fn,'010: calling sp_tst_mn_tst_st_su';
      EXEC test.sp_tst_mn_st_su
       @tst_fn = @tst_fn
      ,@log    = @log;

      EXEC sp_log 0, @fn,'015: setting context state';
      -- ASSERTION: all test fn names set up and initial state initialised properly
      -- Add static test passed count
      SET @fn_tst_pass_cnt_key  = CONCAT(@fn, N' tests passed');
      EXEC sp_set_session_context   @fn_tst_pass_cnt_key , 0;
      EXEC sp_set_session_context N'DISP_TST_RES'        , 1;
      EXEC test.sp_tst_set_crnt_tst_err_st 0;
      END TRY
   BEGIN CATCH
      PRINT CONCAT('ERROR ', @fn, ' 500: caught exception');
      EXEC sp_log 4, @fn, '500: caught exception';
      PRINT CONCAT('ERROR ', @fn, ' 510: caught exception');
      EXEC sp_log_exception @fn;
      PRINT CONCAT('ERROR ', @fn, ' 520: caught exception');
      THROW;
   END CATCH

   EXEC sp_log 0, @fn,'999: leaving OK';
END
/*
EXEC tSQLt.Run 'test.test_059_sp_tst_mn_st'
EXEC 
EXEC tSQLt.RunAll
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current tested fn name from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstdFn]()
RETURNS VARCHAR(60)
AS
BEGIN
   RETURN CONVERT(VARCHAR(60), SESSION_CONTEXT(test.fnGetCrntTstdFnKey()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: accessor: error_state
-- Tests: test_049_SetGetCrntTstValue
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstErrSt]()
RETURNS INT
AS
BEGIN
   RETURN CONVERT( INT, SESSION_CONTEXT(test.fnGetCrntTstErrStKey()));
END
/*
PRINT [test].[fnGetCrntTstErrSt]()
*/



GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 06-FEB-2021
-- Description: Gets the display log flag
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetDisplayLogFlg]()
RETURNS BIT
AS
BEGIN
   RETURN CONVERT(BIT, SESSION_CONTEXT(test.fnGetDisplayLogFlgKey()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 15-JAN-2020
-- Description: returns standard NL char(s)
-- =============================================
CREATE FUNCTION [dbo].[fnGetNL]()
RETURNS VARCHAR(2)
AS
BEGIN
   RETURN NCHAR(13)+NCHAR(10)
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ========================================================
-- Author:      Terry Watts
-- Create date: 06-APR-2020
-- Description: Encapsulates the main test routine startup
-- ========================================================
CREATE PROCEDURE [test].[sp_tst_mn_cls] @err_msg VARCHAR(4000) = NULL
AS
BEGIN
   DECLARE
       @fn           VARCHAR(30)   = N'sp_tst_mn_cls'
      ,@tested_fn    VARCHAR(50)   = test.fnGetCrntTstdFn()
      ,@tst_fn       VARCHAR(50)   = test.fnGetCrntTstFn()
      ,@msg          VARCHAR(2000)
      ,@nl           VARCHAR(2)    = dbo.fnGetNL()
      ,@tests_passed INT
      ,@error_st     BIT            = test.fnGetCrntTstErrSt()
      ,@is_short_msg BIT

   SET @is_short_msg = iif(dbo.fnGetLogLevel()>1, 1,0);
   SET @msg = iif(@error_st = 0, 'Test: All sub tests passed', CONCAT('Error: 1 or more sub tests failed', @NL));
   EXEC sp_log 2, @fn, @tst_fn, ' finished, ', @msg, @short_msg = @is_short_msg;

   -- The disp log flag is set on startup
   -- Display Log both up and down ASC and DESC
   IF test.fnGetDisplayLogFlg() = 1
   BEGIN
      EXEC dbo.sp_appLog_display 1  -- descending order
      EXEC dbo.sp_appLog_display 0; -- ascending  order
   END

   -- Clear all flags and counters
   PRINT test.fnGetTstHdrFooterLine(1, 0, @tst_fn, CONCAT('', iif(@error_st = 0, 'PASSED', 'FAILED')));
END
/*
EXEC test.sp_tst_mn_st 'test_011_sp_import_UseStaging';
EXEC test.sp_tst_mn_cls;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--=======================================================================================
-- Author:           Terry Watts
-- Create date:      12-Jun-2025
-- Rtn:              test.test_068_sp_crt_pop_table
-- Description: main test routine for the dbo.sp_crt_pop_table routine 
--
-- Tested rtn description:
-- Create and populate a table from a data file
--
-- REQUIREMENTS:
-- R06.01: the table with the same name as the file is created:
-- R06.02: the table has the same column names as the column names in the file
-- R06.03: table is populated exactly from the rows and columns from the file
-- R06.04: if a column name contains spaces (any whitespace) then replace each sequence
--         of whitespace with a single underscore
--
-- Design: EA: Dorsu.eap: Dorsu Model.Conceptual Model.Create and populate a table from a data file
-- Define the import data file path
-- Table name = file name
-- Reads the header for the column names
-- Create a table with table name, columns = field names, type = text
-- Create a staging table
-- Create a format file using BCP and the table
-- Generate the import routine using the table and the format file
--
-- Parameters:
--    @file_path     VARCHAR(500) -- the import data file path
--
-- Test strategy:
-- 01. Check no error occurred
-- 02: Check the table exists
-- 03: Check the columns match the file columns
-- 04: Check the data matches
-- 04.01: check the row count of the table matches that of the file
-- 04.02: check the first row all columns
-- 04.03: check the last row all columns
--=======================================================================================
CREATE PROCEDURE [test].[test_068_sp_crt_pop_table]
AS
BEGIN
DECLARE
    @fn  VARCHAR(35) = 'test_068_sp_crt_pop_table'
   ,@tab CHAR        = CHAR(9)

   BEGIN TRY
      EXEC test.sp_tst_mn_st @fn;

      EXEC test.hlpr_068_sp_crt_pop_table
          @tst_num            = '001'
         ,@display_tables     = 1
         ,@inp_file_path      = 'D:\Dev\Property\Data\PropertySales.Resort.txt'
         ,@inp_sep            = '0x09'
         ,@inp_codepage       = NULL
         ,@inp_display_tables = 1
         ,@exp_row_cnt        = NULL
         ,@exp_ex_num         = NULL
         ,@exp_ex_msg         = NULL
      ;
RETURN;
      EXEC test.hlpr_068_sp_crt_pop_table
          @tst_num            = '002'
         ,@display_tables     = 1
         ,@inp_file_path      = 'D:\Dorsu\Data\FileActivityLog.tsv'
         ,@inp_sep            = '0x09'
         ,@inp_codepage       = NULL
         ,@inp_display_tables = 1
         ,@exp_row_cnt        = 60286
         ,@exp_ex_num         = NULL
         ,@exp_ex_msg         = NULL
      ;
      EXEC sp_log 2, @fn, '990: LEAVING EARLY'
      RETURN;

      EXEC sp_log 2, @fn, '999: All subtests PASSED';
   END TRY
   BEGIN CATCH
      EXEC sp_log 2, @fn, '520: caught exception -> sp_log_exception';
      EXEC sp_log_exception @fn;
      EXEC sp_log 2, @fn, '540: rethrowing exception';
      THROW;
   END CATCH

   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_068_sp_crt_pop_table;

SELECT TOP 200 * FROM GenericStaging;

EXEC tSQLt.Run 'test.test_068_sp_crt_pop_table';
EXEC sp_crt_pop_table 'D:\Dev\Property\Data\PropertySales.txt';

EXEC sp_AppLog_Display 'hlpr_068_sp_crt_pop_table';
EXEC sp_AppLog_Display;
SELECT COUNT(*) FROM GenericStaging;
SELECT TOP 200 * FROM GenericStaging;
*/

GO
