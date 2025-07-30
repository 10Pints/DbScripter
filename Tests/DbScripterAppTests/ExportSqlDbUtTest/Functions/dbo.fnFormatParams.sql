SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 09-JAN-2020
-- Description: List parameters - 
--
-- Example usge:
-- INPUT:
--    @workbook_path             NVARCHAR(260)
--   ,@range                     NVARCHAR(50)            -- can be a range or a sheet
--   ,@select_cols               NVARCHAR(2000)          -- select column names for the insert to the table: can apply functions to the columns at this point
--   ,@xl_cols                   NVARCHAR(2000) = ''*''  -- XL column names: can be *
--   ,@extension                 NVARCHAR(50)   = ''''   -- e.g. ''HDR=NO;IMEX=1''
--   ,@whereClause               NVARCHAR(2000) =''      -- Where clause like "WHERE province <> ''"  or ""
--
-- OUTPUT
--     EXEC sp_log 1, @fn, 'starting '
--             ,'@msg              =[', @msg              ,']', @NL 
--             ,'@table_nm         =[', @table_nm         ,']', @NL 
--             ,'@folder           =[', @folder           ,']', @NL 
--             ,'@workbook_nm      =[', @workbook_nm      ,']', @NL 
--             ,'@sheet_nm         =[', @sheet_nm         ,']', @NL 
--             ,'@view_nm          =[', @view_nm          ,']', @NL 
--             ,'@filter           =[', @filter           ,']', @NL 
--             ,'@create_timestamp =[', @create_timestamp ,']', @NL 
--             ,'@max_rows         =[', @max_rows         ,']', @NL 
-- =============================================
CREATE FUNCTION [dbo].[fnFormatParams] (@params NVARCHAR(4000) )
RETURNS @t TABLE(id INT, stpos INT, endpos INT, sz INT, item NVARCHAR(200))
AS
BEGIN
   WITH Split(id, stpos, endpos, sz)
   AS
   (
      SELECT
         1 as id
         ,CHARINDEX('@', @params)                                        AS stpos
         ,CHARINDEX(' ', @params, CHARINDEX('@', @params))               AS endpos
         ,CHARINDEX(' ', @params, CHARINDEX('@', @params))               AS sz
      UNION ALL
      SELECT 
         id + 1 as id
         ,CHARINDEX('@', @params, endpos+1)                              AS stpos
         ,CHARINDEX(' ', @params, CHARINDEX('@', @params, endpos+1)+1)   AS endpos
         ,CHARINDEX(' ', @params, CHARINDEX('@', @params, endpos+1))-CHARINDEX(' ', @params, CHARINDEX('@', @params, endpos+1)+1)   AS sz
      FROM Split
      WHERE CHARINDEX(',', @params, endpos+1) > 1
   )
   , LenFld (szm)
   AS
   (
      SELECT MAX( sz) FROM Split
   )
   INSERT INTO  @t (id, stpos, endpos, sz, item) 
   (
      SELECT 
      id
      ,stpos, endpos, sz
      ,CONCAT
      ( 
           '            ,'''
         , substring(@params,stpos, endpos-stpos)
         ,'=['', '
         , substring(@params,stpos, endpos-stpos)
         ,','']''',', @NL'
      )  AS item
      FROM Split,LenFld
   UNION
      SELECT 999999, 0,0,0,''
   )
   RETURN;
END
/*
SELECT * FROM dbo.fnFormatParams(@parms_list)
*/
GO

