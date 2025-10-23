CREATE TABLE LOS_DESNORMALIZADOS.profesor (
	id BIGINT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(255) NOT NULL,
	apellido VARCHAR(255) NOT NULL,
	dni VARCHAR(10)NOT NULL,
	direccion VARCHAR(255),
	correo VARCHAR(255),
	telefono VARCHAR(255),
	provincia VARCHAR(255),
	localidad VARCHAR(255)
);

CREATE TABLE LOS_DESNORMALIZADOS.alumno (
	legajo BIGINT PRIMARY KEY,
	nombre VARCHAR(255) NOT NULL,
	apellido VARCHAR(255) NOT NULL,
	dni VARCHAR(10) NOT NULL,
	direccion VARCHAR(255),
	telefono VARCHAR(255),
	mail VARCHAR(255),
	provincia VARCHAR(255),
	ciudad VARCHAR(255)
); 

CREATE TABLE LOS_DESNORMALIZADOS.sede(
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    provincia VARCHAR(255),
    localidad VARCHAR(255),
    nombre VARCHAR(255),
    direccion VARCHAR(255),
    telefono VARCHAR(255)
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
    nombre VARCHAR(255) CHECK(nombre IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'))
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

CREATE TABLE LOS_DESNORMALIZADOS.detalle_factura (
	id BIGINT PRIMARY KEY IDENTITY(1,1),
	curso_id BIGINT, -- En la tabla figura como INTEGER(11)
	importe DECIMAL(18,2),
	mes BIGINT CHECK (mes BETWEEN 1 AND 12),
	anio BIGINT,
	FOREIGN KEY (curso_id) REFERENCES LOS_DESNORMALIZADOS.curso(codigo_curso)
);

CREATE TABLE LOS_DESNORMALIZADOS.factura (
	nro_factura BIGINT PRIMARY KEY IDENTITY(1,1),
	fecha_emision DATETIME DEFAULT GETDATE(),
	fecha_vencimiento DATETIME NOT NULL,
	alumno_id BIGINT,
	detalle_factura_id BIGINT,
	importe_total DECIMAL(18, 2),
	FOREIGN KEY (alumno_id) REFERENCES LOS_DESNORMALIZADOS.alumno(legajo),
	FOREIGN KEY (detalle_factura_id) REFERENCES LOS_DESNORMALIZADOS.detalle_factura(id),
    CONSTRAINT CHK_factura_fechas CHECK (fecha_vencimiento >= fecha_emision)
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

