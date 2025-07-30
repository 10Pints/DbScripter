SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CallRegister](
	[id] [int] NOT NULL,
	[rtn] [varchar](50) NULL,
	[limit] [int] NULL,
	[count] [int] NULL,
	[updated] [datetime] NULL,
 CONSTRAINT [PK_SessionContext] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CallRegister] ADD  CONSTRAINT [DF_SessionContext_count]  DEFAULT ((0)) FOR [count]
GO

