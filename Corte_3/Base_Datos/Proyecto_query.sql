-- ============================================================
-- DDL - Sistema de Conexión Estudiantil UVG
-- Base de Datos 1 | Ciclo 1, 2026
-- Motor: SQLite 3
-- Versión: 1.0
-- ============================================================

PRAGMA foreign_keys = ON;   -- Activar integridad referencial en SQLite

-- ============================================================
-- DROP: eliminar tablas en orden inverso de dependencias
-- ============================================================
DROP TABLE IF EXISTS PALABRA_PROHIBIDA;
DROP TABLE IF EXISTS REGLAMENTO;
DROP TABLE IF EXISTS ACCION_MODERACION;
DROP TABLE IF EXISTS ACCION;
DROP TABLE IF EXISTS REPORTE;
DROP TABLE IF EXISTS MOTIVO;
DROP TABLE IF EXISTS TIPO_OBJETIVO;
DROP TABLE IF EXISTS RESENA;
DROP TABLE IF EXISTS CONTEXTO;
DROP TABLE IF EXISTS ACUERDO_ENTREGA;
DROP TABLE IF EXISTS MENSAJE;
DROP TABLE IF EXISTS ESTADO_MENSAJE;
DROP TABLE IF EXISTS CONVERSACION;
DROP TABLE IF EXISTS SESION_TUTORIA;
DROP TABLE IF EXISTS ESTADO_SC;
DROP TABLE IF EXISTS DISPONIBILIDAD_TUTOR;
DROP TABLE IF EXISTS DIA_SEMANA;
DROP TABLE IF EXISTS CERTIFICACION_TUTOR;
DROP TABLE IF EXISTS CATEDRATICO;
DROP TABLE IF EXISTS TUTOR_CURSO;
DROP TABLE IF EXISTS CURSO;
DROP TABLE IF EXISTS DEPARTAMENTO;
DROP TABLE IF EXISTS PERFIL_TUTOR;
DROP TABLE IF EXISTS ANUNCIO_VENDEDOR;
DROP TABLE IF EXISTS FOTO_PUBLICACION;
DROP TABLE IF EXISTS PUBLICACION;
DROP TABLE IF EXISTS ESTADO_PUBLICACION;
DROP TABLE IF EXISTS CATEGORIA;
DROP TABLE IF EXISTS USUARIO_ROL;
DROP TABLE IF EXISTS ROL;
DROP TABLE IF EXISTS USUARIO;
DROP TABLE IF EXISTS ESTADO_USUARIO;

-- ============================================================
-- BLOQUE 1: CATÁLOGOS BASE (tablas de dominio / lookup)
-- ============================================================

-- Estados posibles de una cuenta de usuario
CREATE TABLE ESTADO_USUARIO (
    id_estado_usuario   INTEGER         NOT NULL,
    nombre_estado       VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_estado_usuario    PRIMARY KEY (id_estado_usuario),
    CONSTRAINT uq_estado_usuario    UNIQUE (nombre_estado),
    CONSTRAINT ck_estado_usuario    CHECK (nombre_estado IN ('activo', 'suspendido', 'bloqueado'))
);

-- Roles que puede tener un usuario dentro del sistema
CREATE TABLE ROL (
    id_rol      INTEGER         NOT NULL,
    nombre_rol  VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_rol   PRIMARY KEY (id_rol),
    CONSTRAINT uq_rol   UNIQUE (nombre_rol),
    CONSTRAINT ck_rol   CHECK (nombre_rol IN ('consumidor', 'vendedor', 'tutor', 'moderador', 'emprendedor'))
);

-- Estados posibles de una publicación de objeto/material
CREATE TABLE ESTADO_PUBLICACION (
    id_estado_publicacion   INTEGER         NOT NULL,
    nombre                  VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_estado_publicacion    PRIMARY KEY (id_estado_publicacion),
    CONSTRAINT uq_estado_publicacion    UNIQUE (nombre),
    CONSTRAINT ck_estado_publicacion    CHECK (nombre IN ('disponible', 'reservado', 'vendido'))
);

-- Estados del ciclo de vida de sesiones y acuerdos
CREATE TABLE ESTADO_SC (
    id_estado_sc    INTEGER         NOT NULL,
    nombre          VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_estado_sc     PRIMARY KEY (id_estado_sc),
    CONSTRAINT uq_estado_sc     UNIQUE (nombre),
    CONSTRAINT ck_estado_sc     CHECK (nombre IN ('pendiente', 'confirmada', 'completada', 'cancelada'))
);

-- Estados de lectura de un mensaje
CREATE TABLE ESTADO_MENSAJE (
    id_estado_mensaje   INTEGER         NOT NULL,
    nombre              VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_estado_mensaje    PRIMARY KEY (id_estado_mensaje),
    CONSTRAINT uq_estado_mensaje    UNIQUE (nombre),
    CONSTRAINT ck_estado_mensaje    CHECK (nombre IN ('enviado', 'no_leido', 'leido'))
);

-- Contexto bajo el cual se emite una reseña
CREATE TABLE CONTEXTO (
    id_contexto INTEGER         NOT NULL,
    nombre      VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_contexto  PRIMARY KEY (id_contexto),
    CONSTRAINT uq_contexto  UNIQUE (nombre),
    CONSTRAINT ck_contexto  CHECK (nombre IN ('compra', 'prestamo', 'tutoria'))
);

-- Tipo de entidad que puede ser objeto de un reporte o acción de moderación
CREATE TABLE TIPO_OBJETIVO (
    id_tipo_objetivo    INTEGER         NOT NULL,
    nombre              VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_tipo_objetivo     PRIMARY KEY (id_tipo_objetivo),
    CONSTRAINT uq_tipo_objetivo     UNIQUE (nombre),
    CONSTRAINT ck_tipo_objetivo     CHECK (nombre IN ('publicacion', 'mensaje', 'usuario'))
);

