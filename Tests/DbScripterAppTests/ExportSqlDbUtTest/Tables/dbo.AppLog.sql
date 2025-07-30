SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[timestamp] [nvarchar](30) NOT NULL,
	[fn] [nvarchar](150) NULL,
	[sf] [int] NULL,
	[hit] [int] NULL,
	[log1] [varchar](max) NULL,
	[log2] [varchar](max) NULL,
	[log3] [varchar](max) NULL,
	[msg] [varchar](max) NULL,
	[level] [int] NULL,
	[row_count] [int] NULL,
 CONSTRAINT [PK_AppLog] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppLog] ADD  CONSTRAINT [DF_AppLog_timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO

