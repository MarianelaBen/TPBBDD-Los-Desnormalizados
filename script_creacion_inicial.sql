USE GD2C2025;
GO

CREATE SCHEMA LOS_DESNORMALIZADOS;
GO
------------------------------------------------------
-- CREAMOS TABLAS
------------------------------------------------------
CREATE TABLE LOS_DESNORMALIZADOS.profesor (
                                              id BIGINT PRIMARY KEY IDENTITY(1,1),
                                              nombre VARCHAR(255) NOT NULL,
                                              apellido VARCHAR(255) NOT NULL,
                                              dni VARCHAR(10)NOT NULL,
                                              direccion VARCHAR(255),
                                              fecha_nacimiento DATETIME,
                                              correo VARCHAR(255),
                                              telefono VARCHAR(255),
                                              provincia VARCHAR(255),
                                              localidad VARCHAR(255)
);

CREATE TABLE LOS_DESNORMALIZADOS.alumno (
                                            legajo BIGINT PRIMARY KEY,
                                            nombre VARCHAR(255) NOT NULL,
                                            apellido VARCHAR(255) NOT NULL,
                                            dni BIGINT NOT NULL,
                                            direccion VARCHAR(255),
                                            telefono VARCHAR(255),
                                            mail VARCHAR(255),
                                            provincia VARCHAR(255),
                                            localidad VARCHAR(255),
                                            fecha_nacimiento DATETIME
);

CREATE TABLE LOS_DESNORMALIZADOS.sede(
                                         id BIGINT PRIMARY KEY IDENTITY(1,1),
                                         provincia VARCHAR(255),
                                         localidad VARCHAR(255),
                                         nombre VARCHAR(255),
                                         direccion VARCHAR(255),
                                         telefono VARCHAR(255),
                                         mail VARCHAR(255)
);


CREATE TABLE LOS_DESNORMALIZADOS.institucion(
                                                id BIGINT PRIMARY KEY IDENTITY(1,1),
                                                nombre VARCHAR(255),
                                                razon_social VARCHAR(255),
                                                cuit VARCHAR(255)
);

CREATE TABLE LOS_DESNORMALIZADOS.categoria(
                                              id BIGINT PRIMARY KEY IDENTITY(1,1),
                                              nombre VARCHAR(255) UNIQUE CHECK(nombre IN ('Categoria N°:0',
                                                                                          'Categoria N°:1',
                                                                                          'Categoria N°:2',
                                                                                          'Categoria N°:3',
                                                                                          'Categoria N°:4'))
);

CREATE TABLE LOS_DESNORMALIZADOS.curso(
                                          codigo_curso BIGINT PRIMARY KEY,
                                          sede_id BIGINT,
                                          profesor_id BIGINT,
                                          nombre VARCHAR(255),
                                          descripcion VARCHAR(255),
                                          categoria_id BIGINT,
                                          fecha_inicio DATETIME,
                                          fecha_fin DATETIME,
                                          duracion BIGINT CHECK(duracion BETWEEN 1 AND 10),
                                          precio_mensual DECIMAL(38, 2),
                                          FOREIGN KEY(sede_id) REFERENCES LOS_DESNORMALIZADOS.sede(id),
                                          FOREIGN KEY(profesor_id) REFERENCES LOS_DESNORMALIZADOS.profesor(id),
                                          FOREIGN KEY(categoria_id) REFERENCES LOS_DESNORMALIZADOS.categoria(id)

);

