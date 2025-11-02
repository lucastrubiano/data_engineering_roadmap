-- Cargar datos de listings
INSERT INTO listings(id, name, host_id, price, location, availability)
VALUES
(1, 'Cozy Apartment Downtown', 101, 120.00, 'New York', 30),
(2, 'Beach House', 102, 200.00, 'Los Angeles', 15),
(3, 'Mountain Cabin', 103, 150.00, 'Denver', 60);

-- Cargar datos de users
INSERT INTO users(id, name, email, join_date)
VALUES
(1, 'John Doe', 'john@example.com', '2021-01-10'),
(2, 'Jane Smith', 'jane@example.com', '2021-02-15'),
(3, 'Mike Brown', 'mike@example.com', '2021-03-20');

-- Cargar datos de reservations
INSERT INTO reservations(id, listing_id, user_id, start_date, end_date, total_price)
VALUES
(1, 1, 2, '2023-01-01', '2023-01-05', 480.00),
(2, 3, 1, '2023-01-10', '2023-01-15', 750.00),
(3, 2, 3, '2023-02-01', '2023-02-03', 400.00);

-- Actualizar el precio de un alojamiento
UPDATE listings 
SET price = 130.00 
WHERE id = 1;

-- Actualizar múltiples campos
UPDATE listings 
SET availability = availability - 5, 
    price = price * 1.05;

-- Eliminar un registro específico
DELETE FROM listings 
WHERE location = 'Denver';

-- Eliminar todos los registros
DELETE FROM listings;