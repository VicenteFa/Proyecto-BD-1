-- Creacion de las tablas

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

---- 1. Caracteristicas de los cigarrilos que se estan comprando dentro de una fecha acotada
EXPLAIN ANALYZE SELECT 
    c.fecha_compra, 
    c.c_comprada, 
    c.precio_compra,
    cig.marca, 
    cig.clase, 
    cig.mentol,
    cig.nicotina,          
    cig.nombre_fabricante   
FROM Compras c, Cigarrillos cig
WHERE c.fecha_compra BETWEEN '2024-03-01' AND '2024-03-31'
  AND c.marca = cig.marca 
  AND c.filtro = cig.filtro 
  AND c.color = cig.color 
  AND c.clase = cig.clase 
  AND c.mentol = cig.mentol;

---- 2. Fabricantes y paises que se les esta comprando los cigarrillos
EXPLAIN ANALYZE SELECT 
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

-- 3. Cantidad de stock que tienen los estancos en el almacen de la pronvincia 'Provincia 1 Chile'
EXPLAIN ANALYZE SELECT 
    e.nombre_estanco, 
    e.localidad_estanco, 
    e.provincia_estanco,
    a.marca, 
    a.unidades
FROM Almacenes a, Estancos e
WHERE e.provincia_estanco = 'Provincia 1 Chile' 
   AND a.nif_estanco = e.nif_estanco

-- Metodos de optimizacion, indice y otras alternativas. Punto 3 

---- Creacion de indices para la informacion de los cigarrillos dentro de compras y ventas
CREATE INDEX idx_compras_fk_cigarrillos ON Compras(marca,filtro,color,clase,mentol);
CREATE INDEX idx_ventas_fk_cigarrillos ON Ventas(marca,filtro,color,clase,mentol);

---- Creacion de indice para la cantidad de stock que tienen los estancos
CREATE INDEX idx_fk_almacenes_estanco_unidades ON Almacenes (nif_estanco) INCLUDE (unidades, marca);

---- Creacion de los indices para mejorar las consultas por fecha
CREATE INDEX idx_ventas_fecha ON Ventas(fecha_venta);
CREATE INDEX idx_compras_fecha ON Compras(fecha_compra);

---- Creacion del indice para filtrar estancos por ubicacion
CREATE INDEX idx_estancos_ubicacion ON Estancos (provincia_estanco, localidad_estanco);

---- Creacion de indice para busqueda de un fabricante por su nombre exacto
CREATE INDEX idx_hash_fabricante ON Fabricantes USING HASH (nombre_fabricante);


-- Consultas optimizadas utilizando JOIN y metodos heuristicos. Punto 5

---- consulta 1
EXPLAIN ANALYZE SELECT 
    c.fecha_compra, 
    c.c_comprada, 
    c.precio_compra,
    cig.marca, 
    cig.clase, 
    cig.mentol,
    cig.nicotina,           
    cig.nombre_fabricante   
FROM Compras c
 JOIN Cigarrillos cig 
    ON c.marca = cig.marca 
   AND c.filtro = cig.filtro 
   AND c.color = cig.color 
   AND c.clase = cig.clase 
   AND c.mentol = cig.mentol
WHERE c.fecha_compra BETWEEN '2024-03-01' AND '2024-03-31';

---- consulta 2
EXPLAIN ANALYZE SELECT 
    c.fecha_compra, 
    c.c_comprada, 
    cig.marca, 
    f.nombre_fabricante, 
    f.pais
FROM Fabricantes f
INNER JOIN Cigarrillos cig 
    ON f.nombre_fabricante = cig.nombre_fabricante
INNER JOIN Compras c 
    ON cig.marca = c.marca 
   AND cig.filtro = c.filtro 
   AND cig.color = c.color 
   AND cig.clase = c.clase 
   AND cig.mentol = c.mentol;
   
---- consulta 3
EXPLAIN ANALYZE SELECT 
    e.nombre_estanco, 
    e.localidad_estanco, 
    e.provincia_estanco,
    a.marca, 
    a.unidades
FROM Estancos e
 JOIN Almacenes a 
    ON e.nif_estanco = a.nif_estanco
WHERE e.provincia_estanco = 'Provincia 1 Chile';

-- Nueva version de la base de datos considerando la desnormalizacion. Punto 6

