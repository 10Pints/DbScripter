SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FertHandlerStaging](
	[region] [varchar](max) NULL,
	[company_nm] [varchar](max) NULL,
	[address] [varchar](max) NULL,
	[type] [varchar](max) NULL,
	[license] [varchar](max) NULL,
	[expiry_date] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
