# Create Table for NBA ELO
CREATE TABLE nba_elo (
    game_order INT UNSIGNED
    , game_id VARCHAR(20)
    , lg_id VARCHAR(5)
    , is_copy BOOLEAN
    , year_id YEAR(4)
    , date_game DATE
    , season_game INT UNSIGNED
    , is_playoffs BOOLEAN
    , team_id VARCHAR(5)
    , franchise_id VARCHAR(30)
    , points INT UNSIGNED
    , elo_enter DECIMAL(8,4)
    , elo_leave DECIMAL(8,4)
    , elo_win_equiv DECIMAL(8,6)
    , opp_team_id VARCHAR(5)
    , opp_franchise_id VARCHAR(30)
    , opp_points INT UNSIGNED
    , opp_elo_enter DECIMAL(8,4)
    , opp_elo_leave DECIMAL(8,4)
    , game_location CHAR(1)
    , game_result CHAR(1)
    , forecast DECIMAL(10,9)
    , notes VARCHAR(60)
);

 # Allow us to access local files   
SET GLOBAL local_infile= true; 

# Load Data from Local File.
LOAD DATA LOCAL INFILE '/Users/tylerpugliese/Desktop/nbaallelo.csv' 
IGNORE INTO TABLE poc_work.nba_elo 
FIELDS TERMINATED BY ',' 
# Ignore First Header Row
IGNORE 1 LINES
(
    game_order, game_id, lg_id, is_copy, year_id
    , @col6, season_game, is_playoffs, team_id, franchise_id
    , points, elo_enter, elo_leave, elo_win_equiv, opp_team_id
    , opp_franchise_id, opp_points, opp_elo_enter, opp_elo_leave, game_location
    , game_result, forecast, notes
)
# Format Date
SET date_game = STR_TO_DATE(@col6, '%m/%d/%Y');
