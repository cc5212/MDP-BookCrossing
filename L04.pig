-- Sebastian Aguilera
-- Bryan Ortiz
-- Cinthya Robles

-- This script finds the actors/actresses with the highest number of good movies

raw_roles = LOAD 'hdfs://cm:9000/uhadoop/shared/imdb/imdb-stars.tsv' USING PigStorage('\t') AS (star, title, year, num, type, episode, billing, char, gender);
-- Later you can change the above file to 'hdfs://cm:9000/uhadoop/shared/imdb/imdb-stars.tsv' to see the full output

raw_ratings = LOAD 'hdfs://cm:9000/uhadoop/shared/imdb/imdb-ratings.tsv' USING PigStorage('\t') AS (dist, votes, score, title, year, num, type, episode);
-- Later you can change the above file to 'hdfs://cm:9000/uhadoop/shared/imdb/imdb-ratings.tsv' to see the full output

theatrical_roles = FILTER raw_roles BY type == 'THEATRICAL_MOVIE';
theatrical_ratings = FILTER raw_ratings BY type == 'THEATRICAL_MOVIE';
-- Filter category, we want only THEATRICAL MOVIES

stars = FOREACH theatrical_roles GENERATE CONCAT(title,'##',year,'##',num) AS id, star, gender;
ratings = FOREACH theatrical_ratings GENERATE CONCAT(title,'##',year,'##',num) AS id, votes, score;
-- We create a new relation, with the movie as "unique" id

good_movies = FILTER ratings BY votes >= 10001 AND score >= 7.8;
-- We count a movie as good if:
--   it has at least (>=) 10,001 votes (votes in raw_rating) 
--   it has a score >= 7.8 (score in raw_rating)

stars_gm = JOIN good_movies BY id FULL OUTER, stars BY id;
-- Crossing relations

stars_gm_red = FOREACH stars_gm GENERATE $0, $4, $5;
-- Now we reduce the columns to
--   Good Movie (could be null)
--   Star
--   Gender

stars_f = FILTER stars_gm_red BY gender == 'FEMALE';
-- Female stars

stars_m = FILTER stars_gm_red BY gender == 'MALE';
-- male stars

stars_fg = GROUP stars_f BY star;
stars_mg = GROUP stars_m BY star;
-- Grouped by star

stars_fc = FOREACH stars_fg GENERATE COUNT($1) AS count, group AS star;
stars_mc = FOREACH stars_mg GENERATE COUNT($1) AS count, group AS star;
-- count the # of movies by star

stars_fo = ORDER stars_fc BY count DESC;
stars_mo = ORDER stars_mc BY count DESC;
-- time to order!

STORE stars_fo INTO 'hdfs://cm:9000/uhadoop2020/group20/lab04-f/';
STORE stars_mo INTO 'hdfs://cm:9000/uhadoop2020/group20/lab04-m/';
-- Ready to store finally :)



-- Top 10 actors:
-- 23      Harris, Sam (II)            
-- 18      Stevens, Bert (I)           
-- 18      Miller, Harold (I)          
-- 16      O'Brien, William H.         
-- 16      Tovey, Arthur               
-- 16      Baker, Frank (I)            
-- 15      De Niro, Robert             
-- 15      Corrado, Gino               
-- 15      Kemp, Kenner G.             
-- 15      Sayre, Jeffrey

-- Top 10 actresses:
-- 28      Flowers, Bess               
-- 15      Lynn, Sherry (I)            
-- 12      McGowan, Mickie             
-- 9       Derryberry, Debi            
-- 9       Ridgeway, Suzanne           
-- 8       Marsh, Mae                  
-- 8       Astor, Gertrude             
-- 8       Newman, Laraine             
-- 8       Blanchett, Cate             
-- 7       Plowright, Hilda            

-- Random Results:
-- 9       DiCaprio, Leonardo  
-- 5       Ryder, Winona
-- 4       Monroe, Marilyn 