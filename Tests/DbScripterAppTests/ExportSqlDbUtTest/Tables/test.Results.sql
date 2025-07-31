SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [test].[Results](
	[folder] [nvarchar](max) NULL,
	[file_name] [nvarchar](max) NULL,
	[ext] [nvarchar](max) NULL,
	[fn_pos] [int] NULL,
	[dot_pos] [int] NULL,
	[len] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

