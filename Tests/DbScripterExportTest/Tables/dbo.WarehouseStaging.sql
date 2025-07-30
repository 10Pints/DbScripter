SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseStaging](
	[region] [varchar](50) NULL,
	[company_nm] [varchar](50) NULL,
	[warehouse_nm] [varchar](50) NULL,
	[address] [varchar](250) NULL,
	[type] [varchar](50) NULL,
	[expiry] [varchar](50) NULL
) ON [PRIMARY]
GO

