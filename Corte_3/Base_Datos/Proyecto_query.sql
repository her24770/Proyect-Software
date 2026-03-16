CREATE TABLE IF NOT EXISTS Usuario (
    id_usuario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    carnet INT UNIQUE NOT NULL,
    email_institucional VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    url_foto_perfil VARCHAR(255) NOT NULL,
    reportes_recibidos INT DEFAULT 0
);
CREATE TABLE IF NOT EXISTS Catedratico(
    id_catedratico INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_catedratico VARCHAR(100) NOT NULL,
    cargo_catedratico VARCHAR(100) NOT NULL
);
CREATE TABLE IF NOT EXISTS Etiqueta (
    id_etiqueta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    id_etiqueta_padre INTEGER REFERENCES Etiqueta (id_etiqueta)
);
CREATE TABLE IF NOT EXISTS PalabrasRestringidas (
    id_palabra INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    palabra VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE IF NOT EXISTS Perfil (
    id_perfil INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    calificacion INT NOT NULL CHECK (
        calificacion BETWEEN 0
        AND 5
    ) DEFAULT 0,
    id_usuario INTEGER NOT NULL REFERENCES Usuario (id_usuario),
    tiempo_suspendido INT NOT NULL DEFAULT 0,
	tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('consumidor', 'vendedor', 'tutor'))
);
CREATE TABLE IF NOT EXISTS Contactos (
    id_contacto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil (id_perfil),
    tipo_contacto VARCHAR(100) NOT NULL,
    valor VARCHAR(255) NOT NULL --Se eligió este tamaño para poder recibir enlaces
);
CREATE TABLE IF NOT EXISTS TiempoDisponible (
    id_tiempo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil (id_perfil),
    inicio_intervalo TIMESTAMP NOT NULL,
    fin_intervalo TIMESTAMP NOT NULL,
    estado VARCHAR(50) NOT NULL CHECK (estado IN ('disponible', 'reservado'))
);
CREATE TABLE IF NOT EXISTS Certificacion (
    id_certificacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil (id_perfil),
    ruta_pdf VARCHAR(255) NOT NULL,
    id_catedratico INTEGER NOT NULL REFERENCES Catedratico(id_catedratico),
    id_etiqueta INTEGER NOT NULL REFERENCES Etiqueta (id_etiqueta)
);
CREATE TABLE IF NOT EXISTS Anuncio (
    id_anuncio INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    imagen_url VARCHAR(255) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    id_perfil INTEGER NOT NULL REFERENCES Perfil (id_perfil)
);
CREATE TABLE IF NOT EXISTS Perfil_Etiqueta(
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    id_etiqueta INTEGER NOT NULL REFERENCES Etiqueta(id_etiqueta),
    PRIMARY KEY (id_perfil, id_etiqueta)
);
CREATE TABLE IF NOT EXISTS Publicacion(
    id_publicacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    precio FLOAT NOT NULL CHECK (precio >= 0.0) DEFAULT 0.0,
    estado VARCHAR(50) NOT NULL CHECK (
        estado IN (
            'prestado',
            'disponible',
            'vendido',
            'activo',
            'inactivo'
        )
    ),
    tipo_publicacion VARCHAR(50) NOT NULL CHECK (
        tipo_publicacion IN ('material', 'tutoria', 'negocio')
    ),
    me_gusta INT NOT NULL DEFAULT 0,
	fecha_publicacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil)
);
CREATE TABLE IF NOT EXISTS Imagen_Publicacion(
    id_imagen INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    url VARCHAR(255) NOT NULL,
    id_publicacion INTEGER NOT NULL REFERENCES Publicacion(id_publicacion)
);
CREATE TABLE IF NOT EXISTS Publicacion_Perfil(
    id_publicacion INTEGER NOT NULL REFERENCES Publicacion(id_publicacion),
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    PRIMARY KEY (id_publicacion, id_perfil)
);
CREATE TABLE IF NOT EXISTS Publicacion_Etiquetas(
    id_publicacion INTEGER NOT NULL REFERENCES Publicacion(id_publicacion),
    id_etiqueta INTEGER NOT NULL REFERENCES Etiqueta(id_etiqueta),
    PRIMARY KEY (id_publicacion, id_etiqueta)
);
CREATE TABLE IF NOT EXISTS Resena(
    id_resena INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    contenido VARCHAR(255) NOT NULL,
    calificacion INT NOT NULL DEFAULT 0,
    me_gusta INT NOT NULL DEFAULT 0,
    id_emisor INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    id_receptor INTEGER NOT NULL REFERENCES Perfil(id_perfil)
);
CREATE TABLE IF NOT EXISTS Conversacion(
    id_conversacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_perfil_1 INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    id_perfil_2 INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    estado_conversacion VARCHAR(50) NOT NULL CHECK (estado_conversacion IN ('activa', 'bloqueada')) DEFAULT 'activa'
);
CREATE TABLE IF NOT EXISTS Mensaje(
    id_mensaje INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_conversacion INTEGER NOT NULL REFERENCES Conversacion(id_conversacion),
    id_emisor INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    mensaje VARCHAR(255) NOT NULL,
    estado_mensaje VARCHAR(50) NOT NULL CHECK (estado_mensaje IN ('visto', 'no visto')),
    fecha_enviado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS Transaccion(
    id_transaccion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    id_publicacion INTEGER NOT NULL REFERENCES Publicacion(id_publicacion),
    fecha_adquirido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS Acuerdo(
    id_acuerdo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    id_publicacion INTEGER NOT NULL REFERENCES Publicacion(id_publicacion),
    fecha_entrega TIMESTAMP NOT NULL,
    lugar_entrega VARCHAR(100) NOT NULL,
    estado VARCHAR(50) NOT NULL CHECK (estado in ('pendiente', 'aceptado', 'hecho')) DEFAULT 'pendiente'
);
CREATE TABLE IF NOT EXISTS Tutoria(
    id_tutoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    id_publicacion INTEGER NOT NULL REFERENCES Publicacion(id_publicacion),
    id_tiempo INTEGER NOT NULL REFERENCES TiempoDisponible(id_tiempo),
    lugar VARCHAR(100) NOT NULL,
    estado VARCHAR(50) NOT NULL CHECK (estado in ('pendiente', 'aceptado', 'hecho')) DEFAULT 'pendiente'
);
CREATE TABLE IF NOT EXISTS Reporte(
    id_reporte INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_emisor INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    id_receptor INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    motivo VARCHAR(100) NOT NULL,
    observaciones VARCHAR(255) NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50) NOT NULL CHECK (estado IN ('pendiente', 'aceptada', 'denegada')) DEFAULT 'pendiente'
);
CREATE TABLE IF NOT EXISTS Notificacion(
    id_notificacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    mensaje VARCHAR(255) NOT NULL,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil),
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);