USE [BDLGP_HERDEZV2]
GO

/****** Object:  Table [dbo].[Folio_Precautoria]    Script Date: 26/03/2020 08:40:21 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Folio_Precautoria](
	[id_folio_precaucion] [bigint] IDENTITY(1,1) NOT NULL,
	[id_folio] [numeric](20, 0) NULL,
	[prioridad] [int] NULL,
	[fecha_vencimiento] [datetime] NULL,
	[status] [bit] NULL,
	[evento] [nvarchar](50) NULL,
	[id_region_destino] [int] NULL,
 CONSTRAINT [PK_Folio_Precautoria] PRIMARY KEY CLUSTERED 
(
	[id_folio_precaucion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


