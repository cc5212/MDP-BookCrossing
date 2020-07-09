-- Sebastian Aguilera
-- Bryan Ortiz
-- Cinthya Robles

-- This script (idk what should it do)
-- Use DUMP to show data

-- Loading users, books and ratings
raw_users  = LOAD 'Datos/BX-Users.txt' USING PigStorage('\t') AS (user_id, location,age);
init_raw_books  = LOAD 'Datos/BX-Books.txt' USING PigStorage('\t') AS (isbn, title, author, year, publisher);
init_raw_ratings = LOAD 'Datos/BX-Book-Ratings.txt' USING PigStorage('\t') AS (user_id, isbn, rating);

-- ID's to Lowercase
raw_books = FOREACH init_raw_books GENERATE LOWER(isbn) as isbn, title, author, year, publisher;
raw_ratings = FOREACH init_raw_ratings GENERATE user_id, LOWER(isbn) AS isbn, rating;

-- Filtering Implicit Ratings (=0)
ratings = FILTER raw_ratings BY rating != 0; 

-- Group ratings by book
g_ratings = GROUP ratings BY isbn;
-- g_ratings: {group: bytearray,ratings: {(user_id: bytearray,isbn: bytearray,rating: bytearray)}}

-- Count number of votes per book
ratings_count = FOREACH g_ratings GENERATE group AS isbn, COUNT(ratings) AS count;
-- ratings_count: {isbn: bytearray,count: long}

-- Votes mean per book
ratings_mean = FOREACH g_ratings GENERATE group AS isbn, AVG(ratings.rating) AS mean;
-- ratings_mean: {isbn: bytearray,mean: double}

-- Ratings data Join (INNER)
ratings_join = JOIN ratings_mean BY isbn, ratings_count BY isbn;
-- ratings_join: {ratings_mean::isbn: bytearray,ratings_mean::mean: double,ratings_count::isbn: bytearray,ratings_count::count: long}

-- Deleting extra ISBN field and formatting
ratings_done = FOREACH ratings_join GENERATE $0 AS isbn, $1 AS mean, $3 AS votes;
-- ratings_done: {isbn: bytearray,mean: double,votes: long}

-- Join between Books and ratings (INNER)
books_ratings = JOIN raw_books BY isbn, ratings_done BY isbn;
-- books_ratings: {raw_books::isbn: bytearray,raw_books::title: bytearray,raw_books::author: bytearray,raw_books::year: bytearray,raw_books::publisher: bytearray,ratings_done::isbn: bytearray,ratings_done::mean: double,ratings_done::votes: long}

-- Deleting extra ISBN field and formatting
books_ratings_f = FOREACH books_ratings GENERATE $0 AS isbn, $1 AS title, $2 AS author, $3 AS year, $4 AS publisher, $6 AS mean, $7 AS votes;
-- books_ratings_f: {isbn: bytearray,title: bytearray,author: bytearray,year: bytearray,publisher: bytearray,mean: double,votes: long}


-- From here we could do multiple things.
-- We'll obtain the most popular authors and their best rated books


-- Group by author
grouped_books_ratings = GROUP books_ratings_f BY author;
-- grouped_books_ratings: {group: bytearray,books_ratings_f: {(isbn: bytearray,title: bytearray,author: bytearray,year: bytearray,publisher: bytearray,mean: double,votes: long)}}

-- Best book score per author
max_score = FOREACH grouped_books_ratings GENERATE group AS author, MAX(books_ratings_f.mean) AS max;
-- max_score: {author: bytearray,max: double}

-- Author average score
avg_score = FOREACH grouped_books_ratings GENERATE group AS author, AVG(books_ratings_f.mean) AS author_avg;
-- avg_score: {author: bytearray,author_avg: double}

-- Author total votes
total_votes = FOREACH grouped_books_ratings GENERATE group AS author, SUM(books_ratings_f.votes) AS total_votes;
-- total_votes: {author: bytearray,total_votes: long}

-- Join max score with books_ratings, giving all the books with that score
max_scored_books = JOIN books_ratings_f BY (author, mean), max_score BY (author, max);
-- max_scored_books: {books_ratings_f::isbn: bytearray,books_ratings_f::title: bytearray,books_ratings_f::author: bytearray,books_ratings_f::year: bytearray,books_ratings_f::publisher: bytearray,books_ratings_f::mean: double,books_ratings_f::votes: long,max_score::author: bytearray,max_score::max: double}

-- Concat book title with year
books_year_info = FOREACH max_scored_books GENERATE $2 AS author, CONCAT($1,' # ',$3) AS title_year, $5 AS rating;
-- books_year_info: {author: bytearray,title_year: chararray,rating: double}

-- Gouping by author
best_books_grouped = GROUP books_year_info BY author;
-- best_books_grouped: {group: bytearray,books_year_info: {(author: bytearray,title_year: chararray,rating: double)}}

-- Keeping only author, <books>
best_books = FOREACH best_books_grouped GENERATE group AS author, books_year_info.title_year;
-- best_books: {author: bytearray,{(title_year: chararray)}}

-- Join avg_score and total_votes
avg_total_max = JOIN avg_score BY author, total_votes BY author, max_score BY author;
-- avg_total_max: {avg_score::author: bytearray,avg_score::author_avg: double,total_votes::author: bytearray,total_votes::total_votes: long,max_score::author: bytearray,max_score::max: double}

-- Deleting extra fields and formatting
author_data = FOREACH avg_total_max GENERATE $0 AS author, $1 AS avg_score, $3 AS votes, $5 AS max;
-- author_data: {author: bytearray,avg_score: double,votes: long,max: double}

-- Join avg_total with info table
final_almost = JOIN best_books BY author, author_data BY author; 
-- final_almost: {best_books::author: bytearray,{(title_year: chararray)},author_data::author: bytearray,author_data::avg_score: double,author_data::votes: long,author_data::max: double}

-- Deleting extra fields and formatting
final = FOREACH final_almost GENERATE $0 AS author, $1 AS books, $5 AS best_score, $3 AS avg_score, $4 AS votes;
-- final: {author: bytearray,books: {(title_year: chararray)},best_score: double,avg_score: double,votes: long}

-- Deleting fields with few votes
final_filtered = FILTER final BY votes > 5;

-- Order by average score, and then by votes
final_ord = ORDER final_filtered BY avg_score DESC, votes DESC;

-- Output
out = RANK final_ord;

STORE out INTO 'out';


