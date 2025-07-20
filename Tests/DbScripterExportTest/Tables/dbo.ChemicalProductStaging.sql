SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ChemicalProductStaging](
	[chemical_nm] [varchar](100) NULL,
	[product_nm] [varchar](50) NULL,
 CONSTRAINT [IX_ChemicalProductStaging] UNIQUE NONCLUSTERED 
(
	[chemical_nm] ASC,
	[product_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
