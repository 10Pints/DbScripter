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
CREATE   FUNCTION [dbo].[fnTrim]( @s VARCHAR(4000)
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