CREATE TABLE LOS_DESNORMALIZADOS.dia(
                                        id SMALLINT PRIMARY KEY IDENTITY(1,1),
                                        nombre VARCHAR(255) CHECK(nombre IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes'))
);

CREATE TABLE LOS_DESNORMALIZADOS.turno(
                                          id SMALLINT  PRIMARY KEY IDENTITY(1,1),
                                          nombre VARCHAR(255) CHECK(nombre IN ('Mañana', 'Tarde', 'Noche'))
);

CREATE TABLE LOS_DESNORMALIZADOS.horario_curso(
                                                  id BIGINT PRIMARY KEY IDENTITY(1,1),
                                                  curso_id BIGINT,
                                                  turno_id SMALLINT,
                                                  FOREIGN KEY(curso_id) REFERENCES LOS_DESNORMALIZADOS.curso(codigo_curso),
                                                  FOREIGN KEY(turno_id) REFERENCES LOS_DESNORMALIZADOS.turno(id)
);

CREATE TABLE LOS_DESNORMALIZADOS.horario_curso_dia(
                                                      id BIGINT PRIMARY KEY IDENTITY(1,1),
                                                      horario_curso_id BIGINT,
                                                      dia_id SMALLINT,
                                                      FOREIGN KEY(dia_id) REFERENCES LOS_DESNORMALIZADOS.dia(id),
                                                      FOREIGN KEY(horario_curso_id) REFERENCES LOS_DESNORMALIZADOS.horario_curso(id)
);

CREATE TABLE LOS_DESNORMALIZADOS.final (
                                           id BIGINT PRIMARY KEY IDENTITY(1,1),
                                           fecha DATETIME,
                                           hora VARCHAR(255),
                                           curso_id BIGINT NOT NULL,
                                           descripcion VARCHAR(255),
                                           FOREIGN KEY (curso_id) REFERENCES LOS_DESNORMALIZADOS.curso(codigo_curso)
);

CREATE TABLE LOS_DESNORMALIZADOS.final_inscripto (
                                                     nro_inscripcion BIGINT PRIMARY KEY IDENTITY(1,1),
                                                     alumno_id BIGINT NOT NULL,
                                                     profesor_id BIGINT NOT NULL,
                                                     presente BIT,
                                                     nota BIGINT CHECK (nota BETWEEN 0 AND 10),
                                                     final_id BIGINT NOT NULL,
                                                     fecha_inscripcion DATETIME DEFAULT GETDATE(),
                                                     FOREIGN KEY (alumno_id) REFERENCES LOS_DESNORMALIZADOS.alumno(legajo),
                                                     FOREIGN KEY (profesor_id) REFERENCES LOS_DESNORMALIZADOS.profesor(id),
                                                     FOREIGN KEY (final_id) REFERENCES LOS_DESNORMALIZADOS.final(id)
);

CREATE TABLE LOS_DESNORMALIZADOS.factura (
                                             nro_factura BIGINT PRIMARY KEY,
                                             fecha_emision DATETIME DEFAULT GETDATE(),
                                             fecha_vencimiento DATETIME NOT NULL,
                                             alumno_id BIGINT,
                                             importe_total DECIMAL(18, 2),
                                             FOREIGN KEY (alumno_id) REFERENCES LOS_DESNORMALIZADOS.alumno(legajo),
                                             CONSTRAINT CHK_factura_fechas CHECK (fecha_vencimiento >= fecha_emision)
);


CREATE TABLE LOS_DESNORMALIZADOS.detalle_factura (
                                                     id BIGINT PRIMARY KEY IDENTITY(1,1),
                                                     curso_id BIGINT, -- En la tabla figura como INTEGER(11)
                                                     importe DECIMAL(18,2),
                                                     mes BIGINT CHECK (mes BETWEEN 1 AND 12),
                                                     anio BIGINT,
                                                     factura_id BIGINT,
                                                     FOREIGN KEY (curso_id) REFERENCES LOS_DESNORMALIZADOS.curso(codigo_curso),
                                                     FOREIGN KEY (factura_id) REFERENCES LOS_DESNORMALIZADOS.factura(nro_factura)
);

CREATE TABLE LOS_DESNORMALIZADOS.medio_de_pago (
                                                   id BIGINT PRIMARY KEY IDENTITY(1,1),
                                                   nombre VARCHAR(255) CHECK(nombre IN ('Efectivo',
                                                                                        'Tarjeta Crédito',
                                                                                        'Transferencia',
                                                                                        'Tarjeta Débito'))
);

CREATE TABLE LOS_DESNORMALIZADOS.pago (
                                          id BIGINT PRIMARY KEY IDENTITY(1,1),
                                          factura_id BIGINT,
                                          fecha DATETIME DEFAULT GETDATE(),
                                          importe DECIMAL(18 ,2),
                                          medio_pago_id BIGINT,
                                          FOREIGN KEY (factura_id) REFERENCES LOS_DESNORMALIZADOS.factura(nro_factura),
                                          FOREIGN KEY (medio_pago_id) REFERENCES LOS_DESNORMALIZADOS.medio_de_pago(id)
);

CREATE TABLE LOS_DESNORMALIZADOS.encuesta (
                                              id BIGINT IDENTITY PRIMARY KEY,
                                              curso_id BIGINT NOT NULL,
                                              FOREIGN KEY (curso_id) REFERENCES LOS_DESNORMALIZADOS.curso(codigo_curso)
);

CREATE TABLE LOS_DESNORMALIZADOS.pregunta_encuesta (
                                                       id BIGINT IDENTITY PRIMARY KEY,
                                                       encuesta_id BIGINT NOT NULL,
                                                       pregunta VARCHAR(255),
                                                       FOREIGN KEY (encuesta_id) REFERENCES LOS_DESNORMALIZADOS.encuesta(id)
);

CREATE TABLE LOS_DESNORMALIZADOS.encuesta_anonima (
                                                      id BIGINT IDENTITY PRIMARY KEY,
                                                      encuesta_id BIGINT NOT NULL,
                                                      fecha_registro DATETIME DEFAULT GETDATE(),
                                                      observaciones VARCHAR(255) NULL,
                                                      FOREIGN KEY (encuesta_id) REFERENCES LOS_DESNORMALIZADOS.encuesta(id)
);

CREATE TABLE LOS_DESNORMALIZADOS.encuesta_alumno (
                                                     alumno_id BIGINT NOT NULL,
                                                     encuesta_id BIGINT NOT NULL,
                                                     PRIMARY KEY (alumno_id, encuesta_id)
);

CREATE TABLE LOS_DESNORMALIZADOS.respuesta_encuesta (
                                                        encuesta_anonima_id BIGINT NOT NULL,
                                                        pregunta_id BIGINT NOT NULL,
                                                        respuesta INT,
                                                        PRIMARY KEY (encuesta_anonima_id, pregunta_id),
                                                        FOREIGN KEY (encuesta_anonima_id) REFERENCES LOS_DESNORMALIZADOS.encuesta_anonima(id),
                                                        FOREIGN KEY (pregunta_id) REFERENCES LOS_DESNORMALIZADOS.pregunta_encuesta(id)
);

CREATE TABLE LOS_DESNORMALIZADOS.estado_inscripcion(
                                                       id SMALLINT PRIMARY KEY IDENTITY(1,1),
                                                       nombre VARCHAR(255) CHECK(nombre IN ('Confirmada', 'Rechazada'))
);

CREATE TABLE LOS_DESNORMALIZADOS.inscripcion_curso(
                                                      nro_inscripcion BIGINT PRIMARY KEY IDENTITY(1,1),
                                                      fecha_inscripcion DATETIME DEFAULT GETDATE(),
                                                      alumno_id BIGINT,
                                                      curso_id BIGINT,
                                                      estado_id SMALLINT,
                                                      fecha_respuesta DATETIME DEFAULT GETDATE(),
                                                      FOREIGN KEY(alumno_id) REFERENCES LOS_DESNORMALIZADOS.alumno(legajo),
                                                      FOREIGN KEY(curso_id) REFERENCES LOS_DESNORMALIZADOS.curso(codigo_curso),
                                                      FOREIGN KEY(estado_id) REFERENCES LOS_DESNORMALIZADOS.estado_inscripcion(id)
);

CREATE TABLE LOS_DESNORMALIZADOS.modulo(
                                           id BIGINT PRIMARY KEY IDENTITY(1,1),
                                           nombre VARCHAR(255),
                                           descripcion VARCHAR(255),
                                           curso_id BIGINT,
                                           FOREIGN KEY(curso_id) REFERENCES LOS_DESNORMALIZADOS.curso(codigo_curso)
);

CREATE TABLE LOS_DESNORMALIZADOS.evaluacion(
                                               id BIGINT PRIMARY KEY IDENTITY(1,1),
                                               fecha_evaluacion DATETIME DEFAULT GETDATE(),
                                               modulo_id BIGINT,
                                               FOREIGN KEY(modulo_id) REFERENCES LOS_DESNORMALIZADOS.modulo(id)
);

CREATE TABLE LOS_DESNORMALIZADOS.alumno_evaluado(
                                                    legajo_alumno BIGINT,
                                                    nota BIGINT CHECK (nota BETWEEN 0 AND 10),
                                                    presente BIT NOT NULL,
                                                    instancia BIGINT,
                                                    evaluacion_id BIGINT,
                                                    PRIMARY KEY(legajo_alumno, evaluacion_id),
                                                    FOREIGN KEY(legajo_alumno) REFERENCES LOS_DESNORMALIZADOS.alumno(legajo),
                                                    FOREIGN KEY(evaluacion_id) REFERENCES LOS_DESNORMALIZADOS.evaluacion(id)
);

CREATE TABLE LOS_DESNORMALIZADOS.trabajo_practico(
                                                     id BIGINT PRIMARY KEY IDENTITY(1,1),
                                                     curso_id BIGINT,
                                                     alumno_id BIGINT,
                                                     fecha_evaluacion DATETIME DEFAULT GETDATE(),
                                                     nota BIGINT CHECK (nota BETWEEN 0 AND 10),
                                                     FOREIGN KEY(curso_id)  REFERENCES LOS_DESNORMALIZADOS.curso(codigo_curso),
                                                     FOREIGN KEY(alumno_id) REFERENCES LOS_DESNORMALIZADOS.alumno(legajo)
);
------------------------------------------------------
-- FIN DE CREACION DE TABLAS
------------------------------------------------------

------------------------------------------------------
-- ÍNDICES ÚNICOS (para evitar duplicados)
------------------------------------------------------
CREATE UNIQUE INDEX idx_alumno_legajo
    ON LOS_DESNORMALIZADOS.alumno (legajo);

CREATE UNIQUE INDEX idx_profesor_dni
    ON LOS_DESNORMALIZADOS.profesor (dni);

------------------------------------------------------
-- ÍNDICES DE CLAVES FORÁNEAS
------------------------------------------------------
-- curso
CREATE INDEX idx_curso_profesor
    ON LOS_DESNORMALIZADOS.curso (profesor_id);

CREATE INDEX idx_curso_categoria
    ON LOS_DESNORMALIZADOS.curso (categoria_id);

CREATE INDEX idx_curso_sede
    ON LOS_DESNORMALIZADOS.curso (sede_id);

-- horario_curso
CREATE INDEX idx_horario_curso_curso
    ON LOS_DESNORMALIZADOS.horario_curso (curso_id);

CREATE INDEX idx_horario_curso_turno
    ON LOS_DESNORMALIZADOS.horario_curso (turno_id);

-- inscripcion_curso
CREATE INDEX idx_inscripcion_curso_alumno
    ON LOS_DESNORMALIZADOS.inscripcion_curso (alumno_id);

CREATE INDEX idx_inscripcion_curso_curso
    ON LOS_DESNORMALIZADOS.inscripcion_curso (curso_id);

CREATE INDEX idx_inscripcion_curso_estado
    ON LOS_DESNORMALIZADOS.inscripcion_curso (estado_id);

-- trabajo_practico
CREATE INDEX idx_trabajo_practico
    ON LOS_DESNORMALIZADOS.trabajo_practico (id);

CREATE INDEX idx_pago_unicidad
    ON LOS_DESNORMALIZADOS.pago (factura_id, medio_pago_id, fecha, importe);


-- final_inscripto
CREATE INDEX idx_final_inscripto_alumno
    ON LOS_DESNORMALIZADOS.final_inscripto (alumno_id);

CREATE INDEX idx_final_inscripto_final
    ON LOS_DESNORMALIZADOS.final_inscripto (final_id);

-- detalle_factura
CREATE INDEX idx_detalle_factura_curso
    ON LOS_DESNORMALIZADOS.detalle_factura (curso_id);

-- factura
CREATE INDEX idx_factura_alumno
    ON LOS_DESNORMALIZADOS.factura (alumno_id);

------------------------------------------------------
-- ÍNDICES DE APOYO (búsquedas y filtros frecuentes)
------------------------------------------------------
-- facturas por fecha
CREATE INDEX idx_factura_fecha_emision
    ON LOS_DESNORMALIZADOS.factura (fecha_emision);

-- detalle_factura por año/mes
CREATE INDEX idx_detalle_factura_anio_mes
    ON LOS_DESNORMALIZADOS.detalle_factura (anio, mes);

-- pago
CREATE INDEX idx_pago_factura
    ON LOS_DESNORMALIZADOS.pago (factura_id);

-- encuesta_alumno
CREATE INDEX idx_encuesta_alumno_alumno
    ON LOS_DESNORMALIZADOS.encuesta_alumno (alumno_id);

CREATE INDEX idx_encuesta_alumno_encuesta
    ON LOS_DESNORMALIZADOS.encuesta_alumno (encuesta_id);

CREATE INDEX idx_detalle_unicidad
    ON LOS_DESNORMALIZADOS.detalle_factura (factura_id, curso_id, anio, mes, importe);

------------------------------------------------------
-- FIN DE ÍNDICES
------------------------------------------------------

------------------------------------------------------
-- CREACIÓN DE TRIGGERS
------------------------------------------------------
GO
CREATE TRIGGER LOS_DESNORMALIZADOS.trg_actualizar_importe_factura
    ON LOS_DESNORMALIZADOS.detalle_factura
    AFTER INSERT, UPDATE, DELETE
    AS
BEGIN
    DECLARE @facturas_afectadas TABLE (factura_id BIGINT);

INSERT INTO @facturas_afectadas (factura_id)
SELECT DISTINCT factura_id FROM inserted WHERE factura_id IS NOT NULL
UNION
SELECT DISTINCT factura_id FROM deleted WHERE factura_id IS NOT NULL;

UPDATE f
SET f.importe_total = (
    SELECT SUM(df.importe)
    FROM LOS_DESNORMALIZADOS.detalle_factura df
    WHERE df.factura_id = f.nro_factura
)
    FROM LOS_DESNORMALIZADOS.factura f
    INNER JOIN @facturas_afectadas fa ON f.nro_factura = fa.factura_id;
END;
GO

------------------------------------------------------
-- TRIGGER PARA VALIDAR INSCRIPCIÓN A CURSO ÚNICA
------------------------------------------------------
CREATE TRIGGER trg_validar_inscripcion_unica
    ON LOS_DESNORMALIZADOS.inscripcion_curso
    AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted ins
        JOIN LOS_DESNORMALIZADOS.inscripcion_curso i
            ON i.alumno_id = ins.alumno_id AND i.curso_id = ins.curso_id
        WHERE i.nro_inscripcion <> ins.nro_inscripcion
    )
