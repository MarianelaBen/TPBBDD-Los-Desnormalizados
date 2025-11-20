USE GD2C2025;
GO

-----------------------------------------------------------------------------------------
-- 1. CREACIÓN DE TABLAS DIMENSIONALES
-----------------------------------------------------------------------------------------

-- Dimensión Tiempo
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_tiempo (
                                                   id INT PRIMARY KEY IDENTITY(1,1),
                                                   anio INT,
                                                   cuatrimestre INT,
                                                   mes INT,
                                                   dia INT
);

-- Dimensión Alumno
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_alumno (
                                                   legajo BIGINT PRIMARY KEY,
                                                   nombre VARCHAR(255),
                                                   apellido VARCHAR(255),
                                                   dni BIGINT,
                                                   direccion VARCHAR(255),
                                                   telefono VARCHAR(255),
                                                   mail VARCHAR(255),
                                                   provincia VARCHAR(255),
                                                   localidad VARCHAR(255),
                                                   fecha_nacimiento DATETIME
);

-- Dimensión Profesor
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_profesor (
                                                     id BIGINT PRIMARY KEY,
                                                     nombre VARCHAR(255),
                                                     apellido VARCHAR(255),
                                                     dni VARCHAR(255),
                                                     direccion VARCHAR(255),
                                                     correo VARCHAR(255),
                                                     telefono VARCHAR(255),
                                                     provincia VARCHAR(255),
                                                     localidad VARCHAR(255),
                                                     fecha_nacimiento DATETIME
);

