-- Sebastian Aguilera
-- Bryan Ortiz
-- Cinthya Robles

-- This script (idk what should it do)

-- Loading users, books and ratings
raw_users  = LOAD 'Test/BX-Users.csv' USING PigStorage(';') AS (id, location, age:int);
raw_books  = LOAD 'Test/BX-Books.csv' USING PigStorage(';') AS (isbn:chararray, title:chararray, author:chararray, year_publicated:chararray, publisher:chararray, imgS, imgM, imgL);
raw_ratings = LOAD 'Test/BX-Book-Ratings.csv' USING PigStorage(';') AS (user_id:chararray, book_id:chararray, rating:int);

-- Filtering Ratings 0
ratings = FILTER raw_ratings BY rating != 0;

-- Dropping URLs
books = FOREACH raw_books GENERATE isbn, title, author, year_publicated, publisher;

-- Doesn't work :c
query = FILTER books BY year_publicated eq '2003';

