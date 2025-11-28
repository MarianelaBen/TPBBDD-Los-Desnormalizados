USE GD2C2025;
GO

-----------------------------------------------------------------------------------------
-- 1. CREACIÓN DE TABLAS DIMENSIONALES
-----------------------------------------------------------------------------------------

-- Dimensión Tiempo
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_tiempo (
                                                   id BIGINT PRIMARY KEY IDENTITY(1,1),
                                                   anio INT,
                                                   cuatrimestre INT,
                                                   mes INT,
                                                   dia INT
);

-- Dimensión Sede
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_sede (
                                                 id BIGINT PRIMARY KEY,
                                                 provincia VARCHAR(255),
                                                 localidad VARCHAR(255),
                                                 nombre VARCHAR(255),
                                                 direccion VARCHAR(255),
                                                 telefono VARCHAR(255),
                                                 mail VARCHAR(255),
                                                 institucion_nombre VARCHAR(255),
                                                 institucion_razon_social VARCHAR(255),
                                                 institucion_cuit VARCHAR(255),
);

-- Dimensión Turno
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_turno_curso (
                                                        id SMALLINT PRIMARY KEY,
                                                        nombre VARCHAR(255)
);

-- Dimensión Categoría Curso
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_categoria_curso (
                                                            id BIGINT PRIMARY KEY,
                                                            nombre VARCHAR(255)
);

-- Dimensión Estado Inscripción
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_estado_inscripcion (
                                                               id SMALLINT PRIMARY KEY,
                                                               nombre VARCHAR(255)
);

-- Dimensión Medio de Pago
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_medio_pago (
                                                       id BIGINT PRIMARY KEY,
                                                       nombre VARCHAR(255)
);

-- Dimensión Rango Etario Alumnos
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_rango_etario_alumnos (
                                                                 id INT PRIMARY KEY IDENTITY(1,1),
                                                                 descripcion VARCHAR(32),
                                                                 edad_minima INT,
                                                                 edad_maxima INT
);

-- Dimensión Rango Etario Profesores
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_rango_etario_profesores (
                                                                    id INT PRIMARY KEY IDENTITY(1,1),
                                                                    descripcion VARCHAR(32),
                                                                    edad_minima INT,
                                                                    edad_maxima INT
);

-- Dimensión Bloque Satisfacción
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion (
                                                                id BIGINT PRIMARY KEY IDENTITY(1,1),
                                                                descripcion VARCHAR(50),
                                                                nota_min INT,
                                                                nota_max INT
);

GO

-----------------------------------------------------------------------------------------
-- 2. CREACIÓN DE TABLAS DE HECHOS
-----------------------------------------------------------------------------------------

