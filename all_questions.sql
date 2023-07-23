-- 1. What range of years for baseball games played does the provided database cover? 
--1871-2016
SELECT DISTINCT yearid
FROM teams;

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? 
--What is the name of the team for which he played?
--Eddie Gaedel/ 43 in tall/1 game/St.Louis Browns
SELECT CONCAT(namefirst,' ',namelast) AS player, height::numeric, g_all AS appearance_count, name AS team
FROM people INNER JOIN appearances USING(playerid) 
			INNER JOIN teams USING(teamid) 
ORDER BY height NULLS LAST
LIMIT 1;

-- 3. Find all players in the database who played at Vanderbilt University.Create a list showing each players first and 
--last names as well as the total salary they earned in the major leagues. Sort this list in descending order by 
--the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT namefirst, namelast, SUM(salary::numeric::money) AS total_salary
FROM schools AS s INNER JOIN collegeplaying AS cp ON s.schoolid = cp.schoolid
					INNER JOIN people USING (playerid)
					INNER JOIN salaries USING (playerid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY namefirst, namelast
ORDER BY total_salary DESC;

--QUESTION 4
--Determine the number of putouts made by each of these three groups in 2016.
WITH putouts AS 
(SELECT playerid, yearid,
CASE WHEN pos = 'OF' THEN 'Outfield'
	 WHEN pos = 'SS' THEN 'INFIELD'
	 WHEN pos = '1b' THEN 'INFIELD'
	 WHEN pos = '2b' THEN 'INFIELD'
	 WHEN pos = '3b' THEN 'INFIELD'
	 WHEN pos = 'P'  THEN 'BATTERY'
	 WHEN pos = 'C'  THEN 'BATTERY'
	ELSE 'other'
	 END AS position_group
FROM fielding)

SELECT position_group, SUM(po::numeric) AS total_putouts
FROM putouts INNER JOIN fielding USING (playerid)
WHERE fielding.yearid = 2016 AND position_group NOT LIKE 'other'
GROUP BY position_group;

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places.
--    Do the same for home runs per game. Do you see any trends?
WITH stats_per_decade AS (SELECT FLOOR(yearid / 10) * 10 AS decade,
      							 ROUND(AVG(SO::numeric / G::numeric), 2) AS avg_so_per_game,
       							 ROUND(AVG(HR::numeric / G::numeric), 2) AS avg_hr_per_game
						  FROM TEAMS
						  GROUP BY FLOOR(yearid / 10)
						  ORDER BY decade)
SELECT *
FROM stats_per_decade
WHERE decade >= 1920;

--QUESTION 6 
--Find the player who had the most success stealing bases in 2016,
--success is measured as the percentage of stolen base attempts which are successful. 
--or being caught stealing.) 
--Consider only players who attempted at least 20 stolen bases.
WITH successful_sb AS
(SELECT playerid, yearid, SUM(sb::numeric), SUM(cs::numeric),
sb::numeric + cs::numeric AS sb_attempts
FROM batting
GROUP BY playerid, yearid, sb, cs)

SELECT namefirst,namelast,  batting.yearid, SUM(batting.sb), ROUND(batting.sb/sb_attempts *100) AS sb_pct
FROM successful_sb INNER JOIN batting USING(playerid)
					INNER JOIN people USING (playerid)
WHERE sb_attempts > 20 AND batting.yearid = '2016'
GROUP BY namefirst, namelast, batting.yearid, batting.sb, sb_attempts
ORDER BY sb_pct DESC
LIMIT 1;

-- 7.  From 1970 â€“ 2016, what is the largest number of wins for a team that did not win the world series?
-- What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an 
--unusually small number of wins for a world series champion â€“ determine why this is the case.Then redo your query, 
--excluding the problem year. How often from 1970 â€“ 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
(SELECT DISTINCT yearid, teamid, SUM(w) AS wins, wswin AS world_series_win
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'N'
GROUP BY teamid, yearid, wswin
ORDER BY wins DESC
LIMIT 1)
UNION
(SELECT DISTINCT yearid, teamid, SUM(w) AS wins, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
 	AND yearid <> 1981
GROUP BY teamid, yearid, wswin
ORDER BY wins
LIMIT 1);

