SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ImportState](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[import_root] [varchar](450) NULL,
	[import_file] [varchar](150) NULL,
	[cor_files] [varchar](500) NULL,
	[start_stage] [int] NULL,
	[stop_stage] [int] NULL,
	[start_row] [int] NULL,
	[stop_row] [int] NULL,
	[restore_s1_s2] [bit] NULL,
	[restore_s3_s2] [bit] NULL,
	[log_level] [int] NULL,
	[import_eppo] [bit] NULL,
	[import_id] [int] NULL,
	[file_type] [varchar](10) NULL,
	[cor_file_cnt] [int] NULL,
 CONSTRAINT [PK_ImportState] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
