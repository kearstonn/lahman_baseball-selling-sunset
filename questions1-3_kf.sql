--Q1:1871- 2016
SELECT MIN(yearid), MAX(yearid)
FROM teams;

--Q2:Eddie Gaedel, St. Louis Browns
SELECT MIN(height::numeric)/12 AS height, CONCAT(namefirst, namelast) AS player, g_all AS appearances, playerid,name
FROM people
INNER JOIN appearances
USING (playerid)
INNER JOIN teams
USING (teamid)
WHERE playerid = 'gaedeed01'
GROUP BY g_all,player, name, playerid
ORDER BY height;
SELECT *
FROM collegeplaying
WHERE schoolid LIKE 'vandy';
--Q3:David Price, $245,553,888
SELECT namefirst, namelast, schoolid,playerid, SUM(salary::numeric::money) AS total_salary, lgid
FROM collegeplaying
INNER JOIN people
USING (playerid)
INNER JOIN salaries
USING (playerid)
WHERE schoolid LIKE 'vandy'
GROUP BY namefirst, namelast, schoolid, playerid,lgid
ORDER BY SUM(salary) DESC;

--