--QUESTION 8 
--Using the attendance figures from the homegames table,
--find the teams and parks which had the top 5 average attendance per game in 2016
--(where average attendance is defined as total attendance divided by number of games). 
--Only consider parks where there were at least 10 games played.
--Report the park name, team name, and average attendance.
--Repeat for the lowest 5 average attendance.
--Top:Dodger, Cardinals, Blue Jays,Giants,Cubs
--Bottom: Rays,Athletics,Indians,Marlins,White Sox
SELECT franchname, park_name, AVG(hg.attendance)/games::numeric AS avg_attendance
FROM homegames AS hg INNER JOIN teams ON hg.team = teams.teamid
					INNER JOIN teamsfranchises USING (franchid)
					INNER JOIN parks ON parks.park = hg.park
WHERE year = '2016' AND games > 10 
GROUP BY franchname, park_name, games
ORDER BY avg_attendance 
LIMIT 5;

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--	  Give their full name and the teams that they were managing when they won the award.
WITH winning_managers AS (SELECT CONCAT(namefirst, ' ', namelast) AS manager, name AS team, lgid
   						  FROM awardsmanagers
   						  INNER JOIN people USING(playerid)
 					      INNER JOIN teams USING(yearid, lgid)
 					      WHERE awardid = 'TSN Manager of the Year')
SELECT manager, team
FROM winning_managers
WHERE lgid IN ('AL', 'NL')
GROUP BY manager, team
HAVING COUNT(DISTINCT lgid) = 2;

--QUESTION 10 
--Find all players who hit their career highest number of home runs in 2016. 
--Consider only players who have played in the league for at least 10 years, 
--and who hit at least one home run in 2016.
--Report the players' first and last names and the number of home runs they hit in 2016.
WITH careerhigh AS
(SELECT playerid, yearid, 
RANK()OVER(PARTITION BY playerid ORDER BY hr)
								   AS hr_rank
									FROM batting) 

SELECT CONCAT(namefirst,' ', namelast) AS player_name, batting.yearid, SUM(hr) AS total_hr
FROM careerhigh INNER JOIN people USING (playerid)
				INNER JOIN batting USING (playerid)
WHERE batting.yearid = '2016' AND hr >=1
GROUP BY CONCAT(namefirst,' ', namelast), batting.yearid
HAVING COUNT(playerid) >=10 
ORDER BY player_name; 

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. 
--	   As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.
WITH winvsalary AS (SELECT s.yearid, teamid, SUM(salary::numeric)::money AS team_salary, COUNT(w) AS wins, teams.lgid 
					FROM salaries AS s INNER JOIN teams USING(teamid)
					WHERE s.yearid = 2000 AND teams.lgid = 'AL'
					GROUP BY s.yearid, teamid, teams.lgid)
SELECT DISTINCT teamid, wins, team_salary
FROM winvsalary
ORDER BY wins DESC;

--QUESTION 12a explore the connection between number of wins and attendance.
--Does there appear to be any correlation between attendance at home games and number of wins?
--I don't see a correlation 
WITH wins AS
	(SELECT teamid, SUM(w) AS total_wins
	FROM teams
	GROUP BY teamid),

 big_attendance AS 
				(SELECT teamid, SUM(attendance) AS total_attendance
					FROM teams 
					GROUP BY teamid
					ORDER BY teamid)

SELECT teamid, total_wins, total_attendance
FROM teams INNER JOIN wins USING (teamid) INNER JOIN big_attendance USING (teamid)
GROUP BY teamid, total_wins, total_attendance
ORDER BY total_attendance DESC NULLS LAST;

-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim.
--     First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?
SELECT DISTINCT CONCAT(p.namefirst, ' ', p.namelast) AS pitcher, p.throws, 
       (SELECT SUM(pi.so) AS strikeouts FROM pitching AS pi WHERE pi.playerid = p.playerid) AS total_strikeouts
FROM people AS p
INNER JOIN pitching AS pit ON p.playerid = pit.playerid
WHERE p.throws = 'L'
ORDER BY (SELECT SUM(pi.so) AS strikeouts FROM pitching AS pi WHERE pi.playerid = p.playerid) DESC;
