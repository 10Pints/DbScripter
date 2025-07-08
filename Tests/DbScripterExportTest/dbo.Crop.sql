SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Crop](
	[crop_id] [int] IDENTITY(1,1) NOT NULL,
	[crop_nm] [varchar](100) NOT NULL,
	[latin_nm] [varchar](50) NULL,
	[alt_latin_nms] [varchar](50) NULL,
	[alt_common_nms] [varchar](50) NULL,
	[taxonomy] [varchar](250) NULL,
	[notes] [varchar](150) NULL,
 CONSTRAINT [PK_Crop] PRIMARY KEY CLUSTERED 
(
	[crop_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
