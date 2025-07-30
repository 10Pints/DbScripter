SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 18-MAY-2020
-- Description: lists routine definitions in rows 
-- overcoming the 4000 char limit of dbo.SysRoutinesView
-- or any method based on INFORMATION_SCHEMA.ROUTINES
-- =============================================
CREATE FUNCTION [dbo].[fnSysRtnDef]
(
    @schema NVARCHAR(20)
   ,@name   NVARCHAR(50)
)
RETURNS @t TABLE
(
    [name]        NVARCHAR(100)
   ,[schema]      NVARCHAR(20)
   ,[type_desc]   NVARCHAR(30)
   ,seq           INT
   ,[len]         INT
   ,create_date   DATE
   ,def           NVARCHAR(4000)
)
AS
BEGIN
   INSERT INTO @t ([name], [schema], [type_desc], seq, [len] ,create_date, def) 
   SELECT          rtn_nm, schema_nm, ty_nm, seq, [len], created, def
   FROM SysRtns2_vw
   WHERE schema_nm = @schema AND rtn_nm LIKE @name
   ORDER BY rtn_nm, seq;
   RETURN;
END
/*
SELECT * FROM [dbo].[fnSysRtnDef]( 'dbo', 'sp_exprt_to_xl');
*/
GO