-- Hechos Inscripciones
CREATE TABLE LOS_DESNORMALIZADOS.BI_hechos_inscripciones (
                                                             tiempo_id BIGINT,
                                                             sede_id BIGINT,
                                                             categoria_curso_id BIGINT,
                                                             turno_id SMALLINT,
                                                             rango_etario_alumno_id INT,
                                                             estado_id SMALLINT,

                                                             cantidad_inscripciones INT,
                                                             es_rechazada INT,
                                                             cursada_aprobada INT,

                                                             PRIMARY KEY (tiempo_id, sede_id, categoria_curso_id, turno_id, rango_etario_alumno_id, estado_id),
                                                             FOREIGN KEY (tiempo_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                             FOREIGN KEY (sede_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_sede(id),
                                                             FOREIGN KEY (categoria_curso_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_categoria_curso(id),
                                                             FOREIGN KEY (turno_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_turno_curso(id),
                                                             FOREIGN KEY (rango_etario_alumno_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_rango_etario_alumnos(id),
                                                             FOREIGN KEY (estado_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_estado_inscripcion(id)
);

-- Hechos Finales
CREATE TABLE LOS_DESNORMALIZADOS.BI_hechos_finales (
                                                       tiempo_examen_id BIGINT,
                                                       tiempo_inicio_curso_id BIGINT,
                                                       sede_id BIGINT,
                                                       categoria_curso_id BIGINT,
                                                       rango_etario_alumno_id INT,

                                                       suma_notas_final INT,
                                                       cantidad_examenes_rendidos INT,
                                                       suma_dias_para_finalizar INT,
                                                       cantidad_aprobados INT,
                                                       cantidad_ausentes INT,

                                                       PRIMARY KEY (tiempo_examen_id, tiempo_inicio_curso_id, sede_id, categoria_curso_id, rango_etario_alumno_id),
                                                       FOREIGN KEY (tiempo_examen_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                       FOREIGN KEY (tiempo_inicio_curso_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                       FOREIGN KEY (sede_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_sede(id),
                                                       FOREIGN KEY (categoria_curso_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_categoria_curso(id),
                                                       FOREIGN KEY (rango_etario_alumno_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_rango_etario_alumnos(id)
);

-- Hechos Detalle Factura
CREATE TABLE LOS_DESNORMALIZADOS.BI_hechos_detalle_factura (
                                                               tiempo_emision_id BIGINT,
                                                               tiempo_pago_id BIGINT,
                                                               sede_id BIGINT,
                                                               categoria_curso_id BIGINT,
                                                               medio_pago_id BIGINT,
                                                               rango_etario_alumno_id INT,

                                                               suma_importe_facturado DECIMAL(18,2),
                                                               suma_importe_pagado DECIMAL(18,2),
                                                               suma_importe_adeudado DECIMAL(18,2),
                                                               cantidad_pagos_fuera_termino INT,
                                                               cantidad_facturas INT,

                                                               PRIMARY KEY (tiempo_emision_id, tiempo_pago_id, sede_id, categoria_curso_id, medio_pago_id, rango_etario_alumno_id),
                                                               FOREIGN KEY (tiempo_emision_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                               FOREIGN KEY (tiempo_pago_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                               FOREIGN KEY (sede_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_sede(id),
                                                               FOREIGN KEY (categoria_curso_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_categoria_curso(id),
                                                               FOREIGN KEY (medio_pago_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_medio_pago(id),
                                                               FOREIGN KEY (rango_etario_alumno_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_rango_etario_alumnos(id)
);

-- Hechos Encuestas
CREATE TABLE LOS_DESNORMALIZADOS.BI_hechos_encuestas (
                                                         tiempo_id BIGINT,
                                                         categoria_curso_id BIGINT,
                                                         sede_id BIGINT,
                                                         rango_etario_profesor_id INT,
                                                         bloque_satisfaccion_id BIGINT,

                                                         cantidad_encuestas INT,

                                                         PRIMARY KEY (tiempo_id, categoria_curso_id, sede_id, rango_etario_profesor_id, bloque_satisfaccion_id),
                                                         FOREIGN KEY (tiempo_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                         FOREIGN KEY (categoria_curso_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_categoria_curso(id),
                                                         FOREIGN KEY (sede_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_sede(id),
                                                         FOREIGN KEY (rango_etario_profesor_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_rango_etario_profesores(id),
                                                         FOREIGN KEY (bloque_satisfaccion_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion(id)
);

GO

-----------------------------------------------------------------------------------------
-- 3. FUNCIONES DE SOPORTE
-----------------------------------------------------------------------------------------
CREATE FUNCTION LOS_DESNORMALIZADOS.BI_obtener_edad (@fecha_nacimiento DATETIME, @fecha_referencia DATETIME)
    RETURNS INT AS
BEGIN
    DECLARE @edad INT;
    SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, @fecha_referencia);
    IF (DATEADD(YEAR, @edad, @fecha_nacimiento) > @fecha_referencia) SET @edad = @edad - 1;
RETURN @edad;
END;
GO

CREATE FUNCTION LOS_DESNORMALIZADOS.BI_obtener_rango_etario (@fecha_nacimiento DATETIME, @fecha_referencia DATETIME, @tipo CHAR(1))
    RETURNS INT AS
BEGIN
    IF (@tipo NOT IN ('A', 'P')) RETURN -1;
    DECLARE @edad INT = LOS_DESNORMALIZADOS.BI_obtener_edad(@fecha_nacimiento, @fecha_referencia);
    DECLARE @id_rango INT;
    IF (@tipo = 'A')
SELECT TOP 1 @id_rango = id FROM LOS_DESNORMALIZADOS.BI_dim_rango_etario_alumnos WHERE @edad BETWEEN edad_minima AND edad_maxima;
ELSE
SELECT TOP 1 @id_rango = id FROM LOS_DESNORMALIZADOS.BI_dim_rango_etario_profesores WHERE @edad BETWEEN edad_minima AND edad_maxima;
RETURN @id_rango;
END;
GO

CREATE FUNCTION LOS_DESNORMALIZADOS.BI_alumno_aprobo (@codigo_curso BIGINT, @alumno_id BIGINT)
    RETURNS BIT AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM LOS_DESNORMALIZADOS.modulo m
        JOIN LOS_DESNORMALIZADOS.evaluacion e ON m.id = e.modulo_id
        JOIN LOS_DESNORMALIZADOS.alumno_evaluado ae ON ae.evaluacion_id = e.id
        WHERE m.curso_id = @codigo_curso AND ae.legajo_alumno = @alumno_id
        GROUP BY m.curso_id
        HAVING MIN(ae.nota) >= 4 AND COUNT(DISTINCT m.id) = (SELECT COUNT(*) FROM LOS_DESNORMALIZADOS.modulo WHERE curso_id = @codigo_curso)
    ) AND EXISTS (
        SELECT 1 FROM LOS_DESNORMALIZADOS.trabajo_practico tp WHERE tp.curso_id = @codigo_curso AND tp.alumno_id = @alumno_id AND tp.nota >= 4
    )
        RETURN 1;
RETURN 0;
END;
GO

-----------------------------------------------------------------------------------------
-- 4. PROCEDURES DE MIGRACIÓN
-----------------------------------------------------------------------------------------

CREATE PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_dimensiones AS
BEGIN
    SET NOCOUNT ON;
    -- Rangos y Bloques Fijos
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_rango_etario_alumnos(descripcion, edad_minima, edad_maxima) VALUES ('< 25', 0, 24), ('25 - 35', 25, 35), ('35 - 50', 36, 50), ('> 50', 51, 200);
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_rango_etario_profesores(descripcion, edad_minima, edad_maxima) VALUES ('25 - 35', 25, 35), ('35 - 50', 36, 50), ('> 50', 51, 200);
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion (descripcion, nota_min, nota_max) VALUES ('Insatisfechos', 1, 4), ('Neutrales', 5, 6), ('Satisfechos', 7, 10);

-- Dimensiones Simples

INSERT INTO LOS_DESNORMALIZADOS.BI_dim_sede (id, provincia, localidad, nombre, direccion, telefono, mail, institucion_nombre, institucion_razon_social, institucion_cuit)
SELECT s.id, s.provincia, s.localidad, s.nombre, s.direccion, s.telefono, s.mail, i.nombre, i.razon_social, i.cuit
FROM LOS_DESNORMALIZADOS.sede s JOIN LOS_DESNORMALIZADOS.institucion i ON 1=1;

INSERT INTO LOS_DESNORMALIZADOS.BI_dim_turno_curso SELECT id, nombre FROM LOS_DESNORMALIZADOS.turno;
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_categoria_curso SELECT id, nombre FROM LOS_DESNORMALIZADOS.categoria;
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_estado_inscripcion SELECT id, nombre FROM LOS_DESNORMALIZADOS.estado_inscripcion;
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_medio_pago SELECT id, nombre FROM LOS_DESNORMALIZADOS.medio_de_pago;

-- Dimensión Tiempo
DECLARE @fecha_min DATETIME, @fecha_max DATETIME;
SELECT @fecha_min = MIN(f) FROM (SELECT fecha_emision f FROM LOS_DESNORMALIZADOS.factura UNION SELECT fecha_inicio FROM LOS_DESNORMALIZADOS.curso UNION SELECT fecha_inscripcion FROM LOS_DESNORMALIZADOS.inscripcion_curso UNION SELECT fecha FROM LOS_DESNORMALIZADOS.pago UNION SELECT fecha FROM LOS_DESNORMALIZADOS.final) as F;
SET @fecha_max = GETDATE();

    IF NOT EXISTS (SELECT 1 FROM LOS_DESNORMALIZADOS.BI_dim_tiempo WHERE anio = -1)
BEGIN
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_tiempo (anio, cuatrimestre, mes, dia) VALUES (-1, -1, -1, -1);
END

    WHILE @fecha_min <= @fecha_max BEGIN
        INSERT INTO LOS_DESNORMALIZADOS.BI_dim_tiempo (anio, cuatrimestre, mes, dia) VALUES (YEAR(@fecha_min), CASE WHEN MONTH(@fecha_min) BETWEEN 1 AND 4 THEN 1 WHEN MONTH(@fecha_min) BETWEEN 5 AND 8 THEN 2 ELSE 3 END, MONTH(@fecha_min), DAY(@fecha_min));
        SET @fecha_min = DATEADD(DAY, 1, @fecha_min);
END;
END;
GO

-- Hechos Inscripciones
CREATE PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_inscripciones AS
BEGIN
INSERT INTO LOS_DESNORMALIZADOS.BI_hechos_inscripciones
(tiempo_id, sede_id, categoria_curso_id, turno_id, rango_etario_alumno_id, estado_id, cantidad_inscripciones, es_rechazada, cursada_aprobada)
SELECT
    t.id,
    c.sede_id,
    c.categoria_id,
    hc.turno_id,
    LOS_DESNORMALIZADOS.BI_obtener_rango_etario(a.fecha_nacimiento, ic.fecha_inscripcion, 'A'),
    ic.estado_id,
    COUNT(ic.nro_inscripcion),
    SUM(CASE WHEN ei.nombre = 'Rechazada' THEN 1 ELSE 0 END),
    SUM(CAST(LOS_DESNORMALIZADOS.BI_alumno_aprobo(c.codigo_curso, ic.alumno_id) AS INT))
FROM LOS_DESNORMALIZADOS.inscripcion_curso ic
         JOIN LOS_DESNORMALIZADOS.alumno a ON ic.alumno_id = a.legajo
         JOIN LOS_DESNORMALIZADOS.curso c ON ic.curso_id = c.codigo_curso
         JOIN LOS_DESNORMALIZADOS.estado_inscripcion ei ON ic.estado_id = ei.id
         JOIN LOS_DESNORMALIZADOS.horario_curso hc ON hc.curso_id = c.codigo_curso
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON t.anio = YEAR(ic.fecha_inscripcion) AND t.mes = MONTH(ic.fecha_inscripcion) AND t.dia = DAY(ic.fecha_inscripcion)
GROUP BY t.id, c.sede_id, c.categoria_id, hc.turno_id, ic.estado_id, LOS_DESNORMALIZADOS.BI_obtener_rango_etario(a.fecha_nacimiento, ic.fecha_inscripcion, 'A');
END;
GO

-- Hechos Finales
CREATE PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_finales AS
BEGIN
INSERT INTO LOS_DESNORMALIZADOS.BI_hechos_finales
(tiempo_examen_id, tiempo_inicio_curso_id, sede_id, categoria_curso_id, rango_etario_alumno_id,
 suma_notas_final, cantidad_examenes_rendidos, suma_dias_para_finalizar, cantidad_aprobados, cantidad_ausentes)
SELECT
    t_examen.id,
    t_inicio.id,
    c.sede_id,
    c.categoria_id,
    LOS_DESNORMALIZADOS.BI_obtener_rango_etario(a.fecha_nacimiento, f.fecha, 'A'),
    SUM(ISNULL(fi.nota, 0)),
    COUNT(fi.nro_inscripcion),
    SUM(DATEDIFF(DAY, c.fecha_inicio, f.fecha)),
    SUM(CASE WHEN fi.nota >= 4 THEN 1 ELSE 0 END),
    SUM(CASE WHEN fi.presente = 0 THEN 1 ELSE 0 END)
FROM LOS_DESNORMALIZADOS.final_inscripto fi
         JOIN LOS_DESNORMALIZADOS.final f ON fi.final_id = f.id
         JOIN LOS_DESNORMALIZADOS.curso c ON f.curso_id = c.codigo_curso
         JOIN LOS_DESNORMALIZADOS.alumno a ON fi.alumno_id = a.legajo
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t_examen ON t_examen.anio = YEAR(f.fecha) AND t_examen.mes = MONTH(f.fecha) AND t_examen.dia = DAY(f.fecha)
    JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t_inicio ON t_inicio.anio = YEAR(c.fecha_inicio) AND t_inicio.mes = MONTH(c.fecha_inicio) AND t_inicio.dia = DAY(c.fecha_inicio)
GROUP BY t_examen.id, t_inicio.id, c.sede_id, c.categoria_id, LOS_DESNORMALIZADOS.BI_obtener_rango_etario(a.fecha_nacimiento, f.fecha, 'A');
END;
GO

-- Hechos Detalle Factura
CREATE PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_detalle_factura AS
BEGIN
    DECLARE @id_tiempo_indefinido BIGINT;
SELECT @id_tiempo_indefinido = id FROM LOS_DESNORMALIZADOS.BI_dim_tiempo WHERE anio = -1;

--si no existe -1, lo creamos, si ya existe no hacemos nada
IF NOT EXISTS (SELECT 1 FROM LOS_DESNORMALIZADOS.BI_dim_medio_pago WHERE id = -1)
BEGIN
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_medio_pago (id, nombre) VALUES (-1, 'Desconocido/Impago');
END

INSERT INTO LOS_DESNORMALIZADOS.BI_hechos_detalle_factura
(tiempo_emision_id, tiempo_pago_id, sede_id, categoria_curso_id, medio_pago_id, rango_etario_alumno_id,
 suma_importe_facturado, suma_importe_pagado, suma_importe_adeudado, cantidad_pagos_fuera_termino, cantidad_facturas)
SELECT
    t_emi.id,
    ISNULL(t_pago.id, @id_tiempo_indefinido),
    c.sede_id,
    c.categoria_id,
    ISNULL(p.medio_pago_id, -1),
    LOS_DESNORMALIZADOS.BI_obtener_rango_etario(a.fecha_nacimiento, f.fecha_emision, 'A'),
    SUM(df.importe),
    SUM(ISNULL(p.importe, 0)),
    SUM(CASE WHEN p.id IS NULL THEN df.importe ELSE 0 END),
    SUM(CASE WHEN p.fecha > f.fecha_vencimiento THEN 1 ELSE 0 END),
    COUNT(DISTINCT f.nro_factura)
FROM LOS_DESNORMALIZADOS.detalle_factura df
         JOIN LOS_DESNORMALIZADOS.factura f ON df.factura_id = f.nro_factura
         JOIN LOS_DESNORMALIZADOS.alumno a ON f.alumno_id = a.legajo
         JOIN LOS_DESNORMALIZADOS.curso c ON df.curso_id = c.codigo_curso
         LEFT JOIN LOS_DESNORMALIZADOS.pago p ON f.nro_factura = p.factura_id
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t_emi ON t_emi.anio = YEAR(f.fecha_emision) AND t_emi.mes = MONTH(f.fecha_emision) AND t_emi.dia = DAY(f.fecha_emision)
    LEFT JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t_pago ON t_pago.anio = YEAR(p.fecha) AND t_pago.mes = MONTH(p.fecha) AND t_pago.dia = DAY(p.fecha)
GROUP BY t_emi.id, ISNULL(t_pago.id, @id_tiempo_indefinido), c.sede_id, c.categoria_id, ISNULL(p.medio_pago_id, -1), LOS_DESNORMALIZADOS.BI_obtener_rango_etario(a.fecha_nacimiento, f.fecha_emision, 'A');
END;
GO

-- Hechos Encuestas
CREATE PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_encuestas AS
BEGIN
INSERT INTO LOS_DESNORMALIZADOS.BI_hechos_encuestas
(tiempo_id, categoria_curso_id, sede_id, rango_etario_profesor_id, bloque_satisfaccion_id, cantidad_encuestas)
SELECT
    t.id,
    c.categoria_id,
    c.sede_id,
    LOS_DESNORMALIZADOS.BI_obtener_rango_etario(p.fecha_nacimiento, e.fecha_registro, 'P'),
    bs.id,
    COUNT(de.respuesta)
FROM LOS_DESNORMALIZADOS.detalle_encuesta de
         JOIN LOS_DESNORMALIZADOS.encuesta e ON de.encuesta_id = e.id
         JOIN LOS_DESNORMALIZADOS.curso c ON e.curso_id = c.codigo_curso
         JOIN LOS_DESNORMALIZADOS.profesor p ON c.profesor_id = p.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion bs ON de.respuesta BETWEEN bs.nota_min AND bs.nota_max
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON t.anio = YEAR(e.fecha_registro) AND t.mes = MONTH(e.fecha_registro) AND t.dia = DAY(e.fecha_registro)
GROUP BY t.id, c.categoria_id, c.sede_id, LOS_DESNORMALIZADOS.BI_obtener_rango_etario(p.fecha_nacimiento, e.fecha_registro, 'P'), bs.id;
END;
GO

-----------------------------------------------------------------------------------------
-- 4. EJECUCIÓN
-----------------------------------------------------------------------------------------
EXEC LOS_DESNORMALIZADOS.BI_migrar_dimensiones;
EXEC LOS_DESNORMALIZADOS.BI_migrar_hechos_inscripciones;
EXEC LOS_DESNORMALIZADOS.BI_migrar_hechos_finales;
EXEC LOS_DESNORMALIZADOS.BI_migrar_hechos_detalle_factura;
EXEC LOS_DESNORMALIZADOS.BI_migrar_hechos_encuestas;
GO

-----------------------------------------------------------------------------------------
-- 5. VISTAS
-----------------------------------------------------------------------------------------

-- 1. Categorías y turnos más solicitados
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_01_categorias_turnos_solicitados AS
WITH Ranking AS (
    SELECT t.anio, s.nombre sede, cat.nombre categoria, tur.nombre turno, SUM(h.cantidad_inscripciones) total,
           ROW_NUMBER() OVER (PARTITION BY t.anio, s.nombre ORDER BY SUM(h.cantidad_inscripciones) DESC) rn
    FROM LOS_DESNORMALIZADOS.BI_hechos_inscripciones h
    JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_id = t.id
    JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
    JOIN LOS_DESNORMALIZADOS.BI_dim_categoria_curso cat ON h.categoria_curso_id = cat.id
    JOIN LOS_DESNORMALIZADOS.BI_dim_turno_curso tur ON h.turno_id = tur.id
    GROUP BY t.anio, s.nombre, cat.nombre, tur.nombre
)
SELECT anio, sede, categoria, turno, total FROM Ranking WHERE rn <= 3;
GO

-- 2. Tasa de rechazo
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_02_tasa_rechazo AS
SELECT t.anio, t.mes, s.nombre sede,
       CAST(SUM(CAST(h.es_rechazada AS INT)) * 100.0 / NULLIF(SUM(h.cantidad_inscripciones),0) AS DECIMAL(10,2)) tasa_rechazo
FROM LOS_DESNORMALIZADOS.BI_hechos_inscripciones h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
GROUP BY t.anio, t.mes, s.nombre;
GO

-- 3. Aprobación cursada
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_03_desempenio_cursada AS
SELECT t.anio, s.nombre sede,
       CAST(SUM(CAST(h.cursada_aprobada AS INT)) * 100.0 / NULLIF(SUM(h.cantidad_inscripciones),0) AS DECIMAL(10,2)) aprobacion
FROM LOS_DESNORMALIZADOS.BI_hechos_inscripciones h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
GROUP BY t.anio, s.nombre;
GO

-- 4. Tiempo promedio finalización
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_04_tiempo_promedio_finalizacion AS
SELECT t.anio, cat.nombre categoria,
       CAST(SUM(CAST(h.suma_dias_para_finalizar AS DECIMAL(10,2))) / NULLIF(SUM(h.cantidad_aprobados),0) AS DECIMAL(10,2)) promedio_dias
FROM LOS_DESNORMALIZADOS.BI_hechos_finales h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_inicio_curso_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_categoria_curso cat ON h.categoria_curso_id = cat.id
WHERE h.cantidad_aprobados > 0
GROUP BY t.anio, cat.nombre;
GO

-- 5. Nota promedio finales
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_05_nota_promedio_finales AS
SELECT re.descripcion rango, cat.nombre categoria, t.anio,
       CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END semestre,
       CAST(SUM(CAST(h.suma_notas_final AS DECIMAL(10,2))) / NULLIF(SUM(h.cantidad_examenes_rendidos - h.cantidad_ausentes),0) AS DECIMAL(10,2)) promedio_nota
FROM LOS_DESNORMALIZADOS.BI_hechos_finales h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_examen_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_categoria_curso cat ON h.categoria_curso_id = cat.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_rango_etario_alumnos re ON h.rango_etario_alumno_id = re.id
GROUP BY re.descripcion, cat.nombre, t.anio, CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END;
GO

-- 6. Ausentismo
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_06_ausentismo AS
SELECT s.nombre sede, t.anio, CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END semestre,
       CAST(SUM(CAST(h.cantidad_ausentes AS INT)) * 100.0 / NULLIF(SUM(h.cantidad_examenes_rendidos),0) AS DECIMAL(10,2)) ausentismo
FROM LOS_DESNORMALIZADOS.BI_hechos_finales h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_examen_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
GROUP BY s.nombre, t.anio, CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END;
GO

-- 7. Desvío pagos
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_07_desvio_pagos AS
SELECT t.anio, CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END semestre,
       CAST(SUM(CAST(h.cantidad_pagos_fuera_termino AS INT)) * 100.0 / NULLIF(SUM(h.cantidad_facturas),0) AS DECIMAL(10,2)) porcentaje_tardios
FROM LOS_DESNORMALIZADOS.BI_hechos_detalle_factura h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_pago_id = t.id
GROUP BY t.anio, CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END;
GO

-- 8. Morosidad
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_08_morosidad AS
SELECT t.anio, t.mes,
       CAST(SUM(h.suma_importe_adeudado) * 100.0 / NULLIF(SUM(h.suma_importe_facturado),0) AS DECIMAL(10,2)) tasa_morosidad
FROM LOS_DESNORMALIZADOS.BI_hechos_detalle_factura h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_emision_id = t.id
GROUP BY t.anio, t.mes;
GO

-- 9. Ingresos Categoría
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_09_ingresos_categoria AS
WITH Ingresos AS (
    SELECT t.anio, s.nombre sede, cat.nombre categoria, SUM(h.suma_importe_pagado) total,
           ROW_NUMBER() OVER (PARTITION BY t.anio, s.nombre ORDER BY SUM(h.suma_importe_pagado) DESC) rn
    FROM LOS_DESNORMALIZADOS.BI_hechos_detalle_factura h
    JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_pago_id = t.id
    JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
    JOIN LOS_DESNORMALIZADOS.BI_dim_categoria_curso cat ON h.categoria_curso_id = cat.id
    GROUP BY t.anio, s.nombre, cat.nombre
)
SELECT anio, sede, categoria, total FROM Ingresos WHERE rn <= 3;
GO

-- 10. Satisfacción
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_10_indice_satisfaccion AS
SELECT t.anio, s.nombre sede, re.descripcion rango_profe,
       CAST(((SUM(CASE WHEN bs.descripcion='Satisfechos' THEN h.cantidad_encuestas ELSE 0 END) * 100.0 / NULLIF(SUM(h.cantidad_encuestas),0)) -
             (SUM(CASE WHEN bs.descripcion='Insatisfechos' THEN h.cantidad_encuestas ELSE 0 END) * 100.0 / NULLIF(SUM(h.cantidad_encuestas),0)) + 100) / 2 AS DECIMAL(10,2)) indice
FROM LOS_DESNORMALIZADOS.BI_hechos_encuestas h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_rango_etario_profesores re ON h.rango_etario_profesor_id = re.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion bs ON h.bloque_satisfaccion_id = bs.id
GROUP BY t.anio, s.nombre, re.descripcion;
GO