-- Motivos predefinidos para reportar contenido o usuarios
CREATE TABLE MOTIVO (
    id_motivo   INTEGER         NOT NULL,
    nombre      VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_motivo    PRIMARY KEY (id_motivo),
    CONSTRAINT uq_motivo    UNIQUE (nombre),
    CONSTRAINT ck_motivo    CHECK (nombre IN ('incumple_normas', 'informacion_falsa', 'no_cumplio_fechas'))
);

-- Tipos de acción que un moderador puede aplicar
CREATE TABLE ACCION (
    id_accion   INTEGER         NOT NULL,
    nombre      VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_accion    PRIMARY KEY (id_accion),
    CONSTRAINT uq_accion    UNIQUE (nombre),
    CONSTRAINT ck_accion    CHECK (nombre IN ('eliminacion', 'advertencia', 'suspension', 'bloqueo'))
);

-- Catálogo de días de la semana (usado para disponibilidad de tutores)
CREATE TABLE DIA_SEMANA (
    id_dia_semana   INTEGER         NOT NULL,
    nombre          VARCHAR(15)     NOT NULL,
    CONSTRAINT pk_dia_semana    PRIMARY KEY (id_dia_semana),
    CONSTRAINT uq_dia_semana    UNIQUE (nombre),
    CONSTRAINT ck_dia_semana    CHECK (nombre IN ('lunes','martes','miercoles','jueves','viernes','sabado','domingo'))
);

-- Departamentos académicos de la universidad
CREATE TABLE DEPARTAMENTO (
    id_departamento INTEGER         NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    CONSTRAINT pk_departamento  PRIMARY KEY (id_departamento),
    CONSTRAINT uq_departamento  UNIQUE (nombre)
);

-- Catedráticos que pueden avalar certificaciones de tutores
CREATE TABLE CATEDRATICO (
    id_catedratico      INTEGER         NOT NULL,
    nombre_catedratico  VARCHAR(150)    NOT NULL,
    CONSTRAINT pk_catedratico   PRIMARY KEY (id_catedratico)
);

-- ============================================================
-- BLOQUE 2: USUARIO Y ROLES
-- ============================================================

-- Entidad central del sistema: estudiante universitario
CREATE TABLE USUARIO (
    id_usuario              INTEGER         NOT NULL,
    dpi                     VARCHAR(20)     NOT NULL,
    carnet                  VARCHAR(10)     NOT NULL,
    email_institucional     VARCHAR(100)    NOT NULL,
    contrasena              VARCHAR(255)    NOT NULL,   -- hash bcrypt/argon2
    url_foto_perfil         VARCHAR(500),
    descripcion             TEXT,
    telefono                VARCHAR(15),
    calificacion_promedio   NUMERIC(3,2)    NOT NULL    DEFAULT 0.00,
    fecha_registro          DATE            NOT NULL,
    id_estado_usuario       INTEGER         NOT NULL,
    CONSTRAINT pk_usuario               PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_dpi           UNIQUE (dpi),
    CONSTRAINT uq_usuario_carnet        UNIQUE (carnet),
    CONSTRAINT uq_usuario_email         UNIQUE (email_institucional),
    CONSTRAINT fk_usuario_estado        FOREIGN KEY (id_estado_usuario)
                                            REFERENCES ESTADO_USUARIO (id_estado_usuario),
    CONSTRAINT ck_usuario_calificacion  CHECK (calificacion_promedio BETWEEN 0.00 AND 5.00),
    CONSTRAINT ck_usuario_carnet        CHECK (carnet GLOB '[0-9][0-9][0-9][0-9][0-9]*')
);

-- Relación M:N entre usuarios y roles (un usuario puede tener varios roles)
CREATE TABLE USUARIO_ROL (
    id_usuario       INTEGER  NOT NULL,
    id_rol           INTEGER  NOT NULL,
    fecha_asignacion DATE     NOT NULL,
    CONSTRAINT pk_usuario_rol   PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_ur_usuario    FOREIGN KEY (id_usuario)
                                    REFERENCES USUARIO (id_usuario)
                                    ON DELETE CASCADE,
    CONSTRAINT fk_ur_rol        FOREIGN KEY (id_rol)
                                    REFERENCES ROL (id_rol)
);

-- ============================================================
-- BLOQUE 3: PUBLICACIONES E INTERCAMBIO DE OBJETOS
-- ============================================================

-- Categorías jerárquicas para clasificar publicaciones (auto-referencia)
CREATE TABLE CATEGORIA (
    id_categoria        INTEGER         NOT NULL,
    nombre_categoria    VARCHAR(100)    NOT NULL,
    id_categoria_padre  INTEGER,            -- NULL si es categoría raíz
    CONSTRAINT pk_categoria         PRIMARY KEY (id_categoria),
    CONSTRAINT fk_categoria_padre   FOREIGN KEY (id_categoria_padre)
                                        REFERENCES CATEGORIA (id_categoria)
);

