# [1] Test Query:
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

# [2] Informational Count:
SELECT count(distinct game_id) num_games
, min(date_game) as _from
, max(date_game) as _to 
FROM nba_elo;

# [3] GSW Season
SELECT team_id
, is_playoffs
, game_result
, count(distinct game_id)
FROM nba_elo 
WHERE team_id = 'GSW' 
AND game_result = 'W'
AND year_id = 2015
GROUP BY team_id, is_playoffs, game_result;

# [4] Decade Query
SELECT CONCAT(LEFT(year_id, 3), "0's") as decade
, count(DISTINCT game_id) as num_games
, count(DISTINCT franchise_id) as num_franchises
, count(DISTINCT game_id)/count(DISTINCT year_id) as num_games_in_season
 FROM nba_elo 
 GROUP BY decade;
 
# [5] Draft of Homecourt Advantage
SELECT year_id
, is_playoffs
, game_location
, game_result
, count(game_id)
FROM nba_elo 
WHERE is_copy is FALSE
AND game_location NOT IN ('H', 'A')
GROUP BY year_id, game_location, is_playoffs, game_result;

# [6] Home-court Definition
SELECT game_location, game_result, is_copy, count(distinct game_id)
FROM nba_elo
WHERE is_copy = FALSE
and game_location != 'N'
and game_result != 'L'
GROUP BY game_location, game_result, is_copy;

# [7] Draft of ELO Win Rate
SELECT game_id
, date_game
, franchise_id
, elo_enter
, opp_franchise_id
, opp_elo_enter
, game_result
, forecast
, CASE 
    WHEN elo_enter < opp_elo_enter THEN 'Underdog'
    WHEN elo_enter > opp_elo_enter THEN 'Favorite'
    ELSE 'Equal'
END as class_underdog
, (elo_enter - opp_elo_enter) as _underdog

FROM nba_elo
WHERE is_copy is FALSE
AND is_playoffs is TRUE
AND elo_enter < opp_elo_enter
ORDER BY _underdog ASC;

# [8] Query to get List of All Playoff Games & ELO
SELECT 
play_under.class_underdog
, n_e.game_result
, count(play_under.game_id)
, play_total.total_playoff
, (count(play_under.game_id) / play_total.total_playoff)*100 as win_ratio
, avg(play_under.metric_underdog)
, avg(play_under.elo_diff)
FROM nba_elo as n_e
INNER JOIN (
    SELECT game_id
    , date_game
    , franchise_id
    , elo_enter
    , opp_franchise_id
    , opp_elo_enter
    , game_result
    , forecast
    , CASE 
        WHEN elo_enter < opp_elo_enter THEN 'Underdog'
        WHEN elo_enter > opp_elo_enter THEN 'Favorite'
        ELSE 'Equal'
    END as class_underdog
    , (elo_enter - opp_elo_enter) as metric_underdog
    , (elo_enter - elo_leave) as elo_diff   
    FROM nba_elo
    WHERE is_copy is FALSE
    AND is_playoffs is TRUE
) as play_under ON n_e.game_id = play_under.game_id
INNER JOIN (
    SELECT
    CASE 
        WHEN elo_enter < opp_elo_enter THEN 'Underdog'
        WHEN elo_enter > opp_elo_enter THEN 'Favorite'
        ELSE 'Equal'
    END as class_underdog
    , count(game_id) as total_playoff
    FROM nba_elo
    WHERE is_copy is FALSE
    AND is_playoffs is TRUE
    GROUP BY class_underdog
) as play_total ON play_under.class_underdog = play_total.class_underdog
WHERE is_copy is FALSE
AND is_playoffs is TRUE
GROUP BY n_e.game_result, play_under.class_underdog, play_total.total_playoff
ORDER BY class_underdog DESC, game_result DESC;

# [9] Home-court Advantage By Franchise
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