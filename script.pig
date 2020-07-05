-- Sebastian Aguilera
-- Bryan Ortiz
-- Cinthya Robles

-- This script (idk what should it do)
-- Use DUMP to show data

-- Loading users, books and ratings
raw_users  = LOAD 'Datos/BX-Users.txt' USING PigStorage('\t') AS (id, location,age);
raw_books  = LOAD 'Datos/BX-Books.txt' USING PigStorage('\t') AS (isbn, title, author, year, publisher);
raw_ratings = LOAD 'Datos/BX-Book-Ratings.txt' USING PigStorage('\t') AS (user_id, book_id, rating);

-- Filtering Ratings 0
ratings = FILTER raw_ratings BY rating != 0; 

-- Group ratings by book
grouped_ratings = GROUP ratings BY isbn;

-- Count number of votes per book
ratings_count = FOREACH grouped_ratings GENERATE COUNT(user_id) AS count, GROUP AS isbn:
-- Votes mean per book
ratings_mean = FOREACH grouped_ratings GENERATE AVG(user_id) AS mean, GROUP AS isbn:
-- Ratings data Join (INNER)
ratings_join = JOIN ratings_mean BY isbn, ratings_count BY isbn;


-- Join between Books and ratings (INNER)
books_ratings = JOIN raw_books BY isbn, rating_join BY isbn;
-- Group by author
grouped_books_ratings = GROUP books_ratings BY author
-- Best book score per author
max_score = FOREACH grouped_ratings GENERATE MAX(mean) AS max, GROUP AS author;
-- Author average score
avg_score = FOREACH grouped_ratings GENERATE AVG(mean) AS book_avg, GROUP AS author;
-- Author total votes
total_votes = FOREACH grouped_ratings GENERATE SUM(count) AS total, GROUP AS author;


-- Join max score with books_ratings, giving all the books with that score
max_scored_books = JOIN grouped_books_ratings BY (author, mean), max_score BY (author, max);
-- Concat book title with year
books_year_info = FOREACH max_scored_books GENERATE author, CONCAT(title,' # ',year) AS title_year, max;
-- Concat every book by author

-- Join avg_score and total_votes
avg_total = JOIN avg_score BY author, total_votes BY author;
-- Join avg_total with info table
final = JOIN books_year_info BY author, avg_total BY author; 

-- This script (idk what should it do)

-- Loading users, books and ratings
raw_users  = LOAD 'Datos/BX-Users.txt' USING PigStorage('\t') AS (id, location,age);
raw_books  = LOAD 'Datos/BX-Books.txt' USING PigStorage('\t') AS (isbn, title, author, year, publisher);
raw_ratings = LOAD 'Datos/BX-Book-Ratings.txt' USING PigStorage('\t') AS (user_id, book_id, rating);


