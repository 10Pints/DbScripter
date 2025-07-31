SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SysRtnsDbo_vw]
AS
    SELECT *
    from dbo.SysRtns_vw 
    WHERE schema_nm = 'dbo'
    AND rtn_nm NOT LIKE 'tsu%'
GO

