SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Warehouse](
	[region] [varchar](50) NOT NULL,
	[company_nm] [varchar](50) NOT NULL,
	[warehouse_nm] [varchar](50) NOT NULL,
	[address] [varchar](250) NOT NULL,
	[type] [varchar](50) NOT NULL,
	[expiry] [date] NOT NULL
) ON [PRIMARY]

GO
