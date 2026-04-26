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

-- Consultas

-- 1. Caracteristicas de los cigarrilos que se estan comprando
SELECT 
    c.fecha_compra, 
    c.c_comprada, 
    c.precio_compra,
    cig.marca, 
    cig.clase, 
    cig.mentol
FROM Compras c, Cigarrillos cig
WHERE c.marca = cig.marca 
  AND c.filtro = cig.filtro 
  AND c.color = cig.color 
  AND c.clase = cig.clase 
  AND c.mentol = cig.mentol;

-- 2. Caracteristicas de los cigarrillos que se estan vendidos dentro de una fecha acotada
SELECT 
    v.fecha_venta, 
    v.c_vendida, 
    v.precio_venta,
    cig.marca, 
    cig.clase, 
    cig.mentol
FROM Ventas v, Cigarrillos cig
WHERE v.marca = cig.marca 
  AND v.filtro = cig.filtro 
  AND v.color = cig.color 
  AND v.clase = cig.clase 
  AND v.mentol = cig.mentol
  AND v.fecha_venta BETWEEN '2024-03-01' AND '2024-03-31';

-- 3. Fabricantes y paises que se les esta comprando los cigarrillos
SELECT 
    c.fecha_compra, 
    c.c_comprada, 
    cig.marca, 
    f.nombre_fabricante, 
    f.pais
FROM Compras c, Cigarrillos cig, Fabricantes f
WHERE c.marca = cig.marca 
  AND c.filtro = cig.filtro 
  AND c.color = cig.color 
  AND c.clase = cig.clase 
  AND c.mentol = cig.mentol
  AND cig.nombre_fabricante = f.nombre_fabricante;

-- 4. Cantidad de stock que tienen los estancos en el almacen de la pronvincia 'Provincia 1 Chile'
SELECT 
    e.nombre_estanco, 
    e.localidad_estanco, 
    e.provincia_estanco,
    a.marca, 
    a.unidades
FROM Almacenes a, Estancos e
WHERE a.nif_estanco = e.nif_estanco
  AND e.provincia_estanco = 'Provincia 1 Chile';

-- Metodos de optimizacion, indice y otras alternativas. Punto 3 
