USE [BDLGP_HERDEZV2]
GO

/****** Object:  Table [dbo].[Folio_Tipo_Incidencia]    Script Date: 26/03/2020 08:40:49 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Folio_Tipo_Incidencia](
	[id_tipo_incidencia] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [nvarchar](50) NULL,
	[descripcion] [nvarchar](255) NULL,
 CONSTRAINT [PK_Folio_Tipo_Incidencia] PRIMARY KEY CLUSTERED 
(
	[id_tipo_incidencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


