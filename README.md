# NBA Elo Analysis
## Based on 538 Dataset on Historical NBA Elo

Side project for presentation and pratical examples of SQL, presentation and business skills.

### Questions to Answer:
1. Does Home-court Advantage Exist?

2. In Playoffs, is there a Benefit to Being an Underdog?

3. What recommendations would you make as a Basketball coach?

## SQL Files

### **create_table.sql**
Details the queries I used to create a database, schema and table to represent the structure given in the fivethirtyeight.com explanation.  It also houses queries used import the Elo `.csv` into a local MySQL instance.

#### Caveats:
1. The Date field needed to be isolated and converted into proper `YYYY-MM-DD` format that MySQL expects for the Date type of the `date_game` column.  
2. The `notes` field had textual values with commas involved to denote games part of the [NBA Global Games](https://en.wikipedia.org/wiki/NBA_Global_Games) series where games were played in non-franchise areans.  Based on the `FIELDS TERMINATED BY` parameter on the `LOAD DATA`, it was more complicated to transform these fields into proper strings encased with either `"`s or `'`s to keep the functionality.

### **nba_elo_homecourt_adv.sql**
Queries used to determined the answer to the first question, of if Home-court Advtange exists.  We define this as the count of games won divided by the total games played in that period where the `game_location` of the contest was at Home, multipled to have a percentage value, dubbed the **Win Ratio**.  The first query [1] looks at this ratio at an overall level, while query [2] looks at this value on a yearly basis.

#### Caveats:
* Games that are part of the [NBA Global Games](https://en.wikipedia.org/wiki/NBA_Global_Games) series have a value for `game_location` of 'N' to denote that it is neither a home, nor an away game for any team, so these games are **not** counted in the Win Ratio.
* We suppress `is_copy` = `TRUE` games which isolates home games.
* We remove losses (`game_result` != `'L'`) when determining Wins but include them in the total games played.

### **nba_elo_underdog.sql**
Queries used to determine the answer to the second question, if there is a Benefit to being an Underdog in the playoffs.  We define this as the Win Ratio for games played where `is_playoffs` is TRUE **AND** games where the `elo_enter` < the `opp_elo_enter`.  These values represent the team's Elo difference in the contest.

The first query [1] obtains a count of all playoff games, while query [2] utilizes the Underdog classifier to attribute textual values to the Elo difference.  Query [3] obtains the sub-totals of these classified games so that in query [4] we can utilize the Win Ratio metric on a total scale to determine the win ratios of classified playoff games for analysis.

#### Underdog Classifier:
I used a `CASE` statement, so the textual values for the games could be utilized in SQL's `GROUP BY` functionality.
```sql
CASE 
    WHEN elo_enter < opp_elo_enter THEN 'Underdog'
    WHEN elo_enter > opp_elo_enter THEN 'Favorite'
    ELSE 'Equal'
END
```

#### Caveats:
* Unlike the Home-court queries, we don't supress the Global games because Playoff games all take place in Franchise areans.
* The `ELSE` condition yields the `'Equal'` value, but it was unlikely for two teams to have the _exact_ same Elo rating, so none existed to suppress.

## Reference Links
### 538 ELO Repo:

[Link to Data](https://github.com/fivethirtyeight/data/tree/master/nba-elo "538 Data")

### 538 Article on the Calculation:
[Link to Article](https://fivethirtyeight.com/features/how-we-calculate-nba-elo-ratings/ "538 Blog Post")

### Google Slides Presentation:
[Link to Slides](https://docs.google.com/presentation/d/1fUcpuJ714l--N4Dh-frQ8EnDUKVYHbZOmRYS2CENUCY/edit?usp=sharing "Google Slides")

### Google Sheet Analysis:
[Link to Sheet](https://docs.google.com/spreadsheets/d/1C51OMJWJtAfmNpjK_aOv4YGCB6ku42arU90qX76S0kQ/edit?usp=sharing "Google Sheet")

