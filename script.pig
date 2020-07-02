-- Sebastian Aguilera
-- Bryan Ortiz
-- Cinthya Robles

-- This script (idk what should it do)
-- Charging users, books and ratings
users  = LOAD 'Datos/BX-Users.csv' USING PigStorage(';') AS (id, location, age);
books  = LOAD 'Datos/BX-Books.csv' USING PigStorage(';') AS (isbn, title, author, year_publicated, publisher);
ratings = LOAD 'Datos/BX-Book-Ratings.csv' USING PigStorage(';') AS (user_id, book_id, rating);