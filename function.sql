-- Дана функція виводить назви фільмів, що мають рейтинг >= задному lower_bound_rating
-- станом на дату останнього оновлення рейтингу last_update_date.
-- Результати сортуються у порядку зростання рейтингу.
create or replace function get_movies(lower_bound_rating numeric(3, 1), last_update_date date) 
returns table (movie_title varchar(70), rating_value numeric(3, 1))
language plpgsql
as $$
	begin
		return query
			select series_title::varchar(70), value::numeric(3, 1)
			from movies inner join imdb_ratings
			using (movie_id)
			where update_date = last_update_date
			and value >= lower_bound_rating
			order by value asc;
	end;
$$;