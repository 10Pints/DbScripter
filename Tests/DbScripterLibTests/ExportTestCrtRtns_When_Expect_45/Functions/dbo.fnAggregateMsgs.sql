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