BEGIN
        RAISERROR('El alumno ya está inscripto en este curso.', 16, 1);
ROLLBACK TRANSACTION;
END;
END;
GO

------------------------------------------------------
-- TRIGGER PARA VALIDAR INSCRIPCIÓN A FINAL ÚNICA
------------------------------------------------------

CREATE TRIGGER trg_validar_final_unico
    ON LOS_DESNORMALIZADOS.final_inscripto
    AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted ins
        JOIN LOS_DESNORMALIZADOS.final_inscripto fi
            ON fi.alumno_id = ins.alumno_id AND fi.final_id = ins.final_id
        WHERE fi.nro_inscripcion <> ins.nro_inscripcion
    )
BEGIN
        RAISERROR('El alumno ya está inscripto en este final.', 16, 1);
ROLLBACK TRANSACTION;
END;
END;
GO

------------------------------------------------------
-- STORED PROCEDURES DE MIGRACIÓN DE DATOS
------------------------------------------------------

------------------------------------------------------
-- 1) Migrar instituciones
------------------------------------------------------
CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_instituciones
    AS
BEGIN
    SET NOCOUNT ON;
INSERT INTO LOS_DESNORMALIZADOS.institucion (nombre, razon_social, cuit)
SELECT DISTINCT
    TRIM(m.Institucion_Nombre) as nombre,
    TRIM(m.Institucion_RazonSocial) as razon_social,
    TRIM(m.Institucion_Cuit) as cuit
