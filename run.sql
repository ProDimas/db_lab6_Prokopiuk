-- Функція
-- Має вивести 3 фільми: 
-- 'Shrek 2' з оцінкою 7.3; 
-- 'Spider-Man' з оцінкою 7.4; 
-- 'Indiana Jones and the Temple of Doom' з оцінкою 7.5
select * from get_movies(7.2, '2021-02-01');

-- Процедура
-- Її треба демонструвати до створення тригера (інакше він повпливає на результат)
do $$
	declare
		movie_title movies.series_title%type;
		id          movies.movie_id%type;
		new_chapter integer;
	begin
        -- Тут спочатку записуємо назву фільму, до якого хочемо зняти нову частину
		movie_title := 'Spider-Man';
        -- Знаходимо id цього фільму за його назвою
		select movie_id into id
		from movies
		where series_title = movie_title;
		
        -- Записуємо номер нової частини
		new_chapter := 2;
		
        -- Створюємо нову частину додаючи інформацію про неї в таблиці movies та movie_has_genre
		call create_new_movie_chapter(id, new_chapter);
	end;
$$;

-- Виводимо оновлені таблиці:
-- Для movies має вивести новий рядок з назвою фільму 'Spider-Man: chapter 2';
-- Для movie_has_genre має вивести новий рядок з деяким genre_id при movie_id = 6
select * from movies;
select * from movie_has_genre;

-- Видаляємо додані рядки з таблиць movies та movie_has_genre за id доданого процедурою фільму
delete from movie_has_genre
where movie_id = 
(
	select max(movie_id)
	from movies
);

delete from movies
where movie_id = 
(
	select max(movie_id)
	from movies
);

-- Тригер
-- Для демонстрації коректної роботи тригера, скористаємось раніше написаною процедурою create_new_movie_chapter
-- Тут додамо 4 частину фільму з movie_id = 2 (Це фільм з назвою Pirates of the Caribbean: Dead Men Tell No Tales)
call create_new_movie_chapter(2, 4);

-- Має з'явитися рядок з новим рейтингом для фільму з movie_id = 6
select * from imdb_ratings;

-- Видаляємо додані рядки з таблиць movies, movie_has_genre та imdb_ratings за id доданого процедурою фільму
delete from movie_has_genre
where movie_id = 
(
	select max(movie_id)
	from movies
);

delete from imdb_ratings
where movie_id = 
(
	select max(movie_id)
	from movies
);

delete from movies
where movie_id = 
(
	select max(movie_id)
	from movies
);