# Overall Homecourt Advantage
SELECT nba_elo.game_location
, home_games.wins
, count(game_id)
, (home_games.wins/count(game_id))*100 as homecourt_win_r
FROM nba_elo
JOIN (
    SELECT game_location, game_result, count(game_id) as wins
    FROM nba_elo
    WHERE is_copy is FALSE
    AND game_location != 'N'
    AND game_result != 'L'
    GROUP BY game_location, game_result
) as home_games ON nba_elo.game_location = home_games.game_location
WHERE
is_copy is FALSE
AND nba_elo.game_location = 'H'
GROUP BY nba_elo.game_location, home_games.wins;

# Yearly Homecourt Advantage
SELECT breakdown.year_id
     , game_location
     , game_result
     , count(game_id)
     , tg.total_games
     , (count(game_id) / tg.total_games)*100 as win_ratio
     FROM nba_elo as breakdown
     JOIN (
         SELECT year_id
         , count(game_id) as total_games
         FROM nba_elo
         where is_copy is FALSE
         AND game_location != 'N'
         GROUP BY year_id
     ) as tg ON breakdown.year_id = tg.year_id
     WHERE is_copy is FALSE
     AND game_location = 'H'
     AND game_result = 'W'
     GROUP BY year_id, game_location, game_result, tg.total_games
     ORDER BY win_ratio DESC;

# By Franchise
SELECT breakdown.franchise_id
     , game_location
     , game_result
     , count(game_id)
     , tg.total_games
     , (count(game_id) / tg.total_games)*100 as win_ratio
     FROM nba_elo as breakdown
     JOIN (
         SELECT franchise_id
         , count(game_id) as total_games
         FROM nba_elo
         where is_copy is FALSE
         AND game_location != 'N'
         GROUP BY franchise_id
     ) as tg ON breakdown.franchise_id = tg.franchise_id
     WHERE is_copy is FALSE
     AND game_location = 'H'
     AND game_result = 'W'
     GROUP BY franchise_id, game_location, game_result, tg.total_games
     HAVING tg.total_games > 250
     ORDER BY win_ratio DESC;

