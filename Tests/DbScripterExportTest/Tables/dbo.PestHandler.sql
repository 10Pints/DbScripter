SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PestHandler](
	[id] [int] NOT NULL,
	[region] [varchar](50) NOT NULL,
	[province] [varchar](50) NOT NULL,
	[city] [varchar](50) NOT NULL,
	[address] [varchar](250) NOT NULL,
	[company_nm] [varchar](50) NOT NULL,
	[owner] [varchar](50) NULL,
	[activity] [varchar](50) NOT NULL,
	[type] [varchar](50) NOT NULL,
	[license_app_ty] [varchar](50) NOT NULL,
	[expiry] [date] NOT NULL,
	[license_num] [varchar](50) NOT NULL
) ON [PRIMARY]
GO

