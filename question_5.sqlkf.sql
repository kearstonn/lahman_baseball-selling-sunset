--Q5:
WITH stats_per_decade AS (SELECT FLOOR(yearid / 10) * 10 AS decade,
       ROUND(AVG(SO::numeric / G::numeric), 2) AS avg_strikeouts_per_game,
       ROUND(AVG(HR::numeric / G::numeric), 2) AS avg_home_runs_per_game
FROM TEAMS
GROUP BY FLOOR(yearid / 10)
ORDER BY decade)
SELECT *
FROM stats_per_decade
WHERE decade >= 1920;