FROM gd_esquema.Maestra m
WHERE m.Institucion_Nombre IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM LOS_DESNORMALIZADOS.institucion i
    WHERE i.nombre = TRIM(m.Institucion_Nombre)
);
END;
GO


------------------------------------------------------
-- 2) Migrar sedes
------------------------------------------------------
CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_sedes
    AS
BEGIN
    SET NOCOUNT ON;
INSERT INTO LOS_DESNORMALIZADOS.sede (provincia, localidad, nombre, direccion, telefono, mail)
SELECT DISTINCT
    TRIM(Sede_Provincia),
    TRIM(Sede_Localidad),
    TRIM(Sede_Nombre),
    TRIM(Sede_Direccion),
    TRIM(Sede_Telefono),
    TRIM(Sede_Mail)
FROM gd_esquema.Maestra m
WHERE Sede_Nombre IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM LOS_DESNORMALIZADOS.sede s
    WHERE s.nombre = TRIM(m.Sede_Nombre)
      AND ISNULL(s.provincia,'') = ISNULL(TRIM(m.Sede_Provincia),'')
      AND ISNULL(s.localidad,'') = ISNULL(TRIM(m.Sede_Localidad),'')
);
END;
GO

------------------------------------------------------
-- 3) Migrar profesores
------------------------------------------------------
CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_profesores
    AS
BEGIN
    SET NOCOUNT ON;
INSERT INTO LOS_DESNORMALIZADOS.profesor (nombre, apellido, dni, direccion, correo, telefono, provincia, localidad, fecha_nacimiento)
SELECT DISTINCT
    TRIM(Profesor_nombre),
    TRIM(Profesor_Apellido),
    TRIM(Profesor_Dni),
    TRIM(Profesor_Direccion),
    TRIM(Profesor_Mail),
    TRIM(Profesor_Telefono),
    TRIM(Profesor_Provincia),
    TRIM(Profesor_Localidad),
    Profesor_FechaNacimiento
FROM gd_esquema.Maestra m
WHERE Profesor_Dni IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM LOS_DESNORMALIZADOS.profesor p
    WHERE p.dni = TRIM(m.Profesor_Dni)
);
END;
GO

------------------------------------------------------
-- 4) Migrar alumnos
------------------------------------------------------
CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_alumnos
    AS
BEGIN
    SET NOCOUNT ON;
INSERT INTO LOS_DESNORMALIZADOS.alumno (legajo, nombre, apellido, dni, direccion, telefono, mail, provincia, localidad, fecha_nacimiento)
SELECT DISTINCT
    Alumno_Legajo,
    TRIM(Alumno_Nombre),
    TRIM(Alumno_Apellido),
    Alumno_Dni,
    TRIM(Alumno_Direccion),
    TRIM(Alumno_Telefono),
    TRIM(Alumno_Mail),
    TRIM(Alumno_Provincia),
    TRIM(Alumno_Localidad),
    Alumno_FechaNacimiento
FROM gd_esquema.Maestra m
WHERE Alumno_Legajo IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM LOS_DESNORMALIZADOS.alumno a
    WHERE a.legajo = m.Alumno_Legajo
);
END;
GO

------------------------------------------------------
-- 5) Migrar categorías
------------------------------------------------------
CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_categorias
    AS
BEGIN
    SET NOCOUNT ON;
INSERT INTO LOS_DESNORMALIZADOS.categoria (nombre)
SELECT DISTINCT TRIM(Curso_Categoria)
FROM gd_esquema.Maestra m
WHERE Curso_Categoria IS NOT NULL
  AND TRIM(Curso_Categoria) <> ''
  AND NOT EXISTS (
    SELECT 1 FROM LOS_DESNORMALIZADOS.categoria c
    WHERE c.nombre = TRIM(m.Curso_Categoria)
);
END;
GO

------------------------------------------------------
-- 6) Migrar turnos
------------------------------------------------------

CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_turnos
    AS
BEGIN
	SET NOCOUNT ON;
INSERT INTO LOS_DESNORMALIZADOS.turno (nombre)
SELECT DISTINCT
    TRIM(m.Curso_Turno)
FROM
    gd_esquema.Maestra m
WHERE
    m.Curso_Turno IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM LOS_DESNORMALIZADOS.turno t
    WHERE t.nombre = TRIM(m.Curso_Turno)
);
END;
GO

------------------------------------------------------
-- 7) Migrar dias
------------------------------------------------------

CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_dias
    AS
BEGIN
	SET NOCOUNT ON;
INSERT INTO LOS_DESNORMALIZADOS.dia (nombre)
SELECT DISTINCT
    TRIM(m.Curso_Dia)
FROM
    gd_esquema.Maestra m
WHERE
    m.Curso_Dia IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM LOS_DESNORMALIZADOS.dia d
    WHERE d.nombre = TRIM(m.Curso_Dia)
);
END;
GO

------------------------------------------------------
-- 8) Migrar cursos
------------------------------------------------------
CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_cursos
    AS
BEGIN
	SET NOCOUNT ON;

INSERT INTO LOS_DESNORMALIZADOS.curso (
    codigo_curso,
    sede_id,
    profesor_id,
    nombre,
    descripcion,
    categoria_id,
    fecha_inicio,
    fecha_fin,
    duracion,
    precio_mensual
)
SELECT DISTINCT
    m.Curso_Codigo,
    s.id,
    p.id,
    TRIM(m.Curso_Nombre),
    TRIM(m.Curso_Descripcion),
    cat.id,
    m.Curso_FechaInicio,
    m.Curso_FechaFin,
    m.Curso_DuracionMeses,
    m.Curso_PrecioMensual
FROM
    gd_esquema.Maestra m
        -- Unimos con las tablas ya migradas para obtener los IDs
        JOIN
    LOS_DESNORMALIZADOS.sede s ON s.nombre = TRIM(m.Sede_Nombre)
        AND ISNULL(s.provincia, '') = ISNULL(TRIM(m.Sede_Provincia), '')
        AND ISNULL(s.localidad, '') = ISNULL(TRIM(m.Sede_Localidad), '')
        JOIN
    LOS_DESNORMALIZADOS.profesor p ON p.dni = TRIM(m.Profesor_Dni)
        LEFT JOIN -- Usamos LEFT JOIN por si alguna categoría es NULL
        LOS_DESNORMALIZADOS.categoria cat ON cat.nombre = TRIM(m.Curso_Categoria)
