USE [BDLGP_HERDEZV2]
GO

/****** Object:  Table [dbo].[Folio_Ticket]    Script Date: 26/03/2020 08:40:40 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Folio_Ticket](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[id_folio] [numeric](20, 0) NULL,
	[id_llamada] [varchar](50) NULL,
	[comentario] [nvarchar](255) NULL,
	[receptor] [nvarchar](255) NULL,
	[telefono] [nvarchar](15) NULL,
	[agente] [nvarchar](50) NULL,
	[incidencia] [int] NULL,
	[duracion_llamada] [nvarchar](50) NULL,
	[fecha_alta] [datetime] NULL,
	[duracion_minutos] [decimal](18, 2) NULL,
 CONSTRAINT [PK_Folio_Respuesta] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


