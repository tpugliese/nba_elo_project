# [1] Overall Homecourt Advantage
SELECT n_e.game_location
, home_games.wins
, count(game_id)
, (home_games.wins/count(game_id))*100 as homecourt_win_r
FROM nba_elo as n_e
JOIN (
    SELECT game_location, game_result, count(game_id) as wins
    FROM nba_elo
    WHERE is_copy is FALSE
    AND game_location != 'N'
    AND game_result != 'L'
    GROUP BY game_location, game_result
) as home_games ON n_e.game_location = home_games.game_location
WHERE is_copy is FALSE
AND n_e.game_location = 'H'
GROUP BY n_e.game_location, home_games.wins;

# [2] Yearly Homecourt Advantage
SELECT n_e.year_id
, game_location
, game_result
, count(game_id)
, tg.total_games
, (count(game_id) / tg.total_games)*100 as win_ratio
FROM nba_elo as n_e
JOIN (
    SELECT year_id
    , count(game_id) as total_games
    FROM nba_elo
    where is_copy is FALSE
    AND game_location != 'N'
    GROUP BY year_id
) as tg ON n_e.year_id = tg.year_id
WHERE is_copy is FALSE
AND game_location = 'H'
AND game_result = 'W'
GROUP BY year_id, game_location, game_result, tg.total_games
ORDER BY win_ratio DESC;