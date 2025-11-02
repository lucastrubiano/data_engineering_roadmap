-- Consulta de datos
SELECT name, price, location 
FROM listings;

-- Filtrar registros
SELECT name, price 
FROM listings 
WHERE price < 160;

-- Consulta con múltiples condiciones
SELECT name, location 
FROM listings 
WHERE price BETWEEN 100 AND 200
  AND location IN ('New York', 'Los Angeles');

-- Consulta con ordenamiento
SELECT name, price 
FROM listings 
ORDER BY price DESC;

-- Limitar el número de registros
SELECT name, price 
FROM listings 
ORDER BY price ASC 
LIMIT 1;