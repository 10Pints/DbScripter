/*
Parameters:

--------------------------------------------------------------------------------
 Type                         : Params
--------------------------------------------------------------------------------
 CreateMode                   : Create
 Database                     : Dorsu_dev
 DisplayLog                   : True
 DisplayScript                : True
 IndividualFiles              : False
 Instance                     : 
 IsExprtngData                : False
 LogFile                      : D:\Dev\DbScripter\Tests\DbScripterAppTests\Exportsp_crt_pop_table\Exportsp_crt_pop_table.log
 LogLevel                     : Info
 Name                         : Exportsp_crt_pop_table
 RequiredAssemblies           : System.Collections.Generic.List`1[System.String]
 RequiredSchemas              : System.Collections.Generic.List`1[System.String]
 RequiredFunctions            : System.Collections.Generic.List`1[System.String]
 RequiredProcedures           : System.Collections.Generic.List`1[System.String]
 RequiredTables               : System.Collections.Generic.List`1[System.String]
 RequiredUserDefinedDataTypes : System.Collections.Generic.List`1[System.String]
 RequiredUserDefinedTableTypes: System.Collections.Generic.List`1[System.String]
 RequiredUserDefinedTypes     : System.Collections.Generic.List`1[System.String]
 RequiredViews                : System.Collections.Generic.List`1[System.String]
 Want All:                 : Assembly False
 Want All:                 : Schema False
 Want All:                 : Function False
 Want All:                 : Procedure False
 Want All:                 : Table False
 Want All:                 : UserDefinedDataType False
 Want All:                 : UserDefinedTableType False
 Want All:                 : UserDefinedType False
 Want All:                 : View False
 Want All:                 : Assembly System.Collections.Generic.List`1[System.String]
 Want All:                 : Schema System.Collections.Generic.List`1[System.String]
 Want All:                 : Function System.Collections.Generic.List`1[System.String]
 Want All:                 : Procedure System.Collections.Generic.List`1[System.String]
 Want All:                 : Table System.Collections.Generic.List`1[System.String]
 Want All:                 : UserDefinedDataType System.Collections.Generic.List`1[System.String]
 Want All:                 : UserDefinedTableType System.Collections.Generic.List`1[System.String]
 Want All:                 : UserDefinedType System.Collections.Generic.List`1[System.String]
 Want All:                 : View System.Collections.Generic.List`1[System.String]
 Script Dir                   : D:\Dev\DbScripter\Tests\DbScripterTests\ExportSqlDbUtTest
 Script File                  : D:\Dev\DbScripter\Tests\DbScripterTests\ExportSqlDbUtTest\Exportsp_crt_pop_table.sql
 ScriptUseDb                  : True
 Server                       : DevI9
 AddTimestamp                 : False
 Timestamp                    : 250731-1635

 RequiredSchemas : 2
	dbo
	test

*/

USE [Dorsu_dev]
SET ANSI_NULLS ON
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
ALTER TABLE [dbo].[AppLog] ADD  CONSTRAINT [DF_AppLog_timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO

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

SET ANSI_NULLS ON
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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

SET ANSI_NULLS ON
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
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
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ImportGenericStaging_vw]
AS
SELECT staging
FROM GenericStaging
;
/*
SELECT * FROM ImportExamSchedule_vw;
*/
GO

SET ANSI_NULLS ON
GO
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
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 06-NOV-2023
-- Description: lists the columns for the tables
-- =============================================================
CREATE VIEW [dbo].[list_table_columns_vw]
AS
SELECT TOP 10000 
    TABLE_SCHEMA
   ,TABLE_NAME
   ,COLUMN_NAME
   ,ORDINAL_POSITION
   ,DATA_TYPE
   ,dbo.fnIsTextType(DATA_TYPE) as is_txt
   ,CHARACTER_MAXIMUM_LENGTH
   ,isc.COLLATION_NAME
   ,is_computed
   ,so.[object_id] AS table_oid
   ,so.[type_desc]
   ,so.[type]
FROM [INFORMATION_SCHEMA].[COLUMNS] isc
JOIN sys.objects     so ON so.[name]        = isc.TABLE_NAME
JOIN sys.all_columns sac ON sac.[object_id] =  so.[object_id] AND sac.[name]=isc.column_name
ORDER BY TABLE_NAME, ORDINAL_POSITION;
/*
SELECT column_name FROM list_table_columns_vw where table_name = 'PathogenStaging' and is_txt = 1;
*/
GO

