SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[staging2](
	[id] [int] NOT NULL,
	[company] [varchar](70) NULL,
	[ingredient] [varchar](250) NULL,
	[product] [varchar](100) NULL,
	[concentration] [varchar](100) NULL,
	[formulation_type] [varchar](7) NULL,
	[uses] [varchar](100) NULL,
	[toxicity_category] [int] NULL,
	[registration] [varchar](65) NULL,
	[expiry] [varchar](30) NULL,
	[entry_mode] [varchar](60) NULL,
	[crops] [varchar](250) NULL,
	[pathogens] [varchar](360) NULL,
	[rate] [varchar](200) NULL,
	[mrl] [varchar](200) NULL,
	[phi] [varchar](200) NULL,
	[phi_resolved] [varchar](120) NULL,
	[reentry_period] [varchar](250) NULL,
	[notes] [varchar](250) NULL,
	[comments] [varchar](500) NULL,
	[created] [datetime] NULL,
 CONSTRAINT [PK_staging2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_s1_tst_221018_chemical] ON [dbo].[staging2]
(
	[ingredient] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_s1_tst_221018_crops] ON [dbo].[staging2]
(
	[crops] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ss1_tst_221018_pathogens] ON [dbo].[staging2]
(
	[pathogens] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_staging2_chemical] ON [dbo].[staging2]
(
	[ingredient] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_staging2_crops] ON [dbo].[staging2]
(
	[crops] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_staging2_pathogens] ON [dbo].[staging2]
(
	[pathogens] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

ALTER TABLE [dbo].[staging2]  WITH CHECK ADD  CONSTRAINT [FK_staging2_staging1] FOREIGN KEY([id])
REFERENCES [dbo].[staging1] ([id])

ALTER TABLE [dbo].[staging2] CHECK CONSTRAINT [FK_staging2_staging1]

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- =========================================================
-- Author:      Terry Watts
-- Create date: 30-JAN-2024
-- Description: debug aid - stores the current
--  corrections table fixup id stored  the session context
--  in S2UpdateLog
--  and inserts a summary row in the S2UpdateSummary table
-- It watches for changes in crops, entry_mode, pathogens
-- =========================================================
CREATE TRIGGER [dbo].[sp_Staging2_update_trigger]
ON [dbo].[staging2] AFTER UPDATE
AS
BEGIN

   DECLARE
       @inserted staging2_tbl
      ,@deleted  staging2_tbl

   INSERT INTO @inserted SELECT * FROM inserted;
   INSERT INTO @deleted  SELECT * FROM deleted;
   EXEC sp_update_trigger_s2_crops @inserted, @deleted

   RETURN;
END
/*
   SET NOCOUNT ON;
   DECLARE
    @fn               VARCHAR(35) = N'S2_UPDATE_TRIGGER'
   ,@fixup_row_id     INT       -- xl row id
   ,@imp_file_nm      VARCHAR(400)
   ,@msg              VARCHAR(200)
   ,@nl               VARCHAR(2) = CHAR(13) + CHAR(10)
   ,@new_crops        VARCHAR(200)
   ,@old_crops        VARCHAR(200)
   ,@replace_clause   VARCHAR(200)
   ,@row_cnt          INT
   ,@search_clause    VARCHAR(200)
   ,@xl_row           INT       -- xl row id

   SELECT @row_cnt = COUNT(*) FROM inserted;

   SET @fixup_row_id   = dbo.fnGetCtxFixupRowId();
   SET @search_clause  = dbo.fnGetCtxFixupSrchCls();
   SET @replace_clause = dbo.fnGetCtxFixupRepCls();
   SET @xl_row         = dbo.fnGetCtxFixupStgId();
   SET @imp_file_nm    = dbo.fnGetCtxFixupFile()
   EXEC sp_log 1, @fn, '000: starting @fixup_row_id: ',@fixup_row_id, ', @imp_file_nm: [',@imp_file_nm, '], @fixup_stg_id: ', @xl_row, ', @search_clause: [',@search_clause,']';

   ---------------------------------------------------------------------------------------
   -- Log update summary
   ---------------------------------------------------------------------------------------
   INSERT INTO S2UpdateSummary 
          (fixup_row_id, xl_row, row_cnt, search_clause, replace_clause, imp_file_nm)
   SELECT @fixup_row_id,@xl_row,@row_cnt,@search_clause,@replace_clause,@imp_file_nm;

   EXEC sp_log 1, @fn, '010: @fixup_row_id: ',@fixup_row_id;

   ---------------------------------------------------------------------------------------
   -- Log update details
   ---------------------------------------------------------------------------------------
   INSERT INTO S2UpdateLog (fixup_id, id, old_pathogens, new_pathogens, old_crops, new_crops, old_entry_mode, new_entry_mode, old_chemical, new_chemical)
   SELECT @fixup_row_id, d.id, d.pathogens, i.pathogens,d.crops, i.crops,d.entry_mode, i.entry_mode,d.ingredient,i.ingredient
   FROM deleted d JOIN inserted i ON d.id=i.id
   WHERE d.pathogens <> i.pathogens OR d.crops<> i.crops OR d.entry_mode <> i.entry_mode;

   -- Once inserted in to the log tables run invariant chks
   IF @imp_file_nm LIKE '%Crops%'
   BEGIN
      IF EXISTS 
      (
         SELECT 1 FROM inserted i JOIN deleted d ON i.id = d.id
         WHERE i.crops LIKE '%Green beansbeans%' AND d.crops NOT LIKE '%Green beansbeans%'
      )
--      OR (crops LIKE '%Lettuce and otherCrucifers%'))
      BEGIN
         SELECT @imp_file_nm AS [file], @fixup_row_id AS fixup_row, @xl_row, i.id
         ,i.entry_mode AS i_entry_mode, d.entry_mode AS d_entry_mode
         ,i.crops AS i_crops, d.crops AS d_crops
         FROM inserted i JOIN deleted d ON i.id = d.id
         ;

         SELECT TOP  1
          @new_crops = i.crops
         ,@old_crops = d.crops
         FROM inserted i JOIN deleted d ON i.id = d.id
         ;

         SET @msg = CONCAT(
          'update error'                         , @nl
         ,'file:          ' ,@imp_file_nm        , @nl
         ,'row:           ' ,@xl_row             , @nl
         ,'search_clause  [',@search_clause, ']' , @nl
         ,'replace_clause:[',@replace_clause,']' , @nl
         ,'new crops:     [',@new_crops,']'      , @nl
         ,'old crops:     [',@old_crops,']'      , @nl
         );

         EXEC sp_log 4, @fn, '020: ',@msg;
         EXEC sp_raise_exception 53152, @msg, @fn=@fn;
      END
   END
END
*/
/*
PRINT Ut.dbo.fnGetSessionContextAsInt(N'COR_LOG_FLG');
*/

ALTER TABLE [dbo].[staging2] DISABLE TRIGGER [sp_Staging2_update_trigger]

GO
