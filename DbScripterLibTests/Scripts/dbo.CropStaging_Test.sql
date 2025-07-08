SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[CropStaging_Test](
	[id] [float] NULL,
	[command] [nvarchar](255) NULL,
	[must_update] [float] NULL,
	[doit] [nvarchar](255) NULL,
	[act_cnt] [nvarchar](255) NULL,
	[search_clause] [nvarchar](255) NULL,
	[search_clause_cont] [nvarchar](255) NULL,
	[not_clause] [nvarchar](255) NULL,
	[replace_clause] [nvarchar](255) NULL,
	[case_sensitive] [float] NULL,
	[Latin_name] [nvarchar](255) NULL,
	[common_name] [nvarchar](255) NULL,
	[local_name] [nvarchar](255) NULL,
	[alt_names] [nvarchar](255) NULL,
	[note_clause] [nvarchar](255) NULL,
	[crops] [nvarchar](255) NULL,
	[comments] [nvarchar](255) NULL,
	[results] [nvarchar](255) NULL,
	[chk] [nvarchar](255) NULL
) ON [PRIMARY]

GO
