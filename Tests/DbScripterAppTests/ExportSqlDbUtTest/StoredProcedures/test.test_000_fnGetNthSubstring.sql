SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 27-MAY-2020
-- Description: Tests the fnGetNthSubstring function
-- =====================================================
CREATE PROCEDURE [test].[test_000_fnGetNthSubstring]
AS
BEGIN
   SET NOCOUNT ON
   DECLARE
      @fn NVARCHAR(35)='tst_000_fnGetNthSubstr'
   EXEC test.sp_tst_mn_st @fn;
   -- EXEC sp_set_session_context N'TST_MN_ST'        , 0
   -- EXEC sp_set_session_context N'TSU1 000'         , 0;
   -- EXEC sp_set_session_context N'DISP_TST_RES'     , 1;
   WHILE 1 = 1
   BEGIN
      EXEC sp_log 1, @fn, 'running T001' ;
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T01'
         ,@str    = 'abc,def'
         ,@sep    = ','
         ,@n      = 2
         ,@exp_res='def'
         ;
      EXEC sp_log 1, @fn, 'T001 passed' ;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T000.01','abc,def'     ,':',1, @exp_res='abc,def'
      EXEC sp_log 1, @fn, 'running T002' ;
      EXEC test.hlpr_000_fnGetNthSubstring
          @tst_num= 'T02'
         ,@str    = 'abc,def'
         ,@sep    = ':'
         ,@n      = 1
         ,@exp_res='abc,def'
         ;
      EXEC sp_log 1, @fn, 'T002 passed' ;
--BREAK;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T000.02',NULL          ,',',1, @exp_res=NULL
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T03: null str'
         ,@str    = NULL
         ,@sep    = ','
         ,@n      = 1
         ,@exp_res=NULL
         ;
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T04 MT str, MT sep'
         ,@str    = ''
         ,@sep    = ''
         ,@n      = 0
         ,@exp_res=NULL
         ,@exp_ex_num = 214
         ,@exp_ex_msg = 'Procedure expects parameter ''separator'' of type ''nchar(1)/nvarchar(1)'''
         ;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T05',''            ,',',1, @exp_res=''
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T05: '
         ,@str    = '''            ,'''
         ,@sep    = ','
         ,@n      = 1
         ,@exp_res='''            '
         ;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T06','asd'         ,',',1, @exp_res='asd'
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T06'
         ,@str    = 'asd''         ,'''
         ,@sep    = ','
         ,@n      = 1
         ,@exp_res='asd''         '
         ;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T07','asd'         ,',',0, @exp_resNULL
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T07'
         ,@str    = 'asd''         ,'''
         ,@sep    = ','
         ,@n      = 0
         ,@exp_res=NULL
      ;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T08','asd,'        ,',',1, @exp_res='asd'
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T08'
         ,@str    = 'asd,'
         ,@sep    = ','
         ,@n      = 1
         ,@exp_res= 'asd'
         ;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T09','asd,'        ,',',0, @exp_res='asd'
      EXEC test.hlpr_000_fnGetNthSubstring 
         @tst_num= 'T09'
         ,@str    = 'asd,'
         ,@sep    = ','
         ,@n      = 0
         ,@exp_res=NULL
         ;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T10','asd,fg,'     ,',',2, @exp_res='fg'        -- ('asd,fg,', , 2)
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T10'
         ,@str    = 'asd,fg,'
         ,@sep    = ','
         ,@n      = 2
         ,@exp_res='fg'
         ;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T11','asd,fg'      ,',',2, @exp_res='fg'        -- ('asd,fg', , 2)
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T11'
         ,@str    = 'asd,fg'
         ,@sep    = ','
         ,@n      = 2
         ,@exp_res='fg'
         ;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T12','asd-fg-hijk-'-',',3, @exp_res='fg'        -- ('asd,fg,hijk,', , 2)
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T12'
         ,@str    = 'asd-fg-hijk-'
         ,@sep    = '-'
         ,@n      = 3
         ,@exp_res='hijk'
         ;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T13','asd,fg,hijk',',' ,3, @exp_res='hijk'      -- ('asd,fg,hijk', , 3)
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T13'
         ,@str    = 'asd,fg,hijk'
         ,@sep    = ','
         ,@n      = 3
         ,@exp_res='hijk'
         ;
--       EXEC test.hlpr_000_fnGetNthSubstring 'T000.14','abc,def'    ,'de',1, @exp_res='abc,'      -- ('abc,def', 'de', 1)
      EXEC test.hlpr_000_fnGetNthSubstring 
          @tst_num= 'T14'
         ,@str    = 'abc,def'
         ,@sep    = ''
         ,@n      = 0
         ,@exp_ex_num = 214
         ,@exp_ex_msg = 'Procedure expects parameter ''separator'' of type ''nchar(1)/nvarchar(1)'''
         ;
      BREAK;  -- Do once loop
   END -- WHILE
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_000_fnGetNthSubstring'
EXEC test.test_000_fnGetNthSubstring
*/
GO