-- Publicación de objetos para venta, préstamo o emprendimiento
CREATE TABLE PUBLICACION (
    id_publicacion          INTEGER         NOT NULL,
    id_usuario              INTEGER         NOT NULL,
    id_categoria            INTEGER         NOT NULL,
    titulo                  VARCHAR(200)    NOT NULL,
    descripcion             TEXT,
    precio                  NUMERIC(10,2),
    tipo                    VARCHAR(20)     NOT NULL,   -- venta / prestamo / emprendimiento
    id_estado_publicacion   INTEGER         NOT NULL,
    destacada               INTEGER         NOT NULL    DEFAULT 0,   -- 0=false, 1=true (SQLite no tiene BOOLEAN)
    fecha_publicacion       TEXT            NOT NULL,   -- ISO 8601: YYYY-MM-DD HH:MM:SS
    fecha_actualizacion     TEXT,
    CONSTRAINT pk_publicacion           PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_pub_usuario           FOREIGN KEY (id_usuario)
                                            REFERENCES USUARIO (id_usuario),
    CONSTRAINT fk_pub_categoria         FOREIGN KEY (id_categoria)
                                            REFERENCES CATEGORIA (id_categoria),
    CONSTRAINT fk_pub_estado            FOREIGN KEY (id_estado_publicacion)
                                            REFERENCES ESTADO_PUBLICACION (id_estado_publicacion),
    CONSTRAINT ck_pub_tipo              CHECK (tipo IN ('venta', 'prestamo', 'emprendimiento')),
    CONSTRAINT ck_pub_precio            CHECK (precio IS NULL OR precio >= 0),
    CONSTRAINT ck_pub_destacada         CHECK (destacada IN (0, 1))
);

-- Fotos asociadas a una publicación (entidad débil)
CREATE TABLE FOTO_PUBLICACION (
    id_foto         INTEGER         NOT NULL,
    id_publicacion  INTEGER         NOT NULL,
    url_foto        VARCHAR(500)    NOT NULL,
    orden           INTEGER         NOT NULL,
    CONSTRAINT pk_foto_publicacion  PRIMARY KEY (id_foto),
    CONSTRAINT uq_foto_orden        UNIQUE (id_publicacion, orden),  -- clave candidata: (publicacion, orden)
    CONSTRAINT fk_foto_publicacion  FOREIGN KEY (id_publicacion)
                                        REFERENCES PUBLICACION (id_publicacion)
                                        ON DELETE CASCADE,
    CONSTRAINT ck_foto_orden        CHECK (orden > 0)
);

-- Anuncios generales de vendedores/emprendedores
CREATE TABLE ANUNCIO_VENDEDOR (
    id_anuncio          INTEGER     NOT NULL,
    id_usuario          INTEGER     NOT NULL,
    contenido           TEXT        NOT NULL,
    fecha_publicacion   TEXT        NOT NULL,
    activo              INTEGER     NOT NULL    DEFAULT 1,   -- 0=false, 1=true
    CONSTRAINT pk_anuncio_vendedor  PRIMARY KEY (id_anuncio),
    CONSTRAINT fk_anuncio_usuario   FOREIGN KEY (id_usuario)
                                        REFERENCES USUARIO (id_usuario),
    CONSTRAINT ck_anuncio_activo    CHECK (activo IN (0, 1))
);

-- ============================================================
-- BLOQUE 4: TUTORÍA Y REFUERZO ACADÉMICO
-- ============================================================

-- Perfil extendido de un usuario con rol de tutor (PK = FK a USUARIO)
CREATE TABLE PERFIL_TUTOR (
    id_tutor                INTEGER         NOT NULL,
    descripcion_servicio    TEXT,
    precio_hora             NUMERIC(8,2),
    CONSTRAINT pk_perfil_tutor  PRIMARY KEY (id_tutor),
    CONSTRAINT fk_tutor_usuario FOREIGN KEY (id_tutor)
                                    REFERENCES USUARIO (id_usuario)
                                    ON DELETE CASCADE,
    CONSTRAINT ck_tutor_precio  CHECK (precio_hora IS NULL OR precio_hora > 0)
);

-- Cursos universitarios que pueden ser objeto de tutoría
CREATE TABLE CURSO (
    id_curso        INTEGER         NOT NULL,
    nombre_curso    VARCHAR(150)    NOT NULL,
    id_departamento INTEGER         NOT NULL,
    CONSTRAINT pk_curso                 PRIMARY KEY (id_curso),
    CONSTRAINT uq_curso_nombre_depto    UNIQUE (nombre_curso, id_departamento),  -- clave candidata
    CONSTRAINT fk_curso_departamento    FOREIGN KEY (id_departamento)
                                            REFERENCES DEPARTAMENTO (id_departamento)
);

-- Relación M:N entre tutores y cursos que pueden impartir
CREATE TABLE TUTOR_CURSO (
    id_tutor    INTEGER NOT NULL,
    id_curso    INTEGER NOT NULL,
    CONSTRAINT pk_tutor_curso   PRIMARY KEY (id_tutor, id_curso),
    CONSTRAINT fk_tc_tutor      FOREIGN KEY (id_tutor)
                                    REFERENCES PERFIL_TUTOR (id_tutor)
                                    ON DELETE CASCADE,
    CONSTRAINT fk_tc_curso      FOREIGN KEY (id_curso)
                                    REFERENCES CURSO (id_curso)
);

-- Certificaciones emitidas por catedráticos que avalan a un tutor
CREATE TABLE CERTIFICACION_TUTOR (
    id_certificacion    INTEGER         NOT NULL,
    id_tutor            INTEGER         NOT NULL,
    id_catedratico      INTEGER         NOT NULL,
    descripcion         TEXT,
    url_documento       VARCHAR(500),
    fecha_emision       DATE,
    CONSTRAINT pk_certificacion_tutor   PRIMARY KEY (id_certificacion),
    CONSTRAINT fk_cert_tutor            FOREIGN KEY (id_tutor)
                                            REFERENCES PERFIL_TUTOR (id_tutor)
                                            ON DELETE CASCADE,
    CONSTRAINT fk_cert_catedratico      FOREIGN KEY (id_catedratico)
                                            REFERENCES CATEDRATICO (id_catedratico)
);

