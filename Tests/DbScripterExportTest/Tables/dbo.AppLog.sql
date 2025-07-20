SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AppLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[timestamp] [varchar](30) NOT NULL,
	[schema_nm] [varbinary](20) NULL,
	[rtn] [varchar](60) NULL,
	[hit] [int] NULL,
	[log] [varchar](max) NULL,
	[msg] [varchar](max) NULL,
	[level] [int] NULL,
	[row_count] [int] NULL,
 CONSTRAINT [PK_AppLog] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[AppLog] ADD  CONSTRAINT [DF_AppLog_timestamp]  DEFAULT (getdate()) FOR [timestamp]

GO
