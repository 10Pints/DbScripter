SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[CorrectionLog](
	[id] [int] NOT NULL,
	[stg_id] [int] NULL,
	[cor_id] [int] NULL,
	[old] [varchar](250) NULL,
	[new] [varchar](250) NULL,
	[search_clause] [varchar](250) NULL,
	[replace_clause] [varchar](150) NULL,
	[not_clause] [varchar](150) NULL,
	[row_cnt] [int] NULL,
 CONSTRAINT [PK_CorrectionLog] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
