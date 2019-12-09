# [1] Number of Playoff Games
SELECT count(game_id)
FROM nba_elo
WHERE is_copy is FALSE
AND is_playoffs is TRUE;

# [2] Elo Playoff Breakdown
SELECT game_id
, elo_enter
, elo_leave
, opp_elo_enter
, game_result
, CASE 
    WHEN elo_enter < opp_elo_enter THEN 'Underdog'
    WHEN elo_enter > opp_elo_enter THEN 'Favorite'
    ELSE 'Equal'
END as class_underdog
, (elo_enter - opp_elo_enter) as metric_underdog
, (elo_leave - elo_enter) as elo_gain   
FROM nba_elo
WHERE is_copy is FALSE
AND is_playoffs is TRUE;

# [3] Elo Underdog Classifier Totals
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
GROUP BY class_underdog;

# [4] Query to get List of All Playoff Games & ELO
SELECT 
play_under.class_underdog
, n_e.game_result
, count(play_under.game_id) as sub_total
, play_total.total_playoff as playoff_games
, (count(play_under.game_id) / play_total.total_playoff)*100 as win_ratio
, avg(play_under.metric_underdog) as elo_diff
, avg(play_under.elo_gain) as elo_gain
FROM nba_elo as n_e
INNER JOIN (
    SELECT game_id
    , elo_enter
    , elo_leave
    , opp_elo_enter
    , game_result
    , CASE 
        WHEN elo_enter < opp_elo_enter THEN 'Underdog'
        WHEN elo_enter > opp_elo_enter THEN 'Favorite'
        ELSE 'Equal'
    END as class_underdog
    , (elo_enter - opp_elo_enter) as metric_underdog
    , (elo_leave - elo_enter) as elo_gain   
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
ORDER BY play_under.class_underdog DESC, game_result DESC;