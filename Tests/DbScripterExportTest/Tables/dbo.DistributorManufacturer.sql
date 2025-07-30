SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistributorManufacturer](
	[distributor_id] [int] NOT NULL,
	[manufacturer_id] [int] NOT NULL,
 CONSTRAINT [PK_DistributorManufacturer] PRIMARY KEY CLUSTERED 
(
	[distributor_id] ASC,
	[manufacturer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DistributorManufacturer]  WITH CHECK ADD  CONSTRAINT [FK_DistributorManufacturer_Company] FOREIGN KEY([manufacturer_id])
REFERENCES [dbo].[Company] ([company_id])
GO
ALTER TABLE [dbo].[DistributorManufacturer] CHECK CONSTRAINT [FK_DistributorManufacturer_Company]
GO
ALTER TABLE [dbo].[DistributorManufacturer]  WITH CHECK ADD  CONSTRAINT [FK_DistributorManufacturer_Distributor] FOREIGN KEY([distributor_id])
REFERENCES [dbo].[Distributor] ([distributor_id])
GO
ALTER TABLE [dbo].[DistributorManufacturer] CHECK CONSTRAINT [FK_DistributorManufacturer_Distributor]
GO

