USE [BDLGP_HERDEZV2]
GO

/****** Object:  View [dbo].[View_FolioViaje]    Script Date: 26/03/2020 09:00:05 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_FolioViaje]
AS
SELECT DISTINCT
	FVC.folio_viaje,
	FVC.id_origen,
	CAST(FVC.c_nombre AS NVARCHAR(255)) nombre_origen,
	CAST(FVC.c_direccion AS NVARCHAR(255)) direccion_origen,
	null id_destino,
	null nombre_destino,
	null direccion_destino,
	CAST(
		(CASE
			WHEN FVC.fecha_asignacion_proveedor IS NULL THEN 'Por Asignar a Proveedor'
			WHEN FVC.fecha_asignacion_flotilla IS NULL THEN 'Por Asignar a Flotilla'
			WHEN FVC.fecha_sincronizacion IS NULL THEN 'Sincronización'
			WHEN FVC.inicio_folio IS NULL THEN 'Inicio de Folio'
			WHEN FVC.fecha_llegada_origen_geo IS NULL THEN 'En transito al origen'
			WHEN FVC.fecha_llegada_origen_QR IS NULL THEN 'Llegada a Orgien'
			WHEN FVC.fecha_inicio_carga_QR IS NULL THEN 'Inicio de Carga'
			WHEN FVD.fecha_facturacion IS NULL THEN 'Facturación'
			WHEN FVC.fecha_fin_carga IS NULL THEN 'Fin de Carga'
			WHEN FVC.fecha_salida_origen_QR IS NULL THEN 'Salida de origen'
			--WHEN FVC.fecha_salida_origen_QR IS NOT NULL AND FVD.fecha_llegada_destino_geo IS NULL THEN 'En TRANsito a Destino'
			WHEN FVC.fecha_salida_origen_QR IS NOT NULL
			THEN (
				CASE
					WHEN PLPT1F2.[status] = 3 THEN 'En transito'
					WHEN PLPT1F2.[status] = 4 THEN 'Llegada al destino'
					WHEN PLPT1F2.[status] = 5 THEN 'Inicio de descarga'
					WHEN PLPT1F2.[status] = 6 THEN 'Fin de descarga'
				END
			)
			WHEN FVD.fecha_carga_pod IS NOT NULL THEN 'Folio Finalizado'
		END) AS NVARCHAR(50)
	) evento,
	CAST(
		(CASE
			WHEN FVC.fecha_asignacion_proveedor IS NULL THEN DATEADD(HOUR, -12, FVC.fecha_asignacion_flotilla_teorica)
			WHEN FVC.fecha_asignacion_flotilla IS NULL THEN FVC.fecha_asignacion_flotilla_teorica
			WHEN FVC.fecha_sincronizacion IS NULL THEN FVC.arribo_origen_teorico
			WHEN FVC.inicio_folio IS NULL THEN FVC.arribo_origen_teorico
			WHEN FVC.fecha_llegada_origen_geo IS NULL THEN FVC.arribo_origen_teorico
			WHEN FVC.fecha_llegada_origen_QR IS NULL THEN FVC.arribo_origen_teorico
			WHEN FVC.fecha_inicio_carga_QR IS NULL THEN FVC.fecha_inicio_carga_QR_teorica
			WHEN FVC.fecha_fin_carga IS NULL THEN FVC.fecha_fin_carga_teorica
			WHEN FVD.fecha_facturacion IS NULL THEN FVD.fecha_facturacion_teorica
			WHEN FVC.fecha_salida_origen_QR IS NULL THEN FVC.fecha_salida_origen_teorico
			--WHEN FVC.fecha_salida_origen_QR IS NOT NULL AND FVD.fecha_llegada_destino_QR IS NULL THEN fecha_llegada_destino_QR_teorica
			WHEN FVC.fecha_salida_origen_QR IS NOT NULL THEN PLPT1F2.fecha_llegada_prog

		END) AS DATETIME
	) fecha_planeada,
	CAST(FVC.inicio_folio AS DATETIME) hora_partida,
	CAST(
		FVC.fecha_cita_destino
		AS DATETIME
	) fecha_vencimiento,
	CAST(
		(SELECT TOP 1 ETA 
		 FROM PL_PARADAS_T1_FINALIZADAS_2 
		 WHERE id_ruta = FVC.folio_viaje AND [status] IN (3,4)) AS DECIMAL(18,2)
	) eta,
	PRO.id_provedor id_proveedor,
	PRO.nombre nombre_proveedor,
	PRO.id_region,
	FVC.fecha_cita_destino,
	FVC.[status]
FROM Folio_Viaje_Carga FVC 		  
RIGHT JOIN Folio_Viaje_Descarga FVD ON FVD.folio_viaje = FVC.folio_viaje
LEFT JOIN PROVEEDOR PRO ON FVC.id_region_destino = PRO.id_region
LEFT JOIN PL_PARADAS_T1 PLPT1 ON PLPT1.Folio = FVC.folio_viaje
LEFT JOIN PL_PARADAS_T1_FINALIZADAS_2 PLPT1F2 ON PLPT1F2.id_parada = PLPT1.id_parada AND PLPT1F2.[status] BETWEEN 3 AND 10
LEFT JOIN PL_RUTAS_T1 PLRT1 ON PLRT1.folio_ruta = FVC.folio_viaje
GROUP BY FVC.folio_viaje, FVC.id_origen, FVC.c_nombre, FVC.c_direccion, FVD.id_destino, FVD.c_nombre, FVD.c_direccion, FVC.fecha_asignacion_proveedor, FVC.fecha_asignacion_flotilla,
FVC.fecha_sincronizacion, FVC.inicio_folio, FVC.fecha_llegada_origen_geo, FVC.fecha_llegada_origen_QR, FVC.fecha_inicio_carga_QR, FVD.fecha_facturacion, FVC.fecha_fin_carga,
FVC.fecha_salida_origen_QR, PLPT1F2.[status], FVD.fecha_carga_pod, FVC.fecha_asignacion_flotilla_teorica, FVC.arribo_origen_teorico, FVC.fecha_inicio_carga_QR_teorica, FVC.fecha_fin_carga_teorica,
FVD.fecha_facturacion_teorica, FVC.fecha_salida_origen_teorico, PLPT1F2.fecha_llegada_prog, FVC.fecha_cita_destino, FVD.fecha_llegada_destino_QR_teorica, FVD.fecha_llegada_destino_geo, PRO.id_provedor,
PRO.nombre, PRO.id_region, FVC.[status] 
--HAVING COUNT(FVC.folio_viaje) > 1
--WHERE FVC.[status] IN (0) --AND FVC.fecha_asignacion_proveedor IS NOT NULL;


GO


