# Test Query:
SELECT game_order
, game_id
, date_game
, season_game
, team_id
, franchise_id
, points
, opp_team_id
, opp_franchise_id
, opp_points
, game_location
, game_result 
FROM nba_elo 
WHERE is_copy is FALSE
LIMIT 20;

SELECT year_id
, is_playoffs
, game_location
, game_result
, count(game_id)
FROM nba_elo 
WHERE is_copy is FALSE
GROUP BY year_id, game_location, is_playoffs, game_result;

(SELECT year_id
, count(game_id)
FROM nba_elo
where is_copy is FALSE
GROUP BY year_id) as total_games;

SELECT breakdown.year_id
, is_playoffs
, game_location
, game_result
, count(game_id)
, tg.total_games
FROM nba_elo as breakdown
JOIN (
    SELECT year_id
    , count(game_id) as total_games
    FROM nba_elo
    where is_copy is FALSE
    GROUP BY year_id
) as tg ON breakdown.year_id = tg.year_id
WHERE is_copy is FALSE
GROUP BY year_id, game_location, is_playoffs, game_result, tg.total_games;