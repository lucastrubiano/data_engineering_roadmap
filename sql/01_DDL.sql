-- listings: alojamientos o propiedades que están publicadas o listadas en Airbnb.
CREATE TABLE listings (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    host_id INTEGER,
    price DECIMAL(10, 2),
    location VARCHAR(50),
    availability INTEGER
);

-- users: usuarios registrados en Airbnb que reservan alojamientos.
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100),
    join_date DATE
);

-- reservations: reservas de alojamientos realizadas por los usuarios.
CREATE TABLE reservations (
    id INTEGER PRIMARY KEY,
    listing_id INTEGER,
    user_id INTEGER,
    start_date DATE,
    end_date DATE,
    total_price DECIMAL(10, 2),
    FOREIGN KEY (listing_id) REFERENCES listings(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Agregar una columna
ALTER TABLE listings ADD COLUMN rating DECIMAL(3, 2);

-- Eliminar una tabla
DROP TABLE reservations;