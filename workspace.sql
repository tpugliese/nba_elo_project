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

# Draft of Homecourt Advantage
SELECT year_id
, is_playoffs
, game_location
, game_result
, count(game_id)
FROM nba_elo 
WHERE is_copy is FALSE
AND game_location NOT IN ('H', 'A')
GROUP BY year_id, game_location, is_playoffs, game_result;

# Decade Concatenation
select CONCAT(LEFT(year_id, 3), "0's") as decade, count(game_id) from nba_elo group by decade;

# Draft of ELO Win Rate
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

# Query to get List of All Playoff Games & ELO
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