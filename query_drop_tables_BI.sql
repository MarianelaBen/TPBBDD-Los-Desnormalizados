-----------------------------------------------------------------------------------------
-- 0. LIMPIEZA INICIAL (Para poder re-ejecutar el script)
-----------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_migrar_hechos_encuestas') AND type in (N'P', N'PC'))
DROP PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_encuestas;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_migrar_hechos_detalle_factura') AND type in (N'P', N'PC'))
DROP PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_detalle_factura;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_migrar_hechos_finales') AND type in (N'P', N'PC'))
DROP PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_finales;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_migrar_hechos_inscripciones') AND type in (N'P', N'PC'))
DROP PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_inscripciones;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_migrar_dimensiones') AND type in (N'P', N'PC'))
DROP PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_dimensiones;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_obtener_rango_etario') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION LOS_DESNORMALIZADOS.BI_obtener_rango_etario;

-- Borrar Vistas
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_vista_10_indice_satisfaccion')) DROP VIEW LOS_DESNORMALIZADOS.BI_vista_10_indice_satisfaccion;
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_vista_09_ingresos_categoria')) DROP VIEW LOS_DESNORMALIZADOS.BI_vista_09_ingresos_categoria;
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_vista_08_morosidad')) DROP VIEW LOS_DESNORMALIZADOS.BI_vista_08_morosidad;
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_vista_07_desvio_pagos')) DROP VIEW LOS_DESNORMALIZADOS.BI_vista_07_desvio_pagos;
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_vista_06_ausentismo')) DROP VIEW LOS_DESNORMALIZADOS.BI_vista_06_ausentismo;
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_vista_05_nota_promedio_finales')) DROP VIEW LOS_DESNORMALIZADOS.BI_vista_05_nota_promedio_finales;
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_vista_04_tiempo_promedio_finalizacion')) DROP VIEW LOS_DESNORMALIZADOS.BI_vista_04_tiempo_promedio_finalizacion;
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_vista_03_desempenio_cursada')) DROP VIEW LOS_DESNORMALIZADOS.BI_vista_03_desempenio_cursada;
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_vista_02_tasa_rechazo')) DROP VIEW LOS_DESNORMALIZADOS.BI_vista_02_tasa_rechazo;
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'LOS_DESNORMALIZADOS.BI_vista_01_categorias_turnos_solicitados')) DROP VIEW LOS_DESNORMALIZADOS.BI_vista_01_categorias_turnos_solicitados;

-- Borrar Tablas de Hechos
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_hechos_encuestas', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_hechos_encuestas;
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_hechos_detalle_factura', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_hechos_detalle_factura;
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_hechos_finales', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_hechos_finales;
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_hechos_inscripciones', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_hechos_inscripciones;

-- Borrar Tablas de Dimensiones
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion;
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_dim_rango_etario', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_dim_rango_etario; -- Unificamos rangos en una tabla genérica o usamos dos según DER
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_dim_medio_pago', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_dim_medio_pago;
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_dim_estado_inscripcion', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_dim_estado_inscripcion;
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_dim_categoria_curso', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_dim_categoria_curso;
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_dim_turno_curso', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_dim_turno_curso;
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_dim_sede', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_dim_sede;
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_dim_profesor', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_dim_profesor;
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_dim_alumno', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_dim_alumno;
IF OBJECT_ID('LOS_DESNORMALIZADOS.BI_dim_tiempo', 'U') IS NOT NULL DROP TABLE LOS_DESNORMALIZADOS.BI_dim_tiempo;

GO