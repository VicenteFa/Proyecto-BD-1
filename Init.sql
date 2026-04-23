--Creacion de las tablas

CREATE TABLE IF NOT EXISTS Fabricantes (
    nombre_fabricante VARCHAR(50) PRIMARY KEY,
    pais VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS Estancos (
    nif_estanco VARCHAR(20) PRIMARY KEY,
    num_expendeduria INTEGER NOT NULL,
    cp_estanco VARCHAR(10) NOT NULL,
    nombre_estanco VARCHAR(50) NOT NULL,
    direccion_estanco VARCHAR(180) NOT NULL,
    localidad_estanco VARCHAR(80) NOT NULL,
    provincia_estanco VARCHAR(80) NOT NULL
);

CREATE TABLE IF NOT EXISTS Cigarrillos (
    marca VARCHAR(50) NOT NULL,
    filtro VARCHAR(20) NOT NULL,
    color VARCHAR(40) NOT NULL,
    clase VARCHAR(50) NOT NULL,
    mentol BOOLEAN NOT NULL,
    nicotina DECIMAL(7,2) NOT NULL,
    alquitran DECIMAL(7,2) NOT NULL,
    nombre_fabricante VARCHAR(80) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    precio_costo DECIMAL(10,2) NOT NULL,
    carton INTEGER NOT NULL,
    embalaje INTEGER NOT NULL,
    PRIMARY KEY (marca, filtro, color, clase, mentol),
    FOREIGN KEY (nombre_fabricante) REFERENCES Fabricantes(nombre_fabricante)
);

CREATE TABLE IF NOT EXISTS Almacenes (
    nif_estanco VARCHAR(20) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    filtro VARCHAR(20) NOT NULL,
    color VARCHAR(40) NOT NULL,
    clase VARCHAR(50) NOT NULL,
    mentol BOOLEAN NOT NULL,
    unidades INTEGER NOT NULL,
    PRIMARY KEY (nif_estanco, marca, filtro, color, clase, mentol),
    FOREIGN KEY (nif_estanco) REFERENCES Estancos(nif_estanco),
    FOREIGN KEY (marca, filtro, color, clase, mentol) REFERENCES Cigarrillos(marca, filtro, color, clase, mentol)
);

CREATE TABLE IF NOT EXISTS Compras (
    nif_estanco VARCHAR(20) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    filtro VARCHAR(20) NOT NULL,
    color VARCHAR(40) NOT NULL,
    clase VARCHAR(50) NOT NULL,
    mentol BOOLEAN NOT NULL,
    fecha_compra DATE NOT NULL,
    c_comprada INTEGER NOT NULL,
    precio_compra DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (nif_estanco, marca, filtro, color, clase, mentol, fecha_compra),
    FOREIGN KEY (nif_estanco, marca, filtro, color, clase, mentol) REFERENCES Almacenes(nif_estanco, marca, filtro, color, clase, mentol)
); 
-- HOLA

CREATE TABLE IF NOT EXISTS Ventas (
    nif_estanco VARCHAR(20) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    filtro VARCHAR(20) NOT NULL,
    color VARCHAR(40) NOT NULL,
    clase VARCHAR(50) NOT NULL,
    mentol BOOLEAN NOT NULL,
    fecha_venta DATE NOT NULL,
    c_vendida INTEGER NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (nif_estanco, marca, filtro, color, clase, mentol, fecha_venta),
    FOREIGN KEY (nif_estanco, marca, filtro, color, clase, mentol) REFERENCES Almacenes(nif_estanco, marca, filtro, color, clase, mentol)
);
