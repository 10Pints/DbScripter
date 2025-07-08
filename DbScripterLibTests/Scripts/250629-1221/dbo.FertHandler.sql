SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FertHandler](
	[region] [varchar](5) NOT NULL,
	[company_nm] [varchar](80) NOT NULL,
	[address] [varchar](100) NOT NULL,
	[type] [varchar](15) NOT NULL,
	[license] [varchar](25) NOT NULL,
	[expiry_date] [date] NOT NULL
) ON [PRIMARY]

GO
