--Q9:Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.
SELECT *
FROM awardsmanagers;
SELECT *
FROM teams;
SELECT *
FROM people;
 SELECT awardid,awardsmanagers.lgid, namelast, namefirst, name
 FROM awardsmanagers
 INNER JOIN people
 USING (playerid)
 INNER JOIN teams
 USING (yearid)
 WHERE awardid LIKE 'TSN Manager of the Year'
 AND awardsmanagers.lgid NOT LIKE 'ML';
 
 WITH managers_awards		AS (SELECT DISTINCT am1.yearid AS yearid1,
									am1.playerid AS playerid,
									am1.lgid AS lgid1,
									am2.lgid AS lgid2,
									am1.awardid AS awardid1
						 		FROM awardsmanagers as am1
						 	 	 INNER JOIN awardsmanagers AS am2
						 	 	 USING (playerid)
								 WHERE am1.awardid = 'TSN Manager of the Year'
								 	AND am2.awardid = am1.awardid
									AND am1.lgid <> 'ML'
									AND am2.lgid <> 'ML'
							   		AND am1.lgid <> am2.lgid),
managers_names			AS (SELECT ma.yearid1 AS yearid,
							       ma.playerid AS playerid,
								   ma.lgid1 AS lgid1,
								   ma.lgid2 AS lgid2,
								   ma.awardid1 AS awardid,
								   p.namefirst AS namefirst,
								   p.namelast AS namelast
							   FROM managers_awards as ma
							   LEFT JOIN people as p
							   ON ma.playerid=p.playerid),
managers_table			AS (SELECT DISTINCT mn.yearid AS yearid,
							       mn.playerid AS playerid,
								   mn.namefirst AS namefirst,
								   mn.namelast AS namelast,
								   m.teamid AS teamid
						   FROM managers_names AS mn
						   LEFT JOIN managers AS m
						   ON mn.playerid=m.playerid
						   AND mn.yearid=m.yearid
						   GROUP BY mn.yearid, mn.playerid,namefirst,namelast,teamid),					     	
managers_and_teams		AS(SELECT DISTINCT t.yearid AS yearid,
							       mn.playerid AS playerid,
								   mn.namefirst AS namefirst,
								   mn.namelast AS namelast,
						   		   t.name AS name
						  FROM managers_table AS mn
						  LEFT JOIN teams AS t
						  ON mn.yearid=t.yearid
						  AND mn.teamid=t.teamid)
							
SELECT *
FROM managers_and_teams;
 