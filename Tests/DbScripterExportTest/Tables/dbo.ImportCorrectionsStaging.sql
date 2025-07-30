SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportCorrectionsStaging](
	[id] [int] NOT NULL,
	[action] [varchar](50) NULL,
	[command] [varchar](max) NULL,
	[table_nm] [varchar](max) NULL,
	[field_nm] [varchar](50) NULL,
	[search_clause] [varchar](max) NULL,
	[filter_field_nm] [varchar](max) NULL,
	[filter_op] [varchar](8) NULL,
	[filter_clause] [varchar](250) NULL,
	[not_clause] [varchar](max) NULL,
	[exact_match] [varchar](max) NULL,
	[cs] [varchar](max) NULL,
	[replace_clause] [varchar](max) NULL,
	[field2_nm] [varchar](max) NULL,
	[field2_op] [varchar](8) NULL,
	[field2_clause] [varchar](max) NULL,
	[must_update] [varchar](max) NULL,
	[comments] [varchar](max) NULL,
	[created]  AS (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportCorrectionsStaging] ADD  CONSTRAINT [DF_ImportCorrectionsStaging_must_update]  DEFAULT ((0)) FOR [must_update]
GO