-- Dimensión Sede
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_sede (
                                                 id BIGINT PRIMARY KEY,
                                                 provincia VARCHAR(255),
                                                 localidad VARCHAR(255),
                                                 nombre VARCHAR(255),
                                                 direccion VARCHAR(255),
                                                 telefono VARCHAR(255),
                                                 mail VARCHAR(255)
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

-- Dimensión Rango Etario
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_rango_etario (
                                                         id INT PRIMARY KEY IDENTITY(1,1),
                                                         descripcion VARCHAR(50),
                                                         edad_minima INT,
                                                         edad_maxima INT
);

-- Dimensión Bloque Satisfacción
CREATE TABLE LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion (
                                                                id INT PRIMARY KEY IDENTITY(1,1),
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
                                                             tiempo_id INT,
                                                             sede_id BIGINT,
                                                             categoria_curso_id BIGINT,
                                                             turno_id SMALLINT,
                                                             alumno_id BIGINT,
                                                             estado_id SMALLINT,
                                                             cantidad_inscripciones INT,
                                                             es_rechazada INT,
                                                             cursada_aprobada INT,

                                                             PRIMARY KEY (tiempo_id, sede_id, categoria_curso_id, turno_id, alumno_id),
                                                             FOREIGN KEY (tiempo_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                             FOREIGN KEY (sede_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_sede(id),
                                                             FOREIGN KEY (categoria_curso_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_categoria_curso(id),
                                                             FOREIGN KEY (turno_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_turno_curso(id),
                                                             FOREIGN KEY (alumno_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_alumno(legajo),
                                                             FOREIGN KEY (estado_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_estado_inscripcion(id)
);

-- Hechos Finales
CREATE TABLE LOS_DESNORMALIZADOS.BI_hechos_finales (
                                                       tiempo_examen_id INT,
                                                       tiempo_inicio_curso_id INT,
                                                       alumno_id BIGINT,
                                                       categoria_curso_id BIGINT,
                                                       sede_id BIGINT,
                                                       profesor_id BIGINT,
                                                       rango_etario_alumno_id INT,
                                                       nota_final INT,
                                                       dias_para_finalizar INT,
                                                       es_aprobado INT,
                                                       es_ausente INT,

                                                       FOREIGN KEY (tiempo_examen_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                       FOREIGN KEY (tiempo_inicio_curso_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                       FOREIGN KEY (alumno_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_alumno(legajo),
                                                       FOREIGN KEY (categoria_curso_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_categoria_curso(id),
                                                       FOREIGN KEY (sede_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_sede(id),
                                                       FOREIGN KEY (profesor_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_profesor(id),
                                                       FOREIGN KEY (rango_etario_alumno_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_rango_etario(id)
);

-- Hechos Detalle Factura
CREATE TABLE LOS_DESNORMALIZADOS.BI_hechos_detalle_factura (
                                                               tiempo_emision_id INT,
                                                               tiempo_vencimiento_id INT,
                                                               tiempo_pago_id INT,
                                                               sede_id BIGINT,
                                                               alumno_id BIGINT,
                                                               categoria_curso_id BIGINT,
                                                               medio_pago_id BIGINT,
                                                               importe_facturado DECIMAL(18,2),
                                                               es_pago_fuera_termino INT,
                                                               importe_adeudado DECIMAL(18,2),
                                                               importe_pagado DECIMAL(18,2),

                                                               FOREIGN KEY (tiempo_emision_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                               FOREIGN KEY (tiempo_vencimiento_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                               FOREIGN KEY (tiempo_pago_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                               FOREIGN KEY (sede_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_sede(id),
                                                               FOREIGN KEY (alumno_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_alumno(legajo),
                                                               FOREIGN KEY (categoria_curso_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_categoria_curso(id),
                                                               FOREIGN KEY (medio_pago_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_medio_pago(id)
);

-- Hechos Encuestas
CREATE TABLE LOS_DESNORMALIZADOS.BI_hechos_encuestas (
                                                         tiempo_id INT,
                                                         alumno_id BIGINT,
                                                         categoria_curso_id BIGINT,
                                                         sede_id BIGINT,
                                                         profesor_id BIGINT,
                                                         rango_etario_profesor_id INT,
                                                         bloque_satisfaccion_id INT,
                                                         cantidad_encuestas INT,

                                                         FOREIGN KEY (tiempo_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_tiempo(id),
                                                         FOREIGN KEY (alumno_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_alumno(legajo),
                                                         FOREIGN KEY (categoria_curso_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_categoria_curso(id),
                                                         FOREIGN KEY (sede_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_sede(id),
                                                         FOREIGN KEY (profesor_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_profesor(id),
                                                         FOREIGN KEY (rango_etario_profesor_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_rango_etario(id),
                                                         FOREIGN KEY (bloque_satisfaccion_id) REFERENCES LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion(id)
);

GO

-----------------------------------------------------------------------------------------
-- 3. FUNCIONES Y PROCEDURES DE MIGRACIÓN
-----------------------------------------------------------------------------------------

CREATE FUNCTION LOS_DESNORMALIZADOS.BI_obtener_rango_etario (@fecha_nacimiento DATETIME, @fecha_referencia DATETIME)
    RETURNS INT
AS
BEGIN
    DECLARE @edad INT;
    SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, @fecha_referencia);

    IF (DATEADD(YEAR, @edad, @fecha_nacimiento) > @fecha_referencia)
        SET @edad = @edad - 1;

    DECLARE @id_rango INT;

SELECT TOP 1 @id_rango = id
FROM LOS_DESNORMALIZADOS.BI_dim_rango_etario
WHERE @edad BETWEEN edad_minima AND edad_maxima;

RETURN @id_rango;
END;
GO

-- Procedure: Migración de Dimensiones
CREATE PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_dimensiones
    AS
BEGIN
    -- 1. Rango Etario
    -- Alumnos: <25, 25-35, 35-50, >50
    -- Profesores: 25-35, 35-50, >50.
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_rango_etario (descripcion, edad_minima, edad_maxima) VALUES
                                                                                                ('< 25', 0, 24),
                                                                                                ('25 - 35', 25, 35),
                                                                                                ('35 - 50', 36, 50),
                                                                                                ('> 50', 51, 200);

-- 2. Bloque Satisfacción
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion (descripcion, nota_min, nota_max) VALUES
                                                                                                 ('Insatisfechos', 1, 4),
                                                                                                 ('Neutrales', 5, 6),
                                                                                                 ('Satisfechos', 7, 10);

-- 3. Migrar Alumnos
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_alumno
SELECT legajo, nombre, apellido, dni, direccion, telefono, mail, provincia, localidad, fecha_nacimiento
FROM LOS_DESNORMALIZADOS.alumno;

-- 4. Migrar Profesores
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_profesor
SELECT id, nombre, apellido, dni, direccion, correo, telefono, provincia, localidad, fecha_nacimiento
FROM LOS_DESNORMALIZADOS.profesor;

-- 5. Migrar Sedes
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_sede
SELECT id, provincia, localidad, nombre, direccion, telefono, mail
FROM LOS_DESNORMALIZADOS.sede;

-- 6. Migrar Turnos
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_turno_curso
SELECT id, nombre FROM LOS_DESNORMALIZADOS.turno;

-- 7. Migrar Categorias
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_categoria_curso
SELECT id, nombre FROM LOS_DESNORMALIZADOS.categoria;

-- 8. Migrar Estados
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_estado_inscripcion
SELECT id, nombre FROM LOS_DESNORMALIZADOS.estado_inscripcion;

-- 9. Migrar Medios Pago
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_medio_pago
SELECT id, nombre FROM LOS_DESNORMALIZADOS.medio_de_pago;

-- 10. Migrar Dimensión Tiempo
DECLARE @fecha_min DATETIME, @fecha_max DATETIME;

SELECT @fecha_min = MIN(f) FROM (
                                    SELECT fecha_emision as f FROM LOS_DESNORMALIZADOS.factura
                                    UNION SELECT fecha_inicio FROM LOS_DESNORMALIZADOS.curso
                                    UNION SELECT fecha_inscripcion FROM LOS_DESNORMALIZADOS.inscripcion_curso
                                    UNION SELECT fecha FROM LOS_DESNORMALIZADOS.pago
                                    UNION SELECT fecha FROM LOS_DESNORMALIZADOS.final
                                ) as Fechas;

SET @fecha_max = GETDATE();

    WHILE @fecha_min <= @fecha_max
BEGIN
INSERT INTO LOS_DESNORMALIZADOS.BI_dim_tiempo (anio, cuatrimestre, mes, dia)
VALUES (
           YEAR(@fecha_min),
                CASE WHEN MONTH(@fecha_min) BETWEEN 1 AND 4 THEN 1
                 WHEN MONTH(@fecha_min) BETWEEN 5 AND 8 THEN 2
                 ELSE 3 END,
           MONTH(@fecha_min),
           DAY(@fecha_min)
       );
SET @fecha_min = DATEADD(DAY, 1, @fecha_min);
END;
END;
GO

-- Procedure: Migrar Hechos Inscripciones
CREATE PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_inscripciones
    AS
BEGIN
INSERT INTO LOS_DESNORMALIZADOS.BI_hechos_inscripciones
(tiempo_id, sede_id, categoria_curso_id, turno_id, alumno_id, estado_id, cantidad_inscripciones, es_rechazada, cursada_aprobada)
SELECT
    t.id,
    c.sede_id,
    c.categoria_id,
    hc.turno_id,
    ic.alumno_id,
    ic.estado_id,
    1 as cantidad,
    CASE WHEN ei.nombre = 'Rechazada' THEN 1 ELSE 0 END,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM LOS_DESNORMALIZADOS.modulo m
                              JOIN LOS_DESNORMALIZADOS.evaluacion e ON m.id = e.modulo_id
                              JOIN LOS_DESNORMALIZADOS.alumno_evaluado ae ON ae.evaluacion_id = e.id
            WHERE m.curso_id = c.codigo_curso
              AND ae.legajo_alumno = ic.alumno_id
            GROUP BY m.curso_id
            HAVING MIN(ae.nota) >= 4
               AND COUNT(DISTINCT m.id) = (SELECT COUNT(*) FROM LOS_DESNORMALIZADOS.modulo WHERE curso_id = c.codigo_curso)
        ) AND EXISTS (
            SELECT 1 FROM LOS_DESNORMALIZADOS.trabajo_practico tp
            WHERE tp.curso_id = c.codigo_curso
              AND tp.alumno_id = ic.alumno_id
              AND tp.nota >= 4
        ) THEN 1
        ELSE 0
        END
FROM LOS_DESNORMALIZADOS.inscripcion_curso ic
         JOIN LOS_DESNORMALIZADOS.curso c ON ic.curso_id = c.codigo_curso
         JOIN LOS_DESNORMALIZADOS.estado_inscripcion ei ON ic.estado_id = ei.id
         JOIN LOS_DESNORMALIZADOS.horario_curso hc ON hc.curso_id = c.codigo_curso
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON t.anio = YEAR(ic.fecha_inscripcion) AND t.mes = MONTH(ic.fecha_inscripcion) AND t.dia = DAY(ic.fecha_inscripcion);
END;
GO

-- Procedure: Migrar Hechos Finales
CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_finales
    AS
BEGIN

INSERT INTO LOS_DESNORMALIZADOS.BI_hechos_finales
(tiempo_examen_id, tiempo_inicio_curso_id, alumno_id, categoria_curso_id, sede_id, profesor_id, rango_etario_alumno_id, nota_final, dias_para_finalizar, es_aprobado, es_ausente)
SELECT
    t_examen.id,
    t_inicio.id,
    fi.alumno_id,
    c.categoria_id,
    c.sede_id,
    c.profesor_id,
    LOS_DESNORMALIZADOS.BI_obtener_rango_etario(a.fecha_nacimiento, f.fecha),
    fi.nota,
    DATEDIFF(DAY, c.fecha_inicio, f.fecha),
    CASE WHEN fi.nota >= 4 THEN 1 ELSE 0 END,
    CASE WHEN fi.presente = 0 THEN 1 ELSE 0 END
FROM LOS_DESNORMALIZADOS.final_inscripto fi
         JOIN LOS_DESNORMALIZADOS.final f ON fi.final_id = f.id
         JOIN LOS_DESNORMALIZADOS.curso c ON f.curso_id = c.codigo_curso
         JOIN LOS_DESNORMALIZADOS.alumno a ON fi.alumno_id = a.legajo
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t_examen ON t_examen.anio = YEAR(f.fecha) AND t_examen.mes = MONTH(f.fecha) AND t_examen.dia = DAY(f.fecha)
    JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t_inicio ON t_inicio.anio = YEAR(c.fecha_inicio) AND t_inicio.mes = MONTH(c.fecha_inicio) AND t_inicio.dia = DAY(c.fecha_inicio);
END;
GO

-- Procedure: Migrar Hechos Detalle Factura
CREATE PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_detalle_factura
    AS
BEGIN

INSERT INTO LOS_DESNORMALIZADOS.BI_hechos_detalle_factura
(tiempo_emision_id, tiempo_vencimiento_id, tiempo_pago_id, sede_id, alumno_id, categoria_curso_id, medio_pago_id, importe_facturado, es_pago_fuera_termino, importe_adeudado, importe_pagado)
SELECT
    t_emi.id,
    t_venc.id,
    t_pago.id,
    c.sede_id,
    f.alumno_id,
    c.categoria_id,
    p.medio_pago_id,
    df.importe,
    CASE WHEN p.fecha > f.fecha_vencimiento THEN 1 ELSE 0 END,
    CASE WHEN p.id IS NULL THEN df.importe ELSE 0 END,
    ISNULL(p.importe, 0)
FROM LOS_DESNORMALIZADOS.detalle_factura df
         JOIN LOS_DESNORMALIZADOS.factura f ON df.factura_id = f.nro_factura
         JOIN LOS_DESNORMALIZADOS.curso c ON df.curso_id = c.codigo_curso
         LEFT JOIN LOS_DESNORMALIZADOS.pago p ON f.nro_factura = p.factura_id
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t_emi ON t_emi.anio = YEAR(f.fecha_emision) AND t_emi.mes = MONTH(f.fecha_emision) AND t_emi.dia = DAY(f.fecha_emision)
    JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t_venc ON t_venc.anio = YEAR(f.fecha_vencimiento) AND t_venc.mes = MONTH(f.fecha_vencimiento) AND t_venc.dia = DAY(f.fecha_vencimiento)
    LEFT JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t_pago ON t_pago.anio = YEAR(p.fecha) AND t_pago.mes = MONTH(p.fecha) AND t_pago.dia = DAY(p.fecha);
END;
GO

-- Procedure: Migrar Hechos Encuestas
CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.BI_migrar_hechos_encuestas
    AS
BEGIN
INSERT INTO LOS_DESNORMALIZADOS.BI_hechos_encuestas
(
    tiempo_id,
    alumno_id,
    categoria_curso_id,
    sede_id,
    profesor_id,
    rango_etario_profesor_id,
    bloque_satisfaccion_id,
    cantidad_encuestas
)
SELECT
    t.id,
    NULL,
    c.categoria_id,
    c.sede_id,
    c.profesor_id,
    LOS_DESNORMALIZADOS.BI_obtener_rango_etario(p.fecha_nacimiento, e.fecha_registro),
    bs.id,
    COUNT(de.respuesta)
FROM LOS_DESNORMALIZADOS.detalle_encuesta de
         JOIN LOS_DESNORMALIZADOS.encuesta e ON de.encuesta_id = e.id
         JOIN LOS_DESNORMALIZADOS.curso c ON e.curso_id = c.codigo_curso
         JOIN LOS_DESNORMALIZADOS.profesor p ON c.profesor_id = p.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion bs ON de.respuesta BETWEEN bs.nota_min AND bs.nota_max
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON t.anio = YEAR(e.fecha_registro) AND t.mes = MONTH(e.fecha_registro) AND t.dia = DAY(e.fecha_registro)

GROUP BY
    t.id,
    c.categoria_id,
    c.sede_id,
    c.profesor_id,
    LOS_DESNORMALIZADOS.BI_obtener_rango_etario(p.fecha_nacimiento, e.fecha_registro),
    bs.id;
END;
GO


-----------------------------------------------------------------------------------------
-- 4. EJECUCIÓN DE MIGRACIÓN
-----------------------------------------------------------------------------------------
EXEC LOS_DESNORMALIZADOS.BI_migrar_dimensiones;
EXEC LOS_DESNORMALIZADOS.BI_migrar_hechos_inscripciones;
EXEC LOS_DESNORMALIZADOS.BI_migrar_hechos_finales;
EXEC LOS_DESNORMALIZADOS.BI_migrar_hechos_detalle_factura;
EXEC LOS_DESNORMALIZADOS.BI_migrar_hechos_encuestas;
GO

-----------------------------------------------------------------------------------------
-- 5. CREACIÓN DE VISTAS
-----------------------------------------------------------------------------------------

-- 1. Categorías y turnos más solicitados (Top 3 por año y sede)
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_01_categorias_turnos_solicitados AS
WITH ConteoInscripciones AS (
    SELECT
        t.anio,
        s.nombre AS sede,
        cat.nombre AS categoria,
        tur.nombre AS turno,
        SUM(h.cantidad_inscripciones) AS total_inscriptos
    FROM LOS_DESNORMALIZADOS.BI_hechos_inscripciones h
    JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_id = t.id
    JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
    JOIN LOS_DESNORMALIZADOS.BI_dim_categoria_curso cat ON h.categoria_curso_id = cat.id
    JOIN LOS_DESNORMALIZADOS.BI_dim_turno_curso tur ON h.turno_id = tur.id
    GROUP BY t.anio, s.nombre, cat.nombre, tur.nombre
),
RankingInscripciones AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY anio, sede
            ORDER BY total_inscriptos DESC
        ) AS ranking
    FROM ConteoInscripciones
)
SELECT
    anio,
    sede,
    categoria,
    turno,
    total_inscriptos
FROM RankingInscripciones
WHERE ranking <= 3;
GO

-- 2. Tasa de rechazo de inscripciones
CREATE VIEW LOS_DESNORMALIZADOS.BI_vista_02_tasa_rechazo AS
SELECT
    t.anio,
    t.mes,
    s.nombre AS sede,
    CAST(SUM(h.es_rechazada) AS DECIMAL(10,2)) / COUNT(*) * 100 AS porcentaje_rechazo
FROM LOS_DESNORMALIZADOS.BI_hechos_inscripciones h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
GROUP BY t.anio, t.mes, s.nombre;
GO

-- 3. Comparación de desempeño de cursada por sede
CREATE VIEW LOS_DESNORMALIZADOS.BI_vista_03_desempenio_cursada AS
SELECT
    t.anio,
    s.nombre AS sede,
    CAST(SUM(h.cursada_aprobada) AS DECIMAL(10,2)) / COUNT(*) * 100 AS porcentaje_aprobacion_cursada
FROM LOS_DESNORMALIZADOS.BI_hechos_inscripciones h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
GROUP BY t.anio, s.nombre;
GO

-- 4. Tiempo promedio de finalización de curso
CREATE VIEW LOS_DESNORMALIZADOS.BI_vista_04_tiempo_promedio_finalizacion AS
SELECT
    t.anio,
    cat.nombre AS categoria,
    AVG(h.dias_para_finalizar) AS promedio_dias
FROM LOS_DESNORMALIZADOS.BI_hechos_finales h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_inicio_curso_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_categoria_curso cat ON h.categoria_curso_id = cat.id
WHERE h.es_aprobado = 1
GROUP BY t.anio, cat.nombre;
GO

-- 5. Nota promedio de finales
CREATE VIEW LOS_DESNORMALIZADOS.BI_vista_05_nota_promedio_finales AS
SELECT
    re.descripcion AS rango_etario,
    cat.nombre AS categoria,
    t.anio,
    CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END AS semestre,
    AVG(h.nota_final) AS promedio_nota
FROM LOS_DESNORMALIZADOS.BI_hechos_finales h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_examen_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_categoria_curso cat ON h.categoria_curso_id = cat.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_rango_etario re ON h.rango_etario_alumno_id = re.id
GROUP BY re.descripcion, cat.nombre, t.anio, CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END;
GO

-- 6. Tasa de ausentismo finales
CREATE VIEW LOS_DESNORMALIZADOS.BI_vista_06_ausentismo AS
SELECT
    s.nombre AS sede,
    t.anio,
    CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END AS semestre,
    CAST(SUM(h.es_ausente) AS DECIMAL(10,2)) / COUNT(*) * 100 AS porcentaje_ausentismo
FROM LOS_DESNORMALIZADOS.BI_hechos_finales h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_examen_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
GROUP BY s.nombre, t.anio, CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END;
GO

-- 7. Desvío de pagos (Porcentaje fuera de término)
CREATE VIEW LOS_DESNORMALIZADOS.BI_vista_07_desvio_pagos AS
SELECT
    t.anio,
    CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END AS semestre,
    CAST(SUM(h.es_pago_fuera_termino) AS DECIMAL(10,2)) / COUNT(*) * 100 AS porcentaje_pagos_tardios
FROM LOS_DESNORMALIZADOS.BI_hechos_detalle_factura h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_pago_id = t.id -- Usamos fecha de pago real
GROUP BY t.anio, CASE WHEN t.mes <= 6 THEN 1 ELSE 2 END;
GO

-- 8. Tasa de Morosidad Financiera mensual
CREATE VIEW LOS_DESNORMALIZADOS.BI_vista_08_morosidad AS
SELECT
    t.anio,
    t.mes,
    CAST(SUM(h.importe_adeudado) AS DECIMAL(18,2)) / SUM(h.importe_facturado) * 100 AS tasa_morosidad
FROM LOS_DESNORMALIZADOS.BI_hechos_detalle_factura h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_emision_id = t.id
GROUP BY t.anio, t.mes;
GO

-- 9. Ingresos por categoría de cursos (Top 3)
CREATE OR ALTER VIEW LOS_DESNORMALIZADOS.BI_vista_09_ingresos_categoria AS
WITH SumaIngresos AS (
    SELECT
        t.anio,
        s.nombre AS sede,
        cat.nombre AS categoria,
        SUM(h.importe_pagado) AS total_ingresos
    FROM LOS_DESNORMALIZADOS.BI_hechos_detalle_factura h
    JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_pago_id = t.id
    JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
    JOIN LOS_DESNORMALIZADOS.BI_dim_categoria_curso cat ON h.categoria_curso_id = cat.id
    GROUP BY t.anio, s.nombre, cat.nombre
),
RankingIngresos AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY anio, sede
            ORDER BY total_ingresos DESC
        ) AS ranking
    FROM SumaIngresos
)
SELECT
    anio,
    sede,
    categoria,
    total_ingresos
FROM RankingIngresos
WHERE ranking <= 3;
GO

-- 10. Índice de satisfacción
CREATE VIEW LOS_DESNORMALIZADOS.BI_vista_10_indice_satisfaccion AS
SELECT
    t.anio,
    s.nombre AS sede,
    re.descripcion AS rango_etario_profesor,
    (
        (
            (CAST(SUM(CASE WHEN bs.descripcion = 'Satisfechos' THEN h.cantidad_encuestas ELSE 0 END) AS DECIMAL) / NULLIF(SUM(h.cantidad_encuestas),0) * 100)
                -
            (CAST(SUM(CASE WHEN bs.descripcion = 'Insatisfechos' THEN h.cantidad_encuestas ELSE 0 END) AS DECIMAL) / NULLIF(SUM(h.cantidad_encuestas),0) * 100)
            ) + 100
        ) / 2 AS indice_satisfaccion
FROM LOS_DESNORMALIZADOS.BI_hechos_encuestas h
         JOIN LOS_DESNORMALIZADOS.BI_dim_tiempo t ON h.tiempo_id = t.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_sede s ON h.sede_id = s.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_rango_etario re ON h.rango_etario_profesor_id = re.id
         JOIN LOS_DESNORMALIZADOS.BI_dim_bloque_satisfaccion bs ON h.bloque_satisfaccion_id = bs.id
GROUP BY t.anio, s.nombre, re.descripcion;
GO



select * from LOS_DESNORMALIZADOS.BI_vista_01_categorias_turnos_solicitados
select * from LOS_DESNORMALIZADOS.BI_vista_02_tasa_rechazo order by anio, mes, sede asc
select * from LOS_DESNORMALIZADOS.BI_vista_03_desempenio_cursada order by anio, sede
select * from LOS_DESNORMALIZADOS.BI_vista_04_tiempo_promedio_finalizacion order by anio, categoria
select * from LOS_DESNORMALIZADOS.BI_vista_05_nota_promedio_finales order by anio, semestre, categoria
select * from LOS_DESNORMALIZADOS.BI_vista_06_ausentismo order by anio, semestre, sede
select * from LOS_DESNORMALIZADOS.BI_vista_07_desvio_pagos order by anio, semestre
select * from LOS_DESNORMALIZADOS.BI_vista_08_morosidad order by anio, mes
select * from LOS_DESNORMALIZADOS.BI_vista_09_ingresos_categoria order by anio, sede
select * from LOS_DESNORMALIZADOS.BI_vista_10_indice_satisfaccion order by anio, sede