-- Bloques de disponibilidad horaria semanal de un tutor
CREATE TABLE DISPONIBILIDAD_TUTOR (
    id_disponibilidad   INTEGER     NOT NULL,
    id_tutor            INTEGER     NOT NULL,
    id_dia_semana       INTEGER     NOT NULL,
    hora_inicio         TEXT        NOT NULL,   -- formato HH:MM (SQLite no tiene tipo TIME)
    hora_fin            TEXT        NOT NULL,
    CONSTRAINT pk_disponibilidad_tutor  PRIMARY KEY (id_disponibilidad),
    CONSTRAINT uq_disp_bloque           UNIQUE (id_tutor, id_dia_semana, hora_inicio),  -- clave candidata
    CONSTRAINT fk_disp_tutor            FOREIGN KEY (id_tutor)
                                            REFERENCES PERFIL_TUTOR (id_tutor)
                                            ON DELETE CASCADE,
    CONSTRAINT fk_disp_dia              FOREIGN KEY (id_dia_semana)
                                            REFERENCES DIA_SEMANA (id_dia_semana),
    CONSTRAINT ck_disp_horas            CHECK (hora_fin > hora_inicio)
);

-- Sesión de tutoría agendada entre un tutor y un estudiante
CREATE TABLE SESION_TUTORIA (
    id_sesion       INTEGER         NOT NULL,
    id_tutor        INTEGER         NOT NULL,
    id_usuario      INTEGER         NOT NULL,   -- estudiante
    id_curso        INTEGER         NOT NULL,
    fecha_sesion    DATE            NOT NULL,
    hora_inicio     TEXT            NOT NULL,
    hora_fin        TEXT            NOT NULL,
    id_estado_sc    INTEGER         NOT NULL,
    modalidad       VARCHAR(15)     NOT NULL,   -- presencial / virtual
    CONSTRAINT pk_sesion_tutoria        PRIMARY KEY (id_sesion),
    CONSTRAINT uq_sesion_tutor_hora     UNIQUE (id_tutor, id_usuario, fecha_sesion, hora_inicio),
    CONSTRAINT fk_sesion_tutor          FOREIGN KEY (id_tutor)
                                            REFERENCES PERFIL_TUTOR (id_tutor),
    CONSTRAINT fk_sesion_usuario        FOREIGN KEY (id_usuario)
                                            REFERENCES USUARIO (id_usuario),
    CONSTRAINT fk_sesion_curso          FOREIGN KEY (id_curso)
                                            REFERENCES CURSO (id_curso),
    CONSTRAINT fk_sesion_estado         FOREIGN KEY (id_estado_sc)
                                            REFERENCES ESTADO_SC (id_estado_sc),
    CONSTRAINT ck_sesion_modalidad      CHECK (modalidad IN ('presencial', 'virtual')),
    CONSTRAINT ck_sesion_horas          CHECK (hora_fin > hora_inicio),
    CONSTRAINT ck_sesion_tutor_distinto CHECK (id_tutor <> id_usuario)
);

-- ============================================================
-- BLOQUE 5: MENSAJERÍA Y ACUERDOS
-- ============================================================

-- Hilo de conversación entre dos usuarios (sobre publicación o sesión)
CREATE TABLE CONVERSACION (
    id_conversacion INTEGER     NOT NULL,
    id_usuario_1    INTEGER     NOT NULL,
    id_usuario_2    INTEGER     NOT NULL,
    id_publicacion  INTEGER,                -- nullable
    id_sesion       INTEGER,                -- nullable
    fecha_inicio    TEXT        NOT NULL,
    CONSTRAINT pk_conversacion          PRIMARY KEY (id_conversacion),
    CONSTRAINT uq_conv_usuarios_pub     UNIQUE (id_usuario_1, id_usuario_2, id_publicacion),
    CONSTRAINT fk_conv_usuario1         FOREIGN KEY (id_usuario_1)
                                            REFERENCES USUARIO (id_usuario),
    CONSTRAINT fk_conv_usuario2         FOREIGN KEY (id_usuario_2)
                                            REFERENCES USUARIO (id_usuario),
    CONSTRAINT fk_conv_publicacion      FOREIGN KEY (id_publicacion)
                                            REFERENCES PUBLICACION (id_publicacion),
    CONSTRAINT fk_conv_sesion           FOREIGN KEY (id_sesion)
                                            REFERENCES SESION_TUTORIA (id_sesion),
    CONSTRAINT ck_conv_usuarios         CHECK (id_usuario_1 <> id_usuario_2)
);

-- Mensaje individual dentro de una conversación
CREATE TABLE MENSAJE (
    id_mensaje          INTEGER     NOT NULL,
    id_conversacion     INTEGER     NOT NULL,
    id_emisor           INTEGER     NOT NULL,
    contenido           TEXT        NOT NULL,
    fecha_envio         TEXT        NOT NULL,
    id_estado_mensaje   INTEGER     NOT NULL,
    CONSTRAINT pk_mensaje           PRIMARY KEY (id_mensaje),
    CONSTRAINT fk_msg_conversacion  FOREIGN KEY (id_conversacion)
                                        REFERENCES CONVERSACION (id_conversacion)
                                        ON DELETE CASCADE,
    CONSTRAINT fk_msg_emisor        FOREIGN KEY (id_emisor)
                                        REFERENCES USUARIO (id_usuario),
    CONSTRAINT fk_msg_estado        FOREIGN KEY (id_estado_mensaje)
                                        REFERENCES ESTADO_MENSAJE (id_estado_mensaje)
);