WHERE
    m.Curso_Codigo IS NOT NULL -- Nos aseguramos de que el curso tenga un código
  AND NOT EXISTS ( -- Condición para no insertar duplicados
    SELECT 1
    FROM LOS_DESNORMALIZADOS.curso c
    WHERE c.nombre = TRIM(m.Curso_Nombre)
      AND c.profesor_id = p.id
      AND c.sede_id = s.id
      AND c.fecha_inicio = m.Curso_FechaInicio
);
END;
GO


------------------------------------------------------
-- 9) Migrar modulos
------------------------------------------------------

CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_modulos
    AS
BEGIN
    SET NOCOUNT ON;

INSERT INTO LOS_DESNORMALIZADOS.modulo (
    nombre,
    descripcion,
    curso_id
)
SELECT DISTINCT
    TRIM(m.Modulo_Nombre),
    TRIM(m.Modulo_Descripcion),
    c.codigo_curso
FROM
    gd_esquema.Maestra m
        JOIN LOS_DESNORMALIZADOS.curso c
             ON c.codigo_curso = m.Curso_Codigo
WHERE
    m.Modulo_Nombre IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM LOS_DESNORMALIZADOS.modulo mo
    WHERE mo.curso_id = c.codigo_curso
      AND mo.nombre = TRIM(m.Modulo_Nombre)
);
END;
GO

------------------------------------------------------
-- 10) Migrar Horarios_curso y horarios_curso_dia
------------------------------------------------------

CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_horarios
    AS
BEGIN
	SET NOCOUNT ON;

	-- Paso 1: Migrar la relación Curso-Turno a la tabla horario_curso
INSERT INTO LOS_DESNORMALIZADOS.horario_curso (curso_id, turno_id)
SELECT DISTINCT
    c.codigo_curso,
    t.id
FROM
    gd_esquema.Maestra m
        -- Identificamos el curso
        JOIN LOS_DESNORMALIZADOS.sede s ON s.nombre = TRIM(m.Sede_Nombre) AND ISNULL(s.provincia, '') = ISNULL(TRIM(m.Sede_Provincia), '') AND ISNULL(s.localidad, '') = ISNULL(TRIM(m.Sede_Localidad), '')
        JOIN LOS_DESNORMALIZADOS.profesor p ON p.dni = TRIM(m.Profesor_Dni)
        JOIN LOS_DESNORMALIZADOS.curso c ON c.sede_id = s.id AND c.profesor_id = p.id AND c.nombre = TRIM(m.Curso_Nombre) AND c.fecha_inicio = m.Curso_FechaInicio
        -- Identificamos el turno
        JOIN LOS_DESNORMALIZADOS.turno t ON t.nombre = TRIM(m.Curso_Turno)
WHERE
    m.Curso_Turno IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM LOS_DESNORMALIZADOS.horario_curso hc
    WHERE hc.curso_id = c.codigo_curso AND hc.turno_id = t.id
);

-- Paso 2: Migrar la relación Horario-Día a la tabla horario_curso_dia
INSERT INTO LOS_DESNORMALIZADOS.horario_curso_dia (horario_curso_id, dia_id)
SELECT DISTINCT
    hc.id,
    d.id
FROM
    gd_esquema.Maestra m
        -- Volvemos a identificar el curso para llegar al horario
        JOIN LOS_DESNORMALIZADOS.sede s ON s.nombre = TRIM(m.Sede_Nombre) AND ISNULL(s.provincia, '') = ISNULL(TRIM(m.Sede_Provincia), '') AND ISNULL(s.localidad, '') = ISNULL(TRIM(m.Sede_Localidad), '')
        JOIN LOS_DESNORMALIZADOS.profesor p ON p.dni = TRIM(m.Profesor_Dni)
        JOIN LOS_DESNORMALIZADOS.curso c ON c.sede_id = s.id AND c.profesor_id = p.id AND c.nombre = TRIM(m.Curso_Nombre) AND c.fecha_inicio = m.Curso_FechaInicio
        -- Identificamos el turno
        JOIN LOS_DESNORMALIZADOS.turno t ON t.nombre = TRIM(m.Curso_Turno)
        -- Identificamos el día
        JOIN LOS_DESNORMALIZADOS.dia d ON d.nombre = REPLACE(TRIM(m.Curso_Dia), 'Miercoles', 'Miércoles')
        -- Usamos los datos anteriores para encontrar el ID del horario que acabamos de crear
        JOIN LOS_DESNORMALIZADOS.horario_curso hc ON hc.curso_id = c.codigo_curso AND hc.turno_id = t.id
WHERE
    m.Curso_Dia IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM LOS_DESNORMALIZADOS.horario_curso_dia hcd
    WHERE hcd.horario_curso_id = hc.id AND hcd.dia_id = d.id
);
END;
GO

------------------------------------------------------
-- 11) Migrar Estados_Inscripcion
------------------------------------------------------

CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_estados_inscripcion
    AS
BEGIN
	SET NOCOUNT ON;

INSERT INTO LOS_DESNORMALIZADOS.estado_inscripcion (nombre)
SELECT DISTINCT
    TRIM(m.Inscripcion_Estado)
FROM
    gd_esquema.Maestra m
WHERE
    m.Inscripcion_Estado IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM LOS_DESNORMALIZADOS.estado_inscripcion ei
    WHERE ei.nombre = TRIM(m.Inscripcion_Estado)
);
END;
GO

------------------------------------------------------
-- 12) Migrar Inscripciones_curso
------------------------------------------------------

CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_inscripciones_curso
    AS
BEGIN
	SET NOCOUNT ON;

INSERT INTO LOS_DESNORMALIZADOS.inscripcion_curso (
    fecha_inscripcion,
    alumno_id,
    curso_id,
    estado_id,
    fecha_respuesta
)
SELECT DISTINCT
    m.Inscripcion_Fecha,
    a.legajo,
    c.codigo_curso,
    ei.id,
    m.Inscripcion_FechaRespuesta
FROM
    gd_esquema.Maestra m
        -- Identificamos al alumno por su legajo
        JOIN
    LOS_DESNORMALIZADOS.alumno a ON a.legajo = m.Alumno_Legajo
        -- Identificamos el estado de la inscripción
        JOIN
    LOS_DESNORMALIZADOS.estado_inscripcion ei ON ei.nombre = TRIM(m.Inscripcion_Estado)
        -- Identificamos el curso (usando la misma lógica de siempre)
        JOIN
    LOS_DESNORMALIZADOS.sede s ON s.nombre = TRIM(m.Sede_Nombre)
        AND ISNULL(s.provincia, '') = ISNULL(TRIM(m.Sede_Provincia), '')
        AND ISNULL(s.localidad, '') = ISNULL(TRIM(m.Sede_Localidad), '')
        JOIN
    LOS_DESNORMALIZADOS.profesor p ON p.dni = TRIM(m.Profesor_Dni)
        JOIN
    LOS_DESNORMALIZADOS.curso c ON c.sede_id = s.id
        AND c.profesor_id = p.id
        AND c.nombre = TRIM(m.Curso_Nombre)
        AND c.fecha_inicio = m.Curso_FechaInicio
