-- Sebastian Aguilera
-- Bryan Ortiz
-- Cinthya Robles

-- This script (idk what should it do)

-- Loading users, books and ratings
raw_users  = LOAD 'Test/BX-Users.csv' USING PigStorage(';') AS (id, location, age);
raw_books  = LOAD 'Test/BX-Books.csv' USING PigStorage(';') AS (isbn, title, author, year_publicated, publisher, imgS, imgM, imgL);
raw_ratings = LOAD 'Test/BX-Book-Ratings.csv' USING PigStorage(';') AS (user_id, book_id, rating);

-- Filtering Ratings 0
ratings = FILTER raw_ratings BY (rating matches '.*Book Rating.*');