-- Acuerdo formal de entrega (lugar, fecha y hora pactados en una conversación)
CREATE TABLE ACUERDO_ENTREGA (
    id_acuerdo      INTEGER         NOT NULL,
    id_conversacion INTEGER         NOT NULL,
    id_publicacion  INTEGER,                    -- nullable: acuerdo de objeto
    id_sesion       INTEGER,                    -- nullable: acuerdo de tutoría
    lugar           VARCHAR(200),
    fecha_acordada  DATE,
    hora_acordada   TEXT,
    id_estado_sc    INTEGER         NOT NULL,
    CONSTRAINT pk_acuerdo_entrega       PRIMARY KEY (id_acuerdo),
    CONSTRAINT fk_acuerdo_conv          FOREIGN KEY (id_conversacion)
                                            REFERENCES CONVERSACION (id_conversacion),
    CONSTRAINT fk_acuerdo_publicacion   FOREIGN KEY (id_publicacion)
                                            REFERENCES PUBLICACION (id_publicacion),
    CONSTRAINT fk_acuerdo_sesion        FOREIGN KEY (id_sesion)
                                            REFERENCES SESION_TUTORIA (id_sesion),
    CONSTRAINT fk_acuerdo_estado        FOREIGN KEY (id_estado_sc)
                                            REFERENCES ESTADO_SC (id_estado_sc)
);

-- ============================================================
-- BLOQUE 6: RESEÑAS
-- ============================================================

-- Evaluación que un usuario le da a otro tras una interacción
CREATE TABLE RESENA (
    id_resena       INTEGER     NOT NULL,
    id_evaluador    INTEGER     NOT NULL,
    id_evaluado     INTEGER     NOT NULL,
    calificacion    INTEGER     NOT NULL,   -- 1 a 5
    comentario      TEXT,
    id_contexto     INTEGER     NOT NULL,
    id_sesion       INTEGER,               -- nullable
    id_publicacion  INTEGER,               -- nullable
    fecha_resena    TEXT        NOT NULL,
    CONSTRAINT pk_resena                PRIMARY KEY (id_resena),
    CONSTRAINT uq_resena_sesion         UNIQUE (id_evaluador, id_evaluado, id_contexto, id_sesion),
    CONSTRAINT fk_resena_evaluador      FOREIGN KEY (id_evaluador)
                                            REFERENCES USUARIO (id_usuario),
    CONSTRAINT fk_resena_evaluado       FOREIGN KEY (id_evaluado)
                                            REFERENCES USUARIO (id_usuario),
    CONSTRAINT fk_resena_contexto       FOREIGN KEY (id_contexto)
                                            REFERENCES CONTEXTO (id_contexto),
    CONSTRAINT fk_resena_sesion         FOREIGN KEY (id_sesion)
                                            REFERENCES SESION_TUTORIA (id_sesion),
    CONSTRAINT fk_resena_publicacion    FOREIGN KEY (id_publicacion)
                                            REFERENCES PUBLICACION (id_publicacion),
    CONSTRAINT ck_resena_calificacion   CHECK (calificacion BETWEEN 1 AND 5),
    CONSTRAINT ck_resena_usuarios       CHECK (id_evaluador <> id_evaluado)
);

-- ============================================================
-- BLOQUE 7: MODERACIÓN
-- ============================================================

-- Reporte generado por un usuario sobre contenido o persona
CREATE TABLE REPORTE (
    id_reporte          INTEGER         NOT NULL,
    id_reportante       INTEGER         NOT NULL,
    id_tipo_objetivo    INTEGER         NOT NULL,
    id_mensaje          INTEGER,                    -- nullable: FK polimórfica
    id_publicacion      INTEGER,                    -- nullable: FK polimórfica
    id_usuario          INTEGER,                    -- nullable: usuario reportado
    id_motivo           INTEGER         NOT NULL,
    comentario          TEXT,
    fecha_reporte       TEXT            NOT NULL,
    estado              VARCHAR(20)     NOT NULL    DEFAULT 'pendiente',
    CONSTRAINT pk_reporte               PRIMARY KEY (id_reporte),
    CONSTRAINT fk_reporte_reportante    FOREIGN KEY (id_reportante)
                                            REFERENCES USUARIO (id_usuario),
    CONSTRAINT fk_reporte_tipo          FOREIGN KEY (id_tipo_objetivo)
                                            REFERENCES TIPO_OBJETIVO (id_tipo_objetivo),
    CONSTRAINT fk_reporte_mensaje       FOREIGN KEY (id_mensaje)
                                            REFERENCES MENSAJE (id_mensaje),
    CONSTRAINT fk_reporte_publicacion   FOREIGN KEY (id_publicacion)
                                            REFERENCES PUBLICACION (id_publicacion),
    CONSTRAINT fk_reporte_usuario       FOREIGN KEY (id_usuario)
                                            REFERENCES USUARIO (id_usuario),
    CONSTRAINT fk_reporte_motivo        FOREIGN KEY (id_motivo)
                                            REFERENCES MOTIVO (id_motivo),
    CONSTRAINT ck_reporte_estado        CHECK (estado IN ('pendiente', 'en_revision', 'resuelto', 'descartado'))
);

