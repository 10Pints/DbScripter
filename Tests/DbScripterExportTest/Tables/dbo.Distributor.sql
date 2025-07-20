SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Distributor](
	[distributor_id] [int] IDENTITY(1,1) NOT NULL,
	[distributor_nm] [varchar](100) NULL,
	[city] [varchar](50) NULL,
	[province] [varchar](50) NULL,
	[region] [varchar](50) NULL,
	[address] [varchar](100) NULL,
	[phone 1] [varchar](50) NULL,
	[phone 2] [varchar](50) NULL,
	[maufacturers] [varchar](max) NULL,
 CONSTRAINT [PK_Distributor] PRIMARY KEY CLUSTERED 
(
	[distributor_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
