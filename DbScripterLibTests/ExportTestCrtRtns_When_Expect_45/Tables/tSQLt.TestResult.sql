SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [tSQLt].[TestResult](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Class] [nvarchar](max) NOT NULL,
	[TestCase] [nvarchar](max) NOT NULL,
	[Name]  AS ((quotename([Class])+'.')+quotename([TestCase])),
	[TranName] [nvarchar](max) NULL,
	[Result] [nvarchar](max) NULL,
	[Msg] [nvarchar](max) NULL,
	[TestStartTime] [datetime2](7) NOT NULL,
	[TestEndTime] [datetime2](7) NULL,
 CONSTRAINT [PK:tSQLt.TestResult] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [tSQLt].[TestResult] ADD  CONSTRAINT [DF:TestResult(TestStartTime)]  DEFAULT (sysdatetime()) FOR [TestStartTime]

GO
