-- Дана тригерна функція при вставленні нового рядка у таблицю movies створює рейтинг цього фільму.
-- Додається рейтинг в таблицю imdb_ratings, де величина imdb рейтингу - середнє арифметичне всіх
-- таких величин з інших рейтингів; кількість голосів - середнє арифметичне голосів зі всіх інших
-- рейтингів, округлене до цілого; дата оновлення - дата спрацювання тригеру (current_date);
-- metascore залишається null; movie_id відповідає доданому в movie рядку.
create or replace function insert_rating()
returns trigger
language plpgsql
as $$
	declare
		new_rating_id       imdb_ratings.rating_id%type;
		new_value           imdb_ratings.value%type;
		new_number_of_votes imdb_ratings.number_of_votes%type;
	begin
		select max(rating_id) + 1 into new_rating_id
		from imdb_ratings;
		
		select cast(round(avg(value), 1) as numeric(3, 1)) into new_value
		from imdb_ratings;
		
		select cast(trunc(avg(number_of_votes)) as integer) into new_number_of_votes
		from imdb_ratings;
		
		insert into imdb_ratings (rating_id, value, number_of_votes, update_date, metascore, movie_id)
		values (new_rating_id, new_value, new_number_of_votes, current_date, null, new.movie_id);
		
		return null;
	end;
$$;

drop trigger if exists movie_on_insert on movies;
-- Даний тригер спрацьовує після додавання рядку в таблицю movies.
create trigger movie_on_insert
after insert
on movies
for each row
execute function insert_rating();