---- Creacion de una nueva tabla desnormalizada Compras_cig_fabr_Consultas
CREATE TABLE IF NOT EXISTS Compras_cig_fabr_Consultas (
    fecha_compra DATE NOT NULL,
    c_comprada INTEGER NOT NULL,
    precio_compra DECIMAL(10,2) NOT NULL,
    
    nif_estanco VARCHAR(20) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    filtro VARCHAR(20) NOT NULL,
    color VARCHAR(40) NOT NULL,
    clase VARCHAR(50) NOT NULL,
    mentol BOOLEAN NOT NULL,

    nicotina DECIMAL(7,2) NOT NULL,
    nombre_fabricante VARCHAR(80) NOT NULL,
    pais VARCHAR(60) NOT NULL
);
---- Insercion de los datos a la tabla Compras_cig_fabr_Consultas
INSERT INTO Compras_cig_fabr_Consultas (
    fecha_compra, c_comprada, precio_compra,
    nif_estanco, marca, filtro, color, clase, mentol,
    nicotina, nombre_fabricante, pais
)
SELECT 
    c.fecha_compra, c.c_comprada, c.precio_compra,
    c.nif_estanco, c.marca, c.filtro, c.color, c.clase, c.mentol,
    cig.nicotina, f.nombre_fabricante, f.pais
FROM Compras c, Cigarrillos cig, Fabricantes f
WHERE c.marca = cig.marca 
  AND c.filtro = cig.filtro 
  AND c.color = cig.color 
  AND c.clase = cig.clase 
  AND c.mentol = cig.mentol
  AND cig.nombre_fabricante = f.nombre_fabricante;
  
---- Creacion de una nueva tabla desnormalizada para la consulta 3 Almacenes_estan_Consultas
CREATE TABLE IF NOT EXISTS Almacenes_estan_Consultas (
    marca VARCHAR(50) NOT NULL,
    filtro VARCHAR(20) NOT NULL,
    color VARCHAR(40) NOT NULL,
    clase VARCHAR(50) NOT NULL,
    mentol BOOLEAN NOT NULL,
    unidades INTEGER NOT NULL,

    nif_estanco VARCHAR(20) NOT NULL,
    nombre_estanco VARCHAR(50) NOT NULL,
    localidad_estanco VARCHAR(80) NOT NULL,
    provincia_estanco VARCHAR(80) NOT NULL
);
---- Insercion de los datos a la tabla Almacenes_estan_Consultas
INSERT INTO Almacenes_estan_Consultas (
    marca, filtro, color, clase, mentol, unidades,
    nif_estanco, nombre_estanco, localidad_estanco, provincia_estanco
)
SELECT 
    a.marca, a.filtro, a.color, a.clase, a.mentol, a.unidades,
    e.nif_estanco, e.nombre_estanco, e.localidad_estanco, e.provincia_estanco
FROM Almacenes a, Estancos e
WHERE a.nif_estanco = e.nif_estanco;

---- Consulta 1 sobre la tabla Compras_cig_fabr_Consultas con sus respectivos datos 
EXPLAIN ANALYZE SELECT 
    fecha_compra, 
    c_comprada, 
    precio_compra,
    marca, 
    clase, 
    mentol,
    nicotina,          
    nombre_fabricante   
FROM Compras_cig_fabr_Consultas
WHERE fecha_compra BETWEEN '2024-03-01' AND '2024-03-31';

---- Consulta 2 sobre la tabla Compras_cig_fabr_Consultas con sus respectivos datos 
EXPLAIN ANALYZE SELECT 
    fecha_compra, 
    c_comprada, 
    marca, 
    nombre_fabricante, 
    pais
FROM Compras_cig_fabr_Consultas;

---- Consulta 3 sobre la tabla Almacenes_estan_Consultas con sus respectivos datos 
EXPLAIN ANALYZE SELECT 
    nombre_estanco, 
    localidad_estanco, 
    provincia_estanco,
    marca, 
    unidades
FROM Almacenes_estan_Consultas
WHERE provincia_estanco = 'Provincia 1 Chile';

---- RECREACION DE LOS INDICES
---- Creacion de indice para mejorar las consultas por fecha en la tabla desnormalizada
CREATE INDEX idx_desnorm_compras_fecha ON Compras_cig_fabr_Consultas(fecha_compra);
---- Creacion de indice compuesto y de cobertura para la busqueda por provincia y localidad
CREATE INDEX idx_desnorm_almacenes_ubicacion ON Almacenes_estan_Consultas (provincia_estanco, localidad_estanco) INCLUDE (nombre_estanco, marca, unidades);
---- Creacion de indice Hash para busqueda exacta de fabricante en compras
CREATE INDEX idx_desnorm_hash_fabricante ON Compras_cig_fabr_Consultas USING HASH (nombre_fabricante);
