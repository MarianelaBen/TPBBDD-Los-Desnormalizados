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
    codigo_curso BIGINT PRIMARY KEY IDENTITY(1,1),
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
	nro_factura BIGINT PRIMARY KEY IDENTITY(1,1),
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
    nombre VARCHAR(255) CHECK(nombre IN ('Aprobada', 'Rechazada', 'Pendiente'))
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
-- TRIGGER PARA VALIDAR FACTURA PAGADA
------------------------------------------------------
CREATE TRIGGER trg_validar_pago_factura
ON LOS_DESNORMALIZADOS.pago
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN LOS_DESNORMALIZADOS.factura f ON f.nro_factura = i.factura_id
        GROUP BY i.factura_id, f.importe_total
        HAVING SUM(i.importe) + ISNULL((
            SELECT SUM(p.importe)
            FROM LOS_DESNORMALIZADOS.pago p
            WHERE p.factura_id = i.factura_id
              AND p.id NOT IN (SELECT id FROM inserted)
        ), 0) > f.importe_total
    )
    BEGIN
        RAISERROR('El total de pagos supera el importe total de la factura.', 16, 1);
        ROLLBACK TRANSACTION;
    END
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

	INSERT INTO LOS_DESNORMALIZADOS.modulo (nombre, descripcion, curso_id)
	SELECT DISTINCT
		TRIM(m.Modulo_Nombre),
		TRIM(m.Modulo_Descripcion),
		c.codigo_curso -- Este es el ID que necesitamos
	FROM
		gd_esquema.Maestra m
	-- Necesitamos recrear los JOINs para identificar de forma única a qué curso pertenece el módulo
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
		m.Modulo_Nombre IS NOT NULL
		AND NOT EXISTS ( -- Condición para no insertar duplicados
			SELECT 1
			FROM LOS_DESNORMALIZADOS.modulo mo
			WHERE mo.curso_id = c.codigo_curso
			  AND mo.nombre = TRIM(m.Modulo_Nombre)
		);
END;
GO