WHERE
    m.Inscripcion_Numero IS NOT NULL -- Aseguramos que sea una fila con datos de inscripción
  AND NOT EXISTS ( -- Condición para no insertar duplicados
    SELECT 1
    FROM LOS_DESNORMALIZADOS.inscripcion_curso ic
    WHERE ic.alumno_id = a.legajo AND ic.curso_id = c.codigo_curso
);
END;
GO

------------------------------------------------------
-- 13) Migrar Trabajos_Practicos
------------------------------------------------------

CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_trabajos_practicos
    AS
BEGIN
	SET NOCOUNT ON;

INSERT INTO LOS_DESNORMALIZADOS.trabajo_practico (
    curso_id,
    alumno_id,
    fecha_evaluacion,
    nota
)
SELECT DISTINCT
    c.codigo_curso,
    a.legajo,
    m.Trabajo_Practico_FechaEvaluacion,
    m.Trabajo_Practico_Nota
FROM
    gd_esquema.Maestra m
        -- Identificamos al alumno
        JOIN
    LOS_DESNORMALIZADOS.alumno a ON a.legajo = m.Alumno_Legajo
        -- Identificamos el curso (con la lógica que ya dominamos)
        JOIN
    LOS_DESNORMALIZADOS.sede s ON s.nombre = TRIM(m.Sede_Nombre)
        AND ISNULL(s.provincia, '') = ISNULL(TRIM(m.Sede_Provincia), '')
        AND ISNULL(s.localidad, '') = ISNULL(TRIM(m.Sede_Localidad), '')
        JOIN
    LOS_DESNORMALIZADOS.profesor p ON p.dni = TRIM(m.Profesor_Dni)
        JOIN
    LOS_DESNORMALIZADOS.curso c ON c.sede_id = s.id
        AND c.profesor_id = p.id
        AND c.nombre = TRIM(m.Curso_Nombre)
        AND c.fecha_inicio = m.Curso_FechaInicio
WHERE
    m.Trabajo_Practico_Nota IS NOT NULL -- Solo filas que tengan datos de un TP
  AND m.Trabajo_Practico_FechaEvaluacion IS NOT NULL
  AND NOT EXISTS ( -- Evitamos duplicados
    SELECT 1
    FROM LOS_DESNORMALIZADOS.trabajo_practico tp
    WHERE tp.alumno_id = a.legajo
      AND tp.curso_id = c.codigo_curso
      AND tp.fecha_evaluacion = m.Trabajo_Practico_FechaEvaluacion
);
END;
GO

------------------------------------------------------
-- 14) Migrar Evaluaciones_Modulo
------------------------------------------------------

CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_evaluaciones_modulos
    AS
BEGIN
	SET NOCOUNT ON;

	-- Paso A: Migrar las evaluaciones (el "evento" de examen para un módulo)
INSERT INTO LOS_DESNORMALIZADOS.evaluacion (fecha_evaluacion, modulo_id)
SELECT DISTINCT
    m.Evaluacion_Curso_fechaEvaluacion,
    mo.id
FROM
    gd_esquema.Maestra m
        -- Identificamos el curso para poder llegar al módulo
        JOIN LOS_DESNORMALIZADOS.sede s ON s.nombre = TRIM(m.Sede_Nombre) AND ISNULL(s.provincia, '') = ISNULL(TRIM(m.Sede_Provincia), '') AND ISNULL(s.localidad, '') = ISNULL(TRIM(m.Sede_Localidad), '')
        JOIN LOS_DESNORMALIZADOS.profesor p ON p.dni = TRIM(m.Profesor_Dni)
        JOIN LOS_DESNORMALIZADOS.curso c ON c.sede_id = s.id AND c.profesor_id = p.id AND c.nombre = TRIM(m.Curso_Nombre) AND c.fecha_inicio = m.Curso_FechaInicio
        -- Identificamos el módulo
        JOIN
    LOS_DESNORMALIZADOS.modulo mo ON mo.curso_id = c.codigo_curso AND mo.nombre = TRIM(m.Modulo_Nombre)
WHERE
    m.Evaluacion_Curso_fechaEvaluacion IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM LOS_DESNORMALIZADOS.evaluacion e
    WHERE e.modulo_id = mo.id AND e.fecha_evaluacion = m.Evaluacion_Curso_fechaEvaluacion
);

-- Paso B: Migrar los resultados de los alumnos en esas evaluaciones
INSERT INTO LOS_DESNORMALIZADOS.alumno_evaluado (legajo_alumno, nota, presente, instancia, evaluacion_id)
SELECT DISTINCT
    a.legajo,
    m.Evaluacion_Curso_Nota,
    m.Evaluacion_Curso_Presente,
    m.Evaluacion_Curso_Instancia,
    e.id -- El ID de la evaluación que creamos en el paso A
FROM
    gd_esquema.Maestra m
        -- Identificamos al alumno
        JOIN LOS_DESNORMALIZADOS.alumno a ON a.legajo = m.Alumno_Legajo
        -- Identificamos nuevamente el curso y el módulo para poder encontrar la evaluación
        JOIN LOS_DESNORMALIZADOS.sede s ON s.nombre = TRIM(m.Sede_Nombre) AND ISNULL(s.provincia, '') = ISNULL(TRIM(m.Sede_Provincia), '') AND ISNULL(s.localidad, '') = ISNULL(TRIM(m.Sede_Localidad), '')
        JOIN LOS_DESNORMALIZADOS.profesor p ON p.dni = TRIM(m.Profesor_Dni)
        JOIN LOS_DESNORMALIZADOS.curso c ON c.sede_id = s.id AND c.profesor_id = p.id AND c.nombre = TRIM(m.Curso_Nombre) AND c.fecha_inicio = m.Curso_FechaInicio
        JOIN LOS_DESNORMALIZADOS.modulo mo ON mo.curso_id = c.codigo_curso AND mo.nombre = TRIM(m.Modulo_Nombre)
        -- Este es el JOIN clave: vinculamos todo con la evaluación ya creada
        JOIN
    LOS_DESNORMALIZADOS.evaluacion e ON e.modulo_id = mo.id AND e.fecha_evaluacion = m.Evaluacion_Curso_fechaEvaluacion
WHERE
    m.Evaluacion_Curso_Nota IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM LOS_DESNORMALIZADOS.alumno_evaluado ae
    WHERE ae.legajo_alumno = a.legajo AND ae.evaluacion_id = e.id
);
END;
GO