-- Acción tomada por un moderador en respuesta a un reporte
CREATE TABLE ACCION_MODERACION (
    id_accion_moderacion    INTEGER     NOT NULL,
    id_moderador            INTEGER     NOT NULL,
    id_reporte              INTEGER     NOT NULL,
    id_tipo_objetivo        INTEGER     NOT NULL,
    id_mensaje              INTEGER,                -- nullable: FK polimórfica
    id_publicacion          INTEGER,                -- nullable: FK polimórfica
    id_usuario              INTEGER,                -- nullable: usuario afectado
    id_accion               INTEGER     NOT NULL,
    justificacion           TEXT,
    fecha_accion            TEXT        NOT NULL,
    CONSTRAINT pk_accion_moderacion         PRIMARY KEY (id_accion_moderacion),
    CONSTRAINT fk_acmod_moderador           FOREIGN KEY (id_moderador)
                                                REFERENCES USUARIO (id_usuario),
    CONSTRAINT fk_acmod_reporte             FOREIGN KEY (id_reporte)
                                                REFERENCES REPORTE (id_reporte),
    CONSTRAINT fk_acmod_tipo                FOREIGN KEY (id_tipo_objetivo)
                                                REFERENCES TIPO_OBJETIVO (id_tipo_objetivo),
    CONSTRAINT fk_acmod_mensaje             FOREIGN KEY (id_mensaje)
                                                REFERENCES MENSAJE (id_mensaje),
    CONSTRAINT fk_acmod_publicacion         FOREIGN KEY (id_publicacion)
                                                REFERENCES PUBLICACION (id_publicacion),
    CONSTRAINT fk_acmod_usuario             FOREIGN KEY (id_usuario)
                                                REFERENCES USUARIO (id_usuario),
    CONSTRAINT fk_acmod_accion              FOREIGN KEY (id_accion)
                                                REFERENCES ACCION (id_accion)
);

-- Versiones del reglamento de la plataforma
CREATE TABLE REGLAMENTO (
    id_reglamento   INTEGER         NOT NULL,
    contenido       TEXT            NOT NULL,
    version         VARCHAR(20)     NOT NULL,
    id_moderador    INTEGER         NOT NULL,
    fecha_vigencia  DATE            NOT NULL,
    CONSTRAINT pk_reglamento        PRIMARY KEY (id_reglamento),
    CONSTRAINT uq_reglamento_ver    UNIQUE (version),
    CONSTRAINT fk_reglamento_mod    FOREIGN KEY (id_moderador)
                                        REFERENCES USUARIO (id_usuario)
);

-- Palabras prohibidas registradas por moderadores para filtrado de contenido
CREATE TABLE PALABRA_PROHIBIDA (
    id_palabra      INTEGER         NOT NULL,
    palabra         VARCHAR(100)    NOT NULL,
    id_moderador    INTEGER         NOT NULL,
    fecha_registro  TEXT            NOT NULL,
    CONSTRAINT pk_palabra_prohibida     PRIMARY KEY (id_palabra),
    CONSTRAINT uq_palabra               UNIQUE (palabra),
    CONSTRAINT fk_palabra_moderador     FOREIGN KEY (id_moderador)
                                            REFERENCES USUARIO (id_usuario)
);

-- ============================================================
-- BLOQUE 8: DATOS INICIALES – CATÁLOGOS
-- ============================================================

INSERT INTO ESTADO_USUARIO (id_estado_usuario, nombre_estado) VALUES
    (1, 'activo'),
    (2, 'suspendido'),
    (3, 'bloqueado');

INSERT INTO ROL (id_rol, nombre_rol) VALUES
    (1, 'consumidor'),
    (2, 'vendedor'),
    (3, 'tutor'),
    (4, 'moderador'),
    (5, 'emprendedor');

INSERT INTO ESTADO_PUBLICACION (id_estado_publicacion, nombre) VALUES
    (1, 'disponible'),
    (2, 'reservado'),
    (3, 'vendido');

INSERT INTO ESTADO_SC (id_estado_sc, nombre) VALUES
    (1, 'pendiente'),
    (2, 'confirmada'),
    (3, 'completada'),
    (4, 'cancelada');

INSERT INTO ESTADO_MENSAJE (id_estado_mensaje, nombre) VALUES
    (1, 'enviado'),
    (2, 'no_leido'),
    (3, 'leido');

INSERT INTO CONTEXTO (id_contexto, nombre) VALUES
    (1, 'compra'),
    (2, 'prestamo'),
    (3, 'tutoria');

INSERT INTO TIPO_OBJETIVO (id_tipo_objetivo, nombre) VALUES
    (1, 'publicacion'),
    (2, 'mensaje'),
    (3, 'usuario');

INSERT INTO MOTIVO (id_motivo, nombre) VALUES
    (1, 'incumple_normas'),
    (2, 'informacion_falsa'),
    (3, 'no_cumplio_fechas');

INSERT INTO ACCION (id_accion, nombre) VALUES
    (1, 'eliminacion'),
    (2, 'advertencia'),
    (3, 'suspension'),
    (4, 'bloqueo');

INSERT INTO DIA_SEMANA (id_dia_semana, nombre) VALUES
    (1, 'lunes'),
    (2, 'martes'),
    (3, 'miercoles'),
    (4, 'jueves'),
    (5, 'viernes'),
    (6, 'sabado'),
    (7, 'domingo');

-- Departamentos académicos de la UVG
INSERT INTO DEPARTAMENTO (id_departamento, nombre) VALUES
    (1, 'Matematica'),
    (2, 'Quimica'),
    (3, 'Informatica'),
    (4, 'Fisica'),
    (5, 'Biologia'),
    (6, 'Economia');

-- ============================================================
-- BLOQUE 9: DATOS DE EJEMPLO – USUARIOS Y ROLES
-- ============================================================

INSERT INTO CATEDRATICO (id_catedratico, nombre_catedratico) VALUES
    (1, 'Ing. Carlos Garcia'),
    (2, 'Dra. Maria Lopez'),
    (3, 'MSc. Roberto Fuentes');

