USE [BDLGP_HERDEZV2]
GO

/****** Object:  StoredProcedure [dbo].[USP_ControlTower_GetFolioParada]    Script Date: 26/03/2020 09:06:13 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_ControlTower_GetFolioParada]
@folio_viaje Numeric(20,0)
AS
	DECLARE @Paradas TABLE(
	id_parada INT,
	id_folio NVARCHAR(50),
	id_ruta INT,
	id_cliente nvarchar(100),
	id_region_origen INT,
	c_nombre nvarchar(255), 
	c_dir nvarchar(255), 
	fecha_hora_programada DATETIME);

	DECLARE @Facturas TABLE(
	pedido NUMERIC(20,0),
	folio_viaje NUMERIC(20,0),
	id_parada INT,
	factura NUMERIC(20,0),
	fecha_facturacion DATETIME,
	fecha_facturacion_teorica DATETIME,
	id_concentrado NUMERIC(20,0),
	tipo_movimiento NVARCHAR(1),
	comentario NVARCHAR(150),
	comentario_entrega nvarchar(300)
	);

	DECLARE @DetallesFactura TABLE(
	ID INT,
	pedido NUMERIC(20,0),
	id_sku NVARCHAR(50),
	cantidad_orden DECIMAL(18,4),
	cantidad_embarque DECIMAL(18,4),
	cantidad_entrega DECIMAL(18,4),
	p_descri NVARCHAR(100),
	[status] NVARCHAR(1),
	comentario NVARCHAR(255)
	);

	-- Paradas
	INSERT INTO @Paradas
	SELECT PLPT1.id_parada, PLPT1.Folio, PLPT1F2.id_ruta, PLPT1.id_cliente, FVC.id_region_origen, PLPT1F2.c_nombre, PLPT1F2.c_dir, PLPT1.fecha_hora_programada
	FROM PL_PARADAS_T1 PLPT1 
	INNER JOIN PL_PARADAS_T1_FINALIZADAS_2 PLPT1F2 ON PLPT1.id_parada = PLPT1F2.id_parada AND PLPT1.id_ruta = PLPT1F2.id_ruta AND PLPT1.id_cliente = PLPT1F2.id_cliente AND PLPT1.id_region = PLPT1F2.id_region
	INNER JOIN Folio_Viaje_Carga FVC ON PLPT1.Folio = FVC.folio_viaje AND PLPT1.id_region_origen = FVC.id_region_origen
	WHERE FVC.folio_viaje = @folio_viaje ORDER BY PLPT1.id_parada, FVC.folio_viaje;

	-- Facturas
	INSERT INTO @Facturas
	SELECT FVD.pedido, FVD.folio_viaje, PLPT1.id_parada, FVD.factura, FVD.fecha_facturacion, FVD.fecha_facturacion_teorica, Fvd.id_concentrado, THP.tipo_movimiento, THP.comentario, THP.comentario_entrega
	FROM PL_PEDIDOS_T1 PLPT1 
	INNER JOIN Folio_Viaje_Descarga FVD ON PLPT1.pedido = FVD.pedido
	LEFT JOIN T_HISTORICO_PEDIDO THP ON THP.id_pedido = FVD.pedido
	WHERE PLPT1.id_parada IN (SELECT id_parada FROM @Paradas) AND FVD.folio_viaje = @folio_viaje AND PLPT1.folio_viaje = @folio_viaje;
	
	SELECT * FROM @Paradas;
	SELECT * FROM @Facturas;

	-- Detalle Facturas
	INSERT INTO @DetallesFactura
	SELECT PLPDT1.ID, 
		   PLPDT1.pedido, 
		   PLPDT1.id_sku, 
		   PLPDT1.cantidad_orden, 
		   PLPDT1.cantidad_embarque, 
		   PLPDT1.cantidad_entrega, 
		   PLPDT1.p_descri,
		   (CASE
				WHEN THP.tipo_movimiento IS NULL THEN NULL
				WHEN THP.tipo_movimiento = '' THEN ''
				WHEN THD.cant_entrega = 0 AND THD.cant = 0 THEN 'c'
				WHEN THD.cant_entrega > THD.cant THEN 'p'
				WHEN THP.tipo_movimiento = 'r' THEN 'r' 
		   END) [status],
		   THD.comentario
    FROM PL_PEDIDO_DETALLE_T1 PLPDT1
	LEFT JOIN T_HISTORICO_DETALLE THD ON THD.id_detalle = PLPDT1.ID
	LEFT JOIN T_HISTORICO_PEDIDO THP ON THP.id_pedido = THD.id_pedido
	WHERE pedido IN (SELECT pedido FROM @Facturas);

	SELECT * FROM @DetallesFactura

	-- Evidencias Detalle
	SELECT Evidence_id, id_parada, id_pedido, id_detalle, EVI.lgp_file_id, LGPF.lgp_file_name, LGPF.lgp_file_min_url, LGPF.lgp_file_url FROM Evidence EVI 
	INNER JOIN LGP_File LGPF ON EVI.lgp_file_id = LGPF.lgp_file_id 
	WHERE EVI.id_pedido IN (SELECT pedido FROM @DetallesFactura) ;

	-- Eventos por Parada
	SELECT RFS.folio_status_id id_evento, 
	       P.id_parada, 
		   P.id_folio,
		   (CASE 
				WHEN RFS.folio_status_id = 2 THEN 'En transito'
				WHEN RFS.folio_status_id = 7 THEN 'Llegada al destino'
				WHEN RFS.folio_status_id = 8 THEN 'Inicio de descarga'
				WHEN RFS.folio_status_id = 9 THEN 'Fin de descarga'
			END
		   ) nombre_evento, 
		   FS.descri descripcion_evento, 
		   (CASE
				WHEN RFS.folio_status_id IN (2,7,8,9) THEN 'OPERATIVO'
		   END) tipo_evento, 
		   RFS.status_change_date fecha_real
	FROM @Paradas P 
	INNER JOIN RelFolioStatus RFS ON P.id_parada = RFS.id_parada
	LEFT JOIN FolioStatus FS ON FS.folio_status_id = RFS.folio_status_id
	WHERE RFS.folio_status_id IN (2,7,8,9) ORDER BY fecha_real;
GO