------------------------------------------------------
-- 14) Migrar Finales
------------------------------------------------------

CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_finales
    AS
BEGIN
	SET NOCOUNT ON;

	-- Paso A: Crear los registros de los exámenes finales (Esta parte ya funciona bien)
INSERT INTO LOS_DESNORMALIZADOS.final (fecha, hora, curso_id, descripcion)
SELECT DISTINCT m.Examen_Final_Fecha, m.Examen_Final_Hora, c.codigo_curso, m.Examen_Final_Descripcion
FROM gd_esquema.Maestra m
         JOIN LOS_DESNORMALIZADOS.sede s ON s.nombre = TRIM(m.Sede_Nombre) AND ISNULL(s.provincia, '') = ISNULL(TRIM(m.Sede_Provincia), '') AND ISNULL(s.localidad, '') = ISNULL(TRIM(m.Sede_Localidad), '')
         JOIN LOS_DESNORMALIZADOS.profesor p ON p.dni = TRIM(m.Profesor_Dni)
         JOIN LOS_DESNORMALIZADOS.curso c ON c.sede_id = s.id AND c.profesor_id = p.id AND c.nombre = TRIM(m.Curso_Nombre) AND CAST(c.fecha_inicio AS DATE) = CAST(m.Curso_FechaInicio AS DATE) -- Corrección aplicada aquí también
WHERE m.Examen_Final_Fecha IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM LOS_DESNORMALIZADOS.final f WHERE f.curso_id = c.codigo_curso AND CAST(f.fecha AS DATE) = CAST(m.Examen_Final_Fecha AS DATE));

-- Paso B: Inscribir a los alumnos en los finales y cargar sus notas
INSERT INTO LOS_DESNORMALIZADOS.final_inscripto
(alumno_id, profesor_id, presente, nota, final_id, fecha_inscripcion)
SELECT DISTINCT
    a.legajo                                   AS alumno_id,
    p.id                                       AS profesor_id,
    CASE
        WHEN UPPER(LTRIM(RTRIM(COALESCE(m_inscripcion.Evaluacion_Final_Presente, ''))))
            IN ('S','SI','Y','1','TRUE') THEN 1
        ELSE 0
        END                                        AS presente,
    TRY_CAST(m_inscripcion.Evaluacion_Final_Nota AS DECIMAL(5,2)) AS nota,
    f.id                                       AS final_id,
    m_inscripcion.Inscripcion_Final_Fecha      AS fecha_inscripcion
FROM gd_esquema.Maestra AS m_inscripcion
         JOIN gd_esquema.Maestra AS m_fecha_final
              ON TRIM(m_inscripcion.Sede_Nombre)       = TRIM(m_fecha_final.Sede_Nombre)
                  AND TRIM(m_inscripcion.Profesor_Dni)      = TRIM(m_fecha_final.Profesor_Dni)
                  AND TRIM(m_inscripcion.Curso_Nombre)      = TRIM(m_fecha_final.Curso_Nombre)
                  AND CAST(m_inscripcion.Curso_FechaInicio AS DATE) = CAST(m_fecha_final.Curso_FechaInicio AS DATE)
                  -- 💡 Clave para que sea el MISMO final:
                  AND m_inscripcion.Inscripcion_Final_Nro = m_fecha_final.Inscripcion_Final_Nro
    -- Si no tuvieras ese nro, podés reemplazar por:
    -- AND CAST(m_inscripcion.Examen_Final_Fecha AS DATE) = CAST(m_fecha_final.Examen_Final_Fecha AS DATE)
         JOIN LOS_DESNORMALIZADOS.alumno a
              ON a.legajo = m_inscripcion.Alumno_Legajo
         JOIN LOS_DESNORMALIZADOS.profesor p
              ON p.dni = TRIM(m_inscripcion.Profesor_Dni)
         JOIN LOS_DESNORMALIZADOS.sede s
              ON s.nombre = TRIM(m_inscripcion.Sede_Nombre)
                  AND ISNULL(s.provincia, '') = ISNULL(TRIM(m_inscripcion.Sede_Provincia), '')
                  AND ISNULL(s.localidad, '') = ISNULL(TRIM(m_inscripcion.Sede_Localidad), '')
         JOIN LOS_DESNORMALIZADOS.curso c
              ON c.sede_id = s.id
                  AND c.profesor_id = p.id
                  AND c.nombre = TRIM(m_inscripcion.Curso_Nombre)
                  AND CAST(c.fecha_inicio AS DATE) = CAST(m_inscripcion.Curso_FechaInicio AS DATE)
         JOIN LOS_DESNORMALIZADOS.final f
              ON f.curso_id = c.codigo_curso
                  AND CAST(f.fecha AS DATE) = CAST(m_fecha_final.Examen_Final_Fecha AS DATE)
WHERE
    m_inscripcion.Inscripcion_Final_Nro   IS NOT NULL
  AND m_inscripcion.Evaluacion_Final_Nota   IS NOT NULL
  AND m_fecha_final.Examen_Final_Fecha      IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM LOS_DESNORMALIZADOS.final_inscripto fi
    WHERE fi.alumno_id = a.legajo
      AND fi.final_id  = f.id
);

END;
GO

-- NO FUNCIONA LA PARTE B

------------------------------------------------------
-- 15) Migrar Medios de Pago
------------------------------------------------------
CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_medios_pago
    AS
BEGIN
  SET NOCOUNT ON;

INSERT INTO LOS_DESNORMALIZADOS.medio_de_pago (nombre)
SELECT DISTINCT
    TRIM(m.Pago_MedioPago)
FROM gd_esquema.Maestra m
WHERE m.Pago_MedioPago IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM LOS_DESNORMALIZADOS.medio_de_pago mp
    WHERE TRIM(mp.nombre) = TRIM(m.Pago_MedioPago)
);
END;
GO

------------------------------------------------------
-- 15) Migrar Facturas
------------------------------------------------------
CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_facturas
    AS
BEGIN
  SET NOCOUNT ON;

INSERT INTO LOS_DESNORMALIZADOS.factura
(nro_factura, fecha_emision, fecha_vencimiento, alumno_id, importe_total)
SELECT DISTINCT
    m.Factura_Numero,
    CAST(m.Factura_FechaEmision AS DATE),
    CAST(m.Factura_FechaVencimiento AS DATE),
    a.legajo,
    TRY_CAST(m.Factura_Total AS DECIMAL(12,2))
FROM gd_esquema.Maestra m
         JOIN LOS_DESNORMALIZADOS.alumno a
              ON a.legajo = m.Alumno_Legajo
WHERE m.Factura_Numero IS NOT NULL
  AND m.Factura_FechaEmision  IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM LOS_DESNORMALIZADOS.factura f
    WHERE f.nro_factura = m.Factura_Numero
      AND CAST(f.fecha_emision AS DATE) = CAST(m.Factura_FechaEmision AS DATE)
      AND f.alumno_id = a.legajo
);
END;
GO

