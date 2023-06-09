--Q11: Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question.
--As you do this analysis, keep in mind that salaries across the whole league tend to increase together, ]
--so you may want to look on a year-by-year basis.
SELECT *
FROM salaries;
SELECT *
FROM teams;
SELECT teams. yearid, w,salary
FROM teams
INNER JOIN salaries
USING (teamid)
WHERE teams.yearid >= 2000
ORDER BY teams.yearid;