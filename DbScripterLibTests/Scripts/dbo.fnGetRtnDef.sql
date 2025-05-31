SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 11-NOV-2023
-- Description: take off of MS sp_helptext
-- gets the routine definition
--
-- POSTCONDITIONS:
--  POST 01: if successful returns the script
--  POST 02: if not successful returns the appropriate error message along with 
--           the corresponding negatated MS error code as follows:
--    .1: if rtn is not in the current database:                     -15250, 'Error 01: rtn is not in the current database'
--    .2: if rtn does not exist:                                     -15009, 'Error 02: rtn does not exist'
--    .3: if a system object and it is not in MASTER.sys.syscomments -15197, 'Error 03: system-object check failed'
--    .4: if rtn has no script rows:                                 -15197, 'Error 04: rtn has no lines'
--    .5: if rtn has no script rows*:                                -15471, 'Error 05: rtn has no lines*'
-- ============================================================================================================================
ALTER FUNCTION [dbo].[fnGetRtnDef]
(
    @qrn NVARCHAR(120) -- can be [db_nm.][schema_nm.][rtn_nm]
)
RETURNS
@rtnDef TABLE
(
    id   INT
   ,line NVARCHAR(255) --collate catalog_default
)

AS
BEGIN
   DECLARE
       @dbname          SYSNAME
      ,@objid           INT
      ,@BlankSpaceAdded INT
      ,@BasePos         INT
      ,@CurrentPos      INT
      ,@TextLength      INT
      ,@LineId          INT
      ,@AddOnLen        INT
      ,@LFCR            INT --Lengths of line feed carriage return
      ,@DefinedLength   INT
      ,@n               INT

   /* NOTE: Length of @SyscomText is 4000 to replace the length of
   ** text column in syscomments.
   ** lengths on @Line, #CommentText Text column and
   ** value for @DefinedLength are all 255. These need to all have
   ** the same values. 255 was selected in order for the max length
   ** display using down level clients
   */
      ,@SyscomText      NVARCHAR(4000)
      ,@Line            NVARCHAR(255)

   SELECT @DefinedLength = 255
   SELECT @BlankSpaceAdded = 0 --Keeps track of blank spaces at end of lines. Note Len function ignores  trailing blank spaces*/

   -- Make sure the @objname is local to the current database.
   SELECT @dbname = parsename(@qrn, 3); -- 1 = Object name, 2 = Schema name, 3 = Database name, 4 = Server name

   IF @dbname IS NULL
      SELECT @dbname = db_name();
   ELSE IF @dbname <> db_name()
   BEGIN
      -- raiserror(15250,-1,-1);
     INSERT INTO @rtnDef(id, line)  VALUES (-15250, 'Error 01: rtn is not in the current database');
     RETURN;
   END

   -- See if @objname exists.
   SELECT @objid = object_id(@qrn)
   IF (@objid IS NULL)
   BEGIN
     INSERT INTO @rtnDef(id, line)  VALUES (-15009, 'Error 02: rtn does not exist');
     RETURN;
   END

   IF @objid < 0 -- Handle system-objects
   BEGIN
      -- Check count of rows with text data
      IF (SELECT count(*) from MASTER.sys.syscomments WHERE id = @objid AND text IS NOT null) = 0
      BEGIN
         --raiserror(15197,-1,-1,@objname)
         INSERT INTO @rtnDef(id, line)  VALUES (-15197, 'Error 03: system-object check failed');
         RETURN;
      END

      DECLARE ms_crs_syscom CURSOR LOCAL FOR SELECT text FROM master.sys.syscomments WHERE id = @objid
      ORDER BY number, colid FOR READ ONLY
   END
   ELSE
   BEGIN
      -- Find out how many lines of text are coming back,
      -- and return if there are none.
      IF
      (
         SELECT count(*) 
         FROM syscomments c, sysobjects o 
         WHERE ((o.xtype NOT IN ('S', 'U')) AND (o.id = c.id AND o.id = @objid))
      ) = 0
      BEGIN
         --RAISERROR(15197,-1,-1,@objname)
         INSERT INTO @rtnDef(id, line)  VALUES (-15197, 'Error 04: rtn has no lines')
         RETURN;
      END

      IF (SELECT count(*) FROM syscomments WHERE id = @objid AND encrypted = 0) = 0
      BEGIN
         -- RAISERROR(15471,-1,-1,@objname)
         INSERT INTO @rtnDef(id, line)  VALUES (-15471, 'Error 05: rtn has no lines*')
         RETURN;
      END

      DECLARE ms_crs_syscom  CURSOR LOCAL
      FOR SELECT text FROM syscomments WHERE id = @objid AND encrypted = 0
      ORDER BY number, colid
      FOR READ ONLY
   END

   -- ASSERTION: Parameters validated

   -- else get the text
   SELECT @LFCR   = 2;
   SELECT @LineId = 1;
   OPEN ms_crs_syscom;
   FETCH NEXT from ms_crs_syscom into @SyscomText;

   WHILE @@fetch_status >= 0
   BEGIN
      SELECT  @BasePos    = 1;
      SELECT  @CurrentPos = 1;
      SELECT  @TextLength = LEN(@SyscomText);

      WHILE @CurrentPos != 0
      BEGIN
         --Looking for end of line followed by carriage return
         SELECT @CurrentPos = CHARINDEX(CHAR(13)+CHAR(10), @SyscomText, @BasePos);

         --If carriage return found
         IF @CurrentPos != 0
         BEGIN
            -- If new value for @Lines length will be > then set the length 
            -- then insert current contents of @line and proceed.
            WHILE (isnull(LEN(@Line),0) + @BlankSpaceAdded + @CurrentPos - @BasePos + @LFCR) > @DefinedLength
            BEGIN
               SELECT @AddOnLen = @DefinedLength - (ISNULL(LEN(@Line),0) + @BlankSpaceAdded);

               INSERT @rtnDef (id, line) VALUES
               (
                  @LineId
                  ,ISNULL(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N'')
               );

               SELECT
                   @Line            = NULL
                  ,@LineId          = @LineId + 1
                  ,@BasePos         = @BasePos + @AddOnLen
                  ,@BlankSpaceAdded = 0;

            END -- WHILE (isnull(LEN

            SELECT @Line    = ISNULL(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @CurrentPos-@BasePos + @LFCR), N'')
            SELECT @BasePos = @CurrentPos+2;
            INSERT @rtnDef (id, line) VALUES( @LineId, @Line);
            SELECT @LineId  = @LineId + 1;
            SELECT @Line    = NULL;
         END  -- IF @CurrentPos != 0
         ELSE --else carriage return not found
         BEGIN
            IF @BasePos <= @TextLength
            BEGIN
               --If new value for @Lines length will be > then the defined length
               WHILE (ISNULL(LEN(@Line),0) + @BlankSpaceAdded + @TextLength-@BasePos+1 ) > @DefinedLength
               BEGIN
                  SELECT @AddOnLen = @DefinedLength - (ISNULL(LEN(@Line),0) + @BlankSpaceAdded)
                  INSERT @rtnDef (id, line) VALUES
                  (
                     @LineId
                     ,ISNULL(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N'')
                  );

                  SELECT @Line = NULL, @LineId = @LineId + 1,
                  @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
               END

               SELECT @Line = isnull(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @TextLength-@BasePos+1 ), N'')

               IF LEN(@Line) < @DefinedLength and CHARINDEX(' ', @SyscomText, @TextLength+1 ) > 0
               BEGIN
                  SELECT @Line = @Line + ' ', @BlankSpaceAdded = 1
               END
            END
         END -- -- IF @CurrentPos != 0 ELSE
      END -- WHILE @CurrentPos != 0

      FETCH NEXT FROM ms_crs_syscom INTO @SyscomText
   END -- WHILE @@fetch_status >= 0

   IF @Line IS NOT NULL
      INSERT @rtnDef (id, line) VALUES( @LineId, @Line )

   --SELECT Text FROM CommentText ORDER BY LineId
   CLOSE       ms_crs_syscom;
   DEALLOCATE  ms_crs_syscom;
   --DROP TABLE  #CommentText
   RETURN;-- (0) -- sp_helptext
END
/*
   SELECT * FROM dbo.fnGetRtnDef('dbo.AsFloat');
   EXEC test.sp_crt_tst_rtns 'dbo.fnGetRtnDef'
*/

GO