INSERT INTO USUARIO (id_usuario, dpi, carnet, email_institucional, contrasena,
    url_foto_perfil, descripcion, telefono, calificacion_promedio, fecha_registro, id_estado_usuario) VALUES
    (1,  '1234567890101', '24770', 'jhernandez@uvg.edu.gt',  '$2b$12$hash1...', NULL, 'Estudiante de Informatica', '50212345678', 4.80, '2024-01-15', 1),
    (2,  '2345678901012', '24737', 'jgiron@uvg.edu.gt',      '$2b$12$hash2...', NULL, 'Me gusta la biologia',      '50223456789', 4.50, '2024-01-15', 1),
    (3,  '3456789012023', '24678', 'ajerez@uvg.edu.gt',      '$2b$12$hash3...', NULL, 'Tutor de calculo',         '50234567890', 4.90, '2024-01-20', 1),
    (4,  '4567890123034', '24979', 'jorozco@uvg.edu.gt',     '$2b$12$hash4...', NULL, 'Vendo materiales',         '50245678901', 4.20, '2024-02-01', 1),
    (5,  '5678901234045', '24880', 'orompich@uvg.edu.gt',    '$2b$12$hash5...', NULL, 'Emprendedor UVG',          '50256789012', 3.90, '2024-02-10', 1),
    (6,  '6789012345056', '24759', 'stan@uvg.edu.gt',        '$2b$12$hash6...', NULL, 'Moderador de la plataforma','50267890123', 5.00, '2024-01-01', 1);

INSERT INTO USUARIO_ROL (id_usuario, id_rol, fecha_asignacion) VALUES
    (1, 1, '2024-01-15'),   -- Josué: consumidor
    (1, 3, '2024-03-01'),   -- Josué: tutor
    (2, 1, '2024-01-15'),   -- Jackelyn: consumidor
    (3, 2, '2024-01-20'),   -- Alejandro: vendedor
    (3, 3, '2024-01-20'),   -- Alejandro: tutor
    (4, 2, '2024-02-01'),   -- Juan: vendedor
    (5, 5, '2024-02-10'),   -- Oscar: emprendedor
    (6, 4, '2024-01-01');   -- Sergio: moderador

-- ============================================================
-- BLOQUE 10: DATOS DE EJEMPLO – PUBLICACIONES
-- ============================================================

INSERT INTO CATEGORIA (id_categoria, nombre_categoria, id_categoria_padre) VALUES
    (1, 'Libros y Apuntes',     NULL),
    (2, 'Equipo de Laboratorio',NULL),
    (3, 'Ropa Universitaria',   NULL),
    (4, 'Calculo',              1),
    (5, 'Quimica General',      2),
    (6, 'Batas de Laboratorio', 3);

INSERT INTO PUBLICACION (id_publicacion, id_usuario, id_categoria, titulo, descripcion,
    precio, tipo, id_estado_publicacion, destacada, fecha_publicacion, fecha_actualizacion) VALUES
    (1, 3, 4, 'Libro Calculo Stewart 8va Edicion',    'Buen estado, subrayado en algunos capitulos', 150.00, 'venta',    1, 1, '2026-01-10 09:00:00', '2026-01-10 09:00:00'),
    (2, 4, 6, 'Bata de Laboratorio Talla M',          'Usada un semestre, sin manchas',               80.00, 'venta',    1, 0, '2026-01-20 10:30:00', '2026-01-20 10:30:00'),
    (3, 3, 4, 'Apuntes de Calculo Diferencial',       'Apuntes completos del semestre pasado',        30.00, 'venta',    1, 0, '2026-02-01 08:00:00', NULL),
    (4, 5, 5, 'Gafas de Seguridad',                   'Prestamo por el semestre, con deposito',       25.00, 'prestamo', 1, 0, '2026-02-05 11:00:00', NULL);

INSERT INTO FOTO_PUBLICACION (id_foto, id_publicacion, url_foto, orden) VALUES
    (1, 1, 'fotos/pub1_foto1.jpg', 1),
    (2, 1, 'fotos/pub1_foto2.jpg', 2),
    (3, 2, 'fotos/pub2_foto1.jpg', 1),
    (4, 3, 'fotos/pub3_foto1.jpg', 1);

INSERT INTO ANUNCIO_VENDEDOR (id_anuncio, id_usuario, contenido, fecha_publicacion, activo) VALUES
    (1, 3, '¡Vendo materiales de Ingenieria a buen precio! Libros, apuntes y mas.', '2026-01-10 08:00:00', 1),
    (2, 5, 'Emprendimiento UVG: kits de papeleria personalizados con tu carrera.', '2026-02-01 09:00:00', 1);

-- ============================================================
-- BLOQUE 11: DATOS DE EJEMPLO – TUTORIAS
-- ============================================================

-- Alejandro y Josué son tutores
INSERT INTO PERFIL_TUTOR (id_tutor, descripcion_servicio, precio_hora) VALUES
    (1, 'Tutor con experiencia en calculo y algebra lineal. Modalidad presencial y virtual.', 75.00),
    (3, 'Especialista en Calculo 1, 2 y 3. Ex-asistente de catedra.',                        90.00);

INSERT INTO CURSO (id_curso, nombre_curso, id_departamento) VALUES
    (1, 'Calculo Diferencial',  1),
    (2, 'Calculo Integral',     1),
    (3, 'Algebra Lineal',       1),
    (4, 'Quimica General 1',    2),
    (5, 'Programacion 1',       3);

INSERT INTO TUTOR_CURSO (id_tutor, id_curso) VALUES
    (1, 1), (1, 2), (1, 3),   -- Josué imparte Calc1, Calc2, Algebra
    (3, 1), (3, 2);            -- Alejandro imparte Calc1 y Calc2

INSERT INTO CERTIFICACION_TUTOR (id_certificacion, id_tutor, id_catedratico, descripcion, url_documento, fecha_emision) VALUES
    (1, 3, 1, 'Aval para tutoria de Calculo Diferencial e Integral', 'docs/cert_jerez_calc.pdf',  '2025-07-15'),
    (2, 1, 2, 'Aval para tutoria de Algebra Lineal',                 'docs/cert_hernandez_alg.pdf','2025-08-01');