------------------------------------------------------
-- 15) Migrar Pagos
------------------------------------------------------
CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_pagos
    AS
BEGIN
  SET NOCOUNT ON;

  -- Solo pagos válidos
WITH pagos_validos AS (
    SELECT
        m.Factura_Numero,
        m.Factura_FechaEmision,
        m.Alumno_Legajo,
        m.Pago_Fecha,
        m.Pago_Importe,
        m.Pago_MedioPago
    FROM gd_esquema.Maestra m
    WHERE
        m.Pago_Fecha IS NOT NULL
      AND m.Pago_Importe IS NOT NULL
      AND m.Pago_MedioPago IS NOT NULL
      AND m.Factura_Numero IS NOT NULL
      AND m.Factura_FechaEmision IS NOT NULL
      AND m.Alumno_Legajo IS NOT NULL
)

INSERT INTO LOS_DESNORMALIZADOS.pago
  (factura_id, fecha, importe, medio_pago_id)
SELECT
    f.nro_factura,
    CAST(pv.Pago_Fecha AS DATE),
    CAST(pv.Pago_Importe AS DECIMAL(12,2)),
    mp.id
FROM pagos_validos pv
         JOIN LOS_DESNORMALIZADOS.alumno a
              ON a.legajo = pv.Alumno_Legajo
         JOIN LOS_DESNORMALIZADOS.factura f
              ON f.nro_factura = pv.Factura_Numero
                  AND CAST(f.fecha_emision AS DATE) = CAST(pv.Factura_FechaEmision AS DATE)
                  AND f.alumno_id = a.legajo
         JOIN LOS_DESNORMALIZADOS.medio_de_pago mp
              ON TRIM(mp.nombre) = TRIM(pv.Pago_MedioPago)
         LEFT JOIN LOS_DESNORMALIZADOS.pago pg
                   ON pg.factura_id = f.nro_factura
                       AND pg.medio_pago_id = mp.id
                       AND CAST(pg.fecha AS DATE) = CAST(pv.Pago_Fecha AS DATE)
                       AND pg.importe = CAST(pv.Pago_Importe AS DECIMAL(12,2))
WHERE pg.id IS NULL;
END;
GO

------------------------------------------------------
-- 16) Migrar Detalle Factura
------------------------------------------------------

CREATE OR ALTER PROCEDURE LOS_DESNORMALIZADOS.migrar_detalle_factura
    @fast_mode BIT = 1
    AS
BEGIN
    SET NOCOUNT ON;

    -- Opcional: deshabilitar trigger para acelerar carga masiva
    IF @fast_mode = 1
        DISABLE TRIGGER LOS_DESNORMALIZADOS.trg_actualizar_importe_factura
        ON LOS_DESNORMALIZADOS.detalle_factura;

INSERT INTO LOS_DESNORMALIZADOS.detalle_factura
(curso_id, importe, mes, anio, factura_id)
SELECT
    c.codigo_curso,
    CAST(m.Detalle_Factura_Importe AS DECIMAL(18,2)),
    CAST(m.Periodo_Mes AS INT),
    CAST(m.Periodo_Anio AS INT),
    f.nro_factura
FROM gd_esquema.Maestra m
         JOIN LOS_DESNORMALIZADOS.alumno a
              ON a.legajo = m.Alumno_Legajo
         JOIN LOS_DESNORMALIZADOS.factura f
              ON f.nro_factura = m.Factura_Numero
                  AND CAST(f.fecha_emision AS DATE) = CAST(m.Factura_FechaEmision AS DATE)
                  AND f.alumno_id = a.legajo
         JOIN LOS_DESNORMALIZADOS.curso c
              ON c.codigo_curso = m.Curso_Codigo
    -- Anti-join para evitar duplicados
         LEFT JOIN LOS_DESNORMALIZADOS.detalle_factura d
                   ON d.factura_id = f.nro_factura
                       AND d.curso_id   = c.codigo_curso
                       AND d.mes        = CAST(m.Periodo_Mes AS INT)
                       AND d.anio       = CAST(m.Periodo_Anio AS INT)
                       AND d.importe    = CAST(m.Detalle_Factura_Importe AS DECIMAL(18,2))
WHERE
    m.Factura_Numero IS NOT NULL
  AND m.Factura_FechaEmision IS NOT NULL
  AND m.Alumno_Legajo IS NOT NULL
  AND m.Curso_Codigo IS NOT NULL
  AND m.Periodo_Mes IS NOT NULL
  AND m.Periodo_Anio IS NOT NULL
  AND m.Detalle_Factura_Importe IS NOT NULL
  AND d.id IS NULL;

-- Recalcular importes de facturas en un solo paso si deshabilitaste el trigger
IF @fast_mode = 1
BEGIN
UPDATE f
SET f.importe_total = x.suma
    FROM LOS_DESNORMALIZADOS.factura f
        JOIN (
            SELECT factura_id, SUM(importe) AS suma
            FROM LOS_DESNORMALIZADOS.detalle_factura
            GROUP BY factura_id
        ) x ON x.factura_id = f.nro_factura;

ENABLE TRIGGER LOS_DESNORMALIZADOS.trg_actualizar_importe_factura
        ON LOS_DESNORMALIZADOS.detalle_factura;
END
END
GO


EXEC LOS_DESNORMALIZADOS.migrar_instituciones
EXEC LOS_DESNORMALIZADOS.migrar_sedes
EXEC LOS_DESNORMALIZADOS.migrar_profesores
EXEC LOS_DESNORMALIZADOS.migrar_alumnos
EXEC LOS_DESNORMALIZADOS.migrar_categorias
EXEC LOS_DESNORMALIZADOS.migrar_turnos
EXEC LOS_DESNORMALIZADOS.migrar_dias
EXEC LOS_DESNORMALIZADOS.migrar_cursos
EXEC LOS_DESNORMALIZADOS.migrar_modulos
EXEC LOS_DESNORMALIZADOS.migrar_horarios
EXEC LOS_DESNORMALIZADOS.migrar_estados_inscripcion
EXEC LOS_DESNORMALIZADOS.migrar_inscripciones_curso
EXEC LOS_DESNORMALIZADOS.migrar_trabajos_practicos
EXEC LOS_DESNORMALIZADOS.migrar_evaluaciones_modulos
EXEC LOS_DESNORMALIZADOS.migrar_finales
EXEC LOS_DESNORMALIZADOS.migrar_medios_pago
EXEC LOS_DESNORMALIZADOS.migrar_facturas
EXEC LOS_DESNORMALIZADOS.migrar_pagos
EXEC LOS_DESNORMALIZADOS.migrar_detalle_factura
