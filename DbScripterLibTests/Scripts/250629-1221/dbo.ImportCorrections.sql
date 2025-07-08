SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ImportCorrections](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[action] [varchar](12) NULL,
	[command] [varchar](50) NULL,
	[table_nm] [varchar](50) NULL,
	[field_nm] [varchar](50) NULL,
	[search_clause] [varchar](700) NULL,
	[filter_field_nm] [varchar](50) NULL,
	[filter_op] [varchar](10) NULL,
	[filter_clause] [varchar](250) NULL,
	[not_clause] [varchar](500) NULL,
	[exact_match] [bit] NULL,
	[cs] [bit] NULL,
	[replace_clause] [varchar](500) NULL,
	[field2_nm] [varchar](50) NULL,
	[field2_op] [varchar](8) NULL,
	[field2_clause] [varchar](250) NULL,
	[must_update] [bit] NULL,
	[comments] [varchar](max) NULL,
	[created] [datetime] NULL,
	[update_cnt] [int] NULL,
	[select_sql] [varchar](max) NULL,
	[update_sql] [varchar](max) NULL,
	[result_msg] [varchar](500) NULL,
	[row_id] [int] NULL,
	[stg_file] [varchar](100) NULL,
 CONSTRAINT [PK_ImportCorrections] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[ImportCorrections] ADD  CONSTRAINT [DF_ImportCorrections_must_update]  DEFAULT ((0)) FOR [must_update]

GO