INSERT INTO DISPONIBILIDAD_TUTOR (id_disponibilidad, id_tutor, id_dia_semana, hora_inicio, hora_fin) VALUES
    (1, 3, 1, '08:00', '10:00'),   -- Alejandro: lunes 8-10
    (2, 3, 3, '14:00', '17:00'),   -- Alejandro: miércoles 14-17
    (3, 1, 2, '10:00', '12:00'),   -- Josué: martes 10-12
    (4, 1, 4, '15:00', '18:00');   -- Josué: jueves 15-18

INSERT INTO SESION_TUTORIA (id_sesion, id_tutor, id_usuario, id_curso, fecha_sesion,
    hora_inicio, hora_fin, id_estado_sc, modalidad) VALUES
    (1, 3, 2, 1, '2026-03-10', '08:00', '10:00', 3, 'presencial'),  -- completada
    (2, 1, 4, 3, '2026-03-12', '10:00', '12:00', 2, 'virtual');     -- confirmada

-- ============================================================
-- BLOQUE 12: DATOS DE EJEMPLO – MENSAJERÍA
-- ============================================================

INSERT INTO CONVERSACION (id_conversacion, id_usuario_1, id_usuario_2, id_publicacion, id_sesion, fecha_inicio) VALUES
    (1, 2, 3, 1,    NULL, '2026-02-15 10:00:00'),   -- Jackelyn consulta libro de Alejandro
    (2, 4, 1, NULL, 2,    '2026-03-01 09:00:00');   -- Juan coordina sesión con Josué

INSERT INTO MENSAJE (id_mensaje, id_conversacion, id_emisor, contenido, fecha_envio, id_estado_mensaje) VALUES
    (1, 1, 2, 'Hola, ¿el libro tiene todos los ejercicios resueltos?',  '2026-02-15 10:01:00', 3),
    (2, 1, 3, 'Si, los capitulos 1 al 8 estan completamente resueltos.','2026-02-15 10:05:00', 3),
    (3, 1, 2, 'Perfecto, ¿puedo verlo antes de comprarlo?',             '2026-02-15 10:07:00', 2),
    (4, 2, 4, 'Hola Josue, ¿podemos confirmar la sesion del jueves?',   '2026-03-01 09:02:00', 3),
    (5, 2, 1, 'Claro, quedo confirmada a las 10am via Zoom.',            '2026-03-01 09:10:00', 3);

INSERT INTO ACUERDO_ENTREGA (id_acuerdo, id_conversacion, id_publicacion, id_sesion,
    lugar, fecha_acordada, hora_acordada, id_estado_sc) VALUES
    (1, 1, 1, NULL, 'Plaza Central UVG', '2026-02-20', '14:00', 1),  -- pendiente: ver libro
    (2, 2, NULL, 2, 'En linea (Zoom)',   '2026-03-12', '10:00', 2);  -- confirmada: sesion

-- ============================================================
-- BLOQUE 13: DATOS DE EJEMPLO – RESEÑAS
-- ============================================================

INSERT INTO RESENA (id_resena, id_evaluador, id_evaluado, calificacion, comentario,
    id_contexto, id_sesion, id_publicacion, fecha_resena) VALUES
    (1, 2, 3, 5, 'Excelente tutor, explica muy claro y es puntual.', 3, 1, NULL, '2026-03-11 08:00:00'),
    (2, 3, 2, 5, 'Estudiante muy comprometida y participativa.',      3, 1, NULL, '2026-03-11 09:00:00');

-- ============================================================
-- BLOQUE 14: DATOS DE EJEMPLO – MODERACIÓN
-- ============================================================

INSERT INTO REPORTE (id_reporte, id_reportante, id_tipo_objetivo, id_mensaje, id_publicacion,
    id_usuario, id_motivo, comentario, fecha_reporte, estado) VALUES
    (1, 2, 1, NULL, 4, NULL, 2, 'La descripcion del articulo no coincide con el objeto real.', '2026-02-10 14:00:00', 'resuelto'),
    (2, 1, 3, NULL, NULL, 4, 1, 'El usuario no cumplio con el acuerdo de entrega.', '2026-02-25 10:00:00', 'en_revision');

INSERT INTO ACCION_MODERACION (id_accion_moderacion, id_moderador, id_reporte, id_tipo_objetivo,
    id_mensaje, id_publicacion, id_usuario, id_accion, justificacion, fecha_accion) VALUES
    (1, 6, 1, 1, NULL, 4, NULL, 1, 'Publicacion eliminada por informacion falsa verificada.', '2026-02-11 09:00:00');

INSERT INTO REGLAMENTO (id_reglamento, contenido, version, id_moderador, fecha_vigencia) VALUES
    (1, 'Queda estrictamente prohibido publicar contenido falso, engañoso o que no corresponda al objeto real. El incumplimiento resultara en suspension de cuenta.',
     '1.0', 6, '2026-01-01'),
    (2, 'Los tutores deben contar con aval de al menos un catedratico para ofrecer tutoria en cursos de nivel 3 o superior.',
     '1.1', 6, '2026-02-01');

INSERT INTO PALABRA_PROHIBIDA (id_palabra, palabra, id_moderador, fecha_registro) VALUES
    (1, 'fraude',    6, '2026-01-05 08:00:00'),
    (2, 'estafa',    6, '2026-01-05 08:01:00'),
    (3, 'engano',    6, '2026-01-05 08:02:00'),
    (4, 'ilegal',    6, '2026-01-05 08:03:00');

-- ============================================================
-- FIN DEL SCRIPT
-- Motor: SQLite 3.x  |  PRAGMA foreign_keys = ON requerido
-- ============================================================