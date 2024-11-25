
-- create type season_stats as (
--                         season INTEGER,
--                         gp INTEGER,
--                         pts REAL,
--                         reb REAL,
--                         ast REAL
--
--
--                         )

--  CREATE TYPE scoring_class as ENUM ('star','good','average','bad');
--
-- create table players  (
--     player_name   TEXT,
--     height TEXT,
--     college TEXT,
--     country TEXT,
--     draft_year TEXT,
--     draft_round TEXT,
--     draft_number TEXT,
--     season_stats season_stats[],
--     scoring_class scoring_class[],
--     years_since_last_season INTEGER,
--     current_season INTEGER,
--     primary key(player_name, current_season)
--
--
-- );



INSERT INTO players
with yesterday as
    (
        select * from players
        where current_season = 2000
    ),

    today as (
        select * from player_seasons
        where season = 2001
    )

select coalesce(t.player_name,y.player_name) as player_name,
       coalesce(t.height,y.height) as height,
       coalesce(t.college,y.college) as college,
       coalesce(t.country,y.country) as country,
       coalesce(t.draft_year,y.draft_year) as draft_year,
       coalesce(t.draft_round,y.draft_round) as draft_round,
       coalesce(t.draft_number,y.draft_number) as draft_number,
       case when season_stats is null
           then ARRAY[ROW(
               t.season,
               t.gp,
               t.pts,
               t.reb,
               t.ast
               )::season_stats]
       when t.season is not null then y.season_stats || ARRAY[ROW(
           t.season,
           t.gp,
           t.pts,
           t.reb,
           t.ast
           )::season_stats]
       else y.season_stats
       END as season_stats,
       CASE WHEN t.season is not null then
                ARRAY[
                case when t.pts > 20 then 'star'
                when t.pts > 15 then 'good'
                when t.pts > 10 then 'average'
                else 'bad'
            END::scoring_class]
            else y.scoring_class
        end as scoring_class,
        case
            when t.season is not null then 0
            else y.years_since_last_season + 1
        end as years_since_last_season,
       coalesce(t.season, y.current_season + 1) as current_season

from today t
full outer join yesterday y
on t.player_name = y.player_name




-- with unnested as (select player_name,
--                          unnest(season_stats)::season_stats as season_stats
--                   from players
--                   where current_season = 2001
--                     and player_name = 'Michael Jordan')
--
-- select player_name, (season_stats::season_stats).*
-- from unnested

select * from players
where current_season = 2000
and player_name = 'Michael Jordan'