-- Дана процедура створює нову частину заданого за prev_movie_id фільму.
-- Нова частина матиме номер chapter.
-- Додється рядок з новою частиною фільму в таблицю movies: стара назва доповнюється текстом про нову частину,
-- рік виходу збільшується випадково на ціле число з інтервалу [5;10], тривалість фільму є випадковим цілим числом
-- з інтервалу [70;150], до огляду додається текст про нову частину, сертифікат, режисер та збори зберігаються.
-- Додаєтся рядок відношення нової частини фільму та жанру у таблицю movie_has_genre:
-- id жанру обирається як id одного з жанрів заданого як аргументу фільму.
create or replace procedure create_new_movie_chapter(prev_movie_id integer, chapter integer)
language plpgsql
as $$
	declare
		new_movie_id      movies.movie_id%type;
		new_series_title  movies.series_title%type;
		new_released_year movies.released_year%type;
		new_certificate   movies.certificate%type;
		new_runtime       movies.runtime%type;
		new_overview      movies.overview%type;
		new_director      movies.director%type;
		new_gross         movies.gross%type;
		new_genre_id      genres.genre_id%type;
	begin
		select max(movie_id) + 1 into new_movie_id
		from movies;
		
		select concat(series_title, ': chapter ', chapter) into new_series_title
		from movies
		where movie_id = prev_movie_id;
		
		select released_year + cast(trunc(random() * (10 - 5 + 1) + 5) as integer) into new_released_year
		from movies
		where movie_id = prev_movie_id;
		
		new_runtime := cast(trunc(random() * (150 - 70 + 1) + 70) as integer);
		
		select concat(overview, ' But it''s chapter ', chapter, '!') into new_overview
		from movies
		where movie_id = prev_movie_id;
		
		select certificate, director, gross into new_certificate, new_director, new_gross
		from movies
		where movie_id = prev_movie_id;
		
		insert into movies (movie_id, series_title, released_year, certificate, runtime, overview, director, gross)
		values (new_movie_id, new_series_title, new_released_year, new_certificate,
				new_runtime, new_overview, new_director, new_gross);
				
		select genre_id into new_genre_id
		from movie_has_genre
		where movie_id = prev_movie_id
		limit 1;
		
		insert into movie_has_genre (genre_id, movie_id)
		values (new_genre_id, new_movie_id);
	end;
$$;